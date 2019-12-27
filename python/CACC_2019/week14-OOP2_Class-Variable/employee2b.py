
#  Python Objected-Oriented Programming 2 - Class Variable

# Script name: employee2b.py

'''
1. Why class variable is a better use case?

Class Variable: variables that are shared among all instances of a class
while instance variable can be unqiue for each instance like our names  and emails
 and pay, class variables should be the same for each instance.

Let's say we like to our company gives annual raised every year, now the
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

        Employee.num_of_emps += 1

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        # 1. Access through class variable
        self.pay = int(self.pay * Employee.raise_amount)

        # 2. Access through instance variable
        #self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

print(emp_1.pay)
emp_1.apply_raise()
print(emp_1.pay)

'''
Output:
50000
52000
'''