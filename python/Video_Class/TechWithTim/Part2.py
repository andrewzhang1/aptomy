# Part 2: add one more method: add_one
class Dog:
  def add_one(self, x):
    return x + 1

  def bark(self):
    print("bark")

d = Dog()  # A variable d assinged to instance of Class Dog()
d.bark()

print(d.add_one(2))
print(type(d)) # <class '__main__.Dog'> --> the object of the class; the "d" is called
# __main__ tells us what moudule this class was defined in now by default the module your run is called main module