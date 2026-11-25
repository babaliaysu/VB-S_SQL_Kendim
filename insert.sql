-- =====================================================================
--  Kəndim — Milestone 3: test məlumatları
--  Fayl: insert.sql  (schema.sql-dən sonra işə salınır)
--  İşə salma:  psql -U postgres -d kendim -f insert.sql
--  Qeyd: id-lər BIGSERIAL ilə avtomatik yaranır; aşağıdakı şərhlərdə
--        hər sətrin alacağı id göstərilib (boş bazada 1-dən başlayır).
--  Bütün adlar, telefonlar və hesab nömrələri şərtidir (uydurmadır).
-- =====================================================================
SET search_path TO kendim, public;

BEGIN;

-- ---------------------------------------------------------------------
-- users (13): 1 admin, 5 ev sahibi (2–6), 6 səyahətçi (7–12), 1 bloklanmış (13)
-- Qeyd: 3 nömrəli istifadəçi həm ev sahibi, həm səyahətçidir (BR-02)
-- ---------------------------------------------------------------------
INSERT INTO users (first_name, last_name, email, phone, password_hash, role, status,
                   email_verified_at, phone_verified_at, consent_accepted_at, created_at) VALUES
('Elvin',  'Quliyev',    'admin@kendim.az',      '+994501000001', '$2b$12$adminHashXyZ001', 'admin', 'active', '2026-01-05 10:00+04', '2026-01-05 10:05+04', '2026-01-05 09:55+04', '2026-01-05 09:55+04'),
('Rauf',   'Həsənov',    'rauf.hasanov@mail.az',  '+994501112233', '$2b$12$hostHashAbC002',  'user',  'active', '2026-02-10 12:00+04', '2026-02-10 12:10+04', '2026-02-10 11:50+04', '2026-02-10 11:50+04'),
('Səbinə', 'Quliyeva',   'sabina.q@mail.az',      '+994554445566', '$2b$12$hostHashAbC003',  'user',  'active', '2026-02-15 09:30+04', NULL,                  '2026-02-15 09:20+04', '2026-02-15 09:20+04'),
('Kamran', 'Əliyev',     'kamran.aliyev@mail.az', '+994702223344', '$2b$12$hostHashAbC004',  'user',  'active', NULL,                  '2026-03-01 14:00+04', '2026-03-01 13:50+04', '2026-03-01 13:50+04'),
('Lalə',   'Məmmədova',  'lala.m@mail.az',        '+994553334455', '$2b$12$hostHashAbC005',  'user',  'active', '2026-03-12 16:00+04', '2026-03-12 16:05+04', '2026-03-12 15:55+04', '2026-03-12 15:55+04'),
('Tural',  'Nəsirov',    'tural.n@mail.az',       '+994515556677', '$2b$12$hostHashAbC006',  'user',  'active', '2026-04-02 11:00+04', NULL,                  '2026-04-02 10:50+04', '2026-04-02 10:50+04'),
('Nərmin', 'Əliyeva',    'nermin@mail.az',        '+994506667788', '$2b$12$guestHashQw007',  'user',  'active', '2026-05-01 08:00+04', '2026-05-01 08:02+04', '2026-05-01 07:58+04', '2026-05-01 07:58+04'),
('Orxan',  'Məmmədov',   'orxan@mail.az',         '+994557778899', '$2b$12$guestHashQw008',  'user',  'active', '2026-05-03 19:00+04', NULL,                  '2026-05-03 18:55+04', '2026-05-03 18:55+04'),
('Aysel',  'Rzayeva',    'aysel.r@mail.az',       '+994708889900', '$2b$12$guestHashQw009',  'user',  'active', '2026-05-20 21:00+04', '2026-05-20 21:01+04', '2026-05-20 20:58+04', '2026-05-20 20:58+04'),
('Fərid',  'Babayev',    'farid.b@mail.az',       '+994509990011', '$2b$12$guestHashQw010',  'user',  'active', NULL,                  '2026-06-11 13:00+04', '2026-06-11 12:55+04', '2026-06-11 12:55+04'),
('Günay',  'İsmayılova', 'gunay.i@mail.az',       '+994551231234', '$2b$12$guestHashQw011',  'user',  'active', '2026-06-25 10:00+04', '2026-06-25 10:03+04', '2026-06-25 09:57+04', '2026-06-25 09:57+04'),
('Murad',  'Hüseynov',   'murad.h@mail.az',       '+994704564567', '$2b$12$guestHashQw012',  'user',  'active', '2026-07-08 17:00+04', NULL,                  '2026-07-08 16:58+04', '2026-07-08 16:58+04'),
('Vüqar',  'Cəfərov',    'vugar.c@mail.az',       '+994517897890', '$2b$12$guestHashQw013',  'user',  'blocked', NULL,                 NULL,                  '2026-08-01 12:00+04', '2026-08-01 12:00+04');

-- ---------------------------------------------------------------------
-- regions (10)
-- ---------------------------------------------------------------------
INSERT INTO regions (name) VALUES
('Quba'), ('İsmayıllı'), ('Şəki'), ('Qəbələ'), ('Lənkəran'),
('Qax'), ('Zaqatala'), ('Masallı'), ('Lerik'), ('Şuşa');

-- ---------------------------------------------------------------------
-- villages (11) — region_id → regions
-- ---------------------------------------------------------------------
INSERT INTO villages (region_id, name, description, how_to_get) VALUES
(1,  'Xınalıq',    'Dəniz səviyyəsindən 2300 m hündürlükdə qədim dağ kəndi.',          'Quba şəhərindən 60 km, avtomobillə təxminən 1,5 saat.'),
(1,  'Qrız',       'Şahdağ ətəyində daş evləri ilə tanınan kənd.',                       'Qubadan Xınalıq yolu ilə, sonra 12 km kənd yolu.'),
(2,  'Lahıc',      'Misgərlik sənəti və daş döşənmiş küçələri ilə məşhur kənd.',        'İsmayıllıdan 20 km, Girdiman çayı boyunca.'),
(3,  'Kiş',        'Qədim Alban məbədi olan meşəlik kənd.',                              'Şəki şəhər mərkəzindən 5 km şimalda.'),
(4,  'Laza',       'Şəlalələri və Şahdağ mənzərəsi ilə tanınan dağ kəndi.',              'Qəbələ şəhərindən 30 km, Tufandağ istiqaməti.'),
(5,  'Haftoni',    'Çay plantasiyaları və subtropik iqlimi olan kənd.',                  'Lənkəran şəhərindən 15 km cənub-qərbdə.'),
(6,  'İlisu',      'Qala qalıqları və Ulu körpü ilə tanınan dağ kəndi.',                 'Qax şəhərindən 18 km.'),
(7,  'Car',        'Qoz bağları və Car çayı sahilində yerləşən kənd.',                   'Zaqatala şəhərindən 6 km.'),
(8,  'İstisu',     'Termal mineral bulaqları ilə tanınan kənd.',                         'Masallı şəhərindən 10 km qərbdə.'),
(9,  'Cəngəmiran', 'Uzunömürlülər kəndi kimi tanınan dağ kəndi.',                         'Lerik şəhərindən 12 km.'),
(10, 'Daşaltı',    'Daşaltı çayı dərəsində, qayalıqlar arasında yerləşən kənd.',         'Şuşa şəhərindən 8 km cənubda.');

-- ---------------------------------------------------------------------
-- village_highlights (14) — gəzməli yerlər (attraction) və yeməklər (food)
-- ---------------------------------------------------------------------
INSERT INTO village_highlights (village_id, type, name, description) VALUES
(1,  'attraction', 'Xınalıq etnoqrafiya muzeyi', 'Kəndin məişət əşyaları və tarixi.'),
(1,  'food',       'Xınalıq pendiri',            'Qoyun südündən hazırlanan yerli pendir.'),
(2,  'attraction', 'Şahdağ mənzərə nöqtəsi',     'Kənddən 2 km yuxarıda.'),
(3,  'attraction', 'Misgərlər küçəsi',           'Əl ilə hazırlanan mis qablar.'),
(3,  'food',       'Lahıc kətəsi',               'Göyərti ilə bişirilən yerli kətə.'),
(4,  'attraction', 'Kiş Alban məbədi',           'I əsrə aid edilən məbəd.'),
(4,  'food',       'Şəki pitisi',                'Saxsı qabda bişirilən ənənəvi xörək.'),
(5,  'attraction', 'Laza şəlaləsi',              'Qışda donan şəlalə.'),
(6,  'food',       'Lənkəran ləvəngisi',         'Qoz və alça ilə doldurulmuş toyuq.'),
(7,  'attraction', 'Ulu körpü',                  'Daşdan tikilmiş qədim körpü.'),
(8,  'attraction', 'Car qoz bağı',               'Yüzillik qoz ağacları.'),
(9,  'attraction', 'İstisu bulaqları',           'İsti mineral su mənbələri.'),
(10, 'food',       'Lerik bal',                  'Dağ çiçəklərindən yığılan bal.'),
(11, 'attraction', 'Daşaltı dərəsi',             'Piyada marşrutu olan dərə.');

-- ---------------------------------------------------------------------
-- village_photos (11)
-- ---------------------------------------------------------------------
INSERT INTO village_photos (village_id, url, sort_order) VALUES
(1,  'https://cdn.kendim.az/villages/xinaliq-1.jpg',    1),
(1,  'https://cdn.kendim.az/villages/xinaliq-2.jpg',    2),
(2,  'https://cdn.kendim.az/villages/qriz-1.jpg',       1),
(3,  'https://cdn.kendim.az/villages/lahic-1.jpg',      1),
(4,  'https://cdn.kendim.az/villages/kish-1.jpg',       1),
(5,  'https://cdn.kendim.az/villages/laza-1.jpg',       1),
(6,  'https://cdn.kendim.az/villages/haftoni-1.jpg',    1),
(7,  'https://cdn.kendim.az/villages/ilisu-1.jpg',      1),
(8,  'https://cdn.kendim.az/villages/car-1.jpg',        1),
(9,  'https://cdn.kendim.az/villages/istisu-1.jpg',     1),
(10, 'https://cdn.kendim.az/villages/cengemiran-1.jpg', 1);

-- ---------------------------------------------------------------------
-- amenities (10)
-- ---------------------------------------------------------------------
INSERT INTO amenities (name) VALUES
('Wi-Fi'), ('Mətbəx'), ('Manqal'), ('Parkinq'), ('Kamin'),
('İsti su'), ('Paltaryuyan'), ('Hovuz'), ('Uşaq meydançası'), ('Kondisioner');

-- ---------------------------------------------------------------------
-- commission_settings (3) — faiz tarixçəsi; sətirlər dəyişdirilmir (BR-17)
-- id=2 (10%) hazırda qüvvədədir
-- ---------------------------------------------------------------------
INSERT INTO commission_settings (rate_percent, effective_from, created_by, created_at) VALUES
(12.00, '2026-01-01 00:00+04', 1, '2026-01-05 10:30+04'),
(10.00, '2026-06-01 00:00+04', 1, '2026-05-25 11:00+04'),
( 8.00, '2027-01-01 00:00+04', 1, '2026-11-10 09:00+04');

-- ---------------------------------------------------------------------
-- payout_accounts (6) — hər ev sahibinin 1 aktiv hesabı; id=6 köhnə, deaktiv
-- ---------------------------------------------------------------------
INSERT INTO payout_accounts (user_id, account_holder, account_number, is_active, created_at) VALUES
(2, 'Rauf Həsənov',    'AZ21NABZ00000000137010001944', true,  '2026-06-01 10:00+04'),
(3, 'Səbinə Quliyeva', 'AZ35IBAZ38010019441234567890', true,  '2026-02-16 10:00+04'),
(4, 'Kamran Əliyev',   'AZ77PAHA40060019440000123456', true,  '2026-03-02 10:00+04'),
(5, 'Lalə Məmmədova',  'AZ12KAPT38070019440000654321', true,  '2026-03-13 10:00+04'),
(6, 'Tural Nəsirov',   'AZ90AIIB33080019441111222233', true,  '2026-04-03 10:00+04'),
(2, 'Rauf Həsənov',    'AZ44UBAZ00000000123456789012', false, '2026-02-11 10:00+04');

-- ---------------------------------------------------------------------
-- verification_tokens (10) — yalnız hash saxlanılır (BR-30)
-- ---------------------------------------------------------------------
INSERT INTO verification_tokens (user_id, purpose, token_hash, expires_at, used_at, created_at) VALUES
(2,  'email_verify',   'sha256:a1f3c9e0b2d4', '2026-02-10 12:15+04', '2026-02-10 12:00+04', '2026-02-10 11:55+04'),
(3,  'email_verify',   'sha256:b2e4d0f1c3a5', '2026-02-15 09:35+04', '2026-02-15 09:30+04', '2026-02-15 09:21+04'),
(4,  'phone_verify',   'sha256:c3f5e1a2d4b6', '2026-03-01 14:05+04', '2026-03-01 14:00+04', '2026-03-01 13:51+04'),
(5,  'email_verify',   'sha256:d4a6f2b3e5c7', '2026-03-12 16:10+04', '2026-03-12 16:00+04', '2026-03-12 15:56+04'),
(6,  'email_verify',   'sha256:e5b7a3c4f6d8', '2026-04-02 11:05+04', '2026-04-02 11:00+04', '2026-04-02 10:51+04'),
(7,  'phone_verify',   'sha256:f6c8b4d5a7e9', '2026-05-01 08:10+04', '2026-05-01 08:02+04', '2026-05-01 07:59+04'),
(8,  'email_verify',   'sha256:a7d9c5e6b8f0', '2026-05-03 19:10+04', '2026-05-03 19:00+04', '2026-05-03 18:56+04'),
(10, 'phone_verify',   'sha256:b8e0d6f7c9a1', '2026-06-11 13:10+04', '2026-06-11 13:00+04', '2026-06-11 12:56+04'),
(7,  'password_reset', 'sha256:c9f1e7a8d0b2', '2026-10-02 20:30+04', NULL,                  '2026-10-02 20:00+04'),
(13, 'email_verify',   'sha256:d0a2f8b9e1c3', '2026-08-01 12:15+04', NULL,                  '2026-08-01 12:01+04');

-- ---------------------------------------------------------------------
-- listings (12) — owner_id → users, village_id → villages
-- ---------------------------------------------------------------------
INSERT INTO listings (owner_id, village_id, title, description, price_per_night, max_guests, rooms,
                      utilities_included, guide_service, address, latitude, longitude, view_count, created_at) VALUES
(2, 1,  'Xınalıqda dağ evi',       'Şahdağ mənzərəli iki mərtəbəli ev.',      80.00, 6, 3, true,  true,  'Xınalıq kəndi, Mərkəzi küçə 4',  41.180200, 48.125600, 340, '2026-06-02 10:00+04'),
(2, 2,  'Qrızda daş ev',           'Ənənəvi daş ev, kamin ilə.',              60.00, 4, 2, true,  false, 'Qrız kəndi, Dağ küçəsi 2',       41.208300, 48.199100, 125, '2026-06-05 10:00+04'),
(3, 3,  'Lahıcda bağ evi',         'Meyvə bağı içində rahat ev.',             60.00, 5, 2, true,  true,  'Lahıc kəndi, Hüseynov küçəsi 12', 40.849900, 48.383200, 410, '2026-03-01 10:00+04'),
(3, 3,  'Misgər evi',              'Usta misgər ailəsinin qonaq evi.',        70.00, 4, 2, false, true,  'Lahıc kəndi, Misgərlər küçəsi 7', 40.851100, 48.385000, 198, '2026-03-10 10:00+04'),
(4, 4,  'Kişdə meşə evi',          'Meşənin içində taxta ev.',                90.00, 6, 3, true,  false, 'Kiş kəndi, Məbəd yolu 3',        41.243900, 47.188900, 520, '2026-03-05 10:00+04'),
(4, 5,  'Laza şəlalə evi',         'Şəlaləyə 500 m məsafədə böyük ev.',      100.00, 8, 4, true,  true,  'Laza kəndi, Şəlalə yolu 1',      41.105000, 47.928000, 610, '2026-03-15 10:00+04'),
(5, 6,  'Çay bağı evi',            'Çay plantasiyasının yanında ev.',          50.00, 4, 2, true,  false, 'Haftoni kəndi, Çayçılar küçəsi 9', 38.682000, 48.791000, 150, '2026-03-20 10:00+04'),
(5, 7,  'İlisuda taxta ev',        'Çay kənarında taxta ev.',                  75.00, 5, 2, false, true,  'İlisu kəndi, Körpü küçəsi 5',    41.451900, 46.962400, 275, '2026-04-01 10:00+04'),
(6, 8,  'Car qoz bağı evi',        'Qoz bağının ortasında kənd evi.',          55.00, 4, 2, true,  false, 'Car kəndi, Bağlar küçəsi 14',    41.650000, 46.640000,  95, '2026-04-05 10:00+04'),
(6, 9,  'İstisu termal ev',        'Termal bulağa 300 m.',                     65.00, 3, 1, true,  false, 'İstisu kəndi, Bulaq küçəsi 2',   39.034000, 48.580000,  60, '2026-04-10 10:00+04'),
(2, 10, 'Lerikdə dağ evi',         'Sakit dağ evi, bal dequstasiyası ilə.',    45.00, 4, 2, true,  true,  'Cəngəmiran kəndi, 1-ci döngə 3', 38.770000, 48.420000,  88, '2026-06-10 10:00+04'),
(3, 11, 'Daşaltı qaya evi',        'Qayalıqlar arasında daş ev.',              85.00, 6, 3, true,  true,  'Daşaltı kəndi, Dərə küçəsi 1',   39.740000, 46.760000, 230, '2026-07-01 10:00+04');

-- ---------------------------------------------------------------------
-- listing_photos (17) — hər elanın ən azı 1 şəkli var (BR-07)
-- ---------------------------------------------------------------------
INSERT INTO listing_photos (listing_id, url, sort_order) VALUES
(1,  'https://cdn.kendim.az/listings/1/1.jpg', 1),
(1,  'https://cdn.kendim.az/listings/1/2.jpg', 2),
(1,  'https://cdn.kendim.az/listings/1/3.jpg', 3),
(2,  'https://cdn.kendim.az/listings/2/1.jpg', 1),
(3,  'https://cdn.kendim.az/listings/3/1.jpg', 1),
(3,  'https://cdn.kendim.az/listings/3/2.jpg', 2),
(4,  'https://cdn.kendim.az/listings/4/1.jpg', 1),
(5,  'https://cdn.kendim.az/listings/5/1.jpg', 1),
(5,  'https://cdn.kendim.az/listings/5/2.jpg', 2),
(6,  'https://cdn.kendim.az/listings/6/1.jpg', 1),
(6,  'https://cdn.kendim.az/listings/6/2.jpg', 2),
(7,  'https://cdn.kendim.az/listings/7/1.jpg', 1),
(8,  'https://cdn.kendim.az/listings/8/1.jpg', 1),
(9,  'https://cdn.kendim.az/listings/9/1.jpg', 1),
(10, 'https://cdn.kendim.az/listings/10/1.jpg', 1),
(11, 'https://cdn.kendim.az/listings/11/1.jpg', 1),
(12, 'https://cdn.kendim.az/listings/12/1.jpg', 1);

-- ---------------------------------------------------------------------
-- listing_nearby_places (10)
-- ---------------------------------------------------------------------
INSERT INTO listing_nearby_places (listing_id, place_type, name, distance_km) VALUES
(1,  'mountain', 'Şahdağ',            8.50),
(1,  'river',    'Qudyalçay',         1.20),
(3,  'river',    'Girdiman çayı',     0.30),
(5,  'forest',   'Kiş meşəsi',        0.10),
(6,  'waterfall','Laza şəlaləsi',     0.50),
(7,  'forest',   'Hirkan meşəsi',     4.00),
(8,  'river',    'Kürmükçay',         0.20),
(9,  'river',    'Car çayı',          0.80),
(10, 'spring',   'İstisu bulağı',     0.30),
(12, 'river',    'Daşaltı çayı',      0.40);

-- ---------------------------------------------------------------------
-- listing_amenities (26) — M:N əlaqə cədvəli
-- ---------------------------------------------------------------------
INSERT INTO listing_amenities (listing_id, amenity_id) VALUES
(1,1),(1,2),(1,3),(1,5),
(2,2),(2,5),
(3,1),(3,2),(3,3),(3,4),
(4,1),(4,6),
(5,1),(5,2),(5,4),(5,9),
(6,1),(6,2),(6,3),(6,4),(6,8),
(7,1),(7,10),
(8,3),(9,4),(10,6);

-- ---------------------------------------------------------------------
-- availability_blocks (10) — ev sahibinin bağladığı tarixlər (BR-10)
-- ---------------------------------------------------------------------
INSERT INTO availability_blocks (listing_id, start_date, end_date, reason) VALUES
(1,  '2027-01-05', '2027-01-12', 'Ailə üçün ayrılıb'),
(2,  '2027-01-10', '2027-01-15', 'Təmir'),
(3,  '2027-02-01', '2027-02-07', 'Şəxsi istifadə'),
(4,  '2027-01-20', '2027-01-25', 'Təmir'),
(5,  '2026-12-30', '2027-01-03', 'Yeni il — ailə'),
(6,  '2027-03-01', '2027-03-10', 'Dam təmiri'),
(7,  '2027-01-01', '2027-01-04', 'Bayram'),
(8,  '2026-12-01', '2026-12-05', 'Su sistemi təmiri'),
(9,  '2027-02-14', '2027-02-16', 'Şəxsi istifadə'),
(10, '2027-01-15', '2027-01-20', 'Bulaq bağlıdır');

-- ---------------------------------------------------------------------
-- bookings (21) — 10 statusun hamısı nümayiş olunur
-- response_deadline = created_at + 24 saat; payment_deadline = təsdiqdən 48 saat
-- id: sətir ardıcıllığı ilə 1–21
-- ---------------------------------------------------------------------
INSERT INTO bookings (listing_id, guest_id, check_in, check_out, guests_count, price_per_night, status,
                      response_deadline, payment_deadline, cancelled_by, cancel_reason, created_at)
SELECT listing_id, guest_id, check_in::date, check_out::date, guests_count, price, status,
       created::timestamptz + INTERVAL '24 hours',
       CASE WHEN status IN ('pending', 'rejected') THEN NULL
            ELSE created::timestamptz + INTERVAL '48 hours' END,
       cancelled_by, cancel_reason, created::timestamptz
FROM (VALUES
 ( 1,  7, '2026-09-05', '2026-09-09', 4,  80.00, 'paid_out',    NULL,    NULL,                              '2026-08-20 10:00+04'),  -- 1
 ( 1,  8, '2026-09-12', '2026-09-14', 2,  80.00, 'paid_out',    NULL,    NULL,                              '2026-08-28 12:00+04'),  -- 2
 ( 3,  7, '2026-09-20', '2026-09-22', 3,  60.00, 'completed',   NULL,    NULL,                              '2026-09-01 09:00+04'),  -- 3
 ( 5,  9, '2026-10-01', '2026-10-04', 5,  90.00, 'paid_out',    NULL,    NULL,                              '2026-09-15 18:00+04'),  -- 4
 ( 6, 10, '2026-10-10', '2026-10-12', 6, 100.00, 'completed',   NULL,    NULL,                              '2026-09-25 14:00+04'),  -- 5
 ( 7, 11, '2026-10-15', '2026-10-18', 2,  50.00, 'paid_out',    NULL,    NULL,                              '2026-10-01 11:00+04'),  -- 6
 ( 8, 12, '2026-10-20', '2026-10-23', 4,  75.00, 'disputed',    NULL,    NULL,                              '2026-10-05 16:00+04'),  -- 7
 ( 9,  3, '2026-10-25', '2026-10-27', 2,  55.00, 'paid_out',    NULL,    NULL,                              '2026-10-10 20:00+04'),  -- 8  (ev sahibi Səbinə səyahətçi kimi)
 ( 2,  9, '2026-11-15', '2026-11-20', 3,  60.00, 'in_progress', NULL,    NULL,                              '2026-11-01 10:00+04'),  -- 9
 ( 4, 10, '2026-12-05', '2026-12-08', 2,  70.00, 'paid',        NULL,    NULL,                              '2026-11-10 13:00+04'),  -- 10
 ( 5, 11, '2026-12-10', '2026-12-12', 4,  90.00, 'confirmed',   NULL,    NULL,                              '2026-11-16 09:00+04'),  -- 11
 (10, 12, '2026-12-15', '2026-12-17', 2,  65.00, 'pending',     NULL,    NULL,                              '2026-11-17 22:00+04'),  -- 12
 ( 1,  9, '2026-12-20', '2026-12-23', 3,  80.00, 'rejected',    NULL,    NULL,                              '2026-11-05 15:00+04'),  -- 13
 ( 6,  7, '2026-11-28', '2026-11-30', 4, 100.00, 'refunded',    'host',  'Ev sahibi tarixləri ləğv etdi',   '2026-11-02 12:00+04'),  -- 14
 ( 3,  8, '2026-12-24', '2026-12-27', 2,  60.00, 'pending',     NULL,    NULL,                              '2026-11-17 19:00+04'),  -- 15
 ( 7,  8, '2026-08-01', '2026-08-03', 2,  50.00, 'paid_out',    NULL,    NULL,                              '2026-07-20 10:00+04'),  -- 16
 ( 8,  9, '2026-08-10', '2026-08-13', 3,  75.00, 'paid_out',    NULL,    NULL,                              '2026-07-28 10:00+04'),  -- 17
 (11, 10, '2026-08-20', '2026-08-22', 2,  45.00, 'paid_out',    NULL,    NULL,                              '2026-08-05 10:00+04'),  -- 18
 (12, 11, '2026-08-25', '2026-08-28', 4,  85.00, 'paid_out',    NULL,    NULL,                              '2026-08-10 10:00+04'),  -- 19
 ( 4, 12, '2026-09-01', '2026-09-03', 2,  70.00, 'paid_out',    NULL,    NULL,                              '2026-08-15 10:00+04'),  -- 20
 ( 2,  7, '2026-12-01', '2026-12-04', 2,  60.00, 'cancelled',   'guest', 'Planlar dəyişdi',                 '2026-11-12 10:00+04')   -- 21
) AS v(listing_id, guest_id, check_in, check_out, guests_count, price, status, cancelled_by, cancel_reason, created);

-- ---------------------------------------------------------------------
-- payments (16) — amount = gecə sayı × price_per_night; komissiya 10% (setting id=2)
-- id: 1–16 (şərhdə booking id-si)
-- ---------------------------------------------------------------------
INSERT INTO payments (booking_id, commission_setting_id, amount, commission_amount, refund_amount, status, paid_at) VALUES
( 1, 2, 320.00, 32.00,   0.00, 'released', '2026-08-21 10:00+04'),  -- 1
( 2, 2, 160.00, 16.00,   0.00, 'released', '2026-08-29 12:00+04'),  -- 2
( 3, 2, 120.00, 12.00,   0.00, 'held',     '2026-09-02 09:00+04'),  -- 3
( 4, 2, 270.00, 27.00,   0.00, 'released', '2026-09-16 18:00+04'),  -- 4
( 5, 2, 200.00, 20.00,   0.00, 'held',     '2026-09-26 14:00+04'),  -- 5
( 6, 2, 150.00, 15.00,   0.00, 'released', '2026-10-02 11:00+04'),  -- 6
( 7, 2, 225.00, 22.50,   0.00, 'held',     '2026-10-06 16:00+04'),  -- 7  mübahisə: pul saxlanılır (BR-20)
( 8, 2, 110.00, 11.00,   0.00, 'released', '2026-10-11 20:00+04'),  -- 8
( 9, 2, 300.00, 30.00,   0.00, 'held',     '2026-11-02 10:00+04'),  -- 9
(10, 2, 210.00, 21.00,   0.00, 'held',     '2026-11-11 13:00+04'),  -- 10
(14, 2, 200.00,  0.00, 200.00, 'refunded', '2026-11-03 12:00+04'),  -- 11 ev sahibi ləğv etdi → tam geri qaytarma (BR-19)
(16, 2, 100.00, 10.00,   0.00, 'released', '2026-07-21 10:00+04'),  -- 12
(17, 2, 225.00, 22.50,   0.00, 'released', '2026-07-29 10:00+04'),  -- 13
(18, 2,  90.00,  9.00,   0.00, 'released', '2026-08-06 10:00+04'),  -- 14
(19, 2, 255.00, 25.50,   0.00, 'released', '2026-08-11 10:00+04'),  -- 15
(20, 2, 140.00, 14.00,   0.00, 'released', '2026-08-16 10:00+04');  -- 16

-- ---------------------------------------------------------------------
-- payouts (10) — yalnız 'released' ödənişlərdən, ev sahibinin aktiv hesabına
-- amount = payments.amount − commission_amount
-- ---------------------------------------------------------------------
INSERT INTO payouts (payment_id, payout_account_id, amount, status, paid_at) VALUES
( 1, 1, 288.00, 'completed', '2026-09-10 12:00+04'),   -- Rauf
( 2, 1, 144.00, 'completed', '2026-09-15 12:00+04'),   -- Rauf
( 4, 3, 243.00, 'completed', '2026-10-05 12:00+04'),   -- Kamran
( 6, 4, 135.00, 'completed', '2026-10-19 12:00+04'),   -- Lalə
( 8, 5,  99.00, 'pending',   NULL),                    -- Tural
(12, 4,  90.00, 'completed', '2026-08-04 12:00+04'),   -- Lalə
(13, 4, 202.50, 'completed', '2026-08-14 12:00+04'),   -- Lalə
(14, 1,  81.00, 'completed', '2026-08-23 12:00+04'),   -- Rauf
(15, 2, 229.50, 'completed', '2026-08-29 12:00+04'),   -- Səbinə
(16, 2, 126.00, 'failed',    NULL);                    -- Səbinə

-- ---------------------------------------------------------------------
-- reviews (12) — yalnız completed / paid_out rezervasiyalara (BR-21)
-- id: 1–12
-- ---------------------------------------------------------------------
INSERT INTO reviews (booking_id, rating, comment, status, created_at) VALUES
( 1, 5, 'Mənzərə möhtəşəm idi, ev sahibi çox qonaqpərvərdir.',  'visible', '2026-09-10 18:00+04'),  -- 1
( 2, 1, 'Təhqiramiz ifadələr olan rəy (admin tərəfindən gizlədilib).', 'hidden',  '2026-09-15 09:00+04'),  -- 2
( 3, 4, 'Bağ çox gözəl idi, yol bir az çətindir.',               'visible', '2026-09-23 12:00+04'),  -- 3
( 4, 5, 'Meşədə sakit istirahət, hər şey təmiz idi.',             'visible', '2026-10-05 10:00+04'),  -- 4
( 5, 4, 'Şəlaləyə çox yaxındır, böyük ailə üçün idealdır.',       'visible', '2026-10-13 15:00+04'),  -- 5
( 6, 3, 'Ev yaxşıdır, amma Wi-Fi zəif idi.',                      'visible', '2026-10-19 11:00+04'),  -- 6
( 8, 5, 'Qoz bağı və sakitlik — tövsiyə edirəm.',                 'visible', '2026-10-28 09:00+04'),  -- 7
(16, 4, 'Çay bağı mənzərəsi gözəl idi.',                          'visible', '2026-08-04 20:00+04'),  -- 8
(17, 5, 'Çay kənarında unudulmaz həftəsonu.',                     'visible', '2026-08-14 13:00+04'),  -- 9
(18, 4, 'Bal dequstasiyası çox maraqlı idi.',                     'visible', '2026-08-23 16:00+04'),  -- 10
(19, 3, 'Ev gözəldir, amma təsvirdəki bəzi məlumatlar düz deyil.', 'visible', '2026-08-29 10:00+04'),  -- 11
(20, 5, 'Misgərlik ustad dərsi əla idi.',                         'visible', '2026-09-04 12:00+04');  -- 12

-- ---------------------------------------------------------------------
-- favorites (10) — M:N əlaqə cədvəli
-- ---------------------------------------------------------------------
INSERT INTO favorites (user_id, listing_id, created_at) VALUES
( 7,  1, '2026-08-15 10:00+04'),
( 7,  6, '2026-10-30 21:00+04'),
( 8,  3, '2026-11-10 14:00+04'),
( 9,  5, '2026-09-10 09:00+04'),
( 9,  2, '2026-10-28 18:00+04'),
(10,  6, '2026-09-20 19:00+04'),
(11,  7, '2026-09-28 22:00+04'),
(12,  8, '2026-10-01 08:00+04'),
( 3,  9, '2026-10-05 17:00+04'),
( 4,  1, '2026-07-01 12:00+04');

-- ---------------------------------------------------------------------
-- conversations (10) — bir (elan, səyahətçi) cütü üçün bir söhbət (BR-23)
-- id: 1–10
-- ---------------------------------------------------------------------
INSERT INTO conversations (listing_id, guest_id, created_at) VALUES
( 1,  7, '2026-08-18 10:00+04'),  -- 1  ev sahibi: 2
( 1,  8, '2026-08-27 11:00+04'),  -- 2  ev sahibi: 2
( 3,  7, '2026-08-30 09:00+04'),  -- 3  ev sahibi: 3
( 5,  9, '2026-09-14 17:00+04'),  -- 4  ev sahibi: 4
( 6, 10, '2026-09-24 13:00+04'),  -- 5  ev sahibi: 4
( 7, 11, '2026-09-30 10:00+04'),  -- 6  ev sahibi: 5
( 8, 12, '2026-10-04 15:00+04'),  -- 7  ev sahibi: 5
( 9,  3, '2026-10-09 19:00+04'),  -- 8  ev sahibi: 6
( 2,  9, '2026-10-31 09:00+04'),  -- 9  ev sahibi: 2
(10, 12, '2026-11-17 21:00+04');  -- 10 ev sahibi: 6

-- ---------------------------------------------------------------------
-- messages (20) — sender yalnız səyahətçi və ya elanın sahibi (trigger yoxlayır)
-- id: 1–20
-- ---------------------------------------------------------------------
INSERT INTO messages (conversation_id, sender_id, body, sent_at, read_at) VALUES
( 1,  7, 'Salam, sentyabrın 5-dən 4 nəfər üçün ev boşdur?',            '2026-08-18 10:00+04', '2026-08-18 10:30+04'),  -- 1
( 1,  2, 'Salam, bəli, boşdur. Rezervasiya edə bilərsiniz.',           '2026-08-18 10:35+04', '2026-08-18 11:00+04'),  -- 2
( 2,  8, 'Parkinq yeri var?',                                           '2026-08-27 11:00+04', '2026-08-27 12:00+04'),  -- 3
( 2,  2, 'Bəli, evin qarşısında pulsuz parkinq var.',                   '2026-08-27 12:05+04', '2026-08-27 12:30+04'),  -- 4
( 3,  7, 'Uşaqlar üçün uyğundur?',                                      '2026-08-30 09:00+04', '2026-08-30 09:20+04'),  -- 5
( 3,  3, 'Əlbəttə, bağda təhlükəsiz oyun yeri var.',                    '2026-08-30 09:25+04', '2026-08-30 10:00+04'),  -- 6
( 4,  9, 'Şəki stansiyasından transfer mümkündür?',                     '2026-09-14 17:00+04', '2026-09-14 17:40+04'),  -- 7
( 4,  4, 'Bəli, 10 AZN-ə transfer edə bilərəm.',                        '2026-09-14 17:45+04', '2026-09-14 18:00+04'),  -- 8
( 5, 10, '6 nəfərik, yataq kifayət edər?',                              '2026-09-24 13:00+04', '2026-09-24 13:10+04'),  -- 9
( 5,  4, 'Ev 8 nəfərlikdir, rahat yerləşərsiniz.',                      '2026-09-24 13:15+04', '2026-09-24 14:00+04'),  -- 10
( 6, 11, 'Çay plantasiyasına ekskursiya var?',                          '2026-09-30 10:00+04', '2026-09-30 10:30+04'),  -- 11
( 6,  5, 'Bu cür sual verməyin, saytda hər şey yazılıb!',               '2026-09-30 10:40+04', '2026-09-30 11:00+04'),  -- 12 (şikayət olunub)
( 7, 12, 'Gəldik, amma ev təmiz deyil.',                                '2026-10-20 15:00+04', '2026-10-20 15:30+04'),  -- 13
( 7,  5, 'Üzr istəyirəm, dərhal təmizlətdirirəm.',                      '2026-10-20 15:35+04', '2026-10-20 16:00+04'),  -- 14
( 7, 12, 'Artıq gecdir, bu xidmət biabırçılıqdır!',                     '2026-10-20 18:00+04', '2026-10-20 18:30+04'),  -- 15 (şikayət olunub)
( 8,  3, 'Salam, 2 nəfər üçün oktyabrın 25-i boşdur?',                  '2026-10-09 19:00+04', '2026-10-09 19:30+04'),  -- 16
( 8,  6, 'Bəli, sizi gözləyirik.',                                      '2026-10-09 19:35+04', '2026-10-09 20:00+04'),  -- 17
( 9,  9, 'Kamin üçün odun verilir?',                                    '2026-10-31 09:00+04', '2026-10-31 09:15+04'),  -- 18
( 9,  2, 'Bəli, odun qiymətə daxildir.',                                '2026-10-31 09:20+04', NULL),                   -- 19
(10, 12, 'Termal bulaq qışda da açıqdır?',                              '2026-11-17 21:00+04', NULL);                   -- 20

-- ---------------------------------------------------------------------
-- complaints (11) — hər şikayət dəqiq bir hədəfə (BR-25)
-- 12 nömrəli elana 3 açıq şikayət → trigger elanı avtomatik gizlədir (BR-26)
-- ---------------------------------------------------------------------
INSERT INTO complaints (complainant_id, listing_id, review_id, message_id, booking_id, reason, description,
                        status, resolution, resolved_by, resolved_at, created_at) VALUES
( 7, 12,   NULL, NULL, NULL, 'misleading_info', 'Təsvirdə yazılan çay yaxınlığı düz deyil.', 'open',      NULL, NULL, NULL, '2026-11-01 10:00+04'),
( 8, 12,   NULL, NULL, NULL, 'fake_photos',     'Şəkillər başqa evə aiddir.',               'open',      NULL, NULL, NULL, '2026-11-03 11:00+04'),
( 9, 12,   NULL, NULL, NULL, 'misleading_info', 'Qiymət telefonda fərqli deyildi.',         'open',      NULL, NULL, NULL, '2026-11-05 12:00+04'),
(10,  2,   NULL, NULL, NULL, 'price_issue',     'Qiymət çox bahadır.',                      'rejected',  'Qiymət ev sahibinin hüququdur, qayda pozuntusu yoxdur.', 1, '2026-10-30 10:00+04', '2026-10-29 09:00+04'),
(12, NULL, NULL, NULL, 7,    'cleanliness',     'Ev təmiz deyildi, pulun qaytarılmasını istəyirəm.', 'in_review', NULL, NULL, NULL, '2026-10-21 09:00+04'),
( 2, NULL, 2,    NULL, NULL, 'offensive',       'Rəydə təhqiramiz ifadələr var.',           'resolved',  'Rəy gizlədildi.', 1, '2026-09-16 10:00+04', '2026-09-15 12:00+04'),
(11, NULL, NULL, 12,   NULL, 'rude_message',    'Ev sahibi kobud cavab verdi.',             'resolved',  'Ev sahibinə xəbərdarlıq edildi.', 1, '2026-10-02 10:00+04', '2026-09-30 12:00+04'),
( 9,  6,   NULL, NULL, NULL, 'safety',          'Pilləkənin məhəccəri yoxdur.',             'open',      NULL, NULL, NULL, '2026-11-10 14:00+04'),
( 7,  9,   NULL, NULL, NULL, 'misleading_info', 'Wi-Fi yazılıb, amma yoxdur.',              'rejected',  'Elanda Wi-Fi qeyd olunmayıb.', 1, '2026-10-29 10:00+04', '2026-10-28 09:00+04'),
( 5, NULL, NULL, 15,   NULL, 'rude_message',    'Səyahətçi təhqiramiz mesaj yazdı.',        'open',      NULL, NULL, NULL, '2026-10-21 08:00+04'),
(10,  5,   NULL, NULL, NULL, 'noise',           'Qonşu evdən gecə səs-küy.',                'resolved',  'Ev sahibi ilə danışıldı, problem həll olundu.', 1, '2026-10-16 10:00+04', '2026-10-14 09:00+04');

-- ---------------------------------------------------------------------
-- notifications (12) — 4 kanal nümayiş olunur (BR-27)
-- ---------------------------------------------------------------------
INSERT INTO notifications (user_id, booking_id, type, channel, title, body, is_read, created_at) VALUES
( 2,  1,   'booking_request',   'in_app',   'Yeni rezervasiya sorğusu', 'Nərmin Əliyeva 5–9 sentyabr üçün sorğu göndərdi.', true,  '2026-08-20 10:00+04'),
( 7,  1,   'booking_confirmed', 'email',    'Rezervasiya təsdiqləndi',  'Xınalıqda dağ evi üçün sorğunuz təsdiqləndi.',      true,  '2026-08-20 14:00+04'),
( 7,  1,   'payment_success',   'sms',      'Ödəniş qəbul olundu',      '320 AZN ödəniş platformada saxlanılır.',            true,  '2026-08-21 10:00+04'),
( 2,  1,   'payout_completed',  'whatsapp', 'Köçürmə edildi',           'Hesabınıza 288 AZN köçürüldü.',                     true,  '2026-09-10 12:00+04'),
( 4, 11,   'booking_request',   'in_app',   'Yeni rezervasiya sorğusu', 'Günay İsmayılova 10–12 dekabr üçün sorğu göndərdi.', true, '2026-11-16 09:00+04'),
(11, 11,   'booking_confirmed', 'email',    'Rezervasiya təsdiqləndi',  'Ödənişi 48 saat ərzində edin.',                     false, '2026-11-16 12:00+04'),
( 6, 12,   'booking_request',   'sms',      'Yeni rezervasiya sorğusu', 'Cavab vermək üçün 24 saatınız var.',                false, '2026-11-17 22:00+04'),
( 9, 13,   'booking_rejected',  'in_app',   'Sorğu rədd edildi',        'Ev sahibi bu tarixlər üçün sorğunu rədd etdi.',     true,  '2026-11-05 18:00+04'),
( 7, 14,   'refund_issued',     'email',    'Pul geri qaytarıldı',      '200 AZN kartınıza qaytarıldı.',                     false, '2026-11-03 12:30+04'),
(12,  7,   'dispute_opened',    'in_app',   'Şikayət qəbul olundu',     'Şikayətinizə admin baxır, ödəniş saxlanılır.',      true,  '2026-10-21 09:05+04'),
( 3, NULL, 'listing_hidden',    'email',    'Elanınız gizlədildi',      'Daşaltı qaya evi şikayətlərə görə admin baxışındadır.', false, '2026-11-05 12:05+04'),
( 8, NULL, 'welcome',           'in_app',   'Xoş gəlmisiniz!',          'Kəndim platformasına qoşulduğunuz üçün təşəkkürlər.', true, '2026-05-03 19:00+04');

-- ---------------------------------------------------------------------
-- audit_logs (10) — admin və sistem əməliyyatları (BR-28); +1 sətri trigger yazır
-- ---------------------------------------------------------------------
INSERT INTO audit_logs (actor_id, action, entity_type, entity_id, details, created_at) VALUES
(1,    'block_user',          'user',               13, '{"reason": "saxta hesab"}',                         '2026-08-02 10:00+04'),
(1,    'hide_review',         'review',              2, '{"complaint_id": 6}',                               '2026-09-16 10:00+04'),
(1,    'resolve_complaint',   'complaint',           6, '{"resolution": "rəy gizlədildi"}',                  '2026-09-16 10:01+04'),
(1,    'resolve_complaint',   'complaint',           7, '{"resolution": "xəbərdarlıq"}',                     '2026-10-02 10:00+04'),
(1,    'reject_complaint',    'complaint',           4, '{"reason": "qayda pozuntusu yoxdur"}',              '2026-10-30 10:00+04'),
(1,    'change_commission',   'commission_setting',  3, '{"old_rate": 10.00, "new_rate": 8.00}',             '2026-11-10 09:00+04'),
(NULL, 'expire_token',        'verification_token', 10, '{"rule": "BR-30"}',                                 '2026-08-01 12:15+04'),
(NULL, 'release_payment',     'payment',             1, '{"rule": "BR-16", "amount": 320.00}',               '2026-09-10 11:00+04'),
(NULL, 'release_payment',     'payment',             4, '{"rule": "BR-16", "amount": 270.00}',               '2026-10-05 11:00+04'),
(NULL, 'hold_payment',        'payment',             7, '{"rule": "BR-20", "booking_id": 7}',                '2026-10-21 09:05+04');

COMMIT;
