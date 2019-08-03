#!/usr/bin/env python
"""lab04_1.py -- A coin flipping Experiment. """
import random

def FlipCoin():
    """Simulates the flip of a coin."""

    if random.randrange(0, 2) == 0:
        return "tails"
    return "heads"

def Experiment():
    """Flips coins until it gets 3 head in a row."""

    heads = count = 0
    while heads < 3:
        count += 1
        if FlipCoin() == 'heads':
            heads += 1
        else:    # 'tails'
            heads = 0
    return count

def main():
    """Driver for the Experiment."""
    total = 0
    for n in range(10):
        flips = Experiment()
        #    print flips, "flips"  
        total += flips
        print "On average, it took %.1f coin flips to get 3 in a row."\
              % (total/10.0)
main()
"""
$ lab04_1.py
On average, it took 16.3 coin flips to get 3 in a row.
[... and 9 more like it]
$ """
