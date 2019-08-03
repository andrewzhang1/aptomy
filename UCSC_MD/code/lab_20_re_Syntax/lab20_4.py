#!/usr/bin/env python
"""lab20_4.py Print the names of people born in March."""
import re
import norma  # to collect the data

def BornIn(month, text):
    return re.findall(
        r"""^([^:]+?)     # capture the name
        (?::[^:]+?)       # don't capture colon followed by non colons
        {2}               # twice
        :%s               # follwed by colon and month number
        """ % month, text, re.MULTILINE|re.VERBOSE)
    
def main():
    print BornIn(3, norma.ReadFile('address.data'))

if __name__ == '__main__':
    main()

"""
$ lab20_4.py
['Norma Corder']
$ """
