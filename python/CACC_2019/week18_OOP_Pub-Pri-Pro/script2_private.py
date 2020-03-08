
# Script Name: script2_private.py
'''
By declaring your data
 member private you mean, that nobody
should be able to access it from outside the class:
"strong you can’t touch this policy"

Python supports a technique called name mangling (double underscore__)
'''

class Cup:
    def __init__(self, color):
        self._color = color     # protected variable
        self.__content = None   # private variable

    def fill(self, beverage):
        self.__content = beverage

    def empty(self):
        self.__content = None


redCup = Cup("red")
redCup = Cup("green")
redCup._Cup__content = "tea"

print(redCup._Cup__content)

# Output:
# tea