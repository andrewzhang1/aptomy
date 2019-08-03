#!/usr/bin/env python
"""Use list comprehensions to produce the quiz output again, this time
with the fewest possible lines of code."""

print '\n'.join([''.join(['%4d' % (n * m) \
                          for n in range(6)]) for m in range(6)])
"""
$ lab08_3.py
   0   0   0   0   0   0
   0   1   2   3   4   5
   0   2   4   6   8  10
   0   3   6   9  12  15
   0   4   8  12  16  20
   0   5  10  15  20  25
$
"""

