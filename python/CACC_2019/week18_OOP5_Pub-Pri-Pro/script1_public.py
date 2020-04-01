
# Script Name: script1_public.py

'''
Note: This scritp show All member variables and methods
are public by default in Python. So when you want to
make your member public, you just do nothing.
'''

class Cup:
    def __init__(self):
        self.color = None
        self.content = None

    def fill(self, beverage):
        self.content = beverage

    def empty(self):
        self.content = None

# This will be wrong :
# redCup = Cup("Red")

# Need to instanciate the class first:
redCup = Cup()

# Then we can assign "red" to the color:
redCup.color = "red"
print(redCup.color)
redCup.content = "tea"

print(redCup.content)
redCup.empty()
print(redCup.fill("coffee"))

#
# Output:
# red
# tea
# None
