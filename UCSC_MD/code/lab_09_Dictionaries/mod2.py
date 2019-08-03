#!/usr/bin/env python
"""You can keep your identifiers from being imported with
from ... import * by prefixing a '_' to the name."""

_x = 1    
_y = [1, 2, 3]

def Printx():
    print _x
    
def Printy():
    print _y

"""

>>> from mod2 import *
>>> dir()
['__builtins__', '__doc__', '__name__', 'Printx', 'Printy']

However, if they are asked for explicitly, they come:

>>> from mod2 import _x, _y
>>> dir()
['__builtins__', '__doc__', '__name__', '_x', '_y']
>>> Printx()
1
>>> _x = 33   <-- makes a local _x
>>> Printx()
1

>>> Printy()
[1, 2, 3]
>>> _y[1] = 44 <-- affects mod2's y
>>> Printy()
[1, 44, 3]

>>> import mod2
>>> mod2._x = 8
>>> Printx()
8
>>> 
"""
