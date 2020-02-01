
# Script Name: script3_protect.py
'''
Protected member is (in C++ and Java) accessible only
from within the class and it’s subclasses.

How to accomplish this in Python? The answer is – by convention.
By prefixing the name of your member with a single underscore,
you’re telling others “don’t touch this, unless you’re a subclass”
'''
class Cup:
    def __init__(self):
        self.color = None
        self._content = None # protected variable

    def fill(self, beverage):
        self._content = beverage

    def empty(self):
        self._content = None

cup = Cup()
cup._content = "tea"

print(cup._content)

# Output:
# tea