"""
Python Objected-Oriented Programming

Script name: employee1.py - Decorator

Note: What about after changed the first or last, automatically update the email?
     1. We can use get and set (like java)
     2. In python, we can use "Property Decorator" that allows us to define a method but we access it like an attribute
        (after we added @property before "def eamil(self):" ==> Like Get method

     say we want to do:
     emp_1 = Employee('John', 'Smith')
     emp_1.fullname = 'Andrew Zhang'

     This program will get error!

     3. Add setter method:
     @fullname.setter

     4. What about we want to delete the fullname of our employee

"""
class Employee:

    raise_amount = 1.04
    def __init__(self, first, last):
        self.first = first
        self.last = last
      #  self.email = first + "." + last + '@company.com'

    # Add this
    @property
    def email(self):
        return '{} {}.email.com'.format(self.first, self.last)

    @property
    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    @fullname.setter
    def fullname(self, name):
        first, last = name.split(' ')
        self.first = first
        self.last = last

    @fullname.deleter
    def fullname(self):
        print('Delete Name!')
        self.first = None
        self.last = None

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('John', 'Smith')
emp_1.fullname = 'Andrew Zhang'

print(emp_1.first)
print(emp_1.email)
print(emp_1.fullname)

del emp_1.fullname
# Output:
# Traceback (most recent call last):
#   File "C:/AGZ1/aptomy/python/CACC_2019/Week16b_OOP6_Decorator/employee5.py", line 35, in <module>
#     emp_1.fullname = 'Andrew Zhang'
# AttributeError: can't set attribute
