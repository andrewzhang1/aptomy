#!/usr/bin/env python
"""lab05_2.py
2.  Write a Breakfast function that takes five arguments: meat, eggs,
potatoes, toast, and beverage.  The default meat is bacon, eggs are
over easy, potatoes is hash browns, toast is white, and beverage is
coffee.  The function just says:

Here is your bacon and scrambled eggs with home fries and rye toast.
Can I bring you more milk?

Call it at least 3 different times, scrambling the arguments.
"""

def Breakfast(meat="bacon", eggs="over easy", 
              potatoes="hash browns", toast="white", 
              beverage="coffee"):
    print "Here is your %s and %s eggs with %s and %s toast." \
          % (meat, eggs, potatoes, toast)
    print "Can I bring you more %s?" % beverage

def main():
    Breakfast()
    Breakfast("ham", "basted", "cottage cheese", 
              "cinnamon", "orange juice")
    Breakfast("sausage", toast="wheat", beverage="chai")

main()
"""
$ lab05_2.py
Here is your bacon and over easy eggs with hash browns and white toast.
Can I bring you more coffee?
Here is your ham and basted eggs with cottage cheese and cinnamon toast.
Can I bring you more orange juice?
Here is your sausage and over easy eggs with hash browns and wheat toast.
Can I bring you more chai?
$ 
"""
