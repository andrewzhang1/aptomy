#!/usr/bin/env python
"""
lab13_2.py

MadLibs from dictionary.
"""

MADLIB =  """After trying to %(verb)s around the %(noun)s %(number)s times,
we finally %(past_tense_verb)s the %(plural_noun)s instead.""" 

WORDS_NEEDED = "verb", "noun", "number", "past_tense_verb", "plural_noun"

def CollectUniqueResponses(words_needed):
    """This solution is good if parsed out what you needed by hand, and
    there are no duplicate parts of speech in the madlib.
    """
    replacers_d = {}
    for part_speech in words_needed:
        answer = raw_input("Give me a %s: " % part_speech)
        if not answer:
            return None
        replacers_d[part_speech] = answer
    return replacers_d

def Madlibx(madlib = MADLIB, words_needed = WORDS_NEEDED):
    replacers_d = CollectUniqueResponses(words_needed)
    return madlib % replacers_d

def Madlib(madlib):
    """This is a more flexible solution."""
    
    replacers = {}
    all_parts = madlib.split('%')
    new_strings = [all_parts[0]]
    for replacer in madlib.split('%')[1:]:
        part_speech, rest = replacer[1:].split(')')
        answer = raw_input("Give me a %s: " % part_speech)
        if not answer:
            return None
        while part_speech in replacers:
            part_speech += '_'
        replacers[part_speech] = answer
        new_strings += [')'.join((part_speech, rest))]
    return '%('.join(new_strings) % replacers

def main():
    madlib_str = Madlibx()
    if madlib_str:
        print madlib_str
    madlib = "All %(plural_animal)s, %(plural_animals)s, and "
    "%(plural_animal)s %(past_tense_verb)s"
    " until %(number)s were %(past_tense_verb)s."
    madlib_str = Madlib(madlib)
    if madlib_str:
        print madlib_str

if __name__ == '__main__':
    main()

"""
$ lab13_2.py
Give me a verb: drip
Give me a noun: ball
Give me a number: 3
Give me a past_tense_verb: hopped
Give me a plural_noun: toes
After trying to drip around the ball 3 times,
we finally hopped the toes instead.
Give me a plural_animal: sloths
Give me a plural_animals: ants
Give me a plural_animal: jellyfish
Give me a past_tense_verb: tied
Give me a number: 18
Give me a past_tense_verb: rolled
All sloths, ants, and jellyfish tied until 18 were rolled.
$"""
