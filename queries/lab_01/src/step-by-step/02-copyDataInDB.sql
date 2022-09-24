COPY car_owners FROM '/db/dbdata/car_owner.csv' DELIMITER ',';
--SELECT setval('car_owners_id_seq', max(id)) FROM car_owners;

COPY car_brands FROM '/db/dbdata/brands.csv' DELIMITER ',';

COPY car_models FROM '/db/dbdata/models.csv' DELIMITER ',';

COPY cars FROM '/db/dbdata/cars.csv' DELIMITER ',';