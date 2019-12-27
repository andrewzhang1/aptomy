# Script name: employee3a.py

'''
1. Show why we can access from both class variable and instance variable
'''

class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

        Employee.num_of_emps += 1

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        # self.pay = int(self.pay * Employee.raise_amount)

        # 2. Access through instance variable
        self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

# We can see that we can access this class variable from both my class and the instance.
# Let's see the namespace to see what's going here:

print(emp_1.__dict__)

# Output:
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 50000, 'email': 'Andrew.Zhang@company.com'}

# We don't see the "raise_amount"

print(Employee.__dict__)

# Outout:
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 50000, 'email': 'Andrew.Zhang@company.com'}
# {'__module__': '__main__', 'num_of_emps': 2, 'raise_amount': 1.04, '__init__': <function Employee.__init__ at 0x0000018F925B90D8>, \
# 'fullname': <function Employee.fullname at 0x0000018F925C59D8>, 'apply_raise': <function Employee.apply_raise at 0x0000018F925C5828>,
# '__dict__': <attribute '__dict__' of 'Employee' objects>, '__weakref__': <attribute '__weakref__' of 'Employee' objects>, '__doc__': None}

# We do see "raise_amount" in the class contains this attribute and that's the value for our instance!
