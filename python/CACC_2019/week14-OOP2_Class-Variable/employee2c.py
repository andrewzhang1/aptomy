
#  Python Objected-Oriented Programming 2 - Class Variable

'''
Script name: employee2c.py
Note: Introduce an important concept.


1. Why class variable is a better use case?

Class Variable: variables that are shared among all instances of a class
while instance variable can be unique for each instance like our names and emails
and pay, class variables should be the same for each instance.

Let's say we like to our company gives annual raised every year, now we define two
constance variable
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

#print(emp_1.__dict__)
# Output
# Output
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 50000, 'email': 'Andrew.Zhang@company.com'}

print(Employee.__dict__)
#Output:
# {'__module__': '__main__', 'num_of_emps': 2, 'raise_amount': 1.06, '__init__': <function Employee.__init__ at 0x000001FCD4C094C8>,
# 'fullname': <function Employee.fullname at 0x000001FCD4C09D38>, 'apply_raise': <function Employee.apply_raise at 0x000001FCD4D5C0D8>,
# '__dict__': <attribute '__dict__' of 'Employee' objects>, '__weakref__': <attribute '__weakref__' of 'Employee' objects>, '__doc__': None}