
#  Python Objected-Oriented Programming 2 - Class Variable

# Script name: employee3c.py
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

        # 2. Access through instance variable
        self.pay = int(self.pay * self.raise_amount)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

# Set raise_amount using instance
emp_1.raise_amount = 1.05

print(emp_1.__dict__)

print(Employee.raise_amount)
print(emp_1.raise_amount)  # Why only this changed to 1.05?
print(emp_2.raise_amount)

# Output:
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 50000, 'email': 'Andrew.Zhang@company.com', 'raise_amount': 1.05}
# 1.04
# 1.05
# 1.04
