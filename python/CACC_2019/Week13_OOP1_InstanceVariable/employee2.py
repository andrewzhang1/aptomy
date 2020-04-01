#  Python Objected-Oriented Programming

# Script name: employee2.py

# A class is a blueprint for creating instances.

class Employee:
    pass


# Each employee is an unique instance variable of the Employee class
emp_1 = Employee()
emp_2 = Employee()

print(emp_1)
print(emp_2)

# 1. Instance Variable: contains data that is unique to each instance
emp_1.first = "Andrew"
emp_1.last = "Zhang"
emp_1.email = "andrew.zhang@company.com"
emp_1.pay = 6000


emp_2.first = "Test"
emp_2.last = "User"
emp_2.email = "Test.User@company.com"
emp_2.pay = 6500

print(emp_1.email)
print(emp_2.email)
print(emp_2.pay)

# We don't get much benefit of using classes if we did above way

# output:
# <__main__.Employee object at 0x000001E2572D2348>
# <__main__.Employee object at 0x000001E2572D2588>
# andrew.zhang@company.com
# 6500

