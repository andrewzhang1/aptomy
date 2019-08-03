#!/usr/bin/env python
"""  
Method Resolution For Diamond Inheritance (Optional)

                ----------
               |    A     |
               |  -----   |
               | __init__ |
               |self.x = 1|
                ----------
               /|\    /|\
         -------       ----------
        |   B   |     |    C     |
        |  ---  |     |  -----   |
        |       |     | __init__ |
         -------      |self.x = 2|
           /|\         ----------
            |            /|\
            ----      ----
                |    |
                ------
               |   D  |
                ------

Multiple inheritance from super classes that share a common super super class.
   - - -  - - -  - - -  - - -  - - -  - - -  - - -  - - - 

Resolution order for new style classes in a diamond pattern:

In the classic case, always left to right, depth first:

D().x = 1

In a new-style class, when the classes inherit from "object":

"""








class A(object):
    def __init__(self):
        self.x = 1
class B(A):
    pass
class C(A):
    def __init__(self):
        self.x = 2
class D(B, C):
    pass

print D().x
"""
$ diamond.py
2
$ 
   The new style rules are:
   List all the classes visited in the classic case:
   [D, B, A, C, A]
   If there are duplicates, eliminate all but the last:
   [D, B, C, A]
   And that's the search order.
"""
