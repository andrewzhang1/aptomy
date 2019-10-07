#!/usr/bin/env python
"""Here we implement another class, a HipGreeter, and have it
further down the inheritance tree."""

class Greeter:
    def Greet(self):
        print "Hello World"
    def Bye(self):
        print "Bye now."

class NamedGreeter(Greeter):
    def __init__(self, name):
        self.name = name
    def Greet(self):
        Greeter.Greet(self)
        print "I'm", self.name

class HipGreeter(NamedGreeter):
    def Greet(self):
        NamedGreeter.Greet(self)
        print "Wazzup."

def main():
    rocky = HipGreeter("Rocky")
    rocky.Greet()
    rocky.Bye()
    
if __name__ == '__main__':
    main()

"""
$ greeter6_def.py
Hello World
I'm Rocky
Wazzup.
Bye now.
$ 
"""
