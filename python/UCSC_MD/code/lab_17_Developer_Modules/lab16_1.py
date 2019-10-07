#!/usr/bin/env python
"""lab16_1.py A SortedDictionary class with only "description"
allowed as an attribute -- using __setattr__"""

class SortedDictionary(dict): 

    allowed_attributes = 'description',

    def keys(self):
        return sorted(dict.keys(self))
        # more robust is:
        # return sorted(super(type(self), self).keys())

    def __iter__(self):
        """If we don't define this, it will use the regular dictionary
        __iter__ which does not call SortedDictionary.keys()."""
        
        for each in self.keys():
            yield each

    def __setattr__(self, attribute_name, value):
        if attribute_name not in SortedDictionary.allowed_attributes:
            raise TypeError, "can't set attributes of class %s" \
                  % self.__class__.__name__
        self.__dict__[attribute_name] =  value

def main():
    for d in ( {'Zero':0, 'False':0, 'None':0, 'True':1}, # dictionary
               {},                                  # empty dictionary                 
               (('calling birds', 4), ('french hens', 3), # tuples
                ('turtle doves', 2), ('partridge in a pear tree', 1))
               ):
        sorted_dict = SortedDictionary(d)
        regular_dict = dict(d)
        print "regular_dict:", regular_dict.keys()
        print " sorted_dict:", sorted_dict.keys()
        print "         for:", ', '.join([str(k) for k in sorted_dict])
        
    sorted_dict.description = "Fourth Day of Christmas"
    print "sorted_dict.description =", sorted_dict.description
    try:
        regular_dict.description = "Fourth Day of Christmas"
    except AttributeError:
        pass
    else:
        print "Unexpected behavior!"
    sorted_dict.x = 3
    
if __name__ == '__main__':
    main()

"""
$ lab16_1.py
regular_dict: ['False', 'Zero', 'True', 'None']
 sorted_dict: ['False', 'None', 'True', 'Zero']
         for: False, None, True, Zero
regular_dict: []
 sorted_dict: []
         for: 
regular_dict: ['turtle doves', 'french hens',\
               'partridge in a pear tree', 'calling birds']
 sorted_dict: ['calling birds', 'french hens',\
               'partridge in a pear tree', 'turtle doves']
         for: calling birds, french hens, \
              partridge in a pear tree, turtle doves
sorted_dict.description = Fourth Day of Christmas
Traceback (most recent call last):
  File "./lab16_1.py", line 58, in <module>
    main()
  File "./lab16_1.py", line 55, in main
    sorted_dict.x = 3
  File "./lab16_1.py", line 32, in __setattr__
    % self.__class__.__name__
TypeError: can't set attributes of class SortedDictionary
$ """
