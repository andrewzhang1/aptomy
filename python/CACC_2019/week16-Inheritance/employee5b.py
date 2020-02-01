
#  Python Objected-Oriented Programming - Inheritance

# Script name: employee5b.py - Create a new class: "Magager"
# (gives a empllyee list that the manger supervise.

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
    # pass
    raise_amount = 1.10

    def __init__(self, first, last, pay, prog_lang):
        super().__init__(first, last, pay) # This is a better to do!
        # Employee.__init__(self, first, last, pay)
        self.prog_lang = prog_lang

class Manager(Employee):

    def __init__(self, first, last, pay, employees=None):
        super().__init__(first, last, pay) # This is a better to do!
        # Employee.__init__(self, first, last, pay)
        if employees is None:
            self.employees = []
        else:
            self.employees = employees

    def add_emp(self, emp):
        if emp not in self.employees:
            self.employees.append(emp)

    def remove_emp(self, emp):
        if emp in self.employees:
            self.employees.remove(emp)

    def print_emps(self):
        for emp in self.employees:
            print('-->', emp.fullname())

dev_1 = Developer('Andrew', 'Zhang', 50000, 'python')
dev_2 = Developer('Eric', 'Employee', 60000, 'java')

mrg_1 = Manager('Jane', 'Smith', 90000, [dev_1])


print(mrg_1.email)
mrg_1.print_emps()



# Output:
# Jane.Smith@company.com
# --> Andrew Zhang

