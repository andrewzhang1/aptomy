#!/usr/bin/env python 
"""mod1.py  You can use ->   from module import *
   to bring all the attributes into your local namespace.
   But this is usually considered to be bad practice.
   You lose track of which attributes are local and are
   not local.  And, here's another problem.
"""
   
x = 1   
y = [1,2,3]    

def Printx():
    print x
    
def Printy():
    print y
"""
>>> from mod1 import *


>>> Printx()
1
>>> x = 2
>>> Printx()    <-- gets mod1 version
1
>>> print x     <-- gets local version
2


>>> Printy()
[1, 2, 3]
>>> y[1] = 'a'  <-- a list is mutable!
>>> y
[1, 'a', 3]     <-- local version
>>> Printy()
[1, 'a', 3]     <-- mod1 version
>>> 














You can import certain attributes:

>>> from mod1 import Printx, Printy
>>> Printx()
1
>>> mod1.x = 3
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
NameError: name 'mod1' is not defined


>>> import mod1
>>> mod1.x = 3
>>> Printx()
3
>>> mod1.Printx()
3
>>> """
