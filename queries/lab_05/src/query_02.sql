\c dbcourse;

--\t \a
-- 2) Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
DROP TABLE IF EXISTS brands_from_json;
DROP TABLE IF EXISTS temp;

CREATE TABLE brands_from_json (
    id serial primary key,
    name varchar not null,
    manufact_country_code varchar(2) not null, 
    wheel varchar(5) not null
);

CREATE TABLE IF NOT EXISTS temp (
    data jsonb
);


COPY temp(data) FROM '/db/dbdata/brands.json';
INSERT INTO brands_from_json (id, name, manufact_country_code, wheel)
SELECT (data->>'id')::int, data->>'name', data->>'manufact_country_code', data->>'wheel' FROM temp;

-- посмотреть результат: открыть через клиента (можно и SELECT, но там 1000 записей)