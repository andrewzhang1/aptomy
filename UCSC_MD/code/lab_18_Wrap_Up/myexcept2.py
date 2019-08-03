#!/usr/bin/env python
"""You can override and extend the functionality."""
    
class BadNegativeNumber(ArithmeticError):
    times = 0
    def __init__(self, *args):
        """We call to the base class initializer and add some functionality."""
        ArithmeticError.__init__(self, *args)
        BadNegativeNumber.times += 1
        
    def __str__(self):
        return "You messed %d %s! %s" % (BadNegativeNumber.times, 
            "time" if BadNegativeNumber.times==1 else "times", 
            self.args)

def GetPositiveInt(prompt):
    given = int(raw_input(prompt))
    if given < 0:
        raise BadNegativeNumber, ("Non-positive number given.", given)

def main():
    while True:
        try:
            GetPositiveInt("Number please: ")
        except BadNegativeNumber, msg:
            print msg
            continue
        except Exception, msg:
            print msg
            break

if __name__ == '__main__':
    main()
"""$ myexcept2.py
Number please: -2
You messed 1 time! ('Non-positive number given.', -2)
Number please: -3
You messed 2 times! ('Non-positive number given.', -3)
Number please: -1
You messed 3 times! ('Non-positive number given.', -1)
Number please: 
invalid literal for int() with base 10: ''
$ """
