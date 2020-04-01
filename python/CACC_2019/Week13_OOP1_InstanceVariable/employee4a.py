'''
Python Objected-Oriented Programming
Script name: employee4a.py
Note: One common mistake: Easy to forget "self" argument for the instance when create
     a method
'''

class Employee:
    # 1. We can think this is a constructor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, bu we stick with "self"
    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

print(Employee)

emp_2 = Employee('Test', 'User', 6500)

print(emp_2.fullname())

# Traceback (most recent call last):
#   File "C:/AGZ1/aptomy/python/CACC_2019/Week13_OOP1_InstanceVariable/employee4a.py", line 21, in <module>
#     print(emp_2.fullname())
# TypeError: fullname() takes 0 positional arguments but 1 was given
# <class '__main__.Employee'>
#
# Process finished with exit code 1

