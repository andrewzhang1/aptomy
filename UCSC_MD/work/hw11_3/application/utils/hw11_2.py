

"""
A function which determines whether a normalized (lower cased and trimmed) string is a palindrome
"""


def Palindromize( phrase):
    """
    Input:    a string or number
    Returns:  if a palindrome, the input formatted as a string, lower cased, trimmed of whitespace;
              otherwise None
    """

    # given phrase as int or float, convert to str so that len() applies
    # do not consider phrase of length < 3
    if len( str( phrase)) < 3:
        return None

    # given phrase with length >= 3, convert to str, convert to lower case,
    # and remove whitespace (using .split() and ''.join())
    pal = ''.join( str( phrase).lower().split())
    num = len( pal)

    # compare characters at opposite ends of pal, successively toward middle
    for i in range( 0, num/2, 1):
        if pal[i] <> pal[-(i + 1)]:
            return None

    # pal satisfies required palindrome properties
    return pal


if __name__ == '__main__':
    Data = (
            1,
            123.321,
            '',
            'aa',
            'A A',
            ' A a ',
            'Murder for a jar of red rum',
            12321,
            'nope',
            'abcbA',
            3443,
            'what',
            'Never odd or even',
            'Rats live on no evil star'
            )

    for d in Data:
        p = Palindromize( d)
        if p:
            print "'%s' is a palindrome: '%s'" % (d, p)
        else:
            print "'%s' is not a palindrome" % (d)


"""
>>> 
============= RESTART: C:/Users/E1HL/Python/exercises/hw11_2.py =============
'1' is not a palindrome
'123.321' is a palindrome: '123.321'
'' is not a palindrome
'aa' is not a palindrome
'A A' is a palindrome: 'aa'
' A a ' is a palindrome: 'aa'
'Murder for a jar of red rum' is a palindrome: 'murderforajarofredrum'
'12321' is a palindrome: '12321'
'nope' is not a palindrome
'abcbA' is a palindrome: 'abcba'
'3443' is a palindrome: '3443'
'what' is not a palindrome
'Never odd or even' is a palindrome: 'neveroddoreven'
'Rats live on no evil star' is a palindrome: 'ratsliveonnoevilstar'
>>> 
"""
