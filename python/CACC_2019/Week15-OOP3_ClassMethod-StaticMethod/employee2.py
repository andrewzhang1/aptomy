
#  Python Objected-Oriented Programming 3 - Class Method and Static Method

# Script name: employee2.py
'''
This program show how to use class method to find the working day.
'''

class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    # 1. We can think this is a construtor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, but we stick with "self"

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        # self.pay = int(self.pay * Employee.raise_amount)

        # 2. Also we can ccess through instance variable
        self.pay = int(self.pay * self.raise_amount)
    @classmethod
    def set_raise_amta(cls, amount):
        # Now we can work with class variable and class method
        cls.raise_amount = amount
    # Created a constructor
    @classmethod
    def from_string(cls, emp_str):
        first, last, pay = emp_str.split('-')
        return cls(first, last, pay)

    @staticmethod
    def is_workday(day):
        if day.weekday() == 5 or day.weekday() == 6:
            return False
        return True

emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

import datetime
my_date = datetime.date(2019, 12, 9)
print(Employee.is_workday(my_date))

# Output:
# True