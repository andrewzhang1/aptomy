#!/usr/bin/env python
"""You can raise an exception anytime you take a notion."""
  
def GetPositiveNumber(prompt):
    said = raw_input(prompt)
    number = float(said)
    if number < 0:
        raise ValueError, "Number given must be positive."
    return number

if __name__ == '__main__':
    print GetPositiveNumber("Positive number please: ")

"""
$ raise1.py
Positive number please: -2
Traceback (most recent call last):
  File "./raise.py", line 10, in ?
    GetPositiveNumber("Positive number please: ")
  File "./raise.py", line 8, in GetPositiveNumber
    raise ValueError, "Number given must be positive."
ValueError: Number given must be positive.
$ """

    
