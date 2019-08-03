

"""
Example of calling IsValidIdentifier function
"""

import hw07_1


def main():
    """
    Main program invoked at interpreter
    """

    while True:
        text = raw_input( 'Enter an identifier to validate (null to quit): ')
        if text:
            (valid, reason) = hw07_1.IsValidIdentifier( text)
            print reason
        else:
            break


if __name__ == '__main__':
    main()


"""
>>> 
============= RESTART: C:/Users/E1HL/Python/exercises/hw07_2.py =============
Enter an identifier to validate (null to quit): 23_skidoo
Invalid: first symbol must be alphabetic or underscore.
Enter an identifier to validate (null to quit): Shazam!
Invalid: '!' is not allowed.
Enter an identifier to validate (null to quit): pass
Invalid: this is a keyword!
Enter an identifier to validate (null to quit): _scooby_doo_
Valid!
Enter an identifier to validate (null to quit): 
>>> 
"""
