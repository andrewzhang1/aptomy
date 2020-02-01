
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee4a.py - Show the Developer class is the same as Employee class

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

# Create subclass: manager and developer by changing the pay rate
class Developer(Employee):
    pass

dev_1 = Developer('Andrew', 'Zhang', 50000)
dev_2 = Developer('Eric', 'Employee', 60000)

# print(dev_1.email)
# print(dev_2.email)

print(dev_1.pay)
dev_1.apply_raise()
print(dev_1.pay)

# Output by just apply employee pay raise (developer is an emplopyee)!
# 50000
# 52000

