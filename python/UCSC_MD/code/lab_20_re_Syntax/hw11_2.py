#!/usr/bin/env python
"""Provides Palindromize(phrase)"""

import string

table = ''.join([chr(i) for i in range(256)])
delete_chars = string.punctuation + string.whitespace

def Palindromize(phrase):
    """Returns lowercase version of the phrase with whitespace and
    punctuation removed if the phrase is a palindrome.  If not, it
    returns None."""
    
    phrase = str(phrase).lower().translate(table, delete_chars)
    half_len = len(phrase)/2
    if half_len <= 1:
        return None
    for i, ch in enumerate(phrase[:half_len]):
        if ch != phrase[-(i+1)]:
            return None
    return phrase

def main():
    DATA = ('Murder for a jar of red rum', 12321,
            'nope', 'abcbA', 3443, 'what',
            'Never odd or even', 'Rats live on no evil star')
    for phrase in DATA:
        answer = Palindromize(phrase)
        if answer:
            print "%s -> %s" % (phrase, answer)
        
if __name__ == '__main__':
    main()

"""
$ hw11_2.py
Murder for a jar of red rum -> murderforajarofredrum
12321 -> 12321
abcbA -> abcba
3443 -> 3443
Never odd or even -> neveroddoreven
Rats live on no evil star -> ratsliveonnoevilstar
$"""
