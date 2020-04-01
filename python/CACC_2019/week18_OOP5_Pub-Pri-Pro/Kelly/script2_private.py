class Cup:
    def __init__(self, color):
        self._color = None
        self.__content = None

    def fill(self, beverage):
        self.__content = beverage

    def empty(self):
        self.__content = None

redCup = Cup("red")
redCup._Cup__content = "tea"

print(redCup._Cup__content)