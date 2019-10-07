#!/usr/bin/env python
"""lab18_1.py
Make an UpIt(str) function that returns the input string, but
with all caps.  Your UpIt function will be different from
str.upper() in that, if any of the characters in the input string
are already uppercase, it raises an exception.  Invent your own
exception and put it in a reasonable spot in the exception
hierarchy.
"""
import sys

class CaseError(ValueError):
    pass

def UpIt(s):
    if not s.islower():
        raise CaseError
    return s.upper()

if __name__ == '__main__':
    try:
        print UpIt(sys.argv[1])
    except CaseError:
        print sys.argv[1], 'has at least one upper case letter.'
    except IndexError:
        print 'Usage:', sys.argv[0], 'string_of_lower_case_letters'

"""
$ lab18_1.py HI
HI has at least one upper case letter.
$ lab18_1.py hi
HI
$ lab18_1.py Hi
Hi has at least one upper case letter.
$
"""
