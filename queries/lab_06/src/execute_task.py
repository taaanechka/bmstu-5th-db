from tkinter import *
from tkinter import messagebox as mb


def create_list_box(rows, title, count=15):
    root = Tk()

    root.title(title)
    root.resizable(width=False, height=False)

    size = (count + 3) * len(rows[0]) + 1

    list_box = Listbox(root, width=size, height=22,
                       font="monospace 10", bg="pale turquoise", highlightcolor='pale turquoise', selectbackground='#59405c', fg="#59405c")

    list_box.insert(END, "--" * size)

    for row in rows:
        string = (("| {:^" + str(count) + "} ") * len(row)).format(*row) + '|'
        list_box.insert(END, string)

    
    list_box.insert(END, "--" * size)

    list_box.grid(row=0, column=0)

    root.configure(bg="pale turquoise")

    root.mainloop()


def execute_task1(pwin, cur, clr_entry):
    clr = clr_entry.get()

    if clr == "":
        mb.showerror(title="Ошибка", message="Введите строку!")
        return


    pwin.destroy()

    cur.execute(" \
        SELECT count(*) \
        FROM cars \
        WHERE colour= %s \
        GROUP BY colour", (clr,))

    row = cur.fetchone()
    res = row[0] if (row is not None) else 0

    mb.showinfo(title="Результат",
                message=f"Кол-во автомобилей цвета {clr} составляет: {res}")


def execute_task4(pwin, cur, table_name, con):
    table_name = table_name.get()

    try:
        cur.execute(f"SELECT * FROM {table_name}")
    except:
        # Откатываемся.
        con.rollback()
        mb.showerror(title="Ошибка", message="Такой таблицы нет!")
        return

    pwin.destroy()

    rows = [(elem[0],) for elem in cur.description]

    create_list_box(rows, "Задание 4", 17)


def execute_task6(pwin, cur, co_name_entry):

    co_name = co_name_entry.get()

    pwin.destroy()

    # fn_get_owner_cars - Подставляемая табличная функция.
    cur.execute("SELECT * FROM fn_get_owner_cars(%s);", (co_name,))

    rows = cur.fetchall()

    if rows:
        create_list_box(rows, "Задание 6", 17)
    else:
        mb.showerror(title="Ошибка", message="Такой автовладелец отсутвует в базе!")


def execute_task7(pwin, cur, param, con):
    try:
        aim_id = int(param[0].get())
        delta = int(param[1].get())
    except Exception as e:
        print(str(e))
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    if aim_id < 0 or aim_id > 1000:
        mb.showerror(title="Ошибка", message="Неподходящие значения!")
        return

    pwin.destroy()

    # Выполняем запрос.
    try:
        cur.execute("CALL pr_change_dexperience(%s, %s);", (aim_id, delta))
    except Exception as e:
        print(str(e))
        mb.showerror(title="Ошибка", message="Некорректный запрос!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    # Т.е. посылаем команду в бд.
    # Метод commit() помогает нам применить изменения,
    # которые мы внесли в базу данных,
    # и эти изменения не могут быть отменены,
    # если commit() выполнится успешно.
    con.commit()

    mb.showinfo(title="Информация!", message="Опыт вождения автовладельца изменен!")


def execute_task10(pwin, cur, param, con):
    try:
        owner_id = int(param[0].get())
        car_id = param[1].get()
        reason = param[2].get()
        fine_date = param[3].get()
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    print(owner_id, car_id, reason)

    pwin.destroy()

    cur.execute(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='fines'")

    if not cur.fetchone():
        mb.showerror(title="Ошибка", message="Таблица не создана!")
        return

    try:
        cur.execute("INSERT INTO fines(owner_id, car_id, reason, fine_date) VALUES(%s, %s, %s, %s)",
                    (owner_id, car_id, reason, fine_date))
    except:
        mb.showerror(title="Ошибка!", message="Ошибка запроса!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()

    mb.showinfo(title="Информация!", message="Нарушитель добавлен!")