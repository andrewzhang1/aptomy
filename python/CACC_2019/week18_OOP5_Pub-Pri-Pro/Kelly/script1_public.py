class Cup:
    def __init__(self):
        self.color = None
        self.content = None

    def fill(self, beverage):
        self.content = beverage

    def empty(self):
        self.content = None

redCup = Cup()
redCup.color = "red"

print(redCup.color)
redCup.content = "tea"

print(redCup.content)
redCup.empty()
print(redCup.fill("coffee"))