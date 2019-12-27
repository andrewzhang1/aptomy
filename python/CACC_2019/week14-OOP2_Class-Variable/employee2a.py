
#  Python Objected-Oriented Programming 2 - Class Variable

# Script name: employee2a.py

'''
1. Why class variable is a better use case?

'''

class Employee:

    # 1. We can think this is a construtor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, but we stick with "self"

    range_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

        Employee.num_of_emps += 1

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    # Why this failed?
    def apply_raise(self):
        self.pay = int(self.pay * range_amount)


# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

#emp_1.raise_amount = 1.05

#print(Employee.raise_amount)

print(emp_1.pay)
emp_1.apply_raise()
print(emp_1.pay)


# Why this failed?