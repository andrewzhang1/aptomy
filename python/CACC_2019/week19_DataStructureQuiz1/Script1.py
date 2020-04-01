# Script name: app1.py

# call the function from the file of mathFunction1.py
# from the module1 of week17_module

from CACC_2019.week17_module.module1.mathFunction1 import add
from CACC_2019.week17_module.module1.mathFunction1 import decimalToBinary
from CACC_2019.week17_module.module1.mathFunction1 import binaryToDecimal
from CACC_2019.week17_module.module1.mathFunction1 import mul


# Or:
#from CACC_2019.week17_module.module1.mathFunction1 import *

add1 = add(5, 35)

mul1 = mul(3, 5)

print(add1)
print(mul1)


print("binaryToDecimal 100 ==> ", binaryToDecimal(100))
print("binaryToDecimal 110 ==> ", binaryToDecimal(110))
print("binaryToDecimal 11111111 ==> ", binaryToDecimal(11111111))
print("binaryToDecimal 11000000 ==> ", binaryToDecimal(11000000))

print("decimal 4 to binary is: ", decimalToBinary(4))
print("decimal 8 to binary is: ", decimalToBinary(8))
print("decimal 255 to binary is: ", decimalToBinary(255))

# Output:

# binaryToDecimal 100 ==>  4
# binaryToDecimal 110 ==>  6
# binaryToDecimal 11111111 ==>  255
# binaryToDecimal 11000000 ==>  192
# decimal 4 to binary is:  100
# decimal 8 to binary is:  1000
# decimal 255 to binary is:  11111111
