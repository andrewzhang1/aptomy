#
# OOP1_Employee.py
# Python OOP Tutorial 3: classmethods and staticmethods - YouTube
# https://www.youtube.com/watch?v=rq8cL2XMM5M

# Topic: classmethods and staticmethods

# We can also use classmethods as constractors


class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + '.' + last + '@company.com'

        Employee.num_of_emps += 1


    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)

    @classmethod
    def set_raise_amt(cls, amount):
        cls.raise_amount = amount

#    @staticmethod
    #def set_raise_amt2():

emp1 = Employee("Andrew", "Zhang", 5000)
emp2 = Employee("Jasson", "Zhang", 4000)


print(emp1.raise_amount)

Employee.set_raise_amt(1.05)
print(Employee.raise_amount)

print(emp2.raise_amount)
