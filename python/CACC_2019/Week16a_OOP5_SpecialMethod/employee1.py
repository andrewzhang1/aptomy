"""
Python Objected-Oriented Programming

Script name: employee1.py - Special method + method overloading

https://stackoverflow.com/questions/1436703/difference-between-str-and-repr:

Implement __repr__ for any class you implement. This should be second nature. Implement __str__ if
 you think it would be useful to have a string version which errs on the side of readability.

The default implementation is useless (it’s hard to think of one which wouldn’t be, but yeah)
__repr__ goal is to be unambiguous
__str__ goal is to be readable
Container’s __str__ uses contained objects’ __repr__
"""
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

    def __repr__(self):
        return "Employee('{}', '{}', '{}')".format(self.first, self.last, self.last, self.pay)

    def __str__(self):
         return '{} - {}'.format(self.fullname(), self.email)

    # def __add__(self, other):
    #     return self.pay + other.pay

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'Employee', 50000)

# If we print the following, it just got <__main__.Employee object at 0x000001B782357708>
#print(emp_1)

# Use special method, we can get more informative info:
# print(repr(emp_1))
# print(str(emp_1))
# # Will print out
# Employee('Andrew', 'Zhang', 'Zhang')
# Andrew Zhang - Andrew.Zhang@company.com

print(emp_1.__repr__())
print(emp_1.__str__())
# # Will print out
# Employee('Andrew', 'Zhang', 'Zhang')
# Andrew Zhang - Andrew.Zhang@company.com

# check this out for arithmatics :
print(1+2)
print(int.__add__(1, 2))
print(str.__add__('a', 'b'))

print(emp_1 + emp_2)
# Print out:
# 3
# 3
# ab