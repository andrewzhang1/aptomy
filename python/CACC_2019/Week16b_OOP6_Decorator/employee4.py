"""
Python Objected-Oriented Programming

Script name: employee1.py - Decorator

Note: What about after changed the first or last, automatically update the email?
     1. We can use get and set (like java)
     2. In python, we can use "Property Decorator" that allows us to define a method but we access it like an attribute
        (after we added @property before "def eamil(self):" ==> Like Get method
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

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('John', 'Smith')

emp_1.first = 'Jim'
print(emp_1.first)
print(emp_1.email)
print(emp_1.fullname)

# Output:
# Jim
# Jim Smith.email.com
# Jim Smith
