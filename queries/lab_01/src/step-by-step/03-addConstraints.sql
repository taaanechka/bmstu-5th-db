--ALTER TABLE car_owners 
--ADD constraint owner_age CHECK(age > 15);

ALTER TABLE car_brands
ADD constraint len_country_code CHECK(length(manufact_country_code) = 2);

ALTER TABLE car_models
ADD constraint model_seats_amount CHECK(seats_amount > 1);

ALTER TABLE cars ALTER COLUMN rooftype SET NOT NULL;