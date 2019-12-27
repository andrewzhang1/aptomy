
#  Python Objected-Oriented Programming 2 - Class Variable

# Script name: employee3d.py

'''
1. Now we can see the emp1 has the raise_amount within its namespace = 1.05, and
returns that value before going and search the class and we didn't see that amount on employee 2
so that falls back to the class value before going and searching the class and we didn't set that
raise_amount on employee 2: important to know the difference for class and instance
2. We can use self, any self class (sub class to overwrite the values.
3. We can also track the number of employees
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

        # Init method will increment everytime we create a new Employee instance
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
# emp_2 = Employee('Test', 'User', 60000)
# emp_2 = Employee('Test', 'User', 60000)


print(Employee.num_of_emps)

# Output:
# 2
