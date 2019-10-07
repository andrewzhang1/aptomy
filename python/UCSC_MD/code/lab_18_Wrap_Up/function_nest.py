#!/usr/bin/env python
"""function_nest.py Adapted from 'Learning Python'
by Mark Lutz & Davis Ascher"""  

x = 11
def F1():
    x = 99              # <- Visible in the nest but not outside
    def F2():
        def F3():
            print x     # <- Can see outside namespaces
            y = 4       # <- Not visible from outside.
        F3()
    F2()

if __name__ == '__main__':
    F1()
"""!
$ python -i function_nest.py
99
>>> F2()
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
NameError: name 'F2' is not defined
>>> F1.x
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
AttributeError: 'function' object has no attribute 'x'
>>> 
"""
