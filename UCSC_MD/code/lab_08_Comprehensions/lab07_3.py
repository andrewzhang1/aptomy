#!/usr/bin/env python
"""lab07_3.py
This program translates a line of text from English
to Pig Latin.  The rules for forming Pig Latin words
are as follows:
o  If the word begins with a vowel, add "way" to the
   end of the word.
o  If the word begins with a consonant, extract the
   consonants up to the first vowel, move those 
   consonants to the end of the word, and add "ay".
"""

def Pigify(word):
    vowels = "aeiouyAEIOUY"

    if word[0] in vowels:
        return word + 'way' 
    
    for i, char in enumerate(word):
        if char in vowels:
            break
    return word[i:] + word[:i] + 'ay' 

def PrepWord(word):
    punctuations=",.:;!"
    if word[-1] in punctuations:
        word, punctuation = word[:-1], word[-1]
    else:
        punctuation = ''

    recase = 0
    if word.islower() or word.isupper():
        pass 
    elif word[0].isupper():
        recase = 1
        word = word[0].lower() + word[1:]
    return recase, word, punctuation  

def ToPig(word):
    """Returns a pig latin version of the word."""
    recase, bare_word, punctuation \
            = PrepWord(word)
    word =  Pigify(bare_word) + punctuation
    if recase:
        word = word[0].upper() + word[1:]
    return word

def PigLatinize(line):

    """Returns a string containing the pig latin version of the
    input line.
    """

    pigged_words = []
    for word in line.split():
        pigged_words += [ToPig(word)]
    return ' '.join(pigged_words)

def main():
    print PigLatinize(raw_input('Tell me something good: '))

if __name__ == '__main__':
    main()

"""
$ lab07_3.py
Tell me something good: Ice cream, hot fudge, nuts and a cherry.
Iceway eamcray, othay udgefay, utsnay andway away errychay.
$
"""
