#!/usr/bin/env python


"""Dictionary implementation for demonstrating a Python dictionary."""


# empty dictionary
py_dict = {}

# initializing a dictionary
py_dict2 = {
            'break'    : 'break out of a loop and skip the else',
            'continue' : 'go to the next iteration of the loop',
            'for'      : 'set up looping'
            }

# Updating py_dict1 with py_dict2's keys and values.
# If py_dict2 has keys already in py_dict, py_dict2's values will replace the old values for the key.
py_dict.update(py_dict2)    

# And you can just add an entry
py_dict['pass'] = 'throw the ball'

# If you add an entry with a duplicate key, the new meaning will be the one that sticks:
py_dict['pass'] = 'do nothing'


def MakePrompt(choices):
    choice_list = sorted(choices)
    guts = ', '.join(['(%s)%s' % (choice[0], choice[1:]) for choice in choice_list])
    return 'Choose ' + guts + ' (enter to quit) '


def CollectEntries():
    """Collects a bunch of new entries for the dictionary"""

    while True:
        word = raw_input('Word: ')
        if not word:
            return
        meaning = raw_input('Meaning: ')
        py_dict[word] = meaning


def InvertDefinitions ():
    """
    prints inverted items (value, key) in alphabetical order
    """
    
    inverted = []
    for (key, value) in py_dict.items():
        inverted += [(value, key)]
        
    inverted.sort()
    
    for (value, key) in inverted:
        print value, ':', key
        

def FindDefinitions():
    """Reports a key:value pair for a given key"""

    while True:
        word = raw_input('Word to find: ')
        if not word:
            return
        try:
            print '%s : %s' % (word, py_dict[word])
        except KeyError:
            print '%s is not in the dictionary.' % word


def PrintEntries():
    """Prints out the dictionary entries, sorted by key"""

    for word in sorted(py_dict):
        print '%s : %s' % (word, py_dict[word])


def main():
    """Runs the user interface for dictionary manipulation."""

    # The choices dictionary has function names for values.
    choices = {
                'add'         : CollectEntries,
                'definitions' : InvertDefinitions,
                'find'        : FindDefinitions,
                'print'       : PrintEntries
                }
    prompt = MakePrompt(choices)

    while True:
        raw_choice = raw_input(prompt)
        if not raw_choice:
            break
        given_choice = raw_choice[0].lower()
        for maybe_choice in choices: 
            if maybe_choice[0] == given_choice:
                # The appropriate function is called using the dictionary value for the name of the function.    
                choices[maybe_choice]()
                break
        else:
            print '%s is not an acceptible choice.' % raw_choice


if __name__ == '__main__':
    main()


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab09_exer1.py ===========
Choose (a)dd, (d)efinitions, (f)ind, (p)rint (enter to quit) d
break out of a loop and skip the else : break
do nothing : pass
go to the next iteration of the loop : continue
set up looping : for
Choose (a)dd, (d)efinitions, (f)ind, (p)rint (enter to quit) 
>>> 
"""
