#!/usr/bin/env python
"""Here we have a NamedGreeterGuru Class, and a
GuruNamedGreeter Class, overriding the Bye()
method in the Guru class, demonstrating left-
right, depth-first method resolution.
"""

import random 
    
class Guru:    
    # And here is a class variable, accessable anywhere
    # by Guru.sayings  
    sayings = ("The great man is one who never loses his\n"
               "child's heart.                   Mencius", 
               "There is no solution, for there is no\n"
               "problem.               Marcel Duchamp", 
               "If you could get rid of yourself just once, \n"
               "The secret of secrets would open to you.   \n"
               "                            Jalaluddin Rumi", 
               "Don't be consistent, but be simply true.\n"
               "                   Oliver Wendell Holmes", 
               "Nothing is so simple that it cannot be\n"
               "misunderstood.          Freeman Teague", 
               "What one understands is only half true.\n"  
               "What one does not understand is the full\n"
               "truth.                        Zen Saying", 
               "Trying to define yourself is like trying\n"
               "to bite your own teeth.       Alan Watts")

    def Bye(self):
        print "Good Bye.  And remember:"
        self.Pontificate()
            
    def Pontificate(self):
        print random.choice(Guru.sayings)

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

class GuruNamedGreeter(Guru, NamedGreeter):
    pass
    
class NamedGreeterGuru(NamedGreeter, Guru):
    pass

def main():
    rocky = GuruNamedGreeter("Rocky")
    rocky.Greet()
    rocky.Pontificate()
    rocky.Bye()

    moose = NamedGreeterGuru("Moose")
    moose.Greet()
    moose.Pontificate()
    moose.Bye()
    print "\nAccessing the class variable:"
    print Guru.sayings[random.randrange(len(Guru.sayings))]
        
if __name__ == '__main__':
    main()


"""
$ greeter7_def.py
Hello World
I'm Rocky
Nothing is so simple that it cannot be
misunderstood.          Freeman Teague
Good Bye.  And remember:
If you could get rid of yourself just once,
The secret of secrets would open to you.   
                            Jalaluddin Rumi
Hello World
I'm Moose
Nothing is so simple that it cannot be
misunderstood.          Freeman Teague
Bye now.
Accessing the class variable:
If you could get rid of yourself just once,
The secret of secrets would open to you.   
                            Jalaluddin Rumi
$ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      Notes on discovering all about an object:
      
  
      an_object == another_object  --> True
      
                                       They are the same builtin type
                                       and have the same values for
                                       all nested objects.
      
      an_object is another_object  --> True
                |
                |                      id(an_object) == id(another_object)
        'is' is a keyword!             They occupy the same spot in memory.
                                       id() is a builtin that is rarely
                                       used.
      
      isinstance(an_object, class-or-type-or-tuple)  --> True
        If class-or-type-or-tuple is:
      
          class  --  if an_object is of the class or any subclass of it
          type   --  if an_object is the type
          tuple  --  if an_object isinstance of any of the elements in the
                     tuple.  The tuple elements can be classes and/or types.

      issubclass(C, B)             --> True
                                       C is a subclass of any of the
                                       classes in the tuple.  B can be a
                                       tuple of classes.

"""
