#!/usr/bin/env python
"""Optional: A decorator is a function for wrapping another function,
or many other functions.  Here we are timestamping the function
calls.""" 

import time  

def TimeDecorator(func):
    """Decorator function for reporting when the function was called."""
    def WrappedFunction(*args, **kw_args):
        print "It's %s, time for %s:" % (time.ctime(), func.__name__)
        return func(*args, **kw_args)
    return WrappedFunction

@TimeDecorator  # syntax available in 2.5
def Breakfast(meat='bacon', eggs='scrambled'):
    print "Here's your %s and %s eggs.  Enjoy!" % (meat, eggs)

def Lunch(**substitutions):
    menu = {'meat':'ham', 'cheese':'american', 'bread':'white'}
    menu.update(substitutions)
    print "Here's your %(meat)s and %(cheese)s on %(bread)s bread.  Enjoy!"\
          % menu
Lunch = TimeDecorator(Lunch)  # older syntax

@TimeDecorator
def Tea():
    print "Tea time!"

@TimeDecorator
def Dinner(menu):
    print "%s for dinner tonight." % (menu.title())
    
def main():
    Breakfast(meat='sausage', eggs='basted')
    time.sleep(1)
    Lunch(cheese='swiss', bread='rye')
    time.sleep(1)
    Tea()
    time.sleep(1)
    Dinner('roast beef')
    
if __name__ == '__main__':
    main()
"""
$ decorator.py
It's Thu Mar  1 11:45:28 2007, time for Breakfast:
Here's your sausage and basted eggs.  Enjoy!
It's Thu Mar  1 11:45:29 2007, time for Lunch:
Here's your ham and swiss on rye bread.  Enjoy!
It's Thu Mar  1 11:45:30 2007, time for Tea:
Tea time!
It's Thu Mar  1 11:45:31 2007, time for Dinner:
Roast Beef for dinner tonight.
$ """
