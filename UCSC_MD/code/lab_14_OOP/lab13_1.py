#!/usr/bin/env python
"""lab13_1.py -- a Printf function"""
import sys

def Printf(format, *args):
    """Emulates C-like printf function."""
    sys.stdout.write(format % args)
        
def Printfx(format, *args):
    """This one almost always works."""
    print format % args,

def main(function):
    print 'Testing', function
    function('%d black cats drank %d plates of milk.\n', 4, 2)
    function('%d', 3)
    function('%d\n', 3)
    function('Hello World\n')

if __name__ == '__main__':
    main(Printf)
    main(Printfx)

"""
$ lab13_1.py
Testing <function Printf at 0xb7f23f44>
4 black cats drank 2 plates of milk.
33
Hello World
Testing <function Printfx at 0xb7f23f7c>
4 black cats drank 2 plates of milk.
3 3
Hello World
$
"""
