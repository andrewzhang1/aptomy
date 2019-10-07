#!/usr/bin/env python
"""lab19_2.py Swapping from a dictionary"""
import re

def DoSwap(text, replace_d):
    """Swaps all the replace_d.keys() in the text for their values."""
    # Using VERBOSE and named groups for readability
    compiled_re = re.compile(r"""
    \b               # matches a word boundary
    (?P<found>%s)    # matches apple or orange and puts the match
                     # in a group named "found" if the whole thing matches
    (?P<rest>s?)\b   # matches a word boundary or 's' and a word boundary
                     # and puts the 's', or not, into a group named "rest"
    """ % ('|'.join([re.escape(k) for k in replace_d])), 
                             re.IGNORECASE | re.VERBOSE)

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
        return MatchCase(replace_d[found.lower()], found)
    fixed = compiled_re.sub(SwapMatch, text)
    return fixed

def main():
    replace_d = {
        'general':'band leader', 
        'china':'mexico', 
        'zen':'mariachi', 
        'master':'teacher', 
        'sword':'baton',
        'through':'around'}

    text = open('zen.story').read()
    print DoSwap(text, replace_d)

if __name__ == '__main__':
    main()
"""
$ lab19_2.py
A band leader in ancient Mexico came to see a Mariachi 
teacher.

He drew his baton and pointed it at the teacher, and 
announced: "Don't you know that I am a man who can 
run you around without blinking an eye?"

To which the Mariachi teacher responded instantly: "Don't 
you know that I am a man who can be run around 
without blinking an eye?"

Deeply impressed, the band leader sheathed his baton and 
remained for the teaching.
$
"""
