'''
Python Objected-Oriented Programming 2 - Class Variable
Script name: employee2a.py

Note: Access instance variable

'''

class Employee:
    num_of_emps = 0
    raise_amount = 1.06

    # 1. We can think this is a constructor
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

        # This will cause error: "NameError: name 'raise_amount' is not defined":
        # self.pay = int(self.pay * raise_amount)

        # This one works as well:
        self.pay = int(self.pay * self.raise_amount)

        # ? Why this class variable can be accesd by the instance variable?
        # See employee2a.py

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'User', 60000)

'''
When we try to access an attribute on an instance, it will first check if the instance contains that 
attribut, if it doesn't, then it will see of the class or any class inheritate from.  
'''
# print(Employee.raise_amount)
# print(emp_1.raise_amount)
# emp_1.apply_raise()
# print(emp_1.pay)

print(emp_1.__dict__)

# Output
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 50000, 'email': 'Andrew.Zhang@company.com'}