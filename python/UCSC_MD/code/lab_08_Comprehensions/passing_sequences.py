#!/usr/bin/env python
"""Passing sequences.""" 

def ChangeNumber(number):
    number = 4
def ChangeString(string):
    string = "Boo"
def ChangeTuple(a_tuple):
    a_tuple = ('a', 'b')
def ChangeList(a_list):
    a_list = ['a', 'b']
def ChangeInList(a_list):
    a_list[1] = 'z'

def main():
    number = 3
    ChangeNumber(number)
    print "Numbers don't change:", number

    string = "Halloween"
    ChangeString(string)
    print "Strings don't change:", string

    a_tuple = 1, 2
    ChangeTuple(a_tuple)
    print "Tuples don't change:", a_tuple

    a_list = [1, 2, 3]
    ChangeList(a_list)
    print "Lists don't change:", a_list

    ChangeInList(a_list)
    print "Changing within lists does change:", a_list

if __name__ == '__main__':
    main()
"""
$ passing_sequences.py
Numbers don't change: 3
Strings don't change: Halloween
Tuples don't change: (1, 2)
Lists don't change: [1, 2, 3]
Changing within lists does change: [1, 'z', 3]
$ """
