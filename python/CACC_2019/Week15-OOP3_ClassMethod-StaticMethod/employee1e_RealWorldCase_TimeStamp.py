'''
Python Objected-Oriented Programming 3 - Class Method and Static Method
Script name: employee1e_RealWorldCase_TimeStamp.py

1. Added one more real life case:
    @classmethod
    def fromtimestamp(cls, t):
        "Construcotr a data from a POSIX time stamp (like time.time()"
        y, m, d, hh, m, ss, weekday, jday, dst = _time.locationtime(t)
        return cls(y,m,d)
==> this one not working yet
'''
class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + "." + last + '@company.com'

    def fullname(self):
    #def fullname():
        return '{} {} {}'.format(self.first, self.last, self.pay)

    def apply_raise(self):
        # self.pay = int(self.pay * Employee.raise_amount)

        # 2. Also we can ccess through instance variable
        self.pay = int(self.pay * self.raise_amount)

    @classmethod
    def set_raise_amta(cls, amount):
        # Now we can work with class variable and class method
        cls.raise_amount = amount

    # Addtional constructors
    @classmethod
    def fromtimestamp(cls, t):
        #Construcotr a data from a POSIX time stamp (like time.time()
        y, m, d, hh, mm, ss, weekday, jday, dst = _time.locationtime(t)
        return cls(y, m, d)

    @classmethod
    def today(cls):
        #Construct a date from time.time()
        t = _time.time()
        return cls.fromtimestamp(t)

    @classmethod
    def fromordinal(cls, n):
        """Construct a date from a proleptic Gregorian ordinal
        Jan 1 of year
        pass
"""
    # Created a constructor
    @classmethod
    def from_string(cls, emp_str):
        first, last, pay = emp_str.split('-')
        return cls(first, last, pay)


emp_str_1 = 'John-Doe-70000'
emp_str_2 = 'Jason-Doe-30000'
emp_str_3 = 'Jane-Zhang-90000'

# In order not to parse these string everytime when create a new class method "from_string"
new_emp_1= Employee.from_string(emp_str_1)
print(new_emp_1.email)
print(new_emp_1.pay)

new_emp_2 = Employee.from_string(emp_str_2)
print(new_emp_2.email)
print(new_emp_2.pay)

# Output:
#
# John.Doe@company.com
# 70000
# Jason.Doe@company.com
# 30000

