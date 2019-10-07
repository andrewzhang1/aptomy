#!/usr/bin/env python
"""mod3.py  __all__ specifies identifiers for export"""

__all__ = ['Printx', 'Printy']  

x = 1        
y = [1, 2, 3]  

def Printx():  
    print x
    
def Printy():
    print y

"""

>>> from mod3 import *
>>> dir()
['__builtins__', '__doc__', '__name__', 'Printx', 'Printy']

>>> from mod3 import x
>>> x
1
>>> from mod3 import y
>>> y
[1, 2, 3]
>>> y[1] = 'hey'
>>> Printy()
[1, 'hey', 3]
>>> 


Another SAMPLE RUN:
>>> import mod3 as other
>>> other.x = 88
>>> other.Printx()
88
>>> 
"""
