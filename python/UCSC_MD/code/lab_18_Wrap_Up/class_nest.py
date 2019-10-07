#!/usr/bin/env python
"""class_nest.py class nesting scopes in the other direction."""
w = 10   
class C1:   
    x = 99
    class C2:
        y = 100
        class C3:
            z = 101      # <-- Visible from outside
            print w
            print z
            # print C1.x   <-- Can't see outer classes
            # print y          or any outer identifiers
            
if __name__ == '__main__':
    print 'About to initialize:'
    c1 = C1()
"""
$ python -i class_nest.py
10     <------ This output happened when the class was read into
101    <------ the compiler, not when an instance was instantiated.
About to initialize:
>>> dir(c1)
['C2', '__doc__', '__module__', 'x']
>>> c1.C2.C3.z
101
>>> c1.C2.C3.z = [1,2,3]
>>> L = c1.C2.C3.z
>>> L[1] = 'Boo'
>>> c1.C2.C3.z
[1, 'Boo', 3]
>>> 
"""
