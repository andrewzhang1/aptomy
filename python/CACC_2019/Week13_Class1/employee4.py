
#  Python Objected-Oriented Programming

# Script name: employee4.py
'''
1. Create a specical method: __init__()
2. Create some attributes for the employee
3. Add some action with a method
'''

class Employee:

    # 1. We can think this is a constructor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, bu we stick with "self"

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.email = first + "." + last + '@company.com'

    def fullname(self):
    #def fullname():

        # What is we don't put "self" here?
        # return '{} {}'.format(self.first, self.last)
        return '{} {}'.format(self.first, self.last)
        print("Full name is: ", self.first, self.last)

# Each employee is an unique instance variable of the Employee class
# empl_1 will be passed in as self and then it will set all of those attributes

emp_1 = Employee('Andrew', "Zhang", 6000)
emp_2 = Employee('Test', 'User', 6500)


print("Show the difference for calling the class vs ")

print(emp_1.fullname())
'''
1. this an instance calls a method; it does not need to pass "self", it automatically call the method
2. When we run from the class,we manually pass in the instance as an argument, here the "emp_1"
3. When we run "emp_1.fullname()" 
'''

print(Employee.fullname(emp_1))


# 1. One thing we want the ability to display the email.
#print (emp_1.fullname())

# 2. How to place above action as a method in the class? Create a new method: fullname!
#print (emp_1.fullname()) # Here

# 3. We can call the method directly from the class, but we need to pass the parameter:
# print(Employee.fullname(emp_1))
#print(emp_2.fullname())

# Output:
# Andrew.Zhang@company.com
# Test.User@company.com
# Andrew Zhang
# Andrew Zhang
# Test User

# If we don't have "self" for the method fullname(): it will give errors:
# Traceback (most recent call last):
# Andrew.Zhang@company.com
#   File "C:/AGZ1/aptomy/python/CACC_2019/Week13_Class1/employee4.py", line 48, in <module>
# Test.User@company.com
#     print (emp_1.fullname())
# TypeError: fullname() takes 0 positional arguments but 1 was given
