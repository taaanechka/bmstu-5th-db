from faker import Faker
from datetime import datetime
from dateutil.relativedelta import relativedelta
from random import randint
from random import uniform
from random import choice

MAX_N = 1000


def generate_owners():
    sex = ['m', 'f']
    min_driner_age = 16

    faker = Faker()

    f = open('car_owner.csv', 'w')

    for i in range(MAX_N):
        #age = randint(min_driner_age, 111)
        birth_date = faker.date_of_birth() # minimum_age=0, maximum_age=115
        cur_date = datetime.now().date()
        age = relativedelta(cur_date, birth_date).years
        h = randint(150, 210)
        temp = 0 if int(age - min_driner_age) < 0 else (age - min_driner_age)
        driving_experience = randint(0, temp)
        line = "{0},{1},{2},{3},{4},{5}\n".format(
                                                    i + 1,
                                                    faker.name(),
                                                    choice(sex),
                                                    #age,
                                                    h,
                                                    driving_experience,
                                                    birth_date)
                                                    #faker.date_of_birth())
        f.write(line)

    f.close()


def generate_colours():
    faker = Faker()

    f = open("colours.csv", 'w')

    for i in range(MAX_N):
        line = "{0}\n".format(faker.color_name())
        f.write(line)

    f.close()

def generate_brands():
    wheel = ['left', 'right']
    faker = Faker()

    f = open("brands.csv", 'w')

    fr = open('brands_list.txt', 'r')
    lines = []

    for line in fr:
        lines.append(line[:-1])

    fr.close()

    linesLen = len(lines)

    for i in range(MAX_N):
        line = "{0},{1},{2},{3}\n".format(
                                        i + 1,
                                        choice(lines), #lines[randint(0, linesLen - 1)],
                                        faker.country_code(), #country()
                                        choice(wheel))
        
        f.write(line)

    f.close()
    #fr.close()


def generate_models():
    gearbox = ['automatic', 'mechanical']
    engine = ['gasoline', 'diesel', 'electric']
    model = ['sedan', 'SUV', 'minivan', 'pickup', 'van', 'cabriolet']

    f = open("models.csv", 'w')

    for i in range(MAX_N):
        line = "{0},{1},{2},{3},{4},{5}\n".format(
                                                    i + 1,
                                                    randint(1, MAX_N),
                                                    #name
                                                    choice(model),
                                                    choice(engine),
                                                    choice(gearbox),
                                                    randint(2, 6))
        f.write(line)                                    

    f.close()


def generate_cars():
    #cars
    gear = ['front-wheel', 'rear', 'four-wheel']
    roof = ['covered', 'glazed', 'reclining']

    faker = Faker()

    f = open("cars.csv", 'w')

    for i in range(MAX_N):
        line = "{0},{1},{2},{3},{4},{5}\n".format(
                                                    faker.unique.license_plate(),
                                                    #faker.license_plate(),
                                                    randint(1, MAX_N),
                                                    randint(1, MAX_N),
                                                    choice(gear),
                                                    faker.color_name(),
                                                    choice(roof))
        f.write(line)                                    

    f.close()


if __name__ == "__main__":
    #generate_cars()
    generate_owners()
    #generate_colours()
    #generate_brands()
    #generate_models()