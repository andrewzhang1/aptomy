

"""
"""


import sys


def GetAdLib():
    """
    """

    words   = ('verb', 'noun', 'number', 'past_tense_verb', 'plural_noun')
    choices = {}

    for word in words:
        choice = raw_input( "Enter a %s: " % (word))
        if not choice:
            sys.exit()

        if choice.isdigit():
            choices[word] = int( choice)
        else:
            choices[word] = choice

    return choices


def PutAdLib( **choices):
    """
    Input:   answers is caller's sequence of key:value, as a dictionary
    Returns: None, just print to stdout an ad lib sentence
    """

    print "After trying to %(verb)s around the %(noun)s %(number)d times, we finally %(past_tense_verb)s the %(plural_noun)s instead." \
          % choices


if __name__ == '__main__':
    PutAdLib( **GetAdLib())


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab13_exer2.py ===========
Enter a verb: ring
Enter a noun: rosie
Enter a number: 8
Enter a past_tense_verb: walked
Enter a plural_noun: dogs
After trying to ring around the rosie 8 times, we finally walked the dogs instead.
>>> 
"""
