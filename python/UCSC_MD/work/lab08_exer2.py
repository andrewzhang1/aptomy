

def Deck ():
    """
    List 52 card deck, by suit (Clubs, Diamonds, Hearts, Spades), by face value
    """

    faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    suits = ['C', 'D', 'H', 'S']

    return ['%s of %s' % (face, suit) for suit in suits for face in faces]


if __name__ == '__main__':
    print Deck()


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab08_exer2.py ===========
['2 of C', '3 of C', '4 of C', '5 of C', '6 of C', '7 of C', '8 of C', '9 of C', '10 of C', 'J of C', 'Q of C', 'K of C', 'A of C', '2 of D', '3 of D', '4 of D', '5 of D', '6 of D', '7 of D', '8 of D', '9 of D', '10 of D', 'J of D', 'Q of D', 'K of D', 'A of D', '2 of H', '3 of H', '4 of H', '5 of H', '6 of H', '7 of H', '8 of H', '9 of H', '10 of H', 'J of H', 'Q of H', 'K of H', 'A of H', '2 of S', '3 of S', '4 of S', '5 of S', '6 of S', '7 of S', '8 of S', '9 of S', '10 of S', 'J of S', 'Q of S', 'K of S', 'A of S']
>>> 
"""
