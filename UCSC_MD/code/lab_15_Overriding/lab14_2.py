#!/usr/bin/env python
"""
lab14_2.py  Implement a Stack class.  It should
have two functions: you add things to the top of your
stack (usually called push); and you take things from
the top of your stack, (usually called pop)."""

class Stack:
    def __init__(self, starter=None):
        if starter == None:
            self.things = []
            return
        try:
            # Here we accept any sequence type
            self.things = list(starter)
        except TypeError:
            # Here we accept any non-sequence type
            self.things = [starter]
            
    def push(self, thing):
        self.things += [thing]

    def pop(self):
        try:
            return self.things.pop()
        except IndexError:
            return None
def main():
    box = Stack()
    box.pop()
    box.push('nickel')
    box.push('dime')
    print box.pop()
    print box.pop()
    print box.pop()
    print "Initializations:"
    for init in ([1, 2], "sunshine", 3.2):
        s = Stack(init)
        print "%s:" % (init)
        while True:
            popped = s.pop()
            if popped:
                print popped,
            else:
                print
                break
    
if __name__ == '__main__':
    main()









"""
$ lab14_2.py
dime
nickel
None
$ python -i lab_14_2.py
dime
nickel
None
None
Initializations:
[1, 2]:
2 1
sunshine:
e n i h s n u s
3.2:
3.2
>>> x = Stack('ab')
>>> x.pop()
'b'
>>> y = Stack(x)
>>> y.pop()
<__main__.Stack instance at 0xb7ea42ac>
>>> y = Stack(x)
>>> y.pop().pop()
'a'
>>> 
"""
