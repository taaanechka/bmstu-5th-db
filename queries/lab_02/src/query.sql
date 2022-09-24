\c dbcourse

-- 1. Инструкция SELECT, использующая предикат сравнения. 
SELECT DISTINCT B1.manufact_country_code, B1.name 
FROM car_brands B1 JOIN car_brands AS B2 ON B2.manufact_country_code = B1.manufact_country_code
WHERE B2.id <> B1.id 
  AND B1.wheel = 'left' 
ORDER BY B1.manufact_country_code, B1.name;

--2. Инструкция SELECT, использующая предикат BETWEEN.
--Получить список владельцев автомобилей, даты рождения которых между '1995-01-01' и '1997-03-31'
SELECT DISTINCT name, birth_date
FROM car_owners 
WHERE birth_date BETWEEN '1995-01-01' AND '1997-03-31'; 

--3. Инструкция SELECT, использующая предикат LIKE. 
-- Получить список владельцев автомобилей, в имени которых присутствует слово 'Sara' 
SELECT DISTINCT id, name, birth_date 
FROM car_owners JOIN cars ON cars.owner_id = car_owners.id 
WHERE name LIKE '%Sara%'; 

--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом. 
SELECT car_number, model_id, owner_id, colour
FROM cars 
WHERE model_id IN (SELECT model_id 
        FROM car_models 
        WHERE seats_amount = 4 ) 
    AND colour = 'Black';

--5. Инструкция SELECT, использующая предикат EXISTS с вложенным
--подзапросом. 
SELECT id, name  
FROM car_owners
WHERE EXISTS (SELECT owner_id 
              FROM car_owners LEFT OUTER JOIN cars 
              ON car_owners.id = cars.owner_id
              WHERE cars.rooftype = 'glazed'
); 

--6. Инструкция SELECT, использующая предикат сравнения с квантором. 
SELECT id, name, birth_date
FROM car_owners
WHERE sex = 'f' AND driving_experience > ALL (SELECT driving_experience 
    FROM car_owners 
    WHERE sex = 'm' AND height > 180); 

----7. Инструкция SELECT, использующая агрегатные функции в выражениях
--столбцов. 
SELECT sex, AVG(height) AS "height AVG"
FROM car_owners
GROUP BY sex;

--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях
--столбцов.
-- добавить столбец, который выводит количество моделей 
-- (для модели текущей машины) среди всех машин базы
SELECT car_number, model_id, 
    (SELECT count(*)
    FROM cars
    GROUP BY model_id
    HAVING model_id = c.model_id) AS "models cnt"
FROM cars c
--WHERE model_id = 5;
WHERE colour = 'Red';

--9. Инструкция SELECT, использующая простое выражение CASE. 
SELECT car_number, colour,
    CASE colour
        WHEN 'Black' THEN 'B'
        WHEN 'White' THEN 'W'
        ELSE 'Bright'
    END AS "colour type"
FROM cars
WHERE owner_id > 900;

--10. Инструкция SELECT, использующая поисковое выражение CASE.
SELECT name, birth_date, driving_experience,
    CASE 
        WHEN driving_experience < 2 THEN 'beginner'
        WHEN driving_experience < 10 THEN 'amateur'
        WHEN driving_experience < 15 THEN 'advanced'
        ELSE 'professional'
    END AS "driving experience degree"
FROM car_owners
WHERE sex = 'f' and id > 950;

--11. Создание новой временной локальной таблицы из результирующего набора
--данных инструкции SELECT.
DROP TABLE IF EXISTS spacious_cars;
CREATE TEMP TABLE spacious_cars AS
(SELECT cars.car_number, cars.model_id, car_models.seats_amount 
FROM cars JOIN car_models on cars.model_id = car_models.id 
WHERE car_models.seats_amount > 4);

--12. Инструкция SELECT, использующая вложенные коррелированные
--подзапросы в качестве производных таблиц в предложении FROM.
-- Вывести автомобили черного цвета и их владельцев
SELECT car_number, colour, c.owner_id, name
FROM cars c JOIN LATERAL -- позволяет правому операнду получить доступ к столбцам левого операнда
(SELECT id, name
FROM car_owners WHERE c.colour = 'Black') 
AS black_car_owners ON c.owner_id = black_car_owners.id;

--13 Инструкция SELECT, использующая вложенные подзапросы с уровнем
--вложенности 3. 
-- добавить столбец, который выводит количество типов кабины автомобиля
-- таких, в которых среднее количество мест максимально из выборки средних количеств мест, 
-- сгрупированной по типу кабины автомобиля
SELECT body_type, gearbox, count(id) AS "cars_count"  
FROM car_models 
WHERE body_type IN ( SELECT body_type 
                    FROM car_models 
                    GROUP BY body_type  
                    HAVING AVG(seats_amount) = ( SELECT MAX(SA) 
                                                FROM ( SELECT AVG(seats_amount) as SA 
                                                        FROM car_models 
                                                        GROUP BY body_type 
                                                        ) AS avg_SA 
                                                )
                    )
GROUP BY body_type, gearbox;

--14. Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY, но без предложения HAVING.
-- Получить количество моделей автомобиля, сгрупированное по id моделей автомобиля
SELECT model_id, COUNT(model_id) AS models_qty
FROM cars 
GROUP BY model_id;

--15. Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY и предложения HAVING. 
SELECT model_id, COUNT(model_id) AS models_amount
FROM cars 
GROUP BY model_id
HAVING COUNT(model_id) > 3;
 

--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений. 
INSERT INTO car_brands (id, name, manufact_country_code, wheel) 
VALUES ((SELECT max(id) FROM car_brands) + 1, 'Audi', 'DE', 'left');

--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
--результирующего набора данных вложенного подзапроса.
INSERT INTO car_owners (id, name, sex, height, driving_experience, birth_date)
SELECT (SELECT max(id) FROM car_owners) + 1, 'Victor Cooper', 'm', (SELECT avg(height) FROM car_owners),  
driving_experience + 20, birth_date
FROM car_owners
WHERE name = 'Sara Sullivan' and birth_date = '1948-03-07';

--18. Простая инструкция UPDATE. 
UPDATE car_owners 
SET driving_experience = driving_experience + 5
WHERE id = 43;

--19. Инструкция UPDATE со скалярным подзапросом в предложении SET. 
UPDATE car_owners 
SET height = (SELECT AVG(height) 
    FROM car_owners)
WHERE id = 10;

--20. Простая инструкция DELETE. 
DELETE FROM car_brands 
WHERE id = 1001;

--21. Инструкция DELETE с вложенным коррелированным подзапросом в
--предложении WHERE. 
DELETE
FROM car_owners WHERE height IN 
(SELECT AVG(height) FROM car_owners WHERE name LIKE 'Victor Cooper%');

--22. Инструкция SELECT, использующая простое обобщенное табличное
--выражение
WITH r_black_cars (car_number, model_id, owner_id, colour, rooftype) AS (
    SELECT car_number, model_id, owner_id, colour, rooftype FROM cars
    WHERE colour = 'Black' AND  rooftype = 'reclining'
)
SELECT * FROM r_black_cars;

--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
--выражение.
-- Проверить, можно ли с автовладельца Brian Cox добраться до автовладельца с ростом 152 не более 
-- чем за 5 шагов.
WITH RECURSIVE all_car_owners (id, name, height) AS (
    SELECT id, name, height, 0 AS level FROM car_owners
    WHERE name = 'Brian Cox'
    UNION ALL
    SELECT co.id, co.name, co.height, level + 1 FROM car_owners co
    JOIN all_car_owners aco ON co.id = aco.id + 1 AND level < 5
)
SELECT id, name, height FROM all_car_owners WHERE height = 152;

--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
SELECT DISTINCT sex, 
MAX(driving_experience) OVER(PARTITION BY sex) AS max_driving_experience
FROM car_owners;

--25. Оконные функции для устранения дублей
DROP TABLE IF EXISTS dupl_test_table;
CREATE TABLE dupl_test_table (
    id   SERIAL, 
    name VARCHAR NOT NULL,
    city VARCHAR NOT NULL
);

INSERT INTO dupl_test_table (id, name, city)
        VALUES (0, 'Leo', 'Moscow'), 
        (1, 'Mia', 'London'), 
        (2, 'Sara', 'New-York'), 
        (3, 'Sara', 'New-York'), 
        (4, 'Mary', 'London'),
        (5, 'Leo', 'Moscow');

DELETE FROM dupl_test_table *
WHERE id IN
    (SELECT id
    FROM
        (SELECT
            id, 
            ROW_NUMBER() OVER (PARTITION BY name, city
            ORDER BY name, city) rown
            FROM dupl_test_table) t
        WHERE t.rown > 1 );

SELECT * FROM dupl_test_table;
