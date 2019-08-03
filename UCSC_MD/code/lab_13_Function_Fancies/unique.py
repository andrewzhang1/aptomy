#!/usr/bin/env python
"""(Optional) Function to generate random numbers without repetition.
Demonstrates generators and the 'yield' keyword."""

import random 

def Unique(bot, over_top):
    """Generator to deliver randomly chosen values from bot
    to over_top - 1, delivering each value once only."""
    answers = range(bot, over_top)
    random.shuffle(answers)
    for each in answers:
        yield each

def ListUnique(bot, over_top):
    """Returns a list of the generated numbers"""
    gen = Unique(bot, over_top)
    while True:
        try:
            print gen.next(),
        except StopIteration:
            return

if __name__ == '__main__':
    print '(0, 5) = ',
    ListUnique(0, 5)
    print
    print '(10, 21) = ',
    ListUnique(10, 21)
    print

"""
$ unique.py
(0, 5) =  1 2 3 0 4
(10, 21) =  14 15 20 11 19 10 18 13 17 12 16
$
"""
