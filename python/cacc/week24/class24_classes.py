class CaccClass:
    """A class at CACC school"""
    year = 2019
    projects = []

    def __init__(self, subject, level):
        self.subject = subject
        self.level = level

    def getLevel(self):
        return self.level

myInstance_1 = CaccClass("Python", "Beginner")
print(myInstance_1.getLevel())
myInstance_1.level = "Intermediate"
print(myInstance_1.getLevel())
print(myInstance_1.year)
myInstance_1.year = 2020
print(myInstance_1.year)
myInstance_1.projects.append("Pizza Slicing")
print(myInstance_1.projects)
print()

myInstance_2 = CaccClass("Python", "Advanced")
print(myInstance_2.getLevel())
print(myInstance_2.year)
myInstance_2.projects.append("Guess Number")
print(myInstance_2.projects)