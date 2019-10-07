#!/usr/bin/env python
""" Optional:

Ways to get more info about your caught exception from sys."""

import sys        # gives info -- you can use the traceback 
                  # module but it uses sys

def Fun(msg):    
    raise ArithmeticError, msg 

if __name__ == '__main__':
    try:
        Fun('catch me once')
    except:
        print 'Caught: sys.exc_type =', sys.exc_type
        print 'sys.exc_value =', sys.exc_value
        print 'sys.exc_traceback =', sys.exc_traceback
        print 'sys.exc_info() =', sys.exc_info()
    try:
        Fun(('catch me twice', [1, 2, 3]))
    except Exception, obj:
        print 'obj.args = ', obj.args
        print 'obj = ', obj
"""
$ except3.py
Caught: sys.exc_type = <type 'exceptions.ArithmeticError'>
sys.exc_value = catch me once
sys.exc_traceback = <traceback object at 0xb7f0b5a4>
sys.exc_info() = (<type 'exceptions.ArithmeticError'>, 
                  ArithmeticError('catch me once', ), 
                 <traceback object at 0xb7f0b5a4>)
obj.args =  ('catch me twice', [1, 2, 3])
obj =  ('catch me twice', [1, 2, 3])
$ 
"""
