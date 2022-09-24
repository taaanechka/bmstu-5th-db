\c dbcourse;

-- 4) Выполнить следующие действия:
-- Извлечь JSON фрагмент из JSON документа.
SELECT jsdata->'education' education FROM context;


-- Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT jsdata->'education'->'university' university FROM context;


-- Выполнить проверку существования узла или атрибута.
CREATE OR REPLACE FUNCTION fn_if_key_exists(json_to_check jsonb, key text)
RETURNS BOOLEAN 
AS $$
BEGIN
    RETURN (json_to_check->key) IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
SELECT fn_if_key_exists('{"name": "Tatiana", "age": 19}', 'education');
SELECT fn_if_key_exists('{"name": "Tatiana", "age": 19}', 'name');


-- Изменить JSON документ.
UPDATE context SET jsdata = jsdata || '{"age": 21}'::jsonb WHERE (jsdata->'age')::INT = 20;


-- Разделить JSON документ на несколько строк по узлам.
SELECT * FROM jsonb_array_elements('[
    {"name": "Tatiana", "age": 19, "education": {"university": "BMSTU", "graduation_year": 2023}}, 
    {"name": "Maria", "age": 21, "education": {"university": "BMSTU", "graduation_year": 2023}},
    {"name": "Gregory", "age": 21, "education": {"university": "BMSTU", "graduation_year": 2023}},
    {"name": "Vladimir", "age": 21, "education": {"university": "BMSTU", "graduation_year": 2023}}
]');