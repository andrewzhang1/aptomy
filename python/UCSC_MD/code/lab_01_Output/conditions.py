#!/usr/bin/env python
"""conditions.py demonstrates if/elif/else and while/else."""

number = 4

# if/elif/else

if number < 10:
    print (number, 'is small.')
elif number >= 1000:
    print(number, 'is big.')
else:
    print (number, 'is medium.')

# Alternate syntax for 2.5 -- all one line but less readable.

print(number, "is",)

print ("small." if number < 10 \
               else "big." if number >= 1000 \
               else "medium."  )

# else occurs in a loop too

while number < 6:   
    if number % 3 == 0:
        print (number, 'is divisible by 3.')
        break   
    number += 1
else:  
    print ('Nothing in the loop was divisible by 3.')

"""
$ conditions.py
4 is small.
4 is small.
Nothing in the loop was divisible by 3.
$"""
