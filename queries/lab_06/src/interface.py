from tasks import *

from tkinter import *

root = Tk()


def info_show():
    global root
    info = Toplevel(root)
    info_txt = "Условия заданий \n\n\
    1. Выполнить скалярный запрос.\n \
    2. Выполнить запрос с несколькими соединениями (JOIN).\n\
    3.Выполнить запрос с ОТВ (CTE) и оконными функциями.\n\
    4. Выполнить запрос к метаданным.\n\
    5. Вызвать скалярную функцию (написанную в 3-ей \n лабораторной работе).\n\
    6. Вызвать многооператорную или табличную функцию \n (написанную в 3-ей лабораторной работе).\n\
    7. Вызвать хранимую процедуру (написанную в 3-ей \n лабораторной работе). \n\
    8. Вызвать системную функцию или процедуру. \n\
    9. Создать таблицу в базе данных, соответствующую \n тематике БД. \n\
    10. Выполнить вставку данных в созданную таблицу \n с использованием инструкции INSERT или COPY."

    label1 = Label(info, text=info_txt, font="TimesNewRoman 12", bg="light blue")
    label1.pack()

def form(cur, con):
    global root

    w_width = 800
    w_height = 400

    #helv16 = Font(family="Helvetica",size=16,weight="bold")

    root.title('Лабораторная работа №6')
    root.geometry(f"{w_width}x{w_height}") #root.geometry("1200x800")
    x = (root.winfo_screenwidth() - w_width) / 2
    y = (root.winfo_screenheight() - w_height) / 2
    root.wm_geometry("+%d+%d" % (x, y))
    root.configure(bg="sky blue") #root.configure(bg="lavender")  #aquamarine
    root.resizable(width=False, height=False)

    main_menu = Menu(root)
    root.configure(menu=main_menu)

    third_item = Menu(main_menu, tearoff=0)
    main_menu.add_cascade(label="Техническое задание",
                          menu=third_item, font="Verdana 10")

    third_item.add_command(label="Показать",
                           command=info_show, font="Verdana 12")

    tasks = [task1, task2, task3, task4, task5,
             task6, task7, task8, task9, task10]

    for (index, i) in enumerate(range(30, 380, 70)):
        button = Button(text="Задание " + str(index + 1), width=35, height=2,
                        command=lambda a=index: tasks[a](cur, con),  bg="steel blue", font = "TimesNewRoman 10") #dark turquoise #slate blue
        button.place(x=70, y=i)

        button = Button(text="Задание " + str(index + 6), width=35, height=2,
                        command=lambda a=index + 5: tasks[a](cur, con),  bg="steel blue", font = "TimesNewRoman 10") #thistle3
        button.place(x=440, y=i)  # anchor="center")


    root.mainloop()
