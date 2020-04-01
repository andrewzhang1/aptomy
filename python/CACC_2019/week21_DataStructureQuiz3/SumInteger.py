# Python3 program to calculate sum of
# all numbers present in a str1ing
# containing alphanumeric characters

# Function to calculate sum of all
# numbers present in a str1ing
# containing alphanumeric characters
import re

def find_sum(str1):
    # Regular Expression that matches digits in between a string
    return sum(map(int, re.findall('\d+', str1)))

# Driver code

# input alphanumeric str1ing
str1 = "ab4yz4d"

print(find_sum(str1))

# This code is contributed
# by Venkata Ramana B