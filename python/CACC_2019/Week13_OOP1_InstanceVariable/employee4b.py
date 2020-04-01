'''
Python Objected-Oriented Programming
Script name: employee4b.py
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

#print(Employee)  # Just print a memory address
#emp_1 = Employee('Andrew', "Zhang", 6000)
#emp_2 = Employee('Test', 'User', 6500)

#print(Employee.fullname(emp_1))

print(Employee.fullname('Andrew', "Zhang", 6000))


''' Output:
Traceback (most recent call last):
  File "C:/AGZ1/aptomy/python/CACC_2019/Week13_OOP1_InstanceVariable/employee4b.py", line 28, in <module>
    print(Employee.fullname('Andrew', "Zhang", 6000))
TypeError: fullname() takes 1 positional argument but 3 were given

'''
