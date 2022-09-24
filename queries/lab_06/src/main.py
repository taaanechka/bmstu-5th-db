from interface import *

import psycopg2

# доп: человек с самым низким опытом, имеющий хотя бы 2 машины

def main():
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database="dbcourse", #postgres
            user="stm",
            password="password",
            host="127.0.0.1",  # Адрес сервера базы данных.
            port="5432"		   # Номер порта.
        )
    except:
        print("Ошибка при подключении к БД")
        return

    print("База данных успешно открыта")

    # Объект cursor используется для фактического
    # выполнения наших команд.
    cur = con.cursor()

    # Интерфейс.
    form(cur, con)

    # Закрываем соединение с БД.
    cur.close()
    con.close()
    print("База данных успешно закрыта")



if __name__ == "__main__":
    main()