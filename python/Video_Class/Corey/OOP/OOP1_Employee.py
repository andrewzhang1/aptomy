# (1) Python OOP Tutorial 1: Classes and Instances - YouTube
# https://www.youtube.com/watch?v=ZDa-Z5JzLYM&t=2s

class Employee:

    '''
    DocString: this is a new class

    '''
    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + '.' + last + '@company.com'
    def fullname(self):
        return '{} {}'.format(self.first, self.last)

print ("\nOld:\n")

emp1 = Employee("Andrew", "Zhang", 5000)
emp2 = Employee("Jasson", "Zhang", 4000)

print(emp1.email)
print("emp1 pay: ", emp1.pay)

print(emp2.first)
print('{} {}'.format(emp1.first, emp1.last))
print(emp1.first, emp1.last)

print ("\nNew:\n")
print(emp1.fullname())

print(emp2.fullname())

print(Employee.fullname(emp1))

# Old way before created methods
# emp1.first = "Andrew"
# emp1.last = "Zhang"
# print(emp1.first + " " + emp1.last)
#
# emp2.first = "Jason"
# emp2.last = "Zhang"

# print(emp2.first + " " + emp2.last)
