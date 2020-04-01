
#  Python Objected-Oriented Programming

# Script name: employee1.py

'''
New:
Class Variable: variable that are shared among all instances of a class, while instance variables can be unique for each
instance like name, email, and pay.

Note: this program works,  but there's something wrong here:
1. You have to update the amount for the pay_raise
2. When you update a data, you might have to update in a few places.
3. What if we don't want manually update the 4 %, see the next program: employee2.py

'''

# A class is a blueprint for creating instances.

class Employee:
    # 1. We can think this is a constructor
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
        self.pay = int(self.pay * 1.04)
        #self.pay = self.pay * 1.04

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)
emp_3 = Employee('Test', 'User', 60000)

print(emp_1.pay)
emp_1.apply_raise()
emp_1.apply_raise()  # note the rate changed.
print(emp_1.pay)

# output:

# 50000
# 52000