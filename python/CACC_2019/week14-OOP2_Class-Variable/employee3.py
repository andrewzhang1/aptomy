'''
 Python Objected-Oriented Programming 2 - Class Variable
# Script name: employee3.py

Note: This case show why it doesn't make sense to use "self"
Say we want to keep track the number of employee.

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
        # self.pay = int(self.pay * Employee.raise_amount)

        # 2. Access through instance variable
        self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all of those attributes
print(Employee.num_of_emps)
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)
emp_3 = Employee('Test3', 'User', 60000)

print(emp_1.num_of_emps)
print(Employee.num_of_emps)
print(emp_2.num_of_emps)