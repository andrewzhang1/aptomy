class Greeter:
    def Greeter(self):
        print ("Hello, World")

def main():
    fred = Greeter()
    print(fred.Greeter())
    alma = Greeter()
    print(alma.Greeter())
    print ("Fred is", id(fred))

if __name__ == '__main__':
    main()