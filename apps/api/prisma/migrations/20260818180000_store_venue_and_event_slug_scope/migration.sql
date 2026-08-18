ALTER TABLE "Store" ADD COLUMN "locationName" TEXT NOT NULL DEFAULT '';
ALTER TABLE "Store" ADD COLUMN "address" TEXT NOT NULL DEFAULT '';

UPDATE "Store" SET "locationName" = 'Arena Nexus', "address" = 'Rua Augusta, 1200 — Consolação, São Paulo' WHERE slug = 'arena-nexus';
UPDATE "Store" SET "locationName" = 'Dragão de Aço', "address" = 'Av. Sete de Setembro, 800 — Centro, Curitiba' WHERE slug = 'dragao-de-aco';

DROP INDEX "Event_slug_key";
CREATE UNIQUE INDEX "Event_storeId_slug_key" ON "Event"("storeId", "slug");
