#!/usr/bin/env python
"""
Another inheritance example, using the previous examples
by importing the old code.  This one implements __call__,
__str__, and __del__ and a class attribute."""

import sys
if __name__ == '__main__':
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))
import lab_14_OOP.lab14_3 as employee_def   
import lab_14_OOP.greeter5_def as greeter_def 
     
class Welcomer(greeter_def.NamedGreeter, employee_def.SalariedEmployee):
    """Inherits from Salaried Employee"""
    welcomers = 0

    def __init__(self, name):
        Welcomer.welcomers += 1
        employee_def.SalariedEmployee.__init__(self, name)

    def __call__(self, something): 
        print something, "yourself!"

    def __del__(self):
        Welcomer.welcomers -= 1
        print self.name, 'says "Oh no!"'

    def __str__(self):
        return self.name

def main():
    joe = Welcomer('Joe')
    joe.Greet()
    joe.SetSalary(20000)
    print joe, "here's $%.2f for you. " % joe.CalculatePay(80)
    marsha = Welcomer('Marsha')
    marsha.SetSalary(19500)
    marsha('Get to work')
    print marsha, "here's $%.2f for you. " % marsha.CalculatePay(80)
    print 'There are %d welcomers.' % Welcomer.welcomers
    joe('Goodbye')
    print 'Deleting Joe'
    del joe
    print 'There are %d welcomers.' % Welcomer.welcomers
    marsha.Greet()

if __name__ == '__main__':
    main()
"""
$ welcomer_def.py
Hello World
I'm Joe
Joe here's $30769.23 for you. 
Get to work yourself!
Marsha here's $30000.00 for you. 
There are 2 welcomers.
Goodbye yourself!
Deleting Joe
Joe says "Oh no!"
There are 1 welcomers.
Hello World
I'm Marsha
Marsha says "Oh no!"
$ 
"""
