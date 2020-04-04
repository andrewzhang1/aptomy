"""
Python Objected-Oriented Programming

Script name: employee1.py - Special method + method overloading

https://stackoverflow.com/questions/1436703/difference-between-str-and-repr:

Other special method

"""
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

    def __repr__(self):
        return "Employee('{}', '{}', '{}')".format(self.first, self.last, self.last, self.pay)

    def __str__(self):
         return '{} - {}'.format(self.fullname(), self.email)

    # def __add__(self, other):
    #     return self.pay + other.pay

    # With this, we car run "print(len(emp_2))"
    def __len__(self):
        return len(self.fullname())

# empl_1 will be passed in as self and then it will set all of those attributes
emp_1 = Employee('Andrew', 'Zhang', 50000)
emp_2 = Employee('Test', 'Employee', 50000)

print(len('test'))      # 4
print('test'.__len__()) # 4  We can created this __len__ special method:

print(len(emp_2))  # 13