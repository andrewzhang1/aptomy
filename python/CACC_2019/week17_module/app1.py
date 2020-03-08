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

print("binaryToDecimal 111000 ==> ", binaryToDecimal(111000))
print("decimal 255 to binary is: ", decimalToBinary(255))