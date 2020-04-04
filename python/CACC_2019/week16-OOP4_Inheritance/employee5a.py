
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee5a.py - Change the Developer class by adding
# more attributes by passing a programing languages

class Employee:

    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)

# Create subclass: manager and developer by changing the pay rate
class Developer(Employee):
    raise_amount = 1.10

    def __init__(self, first, last, pay, prog_lang):
        super().__init__(first, last, pay) # This is a better way to do! This pass first, last, pay to our Employee
                                           # init method, and let that class handle those arguments
        #Employee.__init__(self, first, last, pay)  # Or someine prefer doing this!
        self.prog_lang = prog_lang

dev_1 = Developer('Andrew', 'Zhang', 50000, 'python')
dev_2 = Developer('Eric', 'Employee', 60000, 'java')

print(dev_1.email)
print(dev_1.prog_lang)


# Output:
# Andrew.Zhang@company.com
# python

# We can see that the subclass is usefull because we were able to customize
# just a little bit of code and we got all the part from the employee class
# for free just by adding in that one little lines.