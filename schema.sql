-- =====================================================================
--  Kəndim — Kənd Turizmi və Kirayə Ev İdarəetmə Platforması
--  Milestone 3: Physical Database Implementation (PostgreSQL 16)
--  Fayl: schema.sql — verilənlər bazası, sxem, 24 cədvəl, constraint-lər,
--        index-lər, trigger-lər və view-lar
--  İşə salma:  psql -U postgres -f schema.sql
-- =====================================================================

-- 1. Verilənlər bazasının yaradılması --------------------------------
DROP DATABASE IF EXISTS kendim;
CREATE DATABASE kendim ENCODING 'UTF8';
\connect kendim

-- EXCLUDE USING gist (tarix toqquşması) üçün lazımdır
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 2. Ayrıca PostgreSQL sxemi (bonus) ---------------------------------
CREATE SCHEMA kendim;
SET search_path TO kendim, public;
ALTER DATABASE kendim SET search_path TO kendim, public;
ALTER DATABASE kendim SET timezone TO 'Asia/Baku';

-- =====================================================================
-- 3. CƏDVƏLLƏR (asılılıq ardıcıllığı ilə: əvvəl valideyn, sonra uşaq)
-- =====================================================================

-- 3.1 users — bütün istifadəçilər (BR-01, BR-02, BR-04)
CREATE TABLE users (
    id                  BIGSERIAL    PRIMARY KEY,
    first_name          VARCHAR(50)  NOT NULL,
    last_name           VARCHAR(50)  NOT NULL,
    email               VARCHAR(255) NOT NULL,
    phone               VARCHAR(20)  NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    role                VARCHAR(10)  NOT NULL DEFAULT 'user',
    status              VARCHAR(10)  NOT NULL DEFAULT 'active',
    email_verified_at   TIMESTAMPTZ,
    phone_verified_at   TIMESTAMPTZ,
    consent_accepted_at TIMESTAMPTZ  NOT NULL,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT uq_users_email  UNIQUE (email),
    CONSTRAINT uq_users_phone  UNIQUE (phone),
    CONSTRAINT chk_users_role   CHECK (role IN ('user', 'admin')),
    CONSTRAINT chk_users_status CHECK (status IN ('active', 'blocked')),
    CONSTRAINT chk_users_email_format CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    CONSTRAINT chk_users_phone_format CHECK (phone ~ '^\+994[0-9]{9}$')
);

-- 3.2 regions — rayonlar (BR-05)
CREATE TABLE regions (
    id   BIGSERIAL    PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_regions_name UNIQUE (name)
);

-- 3.3 villages — kəndlər (BR-05)
CREATE TABLE villages (
    id          BIGSERIAL    PRIMARY KEY,
    region_id   BIGINT       NOT NULL REFERENCES regions(id) ON DELETE RESTRICT,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    how_to_get  TEXT,
    CONSTRAINT uq_villages_region_name UNIQUE (region_id, name)
);

-- 3.4 village_highlights — gəzməli yerlər və yerli yeməklər (1NF)
CREATE TABLE village_highlights (
    id          BIGSERIAL    PRIMARY KEY,
    village_id  BIGINT       NOT NULL REFERENCES villages(id) ON DELETE CASCADE,
    type        VARCHAR(20)  NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description TEXT,
    CONSTRAINT chk_highlights_type CHECK (type IN ('attraction', 'food')),
    CONSTRAINT uq_highlights UNIQUE (village_id, type, name)
);

-- 3.5 village_photos — kəndin şəkilləri (yalnız URL)
CREATE TABLE village_photos (
    id         BIGSERIAL    PRIMARY KEY,
    village_id BIGINT       NOT NULL REFERENCES villages(id) ON DELETE CASCADE,
    url        VARCHAR(500) NOT NULL,
    sort_order SMALLINT     NOT NULL DEFAULT 1,
    CONSTRAINT chk_village_photos_order CHECK (sort_order >= 1),
    CONSTRAINT uq_village_photos UNIQUE (village_id, sort_order)
);

-- 3.6 amenities — şəraitlərin ümumi siyahısı (BR-08)
CREATE TABLE amenities (
    id   BIGSERIAL   PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    CONSTRAINT uq_amenities_name UNIQUE (name)
);

-- 3.7 commission_settings — komissiya faizinin tarixçəsi (BR-17)
CREATE TABLE commission_settings (
    id             BIGSERIAL    PRIMARY KEY,
    rate_percent   NUMERIC(5,2) NOT NULL,
    effective_from TIMESTAMPTZ  NOT NULL,
    created_by     BIGINT       NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_commission_rate CHECK (rate_percent BETWEEN 0 AND 100),
    CONSTRAINT uq_commission_effective UNIQUE (effective_from)
);

-- 3.8 payout_accounts — ev sahibinin ödəniş hesabları (BR-18, BR-29)
CREATE TABLE payout_accounts (
    id             BIGSERIAL    PRIMARY KEY,
    user_id        BIGINT       NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    account_holder VARCHAR(100) NOT NULL,
    account_number VARCHAR(34)  NOT NULL,
    is_active      BOOLEAN      NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT uq_payout_accounts UNIQUE (user_id, account_number),
    CONSTRAINT chk_payout_iban CHECK (account_number ~ '^AZ[0-9]{2}[A-Z0-9]{24}$')
);
-- BR-29: bir istifadəçinin eyni anda yalnız bir aktiv hesabı ola bilər
CREATE UNIQUE INDEX ux_payout_active ON payout_accounts(user_id) WHERE is_active;

-- 3.9 verification_tokens — təsdiq və şifrə bərpası kodları (BR-03, BR-30)
CREATE TABLE verification_tokens (
    id         BIGSERIAL    PRIMARY KEY,
    user_id    BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    purpose    VARCHAR(20)  NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ  NOT NULL,
    used_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT uq_tokens_hash UNIQUE (token_hash),
    CONSTRAINT chk_tokens_purpose CHECK (purpose IN ('email_verify', 'phone_verify', 'password_reset')),
    CONSTRAINT chk_tokens_expiry  CHECK (expires_at > created_at)
);

-- 3.10 listings — kirayə elanları (BR-05, BR-06, BR-09)
CREATE TABLE listings (
    id                 BIGSERIAL     PRIMARY KEY,
    owner_id           BIGINT        NOT NULL REFERENCES users(id)    ON DELETE RESTRICT,
    village_id         BIGINT        NOT NULL REFERENCES villages(id) ON DELETE RESTRICT,
    title              VARCHAR(150)  NOT NULL,
    description        TEXT,
    price_per_night    NUMERIC(10,2) NOT NULL,
    max_guests         SMALLINT      NOT NULL,
    rooms              SMALLINT      NOT NULL,
    utilities_included BOOLEAN       NOT NULL DEFAULT false,
    guide_service      BOOLEAN       NOT NULL DEFAULT false,
    address            VARCHAR(255)  NOT NULL,
    latitude           NUMERIC(9,6)  NOT NULL,
    longitude          NUMERIC(9,6)  NOT NULL,
    view_count         INTEGER       NOT NULL DEFAULT 0,
    status             VARCHAR(10)   NOT NULL DEFAULT 'active',
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT chk_listings_price  CHECK (price_per_night > 0),
    CONSTRAINT chk_listings_guests CHECK (max_guests >= 1),
    CONSTRAINT chk_listings_rooms  CHECK (rooms >= 1),
    CONSTRAINT chk_listings_views  CHECK (view_count >= 0),
    CONSTRAINT chk_listings_lat    CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT chk_listings_lng    CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_listings_status CHECK (status IN ('active', 'hidden', 'deleted'))
);

-- 3.11 listing_photos — elanın şəkilləri, 1–10 ədəd (BR-07)
CREATE TABLE listing_photos (
    id         BIGSERIAL    PRIMARY KEY,
    listing_id BIGINT       NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    url        VARCHAR(500) NOT NULL,
    sort_order SMALLINT     NOT NULL,
    CONSTRAINT chk_listing_photos_order CHECK (sort_order BETWEEN 1 AND 10),
    CONSTRAINT uq_listing_photos UNIQUE (listing_id, sort_order)
);

-- 3.12 listing_nearby_places — evin yaxınlığındakı yerlər (BR-06)
CREATE TABLE listing_nearby_places (
    id          BIGSERIAL    PRIMARY KEY,
    listing_id  BIGINT       NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    place_type  VARCHAR(30)  NOT NULL,
    name        VARCHAR(150) NOT NULL,
    distance_km NUMERIC(5,2),
    CONSTRAINT chk_nearby_distance CHECK (distance_km >= 0),
    CONSTRAINT uq_nearby UNIQUE (listing_id, place_type, name)
);

-- 3.13 listing_amenities — listings ↔ amenities M:N (BR-08)
CREATE TABLE listing_amenities (
    id         BIGSERIAL PRIMARY KEY,
    listing_id BIGINT    NOT NULL REFERENCES listings(id)  ON DELETE CASCADE,
    amenity_id BIGINT    NOT NULL REFERENCES amenities(id) ON DELETE RESTRICT,
    CONSTRAINT uq_listing_amenity UNIQUE (listing_id, amenity_id)
);

-- 3.14 availability_blocks — ev sahibinin bağladığı tarixlər (BR-10)
CREATE TABLE availability_blocks (
    id         BIGSERIAL    PRIMARY KEY,
    listing_id BIGINT       NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    start_date DATE         NOT NULL,
    end_date   DATE         NOT NULL,
    reason     VARCHAR(255),
    CONSTRAINT chk_blocks_dates CHECK (end_date > start_date),
    CONSTRAINT ex_blocks_no_overlap EXCLUDE USING gist (
        listing_id WITH =,
        daterange(start_date, end_date, '[)') WITH &&
    )
);

-- 3.15 bookings — rezervasiyalar, 10 status (BR-11 … BR-15, BR-20)
CREATE TABLE bookings (
    id                BIGSERIAL     PRIMARY KEY,
    listing_id        BIGINT        NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    guest_id          BIGINT        NOT NULL REFERENCES users(id)    ON DELETE RESTRICT,
    check_in          DATE          NOT NULL,
    check_out         DATE          NOT NULL,
    guests_count      SMALLINT      NOT NULL,
    price_per_night   NUMERIC(10,2) NOT NULL,          -- rezervasiya anındakı qiymət (snapshot)
    status            VARCHAR(20)   NOT NULL DEFAULT 'pending',
    response_deadline TIMESTAMPTZ   NOT NULL DEFAULT (now() + INTERVAL '24 hours'),
    payment_deadline  TIMESTAMPTZ,
    cancelled_by      VARCHAR(10),
    cancel_reason     TEXT,
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT chk_bookings_dates  CHECK (check_out > check_in),
    CONSTRAINT chk_bookings_guests CHECK (guests_count >= 1),
    CONSTRAINT chk_bookings_price  CHECK (price_per_night > 0),
    CONSTRAINT chk_bookings_status CHECK (status IN (
        'pending', 'rejected', 'confirmed', 'paid', 'in_progress',
        'completed', 'paid_out', 'cancelled', 'disputed', 'refunded')),
    CONSTRAINT chk_bookings_cancelled_by CHECK (cancelled_by IN ('guest', 'host', 'system')),
    CONSTRAINT chk_bookings_cancel_info  CHECK (status <> 'cancelled' OR cancelled_by IS NOT NULL),
    -- BR-13: aktiv rezervasiyalar eyni elan üçün üst-üstə düşə bilməz
    CONSTRAINT ex_bookings_no_overlap EXCLUDE USING gist (
        listing_id WITH =,
        daterange(check_in, check_out, '[)') WITH &&
    ) WHERE (status IN ('confirmed', 'paid', 'in_progress', 'completed', 'paid_out', 'disputed'))
);

-- 3.16 payments — simulyasiya ödənişi; pul 'held' saxlanılır (BR-16, BR-17, BR-19)
CREATE TABLE payments (
    id                    BIGSERIAL     PRIMARY KEY,
    booking_id            BIGINT        NOT NULL REFERENCES bookings(id)            ON DELETE RESTRICT,
    commission_setting_id BIGINT        NOT NULL REFERENCES commission_settings(id) ON DELETE RESTRICT,
    amount                NUMERIC(12,2) NOT NULL,
    commission_amount     NUMERIC(12,2) NOT NULL,
    refund_amount         NUMERIC(12,2) NOT NULL DEFAULT 0,
    status                VARCHAR(10)   NOT NULL DEFAULT 'held',
    paid_at               TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT uq_payments_booking UNIQUE (booking_id),           -- 1:1
    CONSTRAINT chk_payments_amount     CHECK (amount > 0),
    CONSTRAINT chk_payments_commission CHECK (commission_amount >= 0),
    CONSTRAINT chk_payments_refund     CHECK (refund_amount >= 0),
    CONSTRAINT chk_payments_total      CHECK (refund_amount + commission_amount <= amount),
    CONSTRAINT chk_payments_status     CHECK (status IN ('held', 'released', 'refunded'))
);

-- 3.17 payouts — ev sahibinə köçürmə (BR-18)
CREATE TABLE payouts (
    id                BIGSERIAL     PRIMARY KEY,
    payment_id        BIGINT        NOT NULL REFERENCES payments(id)        ON DELETE RESTRICT,
    payout_account_id BIGINT        NOT NULL REFERENCES payout_accounts(id) ON DELETE RESTRICT,
    amount            NUMERIC(12,2) NOT NULL,
    status            VARCHAR(10)   NOT NULL DEFAULT 'pending',
    paid_at           TIMESTAMPTZ,
    CONSTRAINT uq_payouts_payment UNIQUE (payment_id),            -- 1:1
    CONSTRAINT chk_payouts_amount CHECK (amount > 0),
    CONSTRAINT chk_payouts_status CHECK (status IN ('pending', 'completed', 'failed')),
    CONSTRAINT chk_payouts_paid_at CHECK (status <> 'completed' OR paid_at IS NOT NULL)
);

-- 3.18 reviews — rəylər, 1–5 ulduz (BR-21)
CREATE TABLE reviews (
    id         BIGSERIAL   PRIMARY KEY,
    booking_id BIGINT      NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    rating     SMALLINT    NOT NULL,
    comment    TEXT,
    status     VARCHAR(10) NOT NULL DEFAULT 'visible',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_reviews_booking UNIQUE (booking_id),            -- 1:1
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_reviews_status CHECK (status IN ('visible', 'hidden'))
);

-- 3.19 favorites — users ↔ listings M:N (BR-22)
CREATE TABLE favorites (
    id         BIGSERIAL   PRIMARY KEY,
    user_id    BIGINT      NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    listing_id BIGINT      NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_favorites UNIQUE (user_id, listing_id)
);

-- 3.20 conversations — elan üzrə söhbət (BR-23)
CREATE TABLE conversations (
    id         BIGSERIAL   PRIMARY KEY,
    listing_id BIGINT      NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    guest_id   BIGINT      NOT NULL REFERENCES users(id)    ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_conversations UNIQUE (listing_id, guest_id)
);

-- 3.21 messages — söhbətdəki mesajlar (BR-23)
CREATE TABLE messages (
    id              BIGSERIAL   PRIMARY KEY,
    conversation_id BIGINT      NOT NULL REFERENCES conversations(id) ON DELETE RESTRICT,
    sender_id       BIGINT      NOT NULL REFERENCES users(id)         ON DELETE RESTRICT,
    body            TEXT        NOT NULL,
    sent_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    read_at         TIMESTAMPTZ,
    CONSTRAINT chk_messages_body CHECK (length(trim(body)) > 0),
    CONSTRAINT chk_messages_read CHECK (read_at IS NULL OR read_at >= sent_at)
);

-- 3.22 complaints — şikayətlər, exclusive arc (BR-20, BR-25, BR-26)
CREATE TABLE complaints (
    id             BIGSERIAL   PRIMARY KEY,
    complainant_id BIGINT      NOT NULL REFERENCES users(id)    ON DELETE RESTRICT,
    listing_id     BIGINT      REFERENCES listings(id)          ON DELETE RESTRICT,
    review_id      BIGINT      REFERENCES reviews(id)           ON DELETE RESTRICT,
    message_id     BIGINT      REFERENCES messages(id)          ON DELETE RESTRICT,
    booking_id     BIGINT      REFERENCES bookings(id)          ON DELETE RESTRICT,
    reason         VARCHAR(50) NOT NULL,
    description    TEXT,
    status         VARCHAR(12) NOT NULL DEFAULT 'open',
    resolution     TEXT,
    resolved_by    BIGINT      REFERENCES users(id)             ON DELETE SET NULL,
    resolved_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_complaints_status CHECK (status IN ('open', 'in_review', 'resolved', 'rejected')),
    CONSTRAINT chk_complaints_one_target CHECK (num_nonnulls(listing_id, review_id, message_id, booking_id) = 1),
    CONSTRAINT chk_complaints_resolved CHECK ((status IN ('resolved', 'rejected')) = (resolved_at IS NOT NULL))
);

-- 3.23 notifications — bildiriş jurnalı (BR-27)
CREATE TABLE notifications (
    id         BIGSERIAL    PRIMARY KEY,
    user_id    BIGINT       NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    booking_id BIGINT       REFERENCES bookings(id)          ON DELETE SET NULL,
    type       VARCHAR(40)  NOT NULL,
    channel    VARCHAR(10)  NOT NULL DEFAULT 'in_app',
    title      VARCHAR(150) NOT NULL,
    body       TEXT         NOT NULL,
    is_read    BOOLEAN      NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_notifications_channel CHECK (channel IN ('in_app', 'email', 'sms', 'whatsapp'))
);

-- 3.24 audit_logs — admin və sistem əməliyyatları (BR-28)
CREATE TABLE audit_logs (
    id          BIGSERIAL   PRIMARY KEY,
    actor_id    BIGINT      REFERENCES users(id) ON DELETE SET NULL,   -- NULL = sistem
    action      VARCHAR(50) NOT NULL,
    entity_type VARCHAR(40) NOT NULL,
    entity_id   BIGINT      NOT NULL,
    details     JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================================
-- 4. INDEX-LƏR (tez-tez axtarılan FK və filtr sütunları)
-- =====================================================================
CREATE INDEX ix_villages_region      ON villages(region_id);
CREATE INDEX ix_listings_owner       ON listings(owner_id);
CREATE INDEX ix_listings_village     ON listings(village_id);
CREATE INDEX ix_listings_status_price ON listings(status, price_per_night);
CREATE INDEX ix_bookings_listing     ON bookings(listing_id);
CREATE INDEX ix_bookings_guest       ON bookings(guest_id);
CREATE INDEX ix_bookings_status      ON bookings(status);
CREATE INDEX ix_messages_conversation ON messages(conversation_id);
CREATE INDEX ix_notifications_user   ON notifications(user_id, is_read);
CREATE INDEX ix_complaints_listing   ON complaints(listing_id) WHERE listing_id IS NOT NULL;

-- =====================================================================
-- 5. TRIGGER-LƏR (bir neçə cədvələ baxmaq tələb edən biznes qaydaları)
-- =====================================================================

-- 5.1 BR-03, BR-04: elan yerləşdirən istifadəçi təsdiqlənmiş və aktiv olmalıdır
CREATE OR REPLACE FUNCTION fn_check_listing_owner() RETURNS trigger AS $$
DECLARE u users%ROWTYPE;
BEGIN
    SELECT * INTO u FROM users WHERE id = NEW.owner_id;
    IF u.status = 'blocked' THEN
        RAISE EXCEPTION 'BR-04: bloklanmış istifadəçi (id=%) elan yerləşdirə bilməz', NEW.owner_id;
    END IF;
    IF u.email_verified_at IS NULL AND u.phone_verified_at IS NULL THEN
        RAISE EXCEPTION 'BR-03: elan üçün email və ya telefon təsdiqlənməlidir (user id=%)', NEW.owner_id;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_listing_owner
    BEFORE INSERT OR UPDATE OF owner_id ON listings
    FOR EACH ROW EXECUTE FUNCTION fn_check_listing_owner();

-- 5.2 BR-09: aktiv rezervasiyası olan elan silinə bilməz
CREATE OR REPLACE FUNCTION fn_prevent_listing_delete() RETURNS trigger AS $$
BEGIN
    IF NEW.status = 'deleted' AND OLD.status <> 'deleted' AND EXISTS (
        SELECT 1 FROM bookings b
        WHERE b.listing_id = NEW.id
          AND b.status IN ('pending', 'confirmed', 'paid', 'in_progress', 'disputed')
    ) THEN
        RAISE EXCEPTION 'BR-09: elanın (id=%) aktiv rezervasiyası var, silinə bilməz', NEW.id;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_listing_delete
    BEFORE UPDATE OF status ON listings
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_listing_delete();

-- 5.3 BR-03, BR-04, BR-10, BR-11, BR-12: rezervasiya yoxlamaları
CREATE OR REPLACE FUNCTION fn_check_booking() RETURNS trigger AS $$
DECLARE l listings%ROWTYPE; g users%ROWTYPE;
BEGIN
    -- Səhv tarix aralığını CHECK (chk_bookings_dates) özü rədd edir;
    -- burada daterange() qurmağa çalışmırıq, yoxsa trigger başqa xəta verir.
    IF NEW.check_out <= NEW.check_in THEN
        RETURN NEW;
    END IF;

    SELECT * INTO l FROM listings WHERE id = NEW.listing_id;
    SELECT * INTO g FROM users    WHERE id = NEW.guest_id;

    IF NEW.guest_id = l.owner_id THEN
        RAISE EXCEPTION 'BR-12: istifadəçi öz elanını rezerv edə bilməz';
    END IF;
    IF NEW.guests_count > l.max_guests THEN
        RAISE EXCEPTION 'BR-11: qonaq sayı (%) elanın tutumunu (%) keçir', NEW.guests_count, l.max_guests;
    END IF;
    IF g.status = 'blocked' THEN
        RAISE EXCEPTION 'BR-04: bloklanmış istifadəçi rezervasiya edə bilməz';
    END IF;
    IF g.email_verified_at IS NULL AND g.phone_verified_at IS NULL THEN
        RAISE EXCEPTION 'BR-03: rezervasiya üçün email və ya telefon təsdiqlənməlidir';
    END IF;
    IF EXISTS (
        SELECT 1 FROM availability_blocks a
        WHERE a.listing_id = NEW.listing_id
          AND daterange(a.start_date, a.end_date, '[)') && daterange(NEW.check_in, NEW.check_out, '[)')
    ) THEN
        RAISE EXCEPTION 'BR-10: seçilmiş tarixlər ev sahibi tərəfindən bağlanıb';
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_booking_check
    BEFORE INSERT OR UPDATE OF listing_id, guest_id, check_in, check_out, guests_count ON bookings
    FOR EACH ROW EXECUTE FUNCTION fn_check_booking();

-- 5.4 BR-21: rəy yalnız tamamlanmış rezervasiyaya yazılır
CREATE OR REPLACE FUNCTION fn_check_review() RETURNS trigger AS $$
DECLARE s VARCHAR(20);
BEGIN
    SELECT status INTO s FROM bookings WHERE id = NEW.booking_id;
    IF s NOT IN ('completed', 'paid_out') THEN
        RAISE EXCEPTION 'BR-21: rəy yalnız tamamlanmış rezervasiyaya yazıla bilər (status=%)', s;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_check
    BEFORE INSERT ON reviews
    FOR EACH ROW EXECUTE FUNCTION fn_check_review();

-- 5.5 BR-23: mesajı yalnız söhbətin səyahətçisi və ya elanın sahibi yaza bilər
CREATE OR REPLACE FUNCTION fn_check_message_sender() RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM conversations c JOIN listings l ON l.id = c.listing_id
        WHERE c.id = NEW.conversation_id AND NEW.sender_id IN (c.guest_id, l.owner_id)
    ) THEN
        RAISE EXCEPTION 'BR-23: istifadəçi (id=%) bu söhbətin iştirakçısı deyil', NEW.sender_id;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_message_sender
    BEFORE INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION fn_check_message_sender();

-- 5.6 BR-18: köçürmə yalnız ev sahibinin aktiv hesabına və buraxılmış ödənişdən
CREATE OR REPLACE FUNCTION fn_check_payout() RETURNS trigger AS $$
DECLARE host_id BIGINT; acc payout_accounts%ROWTYPE; pay_status VARCHAR(10);
BEGIN
    SELECT l.owner_id, p.status INTO host_id, pay_status
    FROM payments p JOIN bookings b ON b.id = p.booking_id JOIN listings l ON l.id = b.listing_id
    WHERE p.id = NEW.payment_id;
    SELECT * INTO acc FROM payout_accounts WHERE id = NEW.payout_account_id;

    IF acc.user_id <> host_id THEN
        RAISE EXCEPTION 'BR-18: hesab (id=%) elanın sahibinə aid deyil', NEW.payout_account_id;
    END IF;
    IF NOT acc.is_active THEN
        RAISE EXCEPTION 'BR-18: köçürmə yalnız aktiv hesaba edilə bilər';
    END IF;
    IF pay_status <> 'released' THEN
        RAISE EXCEPTION 'BR-16: ödəniş hələ buraxılmayıb (status=%)', pay_status;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payout_check
    BEFORE INSERT ON payouts
    FOR EACH ROW EXECUTE FUNCTION fn_check_payout();

-- 5.7 BR-26, BR-28: elan barədə 3 açıq şikayət yığılarsa elan avtomatik gizlədilir
CREATE OR REPLACE FUNCTION fn_auto_hide_listing() RETURNS trigger AS $$
DECLARE open_count INT;
BEGIN
    IF NEW.listing_id IS NOT NULL THEN
        SELECT count(*) INTO open_count FROM complaints
        WHERE listing_id = NEW.listing_id AND status IN ('open', 'in_review');

        IF open_count >= 3 THEN
            UPDATE listings SET status = 'hidden'
            WHERE id = NEW.listing_id AND status = 'active';
            IF FOUND THEN
                INSERT INTO audit_logs(actor_id, action, entity_type, entity_id, details)
                VALUES (NULL, 'auto_hide_listing', 'listing', NEW.listing_id,
                        jsonb_build_object('open_complaints', open_count, 'rule', 'BR-26'));
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_complaint_threshold
    AFTER INSERT ON complaints
    FOR EACH ROW EXECUTE FUNCTION fn_auto_hide_listing();

-- =====================================================================
-- 6. VIEW-LAR (törəmə atributlar saxlanılmır, hesablanır)
-- =====================================================================

-- 6.1 Elanın orta reytinqi və rəy sayı
CREATE VIEW v_listing_summary AS
SELECT l.id                               AS listing_id,
       l.title,
       v.name                             AS village,
       r.name                             AS region,
       u.first_name || ' ' || u.last_name AS owner_name,
       l.price_per_night,
       l.max_guests,
       l.status,
       ROUND(AVG(rv.rating) FILTER (WHERE rv.status = 'visible'), 2) AS avg_rating,
       COUNT(rv.id)         FILTER (WHERE rv.status = 'visible')     AS review_count
FROM listings l
JOIN villages v      ON v.id = l.village_id
JOIN regions  r      ON r.id = v.region_id
JOIN users    u      ON u.id = l.owner_id
LEFT JOIN bookings b ON b.listing_id = l.id
LEFT JOIN reviews rv ON rv.booking_id = b.id
GROUP BY l.id, v.name, r.name, u.first_name, u.last_name;

-- 6.2 Rezervasiyanın gecə sayı və ümumi məbləği
CREATE VIEW v_booking_details AS
SELECT b.id                                        AS booking_id,
       l.title                                     AS listing,
       g.first_name || ' ' || g.last_name          AS guest_name,
       b.check_in,
       b.check_out,
       (b.check_out - b.check_in)                  AS nights,
       b.price_per_night,
       (b.check_out - b.check_in) * b.price_per_night AS total_amount,
       b.status
FROM bookings b
JOIN listings l ON l.id = b.listing_id
JOIN users    g ON g.id = b.guest_id;

-- 6.3 BR-24: ev sahibinin telefonu yalnız təsdiqlənmiş rezervasiyadan sonra görünür
CREATE VIEW v_booking_host_contact AS
SELECT b.id AS booking_id,
       b.guest_id,
       h.first_name || ' ' || h.last_name AS host_name,
       CASE WHEN b.status IN ('confirmed', 'paid', 'in_progress', 'completed', 'paid_out')
            THEN h.phone ELSE 'gizlidir' END AS host_phone
FROM bookings b
JOIN listings l ON l.id = b.listing_id
JOIN users    h ON h.id = l.owner_id;
