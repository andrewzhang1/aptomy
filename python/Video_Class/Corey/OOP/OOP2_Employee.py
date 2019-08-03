#
# OOP1_Employee.py
# Python OOP Tutorial 2: Class Variables - YouTube
# https://www.youtube.com/watch?v=BJ-VvGyQxho

# Topic: Class Variables vs instance variables


class Employee:
    num_of_emps = 0
    raise_amount = 1.04

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + '.' + last + '@company.com'

        Employee.num_of_emps += 1


    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)


print(Employee.num_of_emps)

emp1 = Employee("Andrew", "Zhang", 5000)
emp2 = Employee("Jasson", "Zhang", 4000)

print(Employee.num_of_emps)


#print(emp1.__dict__)
# {'first': 'Andrew', 'last': 'Zhang', 'pay': 5000, 'email': 'Andrew.Zhang@company.com'}

#print(Employee.__dict__)
# {'__module__': '__main__', 'raise_amount': 1.04, '__init__': <function Employee.__init__ at 0x000001973F383E18>,
# 'fullname': <function Employee.fullname at 0x000001973F383D90>, 'apply_raise': <function Employee.apply_raise
# at 0x000001973F39F1E0>, '__dict__': <attribute '__dict__' of 'Employee' objects>, '__weakref__':
# <attribute '__weakref__' of 'Employee' objects>, '__doc__': None}

Employee.raise_amount = 1.05  # This the class raise amount
emp1.raise_amount = 1.06 # This is the instance raise amount

print(Employee.raise_amount)
print(emp1.raise_amount)
print(emp2.raise_amount)

print(emp1.__dict__)








