#!/usr/bin/env python
"""The "assert" statement is useful while debugging.  It goes away
under any optimization."""  

def main():
    x = input("Give me positive x please: ")
    assert x > 0
    print "Good. %s is positive." % x
    
if __name__ == '__main__':
    main()

"""
$ assert_.py
Give me positive x please: 3.14
Good. 3.14 is positive.
$ assert_.py
Give me positive x please: 0
Traceback (most recent call last):
  File "./assert_.py", line 11, in <module>
    main()
  File "./assert_.py", line 7, in main
    assert x > 0
AssertionError
$ 
"""
