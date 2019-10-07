#!/usr/bin/env python
"""tables2.py Interactive 2-D string unwrapper.
"""
import tables

def main():
    while True:
        response = raw_input("Say something: ")
        if not response:
            break
        words = response.split()
        tables.PrintTable(words)

if __name__ == '__main__':
    main()
""" 
$ tables2.py
Say something: "Pythonic Thinking"
" P y t h o n i c
T h i n k i n g "

Say something: 
$ """
