#!/usr/bin/env python
"""lab01_5.py -- produces a christmas tree pattern of stars."""

line = 0
stars = 1
blanks = 12
while line < 10:
    i = 0
    while i < blanks:
        print ' ',
        i += 1
    i = 0
    while i < stars:
        print '*',
        i += 1
    print
    line += 1
    stars += 2
    blanks -= 1

"""
$ lab01_5.py
                        *
                      * * *
                    * * * * *
                  * * * * * * *
                * * * * * * * * *
              * * * * * * * * * * *
            * * * * * * * * * * * * *
          * * * * * * * * * * * * * * *
        * * * * * * * * * * * * * * * * *
      * * * * * * * * * * * * * * * * * * *
$
"""

