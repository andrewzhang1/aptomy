class Polygon:
    """ Polygon class """

    def __init__(self, name, sides):
        self.name = name
        self.sides = sides

    def getName(self):
        return self.name

class Square(Polygon):
    """ Square class """

    def setLength(self, length):
        self.length = length

    def findArea(self):
        return self.length*self.length

class Rectangular(Polygon):
    """ Rectangular class """

    def setLength(self, length, width):
        self.length = length
        self.width = width

    def findArea(self):
        return self.length*self.width

s1 = Square("Square", 4)
s1.setLength(5)
print(s1.getName())
print(s1.findArea())
print()

r1 = Rectangular("Rectangular", 4)
r1.setLength(4, 5)
print(r1.getName())
print(r1.findArea())