#!/usr/bin/env python
"""manynames.py -- from "Learning Python" by Mark Lutz
and David Ascher, published by O'Reilly.  Demonstrates
name-spaces associated with classes, functions, and
methods.""" 

x = 11                # Module (global) name/attribute
class C:
    x = 22            # Class attribute
    def M(self):
        x = 33        # Local identifier in method
        self.x = 44   # instance attribute

def F():
    x = 55        # Local identifier in function

def G():
    print x       # Access module x (11)

if __name__ == '__main__':
    obj = C()
    obj.M()
    print obj.x   # 44: instance
    print C.x     # 22: class (a.k.a. obj.x if no x in instance)
    print x       # 11: module (a.k.a. manynames.x outside file)
    G()   # 11: sees the global x
    try:
        print C.M.x  # fails: only visible in method
    except AttributeError, msg:
        print "C.M.x failed:", msg
    try:
        print F.x    # fails: only visible in function
    except AttributeError, msg:
        print "F.x failed:", msg
"""
$ manynames.py
44
22
11
11
C.M.x failed: 'function' object has no attribute 'x'
F.x failed: 'function' object has no attribute 'x'
$ """
