#!/usr/bin/env python
"""Here we add a name attribute to our class and a method
to set a value into the name.

The value of an attribute belongs solely to the object;
the methods belong both to the class and the objects."""

class Greeter: 
    """The Greeter class makes potentially named Greeter
    objects that can greet you."""

    def SetName(self, name_in): 
        self.name = name_in 

    def Greet(self):
        try:
            print "Hello World. I'm %s" % self.name
        except AttributeError:
            print "Hello World."

def main():
    gracy = Greeter()
    gracy.Greet()
    gracy.SetName('Gracy')
    gracy.Greet()
    george = Greeter()
    george.SetName('George')
    george.Greet()
    gracy.Greet()

if __name__ == '__main__':
    main()
"""
$ greeter2_def.py
Hello World.
Hello World. I'm Gracy
Hello World. I'm George
Hello World. I'm Gracy
$ 
"""
