
# Script name: mathFunction1.py


def add(x,  y):
    return x + y

def mul(x,y):
    return x * y


# Function to convert Decimal number
# to Binary number

def decimalToBinary(n):
    return bin(n).replace("0b", "")

print("decimal 8 to binary is: ", decimalToBinary(8))

# Driver code
#if __name__ == '__main__':

#c = print(add(3,5))

#def multi(x, y):
#    return x * y

#calc = mul(3,4)
#print(c)


def binaryToDecimal(binary):
    binary1 = binary
    decimal, i, n = 0, 0, 0
    while (binary != 0):
        dec = binary % 10
        decimal = decimal + dec * pow(2, i)
        binary = binary // 10
        i += 1
    print(decimal)

#x = binaryToDecimal(10)
# print("binaryToDecimal",x)
#print("binary 1100's decimal is: ", binaryToDecimal(1010))