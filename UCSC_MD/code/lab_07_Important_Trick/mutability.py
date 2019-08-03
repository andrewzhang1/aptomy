#!/usr/bin/env python
"""Mutability of sequence objects.""" 

x = 3
y = x
x *= 30

print y    # y = 3   not mutable

x = (1, 2)
y = x
x = 5      

print y   # y = (1, 2) not mutable

x = [1, 2]
y = x
x[0] = 100   
print y   # y == x still, mutable
          # [100, 2]

x = (1, [10, 22], 3)
x[1][0] = 100
print x  # x[1] is a list, mutable
         # So, (1, [100, 22], 3)

"""
$ mutability.py
3
(1, 2)
[100, 2]
(1, [100, 22], 3)
$
"""
