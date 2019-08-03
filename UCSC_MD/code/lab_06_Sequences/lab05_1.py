#!/usr/bin/env python
""" lab05_1.py
1.  Write a function that returns a total cost from the sales price
and sales tax.  The default value for the tax rate should be 8.25%.
"""
from __future__ import division

def CalculateCost(price, tax=.0825):
    return price * (1 + tax)

def main():
    print " price |   .0825 |   .0925"
    for price in range(50, 1001, 50):
        dollars = price/100
        print "$%5.2f | $%6.2f | $%6.2f" % (dollars, CalculateCost(dollars), 
                                            CalculateCost(tax=.0925,
                                                          price=dollars))
main()
"""
$ lab05_1.py
 price |   .0825 |   .0925
$ 0.50 | $  0.54 | $  0.55
$ 1.00 | $  1.08 | $  1.09
$ 1.50 | $  1.62 | $  1.64
$ 2.00 | $  2.17 | $  2.19
$ 2.50 | $  2.71 | $  2.73
$ 3.00 | $  3.25 | $  3.28
$ 3.50 | $  3.79 | $  3.82
$ 4.00 | $  4.33 | $  4.37
$ 4.50 | $  4.87 | $  4.92
$ 5.00 | $  5.41 | $  5.46
$ 5.50 | $  5.95 | $  6.01
$ 6.00 | $  6.50 | $  6.55
$ 6.50 | $  7.04 | $  7.10
$ 7.00 | $  7.58 | $  7.65
$ 7.50 | $  8.12 | $  8.19
$ 8.00 | $  8.66 | $  8.74
$ 8.50 | $  9.20 | $  9.29
$ 9.00 | $  9.74 | $  9.83
$ 9.50 | $ 10.28 | $ 10.38
$10.00 | $ 10.82 | $ 10.93
$ """
