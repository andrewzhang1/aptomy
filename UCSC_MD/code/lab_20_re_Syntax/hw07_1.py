#!/usr/bin/env python
"""hw07_1.py identifier  
tells you if identifier is a valid Python identifier."""

import keyword

def IsValidIdentifier(name):
    """Tests whether 'name' is a valid python identifier.
    Returns  (True_or_False, reason)"""
    if name in keyword.kwlist:
        return (False, "Invalid: this is a keyword!")
    if not name[0].isalpha() and not name[0] == '_':
        return (False, 
                "Invalid: first symbol must be alphabetic or underscore")
    for char in name:
        if not char.isalnum() and not char == '_':
            return (False, "Invalid: '%s' is not allowed." % char)

    return (True, "Valid!")


if __name__ == "__main__":
    DATA = ('x', '_x', '2x', 'x,y', 'yield', 'is_this_good')
    for word in DATA:
        answer_tuple = IsValidIdentifier(word)
        print "%20s -> %s" % (word, answer_tuple[1])
"""
OUTPUT:

$ hw07_1.py
                   x -> Valid!
                  _x -> Valid!
                  2x -> Invalid: first symbol must be alphabetic or underscore
                 x,y -> Invalid: ',' is not allowed.
               yield -> Invalid: this is a keyword!
        is_this_good -> Valid!
$
"""
