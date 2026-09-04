-- Run this only in an environment where LL_RESERVED_PUBLIC_IPS already exists.
-- LAST_RESERVATION_ID is intentionally not a foreign key: it is retained for
-- reporting even after the reservation lifecycle is cleaned up.

ALTER TABLE ll_reserved_public_ips ADD (
  last_reservation_id NUMBER
);

-- Preserve the current assignment as history for any row already in use.
UPDATE ll_reserved_public_ips
   SET last_reservation_id = reservation_id
 WHERE reservation_id IS NOT NULL
   AND last_reservation_id IS NULL;

COMMIT;
