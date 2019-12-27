
# Script name: employee1b.py
'''
1. Now we can see the emp1 has the raise_amount within its namespace = 1.05, and
returns that value before going and search the class and we didn't see that amount on employee 2
so that falls back to the class value before going and searching the class and we didn't set that
raise_amount on employee 2: important to know the difference for class and instance
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

emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

# Now we want to change the payamount to 5 % using class method
Employee.set_raise_amta(1.05)   # Line x: using class method

Employee.raise_amount = 1.05    # Line y

# Note: Line x and Line y have the same effect!

print(Employee.raise_amount)
print(emp_1.raise_amount)
print(emp_2.raise_amount)

# Output:
#
# 1.05
# 1.05
# 1.05
