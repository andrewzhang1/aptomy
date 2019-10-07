

def MoneyString( num):
    """
    Given num:
    - get whether negative
    - round num to nearest cent by string formatting
    - slice string to dollars and cents
    - digits as list of dollars characters
    - reverse digits to get location of thousands separators
    - build chars list with embedded thousands separators
    - reverse chars for readable order
    - join chars into new string dollars
    Return $dollars.cents string, applying negative if given
    """

    neg = False
    if num < 0:
        num *= -1
        neg = True

    amount  = "%.2f" % (num)
    dollars = amount[:-3]
    cents   = amount[-2:]

    digits = list(dollars)
    digits.reverse()
    
    chars = []
    for (i, digit) in enumerate(digits):
        if i > 0 and i % 3 == 0:
            chars += ','
        chars += digit
        
    chars.reverse()   
    dollars = ''.join(chars)
    
    if not neg:   
        return  "$%s.%s" % (dollars, cents)
    else:
        return "-$%s.%s" % (dollars, cents)


if __name__ == '__main__':
    print MoneyString( 3)
    print MoneyString( 14.3123)
    print MoneyString( 1234567.89)
    print MoneyString( -88.888)


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab08_exer4.py ===========
$3.00
$14.31
$1,234,567.89
-$88.89
>>> 
"""
