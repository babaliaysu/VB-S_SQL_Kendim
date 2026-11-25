-- =====================================================================
--  Kəndim — Milestone 3: verilənlər bazasının yoxlanılması
--  Fayl: validation.sql  (schema.sql və insert.sql-dən sonra)
--  İşə salma:  psql -U postgres -d kendim -f validation.sql
--  Qeyd: "C" bölməsindəki sorğuların XƏTA verməsi gözlənilir —
--        bu, constraint və trigger-lərin işlədiyini göstərir.
-- =====================================================================
SET search_path TO kendim, public;
\pset footer on

-- ============ A. CƏDVƏLLƏRİN SİYAHISI ============
\echo '=== A1. kendim sxemindəki cədvəllər ==='
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'kendim' AND table_type = 'BASE TABLE'
ORDER BY table_name;

\echo '=== A2. Hər cədvəldəki qeyd sayı ==='
SELECT 'users' AS cedvel, COUNT(*) FROM users
UNION ALL SELECT 'regions', COUNT(*) FROM regions
UNION ALL SELECT 'villages', COUNT(*) FROM villages
UNION ALL SELECT 'listings', COUNT(*) FROM listings
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'payouts', COUNT(*) FROM payouts
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'messages', COUNT(*) FROM messages
UNION ALL SELECT 'complaints', COUNT(*) FROM complaints;

\echo '=== A3. Constraint növləri üzrə say ==='
SELECT CASE contype WHEN 'p' THEN 'PRIMARY KEY' WHEN 'f' THEN 'FOREIGN KEY'
                    WHEN 'u' THEN 'UNIQUE' WHEN 'c' THEN 'CHECK' WHEN 'x' THEN 'EXCLUDE' END AS novu,
       COUNT(*) AS say
FROM pg_constraint
WHERE connamespace = 'kendim'::regnamespace
GROUP BY contype ORDER BY say DESC;

-- ============ B. MƏLUMATLARIN GÖSTƏRİLMƏSİ ============
\echo '=== B1. İstifadəçilər ==='
SELECT id, first_name, last_name, email, role, status FROM users ORDER BY id;

\echo '=== B2. Elanlar ==='
SELECT id, title, price_per_night, max_guests, status FROM listings ORDER BY id;

-- ============ C. ƏLAQƏLƏRİN YOXLANILMASI (JOIN) ============
\echo '=== C1. Elan → kənd → rayon → ev sahibi (4 cədvəl JOIN) ==='
SELECT l.title, v.name AS kend, r.name AS rayon, u.first_name || ' ' || u.last_name AS ev_sahibi
FROM listings l
JOIN villages v ON v.id = l.village_id
JOIN regions  r ON r.id = v.region_id
JOIN users    u ON u.id = l.owner_id
ORDER BY l.id;

\echo '=== C2. Rezervasiya → ödəniş → köçürmə zənciri (1:1 əlaqələr) ==='
SELECT b.id AS booking, b.status AS booking_status, p.amount, p.commission_amount,
       p.status AS payment_status, po.amount AS payout, po.status AS payout_status
FROM bookings b
LEFT JOIN payments p  ON p.booking_id = b.id
LEFT JOIN payouts  po ON po.payment_id = p.id
ORDER BY b.id;

\echo '=== C3. M:N — hər elanın şəraitləri ==='
SELECT l.title, string_agg(a.name, ', ' ORDER BY a.name) AS seraitler
FROM listings l
JOIN listing_amenities la ON la.listing_id = l.id
JOIN amenities a          ON a.id = la.amenity_id
GROUP BY l.id, l.title ORDER BY l.id;

\echo '=== C4. View: elanların orta reytinqi ==='
SELECT listing_id, title, village, avg_rating, review_count, status
FROM v_listing_summary ORDER BY listing_id;

\echo '=== C5. View: rezervasiyanın gecə sayı və ümumi məbləği ==='
SELECT * FROM v_booking_details WHERE booking_id <= 5 ORDER BY booking_id;

\echo '=== C6. Trigger nəticəsi: 3 şikayətdən sonra 12 nömrəli elan gizlədilib (BR-26) ==='
SELECT l.id, l.title, l.status, a.action, a.details
FROM listings l JOIN audit_logs a ON a.entity_type = 'listing' AND a.entity_id = l.id
WHERE l.id = 12;

-- ============ D. CONSTRAINT-LƏRİN YOXLANILMASI (XƏTA GÖZLƏNİLİR) ============
\echo '=== D1. UNIQUE: təkrar email ==='
INSERT INTO users (first_name, last_name, email, phone, password_hash, consent_accepted_at)
VALUES ('Test', 'User', 'nermin@mail.az', '+994500000099', 'x', now());

\echo '=== D2. NOT NULL: soyad boş ==='
INSERT INTO users (first_name, last_name, email, phone, password_hash, consent_accepted_at)
VALUES ('Test', NULL, 'test@mail.az', '+994500000098', 'x', now());

\echo '=== D3. CHECK: mənfi qiymət ==='
INSERT INTO listings (owner_id, village_id, title, price_per_night, max_guests, rooms, address, latitude, longitude)
VALUES (2, 1, 'Test', -10, 2, 1, 'Test', 41.1, 48.1);

\echo '=== D4. CHECK: reytinq 1–5 aralığında olmalıdır ==='
UPDATE reviews SET rating = 7 WHERE id = 1;

\echo '=== D5. FOREIGN KEY: mövcud olmayan kənd ==='
INSERT INTO listings (owner_id, village_id, title, price_per_night, max_guests, rooms, address, latitude, longitude)
VALUES (2, 999, 'Test', 50, 2, 1, 'Test', 41.1, 48.1);

\echo '=== D6. FOREIGN KEY RESTRICT: rezervasiyası olan elanı fiziki silmək ==='
DELETE FROM listings WHERE id = 1;

\echo '=== D7. CHECK: çıxış tarixi girişdən əvvəl ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night)
VALUES (3, 9, '2027-03-10', '2027-03-05', 2, 60);

\echo '=== D8. EXCLUDE: aktiv rezervasiyalarla tarix toqquşması (BR-13) ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night, status)
VALUES (1, 10, '2026-09-07', '2026-09-10', 2, 80, 'confirmed');

\echo '=== D9. CHECK num_nonnulls: şikayətin iki hədəfi (BR-25) ==='
INSERT INTO complaints (complainant_id, listing_id, review_id, reason)
VALUES (7, 1, 1, 'test');

\echo '=== D10. Partial UNIQUE index: ikinci aktiv ödəniş hesabı (BR-29) ==='
INSERT INTO payout_accounts (user_id, account_holder, account_number)
VALUES (2, 'Rauf Həsənov', 'AZ55NABZ00000000999999999999');

\echo '=== D11. DEFAULT: yeni elanın statusu avtomatik active, view_count 0 ==='
BEGIN;
INSERT INTO listings (owner_id, village_id, title, price_per_night, max_guests, rooms, address, latitude, longitude)
VALUES (4, 4, 'Default testi', 40, 2, 1, 'Kiş kəndi', 41.24, 47.18)
RETURNING id, status, view_count, utilities_included, created_at IS NOT NULL AS created_at_doldu;
ROLLBACK;

-- ============ E. TRIGGER-LƏRİN YOXLANILMASI (XƏTA GÖZLƏNİLİR) ============
\echo '=== E1. Trigger BR-12: istifadəçi öz elanını rezerv edə bilməz ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night)
VALUES (1, 2, '2027-04-01', '2027-04-03', 2, 80);

\echo '=== E2. Trigger BR-11: qonaq sayı tutumu keçir ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night)
VALUES (10, 7, '2027-04-01', '2027-04-03', 5, 65);

\echo '=== E3. Trigger BR-04: bloklanmış istifadəçi rezervasiya edə bilməz ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night)
VALUES (3, 13, '2027-04-01', '2027-04-03', 2, 60);

\echo '=== E4. Trigger BR-10: bağlı tarixlərə rezervasiya ==='
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night)
VALUES (1, 7, '2027-01-06', '2027-01-08', 2, 80);

\echo '=== E5. Trigger BR-21: tamamlanmamış rezervasiyaya rəy ==='
INSERT INTO reviews (booking_id, rating, comment) VALUES (11, 5, 'test');

\echo '=== E6. Trigger BR-23: söhbətin iştirakçısı olmayan mesaj yazır ==='
INSERT INTO messages (conversation_id, sender_id, body) VALUES (1, 9, 'Salam');

\echo '=== E7. Trigger BR-09: aktiv rezervasiyası olan elanı silmək (soft delete) ==='
UPDATE listings SET status = 'deleted' WHERE id = 5;
