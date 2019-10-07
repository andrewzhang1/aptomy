#!/usr/bin/env python
"""lab015x.py -- produces a christmas tree pattern of stars.
The easy way. """


line = 0
stars = 1
blanks = 12
while line < 10:
    print ('  ' * blanks + '* ' * stars)
    line += 1
    stars += 2
    blanks -= 1

"""
$ lab015x.py
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
