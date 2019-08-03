#!/usr/bin/env python
""" Remember this lab solution:
---    
def Breakfast(meat="bacon", eggs="over easy", 
              potatoes="hash browns", toast="white", 
              beverage="coffee"):
    print "Here is your %s and %s eggs with %s and %s toast."\
          % (meat, eggs, potatoes, toast)
    print "Can I bring you more %s?" % beverage

Breakfast()
Breakfast("ham", "basted", "cottage cheese", "cinnamon", "orange juice")
Breakfast("sausage", toast="white", beverage="chai")
----
Here's an even more flexible way, using the '%' operator for strings
again, but this time with a dictionary -- as well as variable length
keyword calls.
"""
               
def Breakfast(**substitutions): 
    order = {'meat':'bacon','eggs':'over easy',
             'potatoes':'hash browns',   
             'toast':'white','beverage':'coffee'}
    # updating values in order from substitutions
    order.update(substitutions)  
    # string replacement from a dictionary
    print "Here is your %(meat)s and %(eggs)s eggs with %(potatoes)s "\
          "and %(toast)s toast." % order
    print "Can I bring you more %(beverage)s?" % order

def main():
    Breakfast()
    Breakfast(meat="sausage", toast="wheat", beverage="chai")

if __name__ == '__main__':
    main()
"""
$ breakfast.py
Here is your bacon and over easy eggs with hash browns and white toast.
Can I bring you more coffee?
Here is your sausage and over easy eggs with hash browns and wheat toast.
Can I bring you more chai?
$ """
