#!/usr/bin/env python

""" unpack.py - sequences and dictionaries can be unpacked into 
a argument list with the * and ** operators. """

def PrintThings(a, b, c, *tup_args, **dict_args):
    print 'First three args are required:', a, b, c,
    if tup_args:   
        print '\n  From tup_args:',  
        for stuff in tup_args: 
            print stuff, 
    if dict_args:
        print '\n  From dict_args:',
        for k in dict_args.keys():
            print k, '->', dict_args[k],
    print

def PrintDict(uno=8, dos=10, **rest):
    print uno, dos, rest

def main():
    tup = ('Eat','chocolate','candy')
    PrintThings(*tup)
    PrintThings('this', 'that', 'other')
    L = ['live','life','in','the', 'fast', 'lane']
    PrintThings(*L)
    D = {'uno':1, 'dos':2, 'tres':3, 'cuatro':4}
    PrintThings(*tup, **D)
    S = 'Too fast'
    PrintThings(*S)
    print "PrintDict(**D)"
    PrintDict(**D)
    print "PrintThings(*D)"
    PrintThings(*D)

if __name__ == '__main__':
    main()










"""
$ unpack.py
First three args are required: Eat chocolate candy
First three args are required: this that other
First three args are required: live life in 
  From tup_args: the fast lane
First three args are required: Eat chocolate candy 
  From dict_args: cuatro -> 4 dos -> 2 tres -> 3 uno -> 1
First three args are required: T o o 
  From tup_args:   f a s t
PrintDict(**D)
1 2 {'cuatro': 4, 'tres': 3}
PrintThings(*D)
First three args are required: cuatro dos tres 
  From tup_args: uno
$"""
