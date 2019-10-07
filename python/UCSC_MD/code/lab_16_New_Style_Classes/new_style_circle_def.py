#!/usr/bin/env python
"""A Circle class, derived from the builtin list class.

All the facilities of a list are available for free,
for using or overridding.
"""             
import sys      
if __name__ == '__main__':
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))
from lab_15_Overriding.circle_def import main

class Circle(list):

    def __init__(self, data, times):
        list.__init__(self, data)
        self.times = times

    def __getitem__(self, i):
        """circle[i] --> Circle.__getitem__(circle, i)."""
        l_self = len(self)
        if i >= self.times * l_self:
            raise IndexError, \
                  "Error raised: circle object only goes around %d times"\
                  % self.times
        return list.__getitem__(self, i % l_self)

    def __iter__(self):
        """Because we are inheriting from list, and it has it's own
        __iter__, we need to override it to get all the functionality
        we had before.
        """
        for i in range(self.times * len(self)):
            yield self[i]

def TestList():
    circle = Circle("tic", 3)
    print "Testing list functions:", circle
    circle += 'k'
    print [x for x in circle]
    circle.sort()
    print circle

if __name__ == '__main__':
    main()
    TestList()

"""  
$ new_style_circle_def.py
main() produces the same output.
---
Testing list functions: ['t', 'i', 'c']
['t', 'i', 'c', 't', 'i', 'c', 't', 'i', 'c', 't', 'i', 'c']
['c', 'i', 'k', 't']
$

If we didn't define __iter__ here, the output would have been:

Testing list functions: ['t', 'i', 'c']
['t', 'i', 'c', 'k']
['c', 'i', 'k', 't']

Note: Using super, and in general avoiding hardcoding the literal name
of classes, makes your code more robust against change:

super(object)
   Typical use to call a cooperative superclass method:
   class C(B):
       def meth(self, arg):
           super(C, self).meth(arg)


Note that super returns an object, so you don't need to put 'self'
in the argument list when you make a class using 'super'.
"""
