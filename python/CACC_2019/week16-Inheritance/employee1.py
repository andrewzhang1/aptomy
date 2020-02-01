
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee1.py
# Note: A review with the class variabel and instance variable

'''
1. Based on the previous Employee class, we want to be more specific and create
   different types of employee: developers
2. Both developers and managers are employees: they all have names, email address
   and salaries, and thoses are all the things that our employee class already
   has. So instead of copying all these codes into our developer and manafer subclasses
   we can just reuse that code by inheritaing from the employee class.

'''

# Script name: employee1.py, a base class

class Employee:

    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)

print(emp_1.pay)
emp_1.apply_raise()
print(emp_1.pay)
print(emp_1.email)
print(emp_1.fullname())

# Outout:
# 50000
# 52000
# Andrew.Zhang@company.com
