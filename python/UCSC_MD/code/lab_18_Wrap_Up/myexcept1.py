#!/usr/bin/env python
"""You can invent your own exception, having it inherit from some
class in the Exception hierarchy."""
    
class BadNegativeNumber(ArithmeticError):
    pass

def GetPositiveInt(prompt):
    given = int(raw_input(prompt))
    if given < 0:
        raise BadNegativeNumber, ("Non-positive number given.", given)

def main():
    try:
        GetPositiveInt("Number please: ")
    except BadNegativeNumber, msg:
        print msg

if __name__ == '__main__':
    main()
"""
$ myexcept1.py
Number please: -1
('Non-positive number given.', -1)
$
"""
