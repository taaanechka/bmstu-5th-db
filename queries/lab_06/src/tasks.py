from execute_task import *


def task1(cur, con = None):
    root_1 = Tk()

    root_1.title('Задание 1') # вывести количество автомобилей указанного цвета
    root_1.geometry("300x200")
    root_1.configure(bg="pale turquoise")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  Введите цвет автмобиля:", bg="pale turquoise").place(
        x=55, y=50)
    clr_entry = Entry(root_1)
    clr_entry.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=root_1, arg2=cur, arg3=clr_entry: execute_task1(arg1, arg2, arg3),  bg="hot pink", font = "TimesNewRoman 10")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task2(cur, con = None):
    # вывести автовладельцев, имена которых выглядят как '%Sara%'
    cur.execute(" \
    SELECT DISTINCT id, name \
    FROM car_owners JOIN cars ON cars.owner_id = car_owners.id \
    WHERE name LIKE '%Sara%'; ")

    rows = cur.fetchall()
    print(rows)

    create_list_box(rows, "Задание 2")


def task3(cur, con = None):
    # Цвет и количество переднеприводных (front-wheel) автомобилей такого цвета 
    cur.execute("\
    WITH clr_cars (colour, clr_cnt) \
    AS ( \
    SELECT DISTINCT colour, COUNT(*) OVER(PARTITION BY colour) clr_cnt \
    FROM cars \
    WHERE gear = 'front-wheel' \
    ) \
    SELECT * FROM clr_cars \
    ORDER BY colour;")

    rows = cur.fetchall()
    create_list_box(rows, "Задание 3")


def task4(cur, con):

    root_1 = Tk()

    root_1.title('Задание 4') # вывести поля указанной таблицы
    root_1.geometry("300x200")
    root_1.configure(bg="pale turquoise")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="Введите название таблицы:", bg="pale turquoise").place(
        x=65, y=50)
    name = Entry(root_1)
    name.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=root_1, arg2=cur, arg3=name: execute_task4(arg1, arg2, arg3, con),  bg="hot pink", font = "TimesNewRoman 10")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task5(cur, con = None):
    # вывести имя и возраст(с помощью функции) автовладельцев, где id > 950
    cur.execute("SELECT name, fn_get_age(birth_date) AS age FROM car_owners \
        WHERE id > 950;")

    rows = cur.fetchall()
    #print(rows)
    create_list_box(rows, "Задание 5")


def task6(cur, con = None):
    root = Tk()

    root.title('Задание 6') # Вывести автомобили указанного владельца
    root.geometry("300x200")
    root.configure(bg="pale turquoise")
    root.resizable(width=False, height=False)

    Label(root, text="Введите имя автовладельца:", bg="pale turquoise").place(
        x=75, y=50)
    name_entry = Entry(root) # Trevor Brooks
    name_entry.place(x=75, y=85, width=150)

    b = Button(root, text="Выполнить",
               command=lambda arg1=root, arg2=cur, arg3=name_entry: execute_task6(arg1, arg2, arg3),  bg="hot pink", font = "TimesNewRoman 10")
    b.place(x=75, y=120, width=150)

    root.mainloop()


def task7(cur, con=None):
    root = Tk()

    root.title('Задание 7')
    root.geometry("300x300")
    root.configure(bg="pale turquoise")
    root.resizable(width=False, height=False)

    names = ["owner_id",
             "delta"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="pale turquoise").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=70, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task7(root, cur, param, con),  bg="hot pink", font = "TimesNewRoman 10")
    b.place(x=70, y=200, width=150)

    root.mainloop()


def task8(cur, con = None):
    # Информация:
    # https://postgrespro.ru/docs/postgrespro/10/functions-info
    cur.execute(
        "SELECT current_database(), current_user;")
    current_database, current_user = cur.fetchone()
    mb.showinfo(title="Информация",
                message=f"Имя текущей базы данных:\n{current_database}\nИмя пользователя:\n{current_user}")


def task9(cur, con):
    cur.execute(" \
        DROP TABLE IF EXISTS fines;\
        CREATE TABLE fines \
        ( \
            owner_id INT, \
            FOREIGN KEY(owner_id) REFERENCES car_owners(id), \
            car_id VARCHAR, \
            FOREIGN KEY(car_id) REFERENCES cars(car_number), \
            reason VARCHAR, \
            fine_date DATE\
        ) ;")

    con.commit()

    mb.showinfo(title="Информация",
                message="Таблица успешно создана!")


def task10(cur, con):
    root = Tk()

    root.title('Задание 10')
    root.geometry("400x400")
    root.configure(bg="pale turquoise")
    root.resizable(width=False, height=False)

    names = ["owner_id",
             "car_number",
             "reason",
             "fine_date"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="pale turquoise").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=115, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task10(root, cur, param, con),  bg="hot pink", font = "TimesNewRoman 10")
    b.place(x=115, y=270, width=150)

    root.mainloop()

# def task11(cur, con):
#     # доп: человек с самым низким опытом, имеющий хотя бы 2 машины
#     cur.execute("SELECT name, driving_experience FROM car_owners \
#         WHERE driving_experience = min(SELECT driving_experience \
#                                         FROM car_owners co JOIN cars ON car.owner_id = car_owners.id \
#                                         GROUP BY co.id \
#                                         HAVING count(*) > 1)\
#             ;")

#     rows = cur.fetchall()