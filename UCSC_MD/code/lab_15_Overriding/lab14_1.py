#!/usr/bin/env python
"""lab14_1.py Predict the output:"""

class X:  

    def __init__(self):
        self.x = 1

    def Which(self):
        print "X"

class A(X):

    def __init__(self):
        X.__init__(self)
        self.y = 2

class Y:

    def __init__(self):
        self.z = 3

    def Which(self):
        print "Y"

class B(Y):

    def __init__(self):
        Y.__init__(self) 
        self.x = 4
        
class AB(A, B):
    pass

class BA(B, A):
    pass

ab = AB()
ba = BA()








"""python -i lab14_1.py
>>> ab.x
1
>>> ab.y
2
>>> ab.z
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
AttributeError: AB instance has no attribute 'z'
>>> ab.Which()
X
>>> ba.x
4
>>> ba.y
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
AttributeError: BA instance has no attribute 'y'
>>> ba.z
3
>>> ba.Which()
Y
>>>"""
