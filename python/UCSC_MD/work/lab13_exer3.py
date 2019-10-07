

"""
"""


import random

import lab_08_Comprehensions.lab08_2 as deck


def Card():
    """
    Generator function:
    Each time called, yields one card from randomly shuffled deck 
    """

    cards = deck.GetCards()
    random.shuffle( cards)
    for card in cards:
        yield card


def Hand( cobj, size):
    """
    """

    hand = []
    try:
        for i in range( size):
            hand += [cobj.next()]       # deal next card
    except StopIteration:
        return

    return hand


def Game( players=4, size=5):
    """
    """

    # create generator object
    cobj = Card()

    # get 'players' hands of 'size' cards
    for player in range( players):
        print "Player %d has hand: %s" % (player, Hand( cobj, size))


if __name__ == '__main__':
    Game()
    print
    Game( 6, 3)


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab13_exer3.py ===========
Player 0 has hand: ['8 of Clubs', '6 of Diamonds', '6 of Hearts', '9 of Diamonds', 'Queen of Hearts']
Player 1 has hand: ['Ace of Spades', '3 of Spades', '5 of Diamonds', '4 of Hearts', '2 of Hearts']
Player 2 has hand: ['8 of Hearts', '10 of Diamonds', 'Queen of Spades', 'King of Spades', '2 of Spades']
Player 3 has hand: ['7 of Spades', '2 of Clubs', 'Ace of Clubs', 'Joker', 'Queen of Clubs']

Player 0 has hand: ['Jack of Diamonds', '8 of Spades', '3 of Clubs']
Player 1 has hand: ['2 of Diamonds', '8 of Clubs', '3 of Hearts']
Player 2 has hand: ['10 of Clubs', '9 of Spades', '9 of Hearts']
Player 3 has hand: ['5 of Hearts', 'Joker', '4 of Hearts']
Player 4 has hand: ['Ace of Hearts', 'Jack of Clubs', '4 of Diamonds']
Player 5 has hand: ['5 of Clubs', '7 of Clubs', '9 of Diamonds']
>>> 
"""
