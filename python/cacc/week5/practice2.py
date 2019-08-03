# The code should request user to input an integer,
# if the integer is odd, print 10 odd integers after the input integer,
# if even, print 5 even integers after the input. Implement in at least two ways.

def sol1():
    number = int(input("input an integer: "))
    if number%2 == 0:
        r = 5
    else:
        r = 10
    for i in range(r):
        number += 2
        print(number)
def sol4():
    number = int(input("input an integer: "))
    r = 11 if number%2 == 0 else 22
    for i in range(2,r,2):
        print(number+i)

if __name__ == "__main__":
    sol1()
    sol4()
