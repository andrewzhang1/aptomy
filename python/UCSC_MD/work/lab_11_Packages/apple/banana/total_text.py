#!/usr/bin/env python
"""total_text.py provides a TotalText function, which adds up all the
numbers in the text that it receives."""

import string
# Concocting a string of unwanted punctuation
punctuation_except_decimal = string.punctuation.replace('.', '')

def TotalText(text, total=0):
    """Returns the sum of all the numbers in the text."""

    words = text.split()
    for word in words:
        word = word.strip(punctuation_except_decimal)
        word = word.rstrip('.')
        try:
            num = float(word)
        except ValueError:
            pass
        else:
            total += num
    return total

def main():
    print "Total =",
    print TotalText("""
Here is 1. Add 2 makes 3 or maybe 12, depending on how you operate.
You might like 2.2 and that's enough unless you like "8.8" or maybe
1 more or maybe 87. . .5. But she said ".3"  Let's do 88!""")

    
if __name__ == '__main__':
    main()

"""
$ total_text.py
Total = 205.8
$
"""
