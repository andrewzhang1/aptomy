#  Python Objected-Oriented Programming
# Script name: employee4.py
'''
1. Create a specical method: __init__()
2. Use self
'''

class Employee:
    # 1. We can think this is a constructor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, but we stick with "self"
    def __init__(self, first, last):
        self.first = first
        self.last = last
        self.email = first + "." + last + '@company.com'

# Each employee is an unique instance variable of the Employee class
# empl_1 will be passed in as self and then it will set all of those attributes

# print(Employee('Andrew','Zhang')) # This one just prints:  <__main__.Employee object at 0x00000294EFFF07C8>

emp_1 = Employee('Andrew','Zhang')
print(emp_1.email)
print(emp_1.last)

# print(emp_1.first, emp_1.last)
#
# emp_2 = Employee("Test", 'User')
# print(emp_2.email)
#
# print(Employee('Andrew','Zhang')) ## this one won't work
# print(emp_2.first, emp_2.last)