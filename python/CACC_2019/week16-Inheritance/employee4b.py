
#  Python Objected-Oriented Programming - Inheritance

# Script name: employeeb.py -
#
# Change  the Developer class

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

# Create subclass: manager and developer by changing the pay rate
class Developer(Employee):
    # pass
    raise_amount = 1.10

dev_1 = Developer('Andrew', 'Zhang', 50000)

# If we change back to the Employee class, the pay raise still will be 4%:
# Changing the raise_amount in the subclass would affect the employee # instances
# dev_1 = Employee('Andrew', 'Zhang', 50000)

dev_1 = Developer('Andrew', 'Zhang', 50000)
#dev_1 = Employee('Andrew', 'Zhang', 50000)
dev_2 = Developer('Eric', 'Employee', 60000)

# print(dev_1.email)
# print(dev_2.email)

print(dev_1.pay)
dev_1.apply_raise()  # See the rate is changed by applying 1.10
print(dev_1.pay)
print(dev_1.fullname())

# 50000
# 55000
# Andrew Zhang

