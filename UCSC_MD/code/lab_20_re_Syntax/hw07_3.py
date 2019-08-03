#!/usr/bin/env python
"""hw07_3.py an interactive valid Python identifier tester."""

import hw07_1

def main():
    while True:
        identifier = raw_input("Please give an identifier: ")
        if not identifier:
            break
        answer_tuple = lab07_1.IsValidIdentifier(identifier)
        print "%20s -> %s" % (identifier, answer_tuple[1])

if __name__ == '__main__':
    main()

"""
OUTPUT:
$ hw07_3.py
Please give an identifier: x
                   x -> Valid!
Please give an identifier: _x
                  _x -> Valid!
Please give an identifier: 2x
                  2x -> Invalid: first symbol must be alphabetic or underscore
Please give an identifier: x,y
                 x,y -> Invalid: ',' is not allowed.
Please give an identifier: pass
                pass -> Invalid: this is a keyword!
Please give an identifier: is_this_good
        is_this_good -> Valid!
Please give an identifier: 
$
"""
