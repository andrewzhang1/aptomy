"""
Python Objected-Oriented Programming

Script name: employee1.py - Decorator

"""
class Employee:

    raise_amount = 1.04
    def __init__(self, first, last):
        self.first = first
        self.last = last
        self.email = first + "." + last + '@company.com'

    def fullname(self):
        return '{} {}'.format(self.first, self.last)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('John', 'Smith')

print(emp_1.first)
print(emp_1.email)
print(emp_1.fullname())

# Output:
# John
# John.Smith@company.com
# John Smith