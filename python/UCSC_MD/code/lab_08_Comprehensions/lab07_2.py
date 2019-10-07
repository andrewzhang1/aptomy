#!/usr/bin/env python
"""lab07_2.py -- Interactive identifier testing"""

import lab07_1

def main():
    while True:
        translate_this = raw_input("Word to translate: ")
        if translate_this == '':
            break
        print lab07_1.TranslateToKeypad(translate_this)

if __name__ == '__main__':
    main()

"""
$ lab07_2.py
Word to translate: diamond
3426663
Word to translate: Ruby
7829
Word to translate: zirconium
947266486
Word to translate: 
$
"""
