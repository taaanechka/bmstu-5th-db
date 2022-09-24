\c postgres;
DROP DATABASE IF EXISTS dbcourse;
CREATE DATABASE dbcourse;
\c dbcourse;

--DROP TABLE IF EXISTS car_owners;
CREATE TABLE car_owners(
    id serial, --primary key,
    name varchar not null,
    sex char not null,
    --age int, --constraint owner_age CHECK(age > 15),
    height int not null constraint owner_height CHECK(height > 149), 
    driving_experience int  not null,
    birth_date date not null,
    CONSTRAINT owner_id PRIMARY KEY(id)
);
--COPY car_owners FROM '/db/data/car_owner.csv' DELIMITER ',';

--DROP TABLE IF EXISTS car_brands;
CREATE TABLE car_brands(
    id serial primary key,
    name varchar not null,
    manufact_country_code varchar(2) not null, 
    wheel varchar(5) not null
);
--COPY car_brands FROM '/db/data/brands.csv' DELIMITER ',';

--DROP TABLE IF EXISTS car_models;
CREATE TABLE car_models(
    id int primary key,
    brand_id int not null,
    body_type varchar not null,
    engine varchar(8) not null,
    gearbox varchar(10) not null, 
    seats_amount int not null,
    foreign key (brand_id) references car_brands(id) on delete cascade
);
--COPY car_models FROM '/db/data/models.csv' DELIMITER ',';

--DROP TABLE IF EXISTS cars;
CREATE TABLE cars(
    car_number varchar primary key,
    model_id int not null,
    owner_id int not null,
    gear varchar(11) not null,
    colour varchar not null,
    rooftype varchar(9), 
    foreign key (model_id) references car_models(id) on delete cascade,
    foreign key (owner_id) references car_owners(id) on delete cascade
);
--COPY cars FROM '/db/data/cars.csv' DELIMITER ',';