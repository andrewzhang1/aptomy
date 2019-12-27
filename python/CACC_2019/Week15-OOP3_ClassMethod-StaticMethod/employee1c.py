
#  Python Objected-Oriented Programming 3 - Class Method and Static Method

# Script name: employee1c.py

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

emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

# Now we want to change the payamount to 5 % using class method
Employee.set_raise_amta(1.05)   # Line x: using class method

Employee.raise_amount = 1.05    # Line y: Run class method from instance as well
emp_1.raise_amount = 1.05       # Line z1: Use instance to access class variable - not common in real life
emp_1.set_raise_amta(1.05)      # Line z2: Use instance to access class method - not common in real life.

# Note: Line x and Line y have the same effect! But Line y is not offten used in real life

print(Employee.raise_amount)
print(emp_1.raise_amount)
print(emp_2.raise_amount)

# Output:
#
# 1.05
# 1.05
# 1.05
