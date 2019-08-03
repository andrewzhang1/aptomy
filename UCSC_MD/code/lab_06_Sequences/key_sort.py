#!/usr/bin/env python
""" key_sort.py  Demonstrating a homemade key function
for sorting a list."""

def EvensFirstKey(number): 
    """A key function that will sort all even numbers before
    all odd numbers, because "even" sorts before "odd".
    """
    if number % 2:  # odd
        return ('odd', number)
    return ('even', number)

some_list = [2, 1, 0, 5, 3, 6, 8, 7, 9, 4]
print some_list
print "After regular sort", sorted(some_list)
print "After EvensFirstKey", sorted(some_list, key=EvensFirstKey)

"""    
$ key_sort.py
[2, 1, 0, 5, 3, 6, 8, 7, 9, 4]
After regular sort [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
After EvensFirstKey [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]
$ """
