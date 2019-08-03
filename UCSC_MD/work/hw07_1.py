

"""
Provides a function IsValidIdentifier that checks whether a string is a valid identifier:
Input:   a string
Returns: a tuple (True|False, reason)
"""

import keyword


def IsValidIdentifier( text):
    """
    Validations are:
    1. first character  must be alphabetic or underscore
    2. later characters must be alphabetic or underscore or numeric
    3. text must not be a keyword
    """
    
    if not text[0].isalpha() and text[0] != '_':
        return (False, "Invalid: first symbol must be alphabetic or underscore.")

    for char in text:
        if not char.isalnum() and char != '_':
            return (False, "Invalid: '%s' is not allowed." % (char))

    if text in keyword.kwlist:
        return (False, "Invalid: this is a keyword!")

    return (True, "Valid!")


if __name__ == '__main__':
    DATA = ('x', '_x', '2x', 'x,y', 'yield', 'is_this_good')

    for text in DATA:
        (valid, reason) = IsValidIdentifier( text)
        print "%12s -> %s" % (text, reason)


"""
>>> 
============= RESTART: C:\Users\E1HL\Python\exercises\hw07_1.py =============
           x -> Valid!
          _x -> Valid!
          2x -> Invalid: first symbol must be alphabetic or underscore.
         x,y -> Invalid: ',' is not allowed.
       yield -> Invalid: this is a keyword!
is_this_good -> Valid!

>>> import hw07_1
>>> help( hw07_1)
Help on module hw07_1:

NAME
    hw07_1

FILE
    c:\users\e1hl\python\exercises\hw07_1.py

DESCRIPTION
    Provides a function IsValidIdentifier that checks whether a string is a valid identifier:
    Input:   a string
    Returns: a tuple (True|False, reason)

FUNCTIONS
    IsValidIdentifier( text)
        Validations are:
        1. first character  must be alphabetic or underscore
        2. later characters must be alphabetic or underscore or numeric
        3. text must not be a keyword


>>> """
