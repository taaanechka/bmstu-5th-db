\c dbcourse;

-- 3) Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.
DROP TABLE IF EXISTS context;
CREATE TABLE context (
    jsdata jsonb
);
INSERT INTO context(jsdata) VALUES 
('{"name": "Tatiana", "age": 19, "education": {"university": "BMSTU", "graduation_year": 2023}}'), 
('{"name": "Maria", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2023}}'),
('{"name": "Gregory", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2023}}'),
('{"name": "Vladimir", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2023}}');

-- посмотреть результат: открыть через клиента