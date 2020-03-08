# Script Name: script4__main__.py

'''
Here is a very useful Main Function:

In Python "if__name__== "__main__" allows you to run
the Python files either as reusable modules or standalone programs
'''

class Greeter:

    def Greeter(self):
        print("Hello, World")

def main():
    fred = Greeter()
    print(fred.Greeter())
    alma = Greeter()
    print(alma.Greeter())
    print("Fred is", id(alma))

if __name__ == '__main__':
    main()

# Output:
# Hello, World
# None
# Hello, World
# None
# Fred is 2511619448904