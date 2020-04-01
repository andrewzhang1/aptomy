
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee3.py -
# Use help() function to visualize what is going on ...
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

print(emp_1.email)
# Create subclass: manager and developer
print("\nAfter creating Developer class: \n")

class Developer(Employee):
    pass

dev_1 = Developer('Andrew', 'Zhang', 50000)
dev_2 = Developer('Eric', 'Employee', 60000)

print(help(Developer))


# After creating Developer class:
#
# Help on class Developer in module __main__:
#
# class Developer(Employee)
#  |  Developer(first, last, pay)
#  |
#  |  Method resolution order:
#  |      Developer
#  |      Employee
#  |      builtins.object
#  |
#  |  Methods inherited from Employee:
#  |
#  |  __init__(self, first, last, pay)
#  |      Initialize self.  See help(type(self)) for accurate signature.
#  |
#  |  apply_raise(self)
#  |
#  |  fullname(self)
#  |
#  |  ----------------------------------------------------------------------
#  |  Data descriptors inherited from Employee:
#  |
#  |  __dict__
#  |      dictionary for instance variables (if defined)
#  |
#  |  __weakref__
#  |      list of weak references to the object (if defined)
#  |
#  |  ----------------------------------------------------------------------
#  |  Data and other attributes inherited from Employee:
#  |
#  |  raise_amount = 1.04
#
#
#

