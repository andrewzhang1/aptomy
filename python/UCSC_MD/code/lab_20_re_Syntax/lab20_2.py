#!/usr/bin/env python
"""lab20_2.py Print names and numbers of those in the 408 area code."""

import re
import norma  # to collect the data

def GetWhoInAreaCode(text, area_code):
    return re.findall(
        r"""^(?P<name>[^:]+?)   # captured the name
        :%s-                    # must match area code
        (?P<number>\d{3}-\d{4}) # captured the phone number
        :""" \
        % area_code, text, re.MULTILINE | re.VERBOSE)

def main():
    print '\n'.join(["%25s: %s" % (name, number) \
                     for name, number in \
                     GetWhoInAreaCode(norma.ReadFile('address.data'), 408)])

if __name__ == '__main__':
    main()


"""
$ lab20_2.py
             Tommy Savage: 724-0140
            Lesle Kerstin: 456-1234
               JonDeLoach: 253-3122
$ """
