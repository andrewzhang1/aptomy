counter = 1


def doLotsOfStuff():
    global counter

    for i in (1, 2, 3):
        counter += 1


doLotsOfStuff()

print(counter)

print(r"\nwoow")
print("\x48\x49!")

print( 0xb)


class parent:
    def __init__(self, param):
        self.v1 = param

class child(parent):
    def __init__(self, param):
        self.v2 = param

print("hi")
obj = child(11)
print(obj.v2)


class Account:
    def __init__(self, id):
        self.id = id
        id = 666

acc = Account(123)
print(acc.id)