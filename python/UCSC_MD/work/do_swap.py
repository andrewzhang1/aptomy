#!/usr/bin/env python
"""do_swap.py for importing.

Note that this is a faulty function for swapping occurrences of
'orange' for 'apple' and occurrences of 'apple' for 'orange' in the
text.  It is faulty because it is case-sensitive and because it would
change"category" to "dogegory".  You don't care for this exercise.
We'll get it right when we do regular expressions.
"""

def DoSwap(text, apple, orange):
    """Swap apple for orange and orange for apple in the text.

    Return the swapped text.
    """
    
    dummy = 'wxyz'
    while True:
        if text.find(dummy) == -1:
            break
        dummy *= 2
    text = text.replace(apple, dummy)
    text = text.replace(orange, apple)
    text = text.replace(dummy, orange)
    return text

if __name__ == '__main__':
    print DoSwap("""Some dogs and cats played together.""", 'dog', 'cat')

"""        
$ do_swap.py
Some cats and dogs played together.
$ """
