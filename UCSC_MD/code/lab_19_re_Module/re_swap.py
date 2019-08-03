#!/usr/bin/env python
"""Swapping cats and dogs again, but this time doing a better job with
regular expressions.  The old, faulty solution is:

def DoSwap(text, apple, orange):
    '''Swap apple for orange and orange for apple in the text.

    Return the swapped text.
    '''
    
    dummy = 'wxyz'
    while True:
        if text.find(dummy) == -1:
            break
        dummy *= 2
    text = text.replace(apple, dummy)
    text = text.replace(orange, apple)
    text = text.replace(dummy, orange)
    return text

"""
          
import re 

def DoSwap(text, apple, orange):
    """Swaps all occurances of apple for orange, and orange
    for apple in the text."""
    # Using VERBOSE and named groups for readability
    compiled_re = re.compile(r"""
    \b               # matches a word boundary
    (?P<found>%s|%s) # matches apple or orange and puts the match
                     # in a group named "found" if the whole thing matches
    (?P<rest>s?)\b   # matches a word boundary or 's' and a word boundary
                     # and puts the 's', or not, into a group named "rest"
    """ % (re.escape(apple), re.escape(orange)), re.IGNORECASE | re.VERBOSE)

    def MatchCase(answer, like_string):
        if like_string.isupper():
            return answer.upper()
        if like_string.islower():
            return answer.lower()
        if like_string.istitle():
            return answer.title()
        return answer
    
    def SwapMatch(match_object):
        found = match_object.group('found')
        if found.lower() == apple.lower():
            x = MatchCase(orange, found) + match_object.group('rest')
            return x
        x = MatchCase(apple, found) + match_object.group('rest')
        return x

    fixed = compiled_re.sub(SwapMatch, text)
    return fixed

def main():
    print DoSwap("DOGS: 14dogs are a lot of Dogs.", 'dog', 'elephant')
    print DoSwap("3 Categories of CATS.", 'cat','dog')

if __name__ == '__main__':
    main()
"""
$ re_swap_caseless.py
ELEPHANTS: 14dogs are a lot of Elephants.
3 Categories of DOGS.
$
"""
