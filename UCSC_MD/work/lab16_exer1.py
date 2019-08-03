

class SortedDictionary( dict):

    allowed_attrnams = ('description', )

    def keys( self):
        klist = super( type(self), self).keys()     # type(self) = SortedDictionary
#        return sorted( klist)                      # creates new sorted list:
                                                    #   available for any iterable, less memory efficient
        return klist.sort()                         # sortslist in place:
                                                    #   available only for lists,   more memory efficient

    def __iter__( self):                            # must override dict.__iter__
                                                    #because it will not use self.keys
        for key in self.keys:
            yield key                               # __iter__ is a generator

    def __setattr__( self, attrnam, attrval):
        if attrnam in self.allowed_attrnams:
#            super( type( self), self).__setattr__( attrnam, attrval)
            self.__dict__[attrnam] = attrval        # direct insert/update; avoid possible recursion
        else:
            raise AttributeError, "May not define attribute '%s'" % (attrnam)


if __name__ == '__main__':
    d = SortedDictionary( {2:'b', 1:'a', 3:'c'})
    print "sorted dictionary is: ", d
    print

    d.description = "add object attribute 'description'"
    print "description is: ", d.description
    print

    d.badattr = "try to add object attribute 'badattr'"
    print d.badattr
    print


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab16_exer1.py ===========
sorted dictionary is:  {1: 'a', 2: 'b', 3: 'c'}

description is:  add object attribute 'description'


Traceback (most recent call last):
  File "C:/Users/E1HL/Python/exercises/lab16_exer1.py", line 36, in <module>
    d.badattr = "try to add object attribute 'badattr'"
  File "C:/Users/E1HL/Python/exercises/lab16_exer1.py", line 24, in __setattr__
    raise AttributeError, "May not define attribute '%s'" % (attrnam)
AttributeError: May not define attribute 'badattr'
>>> 
"""
