
# Script name: mathFunction1.py


def add(x,  y):
    return x + y

def mul(x,y):
    return x * y


# Function to convert Decimal number
# to Binary number

def decimalToBinary(n):
    return bin(n).replace("0b", "")

def binaryToDecimal(binary):
    binary1 = binary
    decimal, i, n = 0, 0, 0
    while (binary != 0):
        dec = binary % 10
        decimal = decimal + dec * pow(2, i)
        binary = binary // 10
        i += 1
    return decimal

print("binary 100100 to decimal is: ", binaryToDecimal(10))



