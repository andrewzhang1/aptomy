#!/usr/bin/env python
""" lab02_3.py I'm thinking-of-a-number game. """

print "Think of a number between 1 and 10 and I'll try to guess it."
high = 10
low = 1
guesses = 0
while high > low:
    guesses += 1
    guess = (high + low)/2
    print 'Is your number %d?' % guess
    while True:
        answer = raw_input("""Please press:
        'y' for yes
        'n' for no
        """)
        answer = answer[0].lower()
        if answer == 'y' or answer == 'n':
            break
        print 'Please follow directions.'
    if answer == 'y':
        print 'Hurray! Only', guesses, "guesses."
        break

    while True:
        answer = raw_input("""No?  Then please press:
        'h' if %d is higher than your number
        'l' if %d is lower than your number
        """ % (guess, guess))
        answer = answer[0].lower()
        if answer == 'l' or answer == 'h':
            break
        print 'Please follow directions'
                       
    if answer == 'l':
        low = guess + 1
    else:
        high = guess - 1
                       
"""
$ lab02_3.py
Think of a number between 1 and 10 and I'll try to guess it.
Is your number 5?
Please press:
        'y' for yes
        'n' for no
        n
No?  Then please press:
        'h' if 5 is higher than your number
        'l' if 5 is lower than your number
        h
Is your number 2?
Please press:
        'y' for yes
        'n' for no
        y
Hurray! Only 2 guesses.
$ 
"""
