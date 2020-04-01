
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee2.py - Inherit an empty class

class Employee:

    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all
# of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)

print(emp_1.email)

# Create subclass: manager and developer

print("\nAfter creating Developer class: \n")
class DeveloperA():
    pass

class Developer(Employee):
    pass

dev_1 = Developer('Andrew', 'Zhang', 50000)
#dev_2 = Developer('Eric', 'Employee', 60000)

print(dev_1.email)
#print(dev_2.email)

# We will see that the two developers created successfully and we can
# access the attributes that were actually set in our parent Employee class.

# Outout:
# Andrew.Zhang@company.com
#
# After creating Developer class:
#
# Andrew.Zhang@company.com
# Eric.Employee@company.com

