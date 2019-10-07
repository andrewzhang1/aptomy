#!/usr/bin/env python
"""(Optional)
@staticmethod and @classmethod built-in decorators let you invoke
methods without having objects."""

import static  
               
class Static2(static.Static):

    @classmethod                   
    def JumpUp(cls, number):      # cls will be the class
        print 'In classmethod(JumpUp), cls =', cls
        static.Static.number += number
    
    @staticmethod
    def StartOver():           # no self for a static method!
        static.Static.number = 0

def main():
    objects = [Static2() for i in range(3)]
    print ', '.join([str(obj) for obj in objects])
    Static2.StartOver()
    objects += [Static2() for i in range(3)]
    print 'After StartOver()', ', '.join([str(obj) for obj in objects])
    Static2.JumpUp(100)
    objects += [Static2() for i in range(3)]
    print 'After JumpUp()', ', '.join([str(obj) for obj in objects])

if __name__ == '__main__':
    main()
    
"""
$ static2.py
1 of 3, 2 of 3, 3 of 3
After StartOver() 1 of 3, 2 of 3, 3 of 3, 1 of 3, 2 of 3, 3 of 3
In classmethod(JumpUp), cls = __main__.Static2
After JumpUp() 1 of 106, 2 of 106, 3 of 106, 1 of 106, 2 of 106, 3 of 106,
 104 of 106, 105 of 106, 106 of 106
$ """
 
