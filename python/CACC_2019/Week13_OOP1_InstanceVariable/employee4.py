'''
Python Objected-Oriented Programming
Script name: employee4.py
Note: One common mistake: Easy to forget "self" argument for the instance when create
     a method (see: employee4a.py)
'''

class Employee:
    # 1. We can think this is a constructor
    # 2. By convention, we call this the instance "self" for now
    #    and you can call it whatever you want, bu we stick with "self"
    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
        self.pay = int(self.pay * 1.04)
        return '{} {} {}'.format(self.first, self.last, self.pay)

print(Employee)  # Just print a memory address

emp_1 = Employee('Andrew', "Zhang", 6000)
emp_2 = Employee('Test', 'User', 6500)

# Run1
print(emp_1.fullname())

# Run2
print(Employee.fullname(emp_1))

'''
# run1 and Run2 get exactly the same result,  but:
Run1:   The instance calls a method, which doesn't need to pass in self, it does automatically;
        it gets transformed into this here Employee dot fullname "Employee.fullname(emp_1)" and
        passes in "emp_1" as "self" and that's why we have self for these methods. 

Run2: when we call a method on the class, it doesn't know what instance that we want to run that method,
so we have to pass in the instance and that gets passed in as "self"

output:
=========
<class '__main__.Employee'>
Andrew Zhang 6240
Andrew Zhang 6489

'''
