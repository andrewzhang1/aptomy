#!/usr/bin/env python
"""static.py (Optional) Class variables are supported and work nicely,
but there is no obvious way to call a method unless you have an
object."""  

class Static:
    number = 0
    
    def __init__(self):
        Static.number += 1
        self.number = Static.number

    def __str__(self):
        return "%d of %d" % (self.number, Static.number)

def main():
    objects = [Static() for i in range(3)]
    print ', '.join([str(obj) for obj in objects])
    
if __name__ == '__main__':
    main()
"""
$ static.py
1 of 3, 2 of 3, 3 of 3
$ """

