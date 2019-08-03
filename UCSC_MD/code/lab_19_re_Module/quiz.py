#!/usr/bin/env python
"""Quiz answer."""

import sys
sys.path.insert(0, '..')
import pet_store.pet_def

class Rock(pet_store.pet_def.Pet):
    no_rocks = 0
    
    def __init__(self, name, weight):
        super(Rock, self).__init__(name)
        pet_store.pet_def.Pet.__init__(self, name)
        Rock.no_rocks += 1
        self.__weight = weight

def main():
    rocky = Rock("Rocky", "3 oz")
    gravel = Rock("Gravel", "1/2 oz")
    diamond = Rock("Diamond", ".03 oz")
    print "Made %d pet rocks." % Rock.no_rocks
    print rocky.__weight

if __name__ == '__main__':
    main()
"""
$ quiz.py
Made 3 pet rocks.
Traceback (most recent call last):
  File "./quiz.py", line 23, in <module>
    main()
  File "./quiz.py", line 20, in main
    print rocky.__weight
AttributeError: 'Rock' object has no attribute '__weight'
$ tree.py mall
|-- /mall
|   |-- /basket
|   |   |-- quiz.py
|   |-- /pet_store
|   |   |-- pet_def.py
|   |   |-- __init__.py
$ """
