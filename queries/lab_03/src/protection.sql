-- вывести средний стаж по модели машины
CREATE OR REPLACE PROCEDURE prGetAvgDExperienceByModel(defined_model_id int)
AS $$
    DECLARE
    avg_dr_experience int;
    cnt_car_owners int;
    BEGIN
    SELECT sum(driving_experience), count(*)
    FROM car_owners co JOIN cars c ON c.owner_id = co.id
    GROUP BY model_id
    HAVING COUNT(model_id) = (select count(*)
                                from cars 
                                where cars.model_id = defined_model_id
                                group by model_id)

    INTO avg_dr_experience, cnt_car_owners;

    avg_dr_experience = avg_dr_experience / cnt_car_owners;
    RAISE NOTICE 'Model_id: % avg_dr_experience: %', defined_model_id, avg_dr_experience;

    END;
$$ LANGUAGE PLPGSQL;

CALL prGetAngDExperienceByModel(249); 