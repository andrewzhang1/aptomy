#!/usr/bin/env python
""" Lab06.2 (Deitel 5.3)
Use a list to solve the following problem: Read in 5 numbers.  As each
number is read, print it only if it is not a duplicate of a number
already read.
"""

def AskForAndPrintUniqueNumbers(number_of_numbers):
    numbers = []
    for i in range(number_of_numbers):
        while True:
            new_number = raw_input("Number please: ")
            try:
                new_number = float(new_number)
            except ValueError:
                print new_number, "is not a number."
                continue
            break
        if not new_number in numbers:
            print new_number
            numbers += [new_number]
def main():
    AskForAndPrintUniqueNumbers(5)
main()

"""
$ lab06_2.py
1
1.0
Number please: 2
2.0
Number please: xx
xx is not a number.
Number please: 3
3.0
Number please: 4
4.0
Number please: 5
5.0
$ 
"""
