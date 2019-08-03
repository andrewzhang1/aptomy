#!/usr/bin/env python
"""Here we implement 'inheritance' to leave the original
Greeter class intact and add a NamedGreeter class, that
has all the functionality of the Greeter class plus some
new things. """

class Greeter: 

    def Greet(self):
        print "Hello World"

class NamedGreeter(Greeter):
    # Inherits the methods in the Greeter class, and adds some
    # of it's own.

    def __init__(self, name):
        self.name = name

    def SayMyName(self):
        print "I'm", self.name

def main():
    fred = NamedGreeter('Fred')
    print 'fred.Greet():'
    fred.Greet()
    fred.SayMyName()

    # code that depends on the Greeter class is unaffected.
    x = Greeter()
    print 'x.Greet():'
    x.Greet()
    
if __name__ == '__main__':
    main()
"""
$ greeter4_def.py
fred.Greet():
Hello World
I'm Fred
x.Greet():
Hello World
$ """
