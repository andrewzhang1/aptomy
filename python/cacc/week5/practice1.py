# The code should request user to input an integer,
# if the integer is odd, print 10 odd integers after the input integer,
# if even, print 10 even integers after the input. Implement in at least two ways.

def sol1():
    number = int(input("input an integer: "))
    for i in range(10):
        number += 2
        print(number)
def sol2():
    number = int(input("input an integer: "))
    count = 0
    while True:
        number, count = number+2, count+1
        print(number)
        if count >= 10:
            break
def sol3():
    number = int(input("input an integer: "))
    count = 0
    while count < 10:
        number +=2
        count += 1
        print(number)
def sol4():
    number = int(input("input an integer: "))
    for i in range(2,22,2):
        print(number+i)
def sol5():
    number = int(input("input an integer: "))
    print('\n'.join([str(x + number) for x in range(2, 22, 2)]))

if __name__ == "__main__":
    sol1()
    sol2()
    sol3()
    sol4()
    sol5()
