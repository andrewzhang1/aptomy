#!/usr/bin/env python
"""A stack again, this time using the built-in "list" type.

A stack is just a list with a "push" method, since the list
already has a "pop".  When it is-a "list" it inherits all
the builtin facilities of the list.
""" 

class Stack(list):
    
    def push(self, thing):
        list.append(self, thing)

if __name__ == '__main__':
    stack = Stack()
    stack.push('Gone With The Wind')
    stack.push('Maltese Falcon')
    stack.push('Fifth Element')
    print "The stack has a rather nice __str__ already:"
    print stack
    print "The stack has all the list facilities, plus the 'push':"
    print dir(stack)
    print "Sorting then popping:"
    stack.sort()
    print stack.pop()
"""
$ new_style_stack_def.py
The stack has a rather nice __str__ already:
['Gone With The Wind', 'Maltese Falcon', 'Fifth Element']
The stack has all the list facilities, plus the 'push':
['__add__', '__class__', '__contains__', '__delattr__', '__delitem__',
 '__delslice__', '__dict__', '__doc__', '__eq__', '__ge__',
 '__getattribute__', '__getitem__', '__getslice__', '__gt__',
 '__hash__', '__iadd__', '__imul__', '__init__', '__iter__', '__le__',
 '__len__', '__lt__', '__module__', '__mul__', '__ne__', '__new__',
 '__reduce__', '__reduce_ex__', '__repr__', '__reversed__', '__rmul__',
 '__setattr__', '__setitem__', '__setslice__', '__str__',
 '__weakref__', 'append', 'count', 'extend', 'index', 'insert', 'pop',
 'push', 'remove', 'reverse', 'sort']
Sorting then popping:
Maltese Falcon
$
"""    
