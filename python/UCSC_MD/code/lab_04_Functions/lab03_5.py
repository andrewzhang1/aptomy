#!/usr/bin/env python
"""lab03_5.py Prints the decimal equivalent of a binary string."""

string= raw_input("Binary string: ")
for ch in string:
    if ch not in "01":
        print string, 'is not a binary string.'
        break
else:
    # while method
    number = int(string)
    answer = 0
    power = 1
    while number > 0:
        answer += (number % 10) * power
        number /= 10
        power *= 2
    print 'while-loop: %s in binary is %d.' % (string, answer)

    # for method
    answer = 0
    power = 2 ** (len(string) - 1)
    for ch in string:
        answer += power * int(ch)
        power /= 2
    print 'for-loop: %s in binary is %d.' % (string, answer)

    # Python method
    print 'Easy way:', int(string, 2)

"""

$ lab03_5.py
Binary string: 1011
while-loop: 1011 in binary is 11.
for-loop: 1011 in binary is 11.
Easy way: 11
$ lab1_3_5.py
Binary string: 321
321 is not a binary string.
$ """
