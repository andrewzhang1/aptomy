#!/usr/bin/env python
"""A Circle class, acheived by overriding __getitem__ which provides
the behavior for indexing, i.e., [].  This also provides the correct
cyclical behavior whenever an iterator is used, i.e., for,
enumerate() and sorted().  reversed() needs __reversed__ defined.
"""   
class Circle: 
   
    def __init__(self, data, times):
        """Put the 'data' in a circle that goes around 'times' times."""
        self.data = data
        self.times = times

    def __getitem__(self, i): 
        """circle[i] --> Circle.__getitem__(circle, i)."""
        l_self = len(self)
        if i >= self.times * l_self:
            raise IndexError, \
                  "Error raised: circle object only goes around %d times"\
                  % self.times
        return self.data[i % l_self]

    def __len__(self):
        return len(self.data)

def main():
    circle = Circle("around", 3)

    print "Works with circle[i], for i > len(circle) too:"
    for i in range(4 * len(circle)):
        try:
            print "circle[%2d] = %s" % (i, circle[i])
        except IndexError, msg:
            print msg
            break

    print "Works with sorted:"
    print sorted(circle)

    print "Works for nested loops:"
    small_circle = Circle("XO", 2)
    for i, elementi in enumerate(small_circle):
        print "small_circle[%d] = %s" % (i, elementi)

    for i, elementi in enumerate(small_circle):
        for j, elementj in enumerate(small_circle):
            print "%3d:%3d -> %s%s" % (i, j,
                                       elementi, elementj)
if __name__ == '__main__':
    main()

"""
$ circle_def.py
Works with circle[i], for i > len(circle) too:
circle[ 0] = a
circle[ 1] = r
circle[ 2] = o
circle[ 3] = u
circle[ 4] = n
circle[ 5] = d
circle[ 6] = a
circle[ 7] = r
circle[ 8] = o
circle[ 9] = u
circle[10] = n
circle[11] = d
circle[12] = a
circle[13] = r
circle[14] = o
circle[15] = u
circle[16] = n
circle[17] = d
Error raised: circle object only goes around 3 times
Works with sorted:
['a', 'a', 'a', 'd', 'd', 'd', 'n', 'n', 'n', 'o', ...
Works for nested loops:    
small_circle[0] = X        
small_circle[1] = O         (continued from bottom)  
small_circle[2] = X          1:  3 -> OO
small_circle[3] = O          2:  0 -> XX
  0:  0 -> XX                2:  1 -> XO
  0:  1 -> XO                2:  2 -> XX
  0:  2 -> XX                2:  3 -> XO
  0:  3 -> XO                3:  0 -> OX
  1:  0 -> OX                3:  1 -> OO
  1:  1 -> OO                3:  2 -> OX
  1:  2 -> OX                3:  3 -> OO
$ """
