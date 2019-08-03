#!/usr/bin/env python
"""Alternatively, we define an __init__ method so that the
name is given when the object is created."""
  
class Greeter:
    # This Greeter class needs a name when instantiated.

    def __init__(self, name):
        # __init__ is Python's constructor method
        self.name = name

    def Greet(self):
        print "Hello World. I'm", self.name

def main():
    fred = Greeter('Fred')
    print 'fred.Greet():'
    fred.Greet()
    
    x = Greeter()    #  error!
    print 'x.Greet():'
    x.Greet()
    
if __name__ == '__main__':
    main()

"""
$ greeter3_def.py
fred.Greet():
Hello World. I'm Fred
Traceback (most recent call last):
  File "./greeter3_def.py", line 25, in ?
    main()
  File "./greeter3_def.py", line 20, in main
    x = Greeter()    #  error!
TypeError: __init__() takes exactly 2 arguments (1 given)
$ 
"""
