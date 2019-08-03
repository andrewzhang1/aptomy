#!/usr/bin/env python   
"""default.py -- demonstrates defaulted arguments."""

def GoToThePark(name, best_friend="Jose'"): 
    print name, 'and', best_friend 
    print 'go to the park'
    print 'play hide-and-seek'
    print 'till long after dark'
    print

GoToThePark('Charlie', 'Jacqueline')
GoToThePark('Judi')

"""
$ default.py
Charlie and Jacqueline
go to the park
play hide-and-seek
till long after dark

Judi and Jose'
go to the park
play hide-and-seek
till long after dark

$

"""
