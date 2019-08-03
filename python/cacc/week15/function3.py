import random

def display(message):
    print(message)

    return message

def give_random_number():
    value = random.randint(60, 100)
    return value


def answer_question(question):
    response = None
    while response != 'y'and response != 'n':
        response = input(question).lower()
    return response

def answer_question2(question='please type y or n'):
    response = None
    while response != 'y'and response != 'n':
        response = input(question).lower()
    return response

def give_random_number2(low=0, high=100, message="here is the number"):
    value = random.randint(low, high)
    print(message + " " + str(value) )
#    print(message + value)
    return  value

# display("print something")
# value = give_random_number()
# print(value)
# print("The ramdom value is:", value)
#

# This especailly useful when to use
#print(answer_question("Do you like python? "))

#print((display("Hi")))

# different ways to call thg fuction with and w/o arguments:



# 1.
give_random_number2()
# 2.
give_random_number2(100, 1000)
# 3.
give_random_number2(100, 1000, "new message here")

# This does not work
#give_random_number2("new message here")

# 4. This works
give_random_number2(high=300, message="new message here")
