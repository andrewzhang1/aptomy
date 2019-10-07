#!/usr/bin/env python
"""Here is a very simple object-oriented python program.
Note that we make 3 namespaces: the Greeter class, and two
instances of the Greeter class, fred and alma.""" 

class Greeter:   
    """The Greeter class makes Greeter objects that can greet you."""

    def Greet(self):           # 'self' is always the first argument
        print 'Hello World'    # of every method in every class.

def main():                    # A call:  fred.Greet() is interpreted
    fred = Greeter()           # as Greeter.Greet(fred). So fred is
    print 'fred.Greet():'      # the self in this call, and fred is 
    fred.Greet()               # the namespace we are referring to.
    alma = Greeter()
    print 'alma.Greet():'
    alma.Greet()
    print 'Fred is', id(fred), 'Alma is', id(alma), \
          'Greeter class is', id(Greeter)
    
if __name__ == '__main__':
    main()

"""
$ greeter1_def.py
fred.Greet():
Hello World
alma.Greet():
Hello World
Fred is 135591268 Alma is 135590980 Greeter class is 135413484
$
"""
