class Animal(object):
    def __init__(self, age):
        self.age = age
        self.name = None
    def get_age(self):
        return self.age
    def get_name(self):
        return self.name
    def set_age(self, newage):
        self.age = newage
    def set_name(self, newname=""):
        self.name = newname
    def __str__(self):
        return "animal: " + str(self.name) + ":" + self(self.age)

a = Animal(15)

print(a.age)
newname = a.set_name("Andrew")
print(newname)

class cat(Animal):
    def speak(self):
        print("meow")
    def __str__(self):
        return "cat:" + self(self.name)+ ":" + self(self.age)















