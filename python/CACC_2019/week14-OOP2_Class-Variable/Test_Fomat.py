class Fullname():
    def __init__(self, first, last, age):
        self.first = first
        self.last = last
        self.age = age

    def showID(self):
        return '{} {} {}'.format(self.last, self.first, self.age)
        print(self.first, self.last, self.age)

andy = Fullname("Andrew", "Zhang", 56)
print(andy.showID())

# formatting a string using a numeric constant
print ("Hello, I am {} years old !".format(18))


# This one does not work
Fullname.showID()