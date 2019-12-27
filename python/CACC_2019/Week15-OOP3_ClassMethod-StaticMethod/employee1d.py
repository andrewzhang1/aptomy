
#  Python Objected-Oriented Programming 3 - Class Method and Static Method

# Script name: employee1d.py
'''
Use class method as alternative constructors:
1.Added:
   @classmethod
    def set_raise_amta(cls, amount):

2. Added:
    @classmethod
    def from_string(cls, emp_str):

'''
class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    # 1. We can think this is a construtor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, but we stick with "self"

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        # self.pay = int(self.pay * Employee.raise_amount)

        # 2. Also we can ccess through instance variable
        self.pay = int(self.pay * self.raise_amount)

    @classmethod
    def set_raise_amta(cls, amount):
        # Now we can work with class variable and class method
        cls.raise_amount = amount

    # Created a constructor
    @classmethod
    def from_string(cls, emp_str):
        first, last, pay = emp_str.split('-')
        return cls(first, last, pay)

# emp_1 = Employee('Andrew', 'Zhang', 50000)
# emp_2 = Employee('Test', 'User', 60000)

# Use class method as alternative constructors - use these class methods in order to
# provide multiple ways of creating our obejects
# Use Case:
# We had someone who is using our employee class where I'm getting employee information
# in the form of a string that is seperated by "-" and I'm constantly needing to parse the string
# before I create new employees so there's a way to just pass in a string and create an employee
# from there.

emp_str_1 = 'John-Doe-70000'
emp_str_2 = 'Jason-Doe-30000'
emp_str_3 = 'Jane-Zhang-90000'

# In order not to parse these string everytime when create a new class method "from_string"
new_emp_1= Employee.from_string(emp_str_1)
print(new_emp_1.email)
print(new_emp_1.pay)

new_emp_2 = Employee.from_string(emp_str_2)
print(new_emp_2.email)
print(new_emp_2.pay)

# Output:
#
# John.Doe@company.com
# 70000
# Jason.Doe@company.com
# 30000