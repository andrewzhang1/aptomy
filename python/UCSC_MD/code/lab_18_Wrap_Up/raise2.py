#!/usr/bin/env python
"""And, you can re-raise an exception."""

import raise1

try:
    number = raise1.GetPositiveNumber("Positive number please: ")
except ValueError, msg:
    print "That was wrong!"
    raise    # Raises last exception again

"""
$ raise2.py
Positive number please: -2
That was wrong!
Traceback (most recent call last):
  File "./raise2.py", line 7, in <module>
    number = raise1.GetPositiveNumber("Positive number please: ")
  File "/home/marilyn/python/mm/labs/lab_19_Exceptions/raise1.py", \
       line 8, in get_positive_number
    raise ValueError, "Number given must be positive."
ValueError: Number given must be positive.
$ """

    
