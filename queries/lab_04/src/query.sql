\c dbcourse;

CREATE EXTENSION IF NOT EXISTS plpython3u;

-- 1) Определяемая пользователем скалярная функция CLR.
-- Возвращает полный возраст (число лет, месяцев, дней)
DROP FUNCTION IF EXISTS fn_get_age_py;
CREATE OR REPLACE FUNCTION fn_get_age_py(birth_d date)
    RETURNS smallint
AS $$
    from datetime import datetime
    from dateutil import parser
    from dateutil.relativedelta import relativedelta
    
    b_date = parser.parse(birth_d) # в питоне дата хранится в другом виде

    now_t = datetime.utcnow()
    now_t = now_t.date()

    age = relativedelta(now_t, b_date)
    age = age.years

    return age
$$ LANGUAGE PLPYTHON3U;

SELECT *, fn_get_age_py(birth_date) AS owner_age
FROM car_owners
WHERE id > 950;


-- 2) Пользовательская агрегатная функция CLR.
-- Возвращает средний возраст автовладельцев (число лет)
DROP FUNCTION IF EXISTS fn_get_avg_age_py;
CREATE OR REPLACE FUNCTION fn_get_avg_age_py()
    RETURNS DECIMAL
AS $$
    query = "select fn_get_age_py(birth_date) from car_owners;"
    result = plpy.execute(query)
    qsum = 0
    qlen = len(result)

    for x in result:
        qsum += x["fn_get_age_py"]

    return qsum / qlen
$$ LANGUAGE PLPYTHON3U;

SELECT fn_get_avg_age_py() as avg_age;


-- 3) Определяемая пользователем табличная функция CLR.
-- Возвращает все автомобили, принадлежащие указанному владельцу 
CREATE OR REPLACE FUNCTION fn_get_owner_cars_py(ownr_name varchar)
RETURNS TABLE (
    owner_name varchar,
    car_number varchar,
    colour varchar
) AS $$
    query = f"SELECT co.name coname, c.car_number cnumb, c.colour cclr FROM cars c JOIN car_owners co on c.owner_id = co.id WHERE co.name = '{ownr_name}';"
    result = plpy.execute(query)
    for x in result:
        yield(x["coname"], x["cnumb"], x["cclr"])
$$ LANGUAGE PLPYTHON3U;

SELECT * FROM fn_get_owner_cars_py('Trevor Brooks');

-- 4) Хранимая процедура CLR.
-- Изменить опыт вождения на delta указанного владельца автомобиля
CREATE OR REPLACE PROCEDURE pr_change_dr_experience_py(aim_id int, delta int)
AS $$
    plan = plpy.prepare(
        "UPDATE car_owners SET driving_experience = driving_experience + $2 WHERE id = $1;",
        ["INT", "INT"]
    )
    plpy.execute(plan, [aim_id, delta])
$$ LANGUAGE PLPYTHON3U;

CALL pr_change_dr_experience_py(45, 2);
SELECT id, name, driving_experience
FROM car_owners WHERE id = 45;


-- 5) Триггер CLR.
-- Классифицирует водителя по его опыту вождения
CREATE OR REPLACE FUNCTION fn_get_dr_experience_py()
RETURNS TRIGGER
AS $$
    if TD["new"]["driving_experience"] > 8:
        plpy.notice(f"{TD['new']['name']} has a high driving experience (tr_LR_04).")
    else:
        plpy.notice(f"{TD['new']['name']} has a low driving experience (tr_LR_04).")
$$ LANGUAGE PLPYTHON3U;

CREATE TRIGGER tr_dr_experience_classification_py AFTER INSERT ON car_owners
FOR ROW EXECUTE PROCEDURE fn_get_dr_experience_py();

INSERT INTO car_owners (id, name, sex, height, driving_experience, birth_date)
VALUES (1001, 'Maria Swan', 'f', 170, 10, '1994-07-21');

DELETE FROM car_owners WHERE name = 'Maria Swan';


-- 6) Определяемый пользователем тип данных CLR.
DROP TYPE dr_experience_tuple CASCADE;
CREATE TYPE dr_experience_tuple AS (
    name    VARCHAR,
    driving_experience INT
);

CREATE OR REPLACE FUNCTION fn_set_name_dr_exp_py(nm VARCHAR, dr_exp DECIMAL)
RETURNS SETOF dr_experience_tuple
AS $$
    return ([nm, dr_exp],)
$$ LANGUAGE PLPYTHON3U;

SELECT * FROM fn_set_name_dr_exp_py('Make Brawn', 10);
