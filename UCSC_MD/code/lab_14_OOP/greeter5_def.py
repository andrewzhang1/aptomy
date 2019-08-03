#!/usr/bin/env python
"""Here, both classes have a Greet method.  The lingo is:
the NamedGreeter.Greet() method 'overrides' the 
Greeter.Greet() method.  When an object of the NamedGreeter
class calls Greet(), it accesses and runs NamedGreeter.Greet()
while an object of the Greeter class executes Greeter.Greet().
"""            
class Greeter:  

    def Greet(self):
        print "Hello World"
    def Bye(self):
        print "Bye now."

class NamedGreeter(Greeter):

    def __init__(self, name):
        self.name = name
    def Greet(self):
        # NamedGreeter.Greet() calls the Greeter.Greet() method
        # and then adds some functionality.  This is a common and
        # useful technique.
        Greeter.Greet(self) 
        print "I'm", self.name

def main():
    fred = NamedGreeter('Fred')
    print 'fred.Greet():'
    fred.Greet()                # Output:
    print 'fred.Bye():'         #
    fred.Bye()                  # $ greeter5_def.py
    x = Greeter()               # fred.Greet():
    print 'x.Greet():'          # Hello World
    x.Greet()                   # I'm Fred
    print 'x.Bye():'            # fred.Bye():
    x.Bye()                     # Bye now.
                                # x.Greet()
if __name__ == '__main__':      # Hello Word
    main()                      # x.Bye():
                                # Bye now.
                                # $
