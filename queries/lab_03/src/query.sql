\c dbcourse

-- 1) Скалярная функция
-- возвращает полный возраст (число лет, месяцев, дней)
DROP FUNCTION fnGetAge;
CREATE OR REPLACE FUNCTION fnGetAge(birth_d date)
    RETURNS interval AS $$
    BEGIN
        RETURN age(birth_d);
    END;
$$ LANGUAGE PLPGSQL;

SELECT *, fnGetAge(birth_date) AS owner_age
FROM car_owners
WHERE id > 950


-- 2)Подставляемая табличная функция
-- Возвращает таблицу вида (имя, пол, опыт_вождения)
-- с опытом вождения меньше указанного и указанным полом
CREATE TABLE typedtbl(
    name varchar,
    sex char,
    driv_exp int
);

CREATE OR REPLACE FUNCTION fnGetLowDExperience(_tbl_type ANYELEMENT, defined_driv_exp integer, defined_sex char)
    RETURNS SETOF ANYELEMENT
AS $$
    BEGIN
    RETURN QUERY
    EXECUTE
    'SELECT co.name, co.sex, co.driving_experience
    FROM car_owners co
    WHERE  co.driving_experience < $1 AND co.sex = $2'
    USING defined_driv_exp, defined_sex;
    END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM fnGetLowDExperience(NULL::typedtbl, 5, 'f');


-- 3) Многооператорная табличная функция
-- Возвращает все автомобили, принадлежащие указанному владельцу (ownr)
CREATE OR REPLACE FUNCTION fnGetOwnerCars(ownr varchar)
RETURNS TABLE (
    owner_name varchar,
    car_number varchar,
    colour varchar
) AS $$
BEGIN 
    CREATE TEMP TABLE tbl (
        owner_name varchar,
        car_number varchar,
        colour varchar
    );
    INSERT INTO tbl(owner_name, car_number, colour)
    SELECT ownr, c.car_number, c.colour
    FROM cars c JOIN car_owners co on c.owner_id = co.id
    WHERE co.name = $1;
    RETURN QUERY
    SELECT * FROM tbl;
END;
$$ LANGUAGE PLPGSQL;
SELECT * FROM fnGetOwnerCars('Trevor Brooks');

-- 4)Рекурсивная функция
-- Можно ли с автовладельца CO1 добраться до автовладельца с ростом h 
-- не более чем за N шагов
DROP FUNCTION fnGetRequiredCarOwner;
CREATE OR REPLACE FUNCTION fnGetRequiredCarOwner(car_owner_1 varchar, h int, N int)
RETURNS TABLE (
    id int,
    name varchar,
    height int
) AS $$
BEGIN 
    RETURN QUERY
    WITH RECURSIVE all_car_owners (id, name, height) AS (
    SELECT car_owners.id, car_owners.name, car_owners.height, 0 AS level 
    FROM car_owners WHERE car_owners.name = car_owner_1
    UNION ALL
    SELECT co.id, co.name, co.height, level + 1 
    FROM car_owners co
    JOIN all_car_owners aco ON co.id = aco.id + 1 AND level < N
    )
    SELECT aco.id, aco.name, aco.height 
    FROM all_car_owners aco WHERE aco.height = h;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM fnGetRequiredCarOwner('Brian Cox', 152, 5);


-- 5)Хранимая процедура с параметрами
-- Изменить опыт вождения на delta указанного владельца автомобиля
CREATE OR REPLACE PROCEDURE prChangeDrivingExperience(aim_id int, delta int)
AS $$
BEGIN
    UPDATE car_owners
    SET driving_experience = driving_experience + delta
    WHERE id = aim_id;
    COMMIT;
END;
$$ LANGUAGE PLPGSQL;

CALL prChangeDrivingExperience(45, 2);
SELECT id, name, driving_experience
FROM car_owners WHERE id = 45;


-- 6)Рекурсивная хранимая процедура
-- Выводит сообщение с именем автовладельца из списка, на котором мы сейчас остановились,
-- совершает поиск ближайшего предыдущего по списку автовладельца-мужчины
-- или останавливается ранее, если оказываемся в начале списка.
CREATE OR REPLACE PROCEDURE prFindPreviousMan(current_name varchar)
AS $$
DECLARE
    cur_id int;
    cur_name varchar;
    cur_sex char;
BEGIN
    SELECT co.sex FROM car_owners co WHERE co.name = $1 
    INTO cur_sex;
    SELECT co.id FROM car_owners co WHERE co.name = $1 
    INTO cur_id;
    SELECT co.name FROM car_owners co WHERE co.name = $1 
    INTO cur_name;

    IF cur_sex = 'm' OR cur_id = 1 THEN
        RAISE NOTICE 'You are now at %s. You have reached the goal!', cur_name;
    ELSE
        RAISE NOTICE 'You are now at %s. Continue searching!', cur_name;
        SELECT co.name FROM car_owners co WHERE co.id = cur_id - 1
        INTO cur_name;
        CALL prFindPreviousMan(cur_name);
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CALL prFindPreviousMan('Jennifer Warren');


-- 7)Хранимая процедура с курсором
-- Выводит всех автовладельцев-мужчин с датой рождения > заданной
CREATE OR REPLACE PROCEDURE prFetchCarOwnersByBrthDate(defined_sex char, defined_brth date)
AS $$
DECLARE 
    rec_list record;
    list_cur CURSOR FOR
        SELECT * FROM car_owners co
        WHERE co.name IS NOT NULL AND co.sex = defined_sex AND co.birth_date > defined_brth 
        AND co.id > 980;
BEGIN
    OPEN list_cur;
    LOOP
        FETCH list_cur INTO rec_list;
        RAISE NOTICE '% is % and birth date is %!', rec_list.name, defined_sex, rec_list.birth_date;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE list_cur;
END;
$$ LANGUAGE PLPGSQL;

CALL prFetchCarOwnersByBrthDate('m', '2002-12-30');



-- 8)Хранимая процедура доступа к метаданным
-- Выводит имя, ID и максимальное число параллельных соединений
-- по имени БД.
CREATE OR REPLACE PROCEDURE prGetDBMetadata(dbname varchar)
AS $$
DECLARE
    dbid int;
    dbconnlimit int;
BEGIN
    SELECT pg.oid, pg.datconnlimit FROM pg_database pg WHERE pg.datname = dbname
    INTO dbid, dbconnlimit;
    RAISE NOTICE 'DB: %, ID: %, CONNECTION LIMIT: %', dbname, dbid, dbconnlimit;
END;
$$ LANGUAGE PLPGSQL;

CALL prGetDBMetadata('dbcourse');


-- 9)Триггер AFTER
-- Классифицирует водителя по его опыту вождения
CREATE OR REPLACE FUNCTION prGetDExperience()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.driving_experience > 8 THEN
        RAISE NOTICE '% has a high driving experience.', NEW.name;
    ELSE
        RAISE NOTICE '% has a low driving experience.', NEW.name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER carOwnersDExperienceClassification AFTER INSERT ON car_owners
FOR ROW EXECUTE PROCEDURE prGetDExperience();

INSERT INTO car_owners (id, name, sex, height, driving_experience, birth_date)
VALUES (1001, 'Mary Swan', 'f', 170, 10, '1994-07-21');

DELETE FROM car_owners WHERE name = 'Mary Swan';



-- 10)Триггер INSTEAD OF
-- Добавляет автовладельца в базу, если у него меньше 3 машин
DROP FUNCTION fnInsertCarOwner CASCADE;
DROP VIEW carownersview;

CREATE OR REPLACE FUNCTION fnInsertCarOwner()
RETURNS TRIGGER
AS $$
DECLARE
    cars_cnt int;
    car_owner_name varchar;
BEGIN
    SELECT co.name, COUNT(*) 
    FROM car_owners co JOIN cars c on c.owner_id = co.id
    WHERE co.id = NEW.id
    GROUP BY c.owner_id, co.name
    INTO car_owner_name, cars_cnt;

    IF cars_cnt > 3 THEN
        RAISE EXCEPTION '% already have more than 3 cars. Aborting.', car_owner_name;
        RETURN NULL;
    ELSE
        IF cars_cnt = 0 THEN
        RAISE EXCEPTION '% has no cars.', car_owner_name;
        ELSE
            RAISE NOTICE '% cars left for %', 3 - cars_cnt, car_owner_name;
            INSERT INTO car_owners (
                id,
                name,
                sex,
                height,
                driving_experience,
                birth_date
            )
            VALUES (
                NEW.id,
                NEW.name,
                NEW.sex,
                NEW.height,
                NEW.driving_experience,
                NEW.birth_date
            );
        END IF;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE VIEW carownersview AS
SELECT * FROM car_owners LIMIT 10;

CREATE TRIGGER carOwnersInsertion INSTEAD OF INSERT ON carownersview
FOR EACH ROW EXECUTE PROCEDURE fnInsertCarOwner();

INSERT INTO carownersview (
    id,
    name,
    sex,
    height,
    driving_experience,
    birth_date
)
VALUES (
    2130,
    'Tanya S',
    'f',
    165,
    0,
    '2001-11-18'
);
DELETE FROM car_owners WHERE id = 2130;

