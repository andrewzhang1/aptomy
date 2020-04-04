"""
Python Objected-Oriented Programming

Script name: employee1.py - Decorator

Note: What about after changed the first or last, automatically update the email?
     1. We can use get and set (like java)
     2. In python, we can use "Property Decorator" that allows us to define a method but we access it like an attribute
"""
class Employee:

    raise_amount = 1.04
    def __init__(self, first, last):
        self.first = first
        self.last = last
      #  self.email = first + "." + last + '@company.com'

    # Add this
    def email(self):
        return '{} {}.email.com'.format(self.first, self.last)

    def fullname(self):
        return '{} {}'.format(self.first, self.last)

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('John', 'Smith')

emp_1.first = 'Jim'
print(emp_1.first)
print(emp_1.email)  # This one will show: "<bound method Employee.email of <__main__.Employee object at 0x0000026A5F8B7708>>"
print(emp_1.email())  # However, anyone using our class would have to change their code also, which is not good!
print(emp_1.fullname())

# Output:
# Jim
# <bound method Employee.email of <__main__.Employee object at 0x0000018BD9857708>>
# Jim Smith.email.com
# Jim Smith

