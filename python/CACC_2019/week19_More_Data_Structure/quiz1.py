def factorial(n):
    num = 1
    while n >= 1:
        num = num * n
        n = n - 1
    return num

# Run a test of factorial 6:
print (factorial(6))


# 2nd way: use math function
from math import *
print (factorial(6))