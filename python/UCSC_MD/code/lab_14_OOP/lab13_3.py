#!/usr/bin/env python
"""lab13_3.py

A generator-based program to deal card games.

"""
import sys
import os
if __name__ == '__main__':
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))
import lab_08_Comprehensions.lab08_2 as cards
import random

__pychecker__ = "no-local"    # Ask me!

def DealCard():
    """Generator to yield one card at a time from a deck."""
    deck = cards.GetCards()
    random.shuffle(deck)
    for card in deck:
        yield card

def DealHand(no_cards):
    """Generator to yield a hand of no_cards cards."""
    card_generator = DealCard()
    while True:
        the_hand = []
        for i in range(no_cards):
            try:
                the_hand += [card_generator.next()]
            except StopIteration:
                the_hand += ['None']
        yield the_hand

def DealGame(no_players=4, no_cards=5):
    """Delivers a list of card hands, one for each player."""
    hand_generator = DealHand(int(no_cards))
    the_hands = []
    for i in range(int(no_players)):
        the_hands += [hand_generator.next()]
    return the_hands

def PrintGame(game_list):
    for player in game_list:
        print ', '.join([card for card in player])

def main():
    print "DealGame():"
    PrintGame(DealGame())
    print "DealGame(6, 3):"
    PrintGame(DealGame(6, 3))
    print "DealGame(11):"
    PrintGame(DealGame(11))
    
if __name__ == '__main__':
    main()
"""
$ lab13_3.py
DealGame():
Ace of Spades, 5 of Diamonds, 2 of Hearts, 8 of Clubs, 6 of Clubs
Joker, 9 of Spades, Joker, Jack of Diamonds, 3 of Spades
6 of Diamonds, Queen of Spades, 6 of Spades, Ace of Diamonds, 5 of Spades
7 of Diamonds, 9 of Clubs, 7 of Spades, 8 of Spades, 4 of Spades
DealGame(6, 3):
Jack of Clubs, 5 of Spades, 6 of Hearts
6 of Clubs, Queen of Clubs, Joker
Joker, 2 of Clubs, Queen of Spades
7 of Diamonds, 8 of Hearts, Queen of Hearts
Jack of Hearts, 9 of Diamonds, 5 of Hearts
2 of Hearts, 8 of Diamonds, 3 of Diamonds
DealGame(11):
9 of Diamonds, Queen of Diamonds, 8 of Diamonds, 6 of Spades, Jack of Diamonds
King of Diamonds, 3 of Spades, Joker, 10 of Diamonds, 10 of Spades
3 of Diamonds, Ace of Spades, 8 of Spades, 5 of Clubs, Ace of Clubs
4 of Clubs, 3 of Hearts, 9 of Hearts, King of Spades, 6 of Hearts
3 of Clubs, 4 of Hearts, Jack of Clubs, Queen of Clubs, 9 of Spades
King of Clubs, Ace of Diamonds, 6 of Clubs, 4 of Spades, 5 of Diamonds
Queen of Hearts, 5 of Hearts, King of Hearts, 2 of Clubs, 7 of Clubs
Queen of Spades, 2 of Spades, Jack of Hearts, 8 of Hearts, 2 of Diamonds
2 of Hearts, 6 of Diamonds, 7 of Hearts, 7 of Spades, 9 of Clubs
10 of Clubs, 10 of Hearts, Ace of Hearts, Joker, 7 of Diamonds
8 of Clubs, 5 of Spades, Jack of Spades, 4 of Diamonds, None
$ """
