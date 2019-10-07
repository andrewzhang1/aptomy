

"""
Convert string according to telephone keypad
"""


def Keypad (string):
    """
    Inputs:  a string of alphabetic characters
    Returns: a string of numeric digits mapped as on telephone keypad
                abc  -> 2
                def  -> 3
                ghi  -> 4
                jkl  -> 5
                mno  -> 6
                pqrs -> 7
                tuv  -> 8
                wxyz -> 9
    """

    digits = ''    
    for char in string:
        if char in 'ABCabc':
            num = '2'
        elif char in 'DEFdef':
            num = '3'
        elif char in 'GHIghi':
            num = '4'
        elif char in 'JKLjkl':
            num = '5'
        elif char in 'MNOmno':
            num = '6'
        elif char in 'PQRSpqrs':
            num = '7'
        elif char in 'TUVtuv':
            num = '8'
        elif char in 'WXYZwxyz':
            num = '9'
        else:
            num = char
            
        digits += num

    return digits


# tests
if __name__ == '__main__':
    tests = ["peanut", "salt", "lemonade", "good time", ":10", "Zilch"]
    for test in tests:
        print test
        print Keypad(test)


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab07_exer1.py ===========
peanut
732688
salt
7258
lemonade
53666233
good time
4663 8463
:10
:10
Zilch
94524
>>> 
"""
