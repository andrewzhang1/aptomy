# https://www.youtube.com/watch?v=-DP1i2ZU9gk

class Coordiate(object):
    # object is very basic, you can use it an attribute
    # data attribute: what is the object: x,y for example
    # procedure attributes: method (function): how we interact with the object
    # use special method to create an instance:
    # self is a parameter to refer to an instance of the class

    def __str__(self):
        return "<" + str(self.x) + "," + str(self.y) + ">"

    def __init__(self, x, y):
        self.x = x
        self.y = y


    def addTwo(self,x,y):
        return x + y

    def distance(self, other):
        x_diff_sq = (self.x - other.x)**2
        y_diff_sq = (self.y - other.y) ** 2
        return (x_diff_sq + y_diff_sq)**0.5


# Start to create an instance of a calss

c = Coordiate(2,3) # when we create an object, we only give two parameters
                   # self means the object of c, so it's omitted.

print(c)
print("====")
print(type(c))
print("====")

zero = Coordiate(0,0)
add1 = c.addTwo(2,3)

print(c.x)
print(c.y)

print("====")
print("add1 is: ", add1)
print (c.distance())
print(zero)


























































