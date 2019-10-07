#!/usr/bin/env python
"""lab16_2.py A Money class"""
import sys
if __name__ == '__main__': 
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))

import lab_08_Comprehensions.lab08_4 as make_money_string

class Money(float):

    def __add__(self, other):
        return Money(float.__add__(self, other))

    def __div__(self, number):
        return Money(float.__div__(self, number))

    def __rmul__(self, number):
        return Money(float.__mul__(self, number))

    def __mul__(self, number):
        return Money(float.__mul__(self, number))

    def __neg__(self):
        return Money(float.__neg__(self))

    def __repr__(self):
        return """Money('%f')""" % self
    
    def __str__(self):
        return make_money_string.MakeMoneyString(self)

    def __sub__(self, other):
        return Money(float.__sub__(self, other))

def main():
    print Money(-123.21)
    print Money(40.50)
    print Money(-1001.011)
    print Money(123456789.999)
    print Money(.10)
    print Money(.01)
    print Money(.055)
    print 'add:', Money(10) + Money(20), '==', Money(30)
    print 'repr:', eval(repr(Money(44.123))), '==', Money(44.123)
    print 'sub:', Money(44.333) - Money(55.444), '==', Money(-11.111)
    print 'neg:', -Money(10.00), '==', Money(-10.00)
    print 'mult:', 2 * Money(-11.11), '==', Money(-22.22), \
          '==', Money(11.11) * -2
    print 'div:', (Money(44.44))/4, '==', Money(11.11)

if __name__ == '__main__':
    main()

"""
$ lab16_2.py
-$123.21
$40.50
-$1,001.01
$123,456,790.00
$0.10
$0.01
$0.06
add: $30.00 == $30.00
repr: $44.12 == $44.12
sub: -$11.11 == -$11.11
neg: -$10.00 == -$10.00
mult: -$22.22 == -$22.22 == -$22.22
div: $11.11 == $11.11
$ """
