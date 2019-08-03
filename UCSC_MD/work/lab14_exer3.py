

from __future__ import division


class Employee:
    def __init__( self, name):
        self.name = name

    def PrintName( self):
        print self.name,

class SalariedEmployee( Employee):
    def __init__( self, name):
        Employee.__init__( self, name)

    def SetSalary( self, salary):
        self.salary = salary

    def GiveRaise( self, percent):
        self.salary *= (100 + percent)/100

    def CalculatePay( self, weeks):
        return (self.salary/52) * weeks

class ContractEmployee( Employee):
    def __init__( self, name):
        Employee.__init__( self, name)

    def SetRate( self, rate):
        self.rate = rate

    def GiveRaise( self, percent):
        self.rate *= (100 + percent)/100

    def CalculatePay( self, weeks):
        return (self.rate*40) * weeks


if __name__ == '__main__':
    joe = SalariedEmployee( 'Joe')
    joe.SetSalary( 52000)
    joe.PrintName()
    print "here's $%.2f for you." % joe.CalculatePay( 1)
    joe.GiveRaise( 2)
    joe.PrintName()
    print "here's $%.2f for you." % joe.CalculatePay( 2)
    print

    sue = ContractEmployee( 'Sue')
    sue.SetRate( 100)
    sue.PrintName()
    print "here's $%.2f for you." % sue.CalculatePay( 1)
    sue.GiveRaise( 2)
    sue.PrintName()
    print "here's $%.2f for you." % sue.CalculatePay( 2)
    print


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab14_exer3.py ===========
Joe here's $1000.00 for you.
Joe here's $2040.00 for you.

Sue here's $4000.00 for you.
Sue here's $8160.00 for you.

>>> 
"""
