\c dbcourse;

-- 1) Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.
--\t
\o /db/dbdata/cars.json
SELECT ROW_TO_JSON(c) cars FROM cars c;

\o /db/dbdata/owners.json
SELECT ROW_TO_JSON(c) car_owners FROM car_owners c;

\o /db/dbdata/models.json
SELECT ROW_TO_JSON(c) car_models FROM car_models c;

\o /db/dbdata/brands.json
SELECT ROW_TO_JSON(c) car_brands  FROM car_brands c;
\o
