#!/usr/bin/env python
"""lab14_3.py  Implement this inheritance tree:

     Employee
        name

     SalariedEmployee   --> Inherits from Employee
        Has a yearly salary.

     ContractEmployee   --> Inherits from Employee
        Has an hourly rate
"""
from __future__ import division
import sys   

class Employee:
    """Employee class, should only be instantiated in a subclass"""

    def __init__(self, name):
        self.name = name

    def GiveRaise(self, percent):
        """percent is the percent raise, where 100 doubles
        the pay rate."""
        
        percent /= 100.0
        self.pay_rate *= 1 + percent

    def PrintName(self):
        print self.name,

    def SetPayRate(self, pay_rate):
        """The pay period is in the sub-class"""
        try:
            self.pay_rate = float(pay_rate)
        except ValueError:
            print >> sys.stderr, 'The rate must be a number.'

class SalariedEmployee(Employee):
    """pay_rate is the yearly salary.  A pay period is 1 week."""
    
    def CalculatePay(self, weeks):
        try:
            return self.pay_rate * weeks/52
        except ValueError:
            print 'How many weeks?'
        except AttributeError:
            print 'You must SetPayRate first'

    def SetSalary(self, amt):
        Employee.SetPayRate(self, amt)

class ContractEmployee(Employee):
    """pay_rate is hourly pay.  A pay period is 1 hour."""
    
    def CalculatePay(self, hours):
        try:
            return self.pay_rate * hours
        except ValueError:
            print >> sys.stderr, 'How man hours?'
        except AttributeError:
            print >> sys.stderr, 'You must SetPayRate first'
        sys.exit(1)

def main():
    joe = SalariedEmployee('Joe')
    joe.SetSalary(52000)
    joe.PrintName()
    print "here's $%.2f for you. " % joe.CalculatePay(1) 
    joe.GiveRaise(2)    
    joe.PrintName()
    print "here's $%.2f for you. " % joe.CalculatePay(2) 

    susan = ContractEmployee('Susan')
    susan.PrintName()
    susan.SetPayRate(100)
    print "here's $%.2f for you. " % susan.CalculatePay(80) 
    susan.GiveRaise(2)     
    susan.PrintName()
    print "here's $%.2f for you. " % susan.CalculatePay(80)

    fred = Employee('Fred')  
    fred.SetPayRate(100)
    try:
        fred.CalculatePay(20) # Crash! No CalculatePay for Employee
    except AttributeError:
        pass

if __name__ == '__main__':
    main()

"""
$ lab14_3.py
Joe here's $1000.00 for you. 
Joe here's $2040.00 for you. 
Susan here's $8000.00 for you. 
Susan here's $8160.00 for you. 
$ 
"""

