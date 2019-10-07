#!/usr/bin/env python
"""lab17_2.py  -- deals card hands:
lab17_2.py  -- deals 4 hands of 5 cards
lab17_2.py -p 6 -c 3  -- deals 6 hands of 3 cards
"""
import sys
import random

sys.path.insert(0, '..')
import lab_08_Comprehensions.lab08_2 as cards

class Deck:
    """An iteratiing deck of cards that destroys each card as it is
    taken with a next call - or as it is iterated with a for-loop."""
    
    def __init__(self):
        self._cards = cards.GetCards()
        random.shuffle(self._cards)
        
    def __iter__(self):
        return self

    def next(self):
        try:
            return self._cards.pop()
        except IndexError:
            raise StopIteration

class GameDealer:
    def __init__(self, no_players=4, no_cards=5):
        self.no_players = int(no_players)
        self.no_cards = int(no_cards)
        self.hands = []
        self.deck = Deck()

    def DealAll(self):
        return [c for c in self.deck]

    def DealCard(self):
        try:
            return self.deck.next()
        except StopIteration:
            return "Blank"

    def DealHand(self):
        """Add a hand to the list of hands."""
        self.hands += [[self.DealCard() for i in range(self.no_cards)]]
        return self.hands[-1]

    def DealGame(self):
        """Make a list of hands, each hand is also a list."""
        return [self.DealHand() for i in range(self.no_players)]

    def __str__(self):
        """Returns a string representation of the dealt cards."""
        if not self.hands:
            self.DealGame()
        return  '\n'.join([', '.join(c for c in h) for h in self.hands])

def main():
    import optparse
    parser = optparse.OptionParser(\
        "%prog [-p number_of_players=4] [-c number_of_cards=5]")
    parser.add_option("-p", "--players", dest="no_players", 
                      help="number of players", default=4)
    parser.add_option("-c", "--cards", dest="no_cards", 
                      help="number of cards per hand", default=5)
    (options, args) = parser.parse_args()
    if len(args) > 0:
        parser.error("I don't recognize %s", (' '.join(args)))
    print GameDealer(options.no_players, options.no_cards)

    # To use the generator-based solution::
    # import lab_13_Function_Fancies.lab13_3 as dealer
    # dealer.PrintGame(dealer.DealGame(options.no_players, options.no_cards))
    
if __name__ == '__main__':
    main()
"""
$ lab17_2.py
Joker, 6 of Diamonds, Ace of Hearts, 4 of Clubs, 2 of Clubs
9 of Clubs, King of Spades, 4 of Hearts, King of Diamonds, 7 of Clubs
10 of Hearts, 5 of Diamonds, Queen of Diamonds, 2 of Hearts, 3 of Diamonds
8 of Hearts, 4 of Diamonds, 9 of Diamonds, 10 of Clubs, 3 of Hearts
$ lab17_2.py -x
Usage: lab17_2.py [-p number_of_players=4] [-c number_of_cards=5]

lab17_2.py: error: no such option: -x
$ lab17_2.py -help
Usage: lab17_2.py [-p number_of_players=4] [-c number_of_cards=5]

Options:
  -h, --help            show this help message and exit
  -p NO_PLAYERS, --players=NO_PLAYERS
                        number of players
  -c NO_CARDS, --cards=NO_CARDS
                        number of cards per hand
$ lab17_2.py -p 6 -c 3
Jack of Spades, 10 of Diamonds, Ace of Clubs
9 of Clubs, 4 of Spades, Joker
9 of Diamonds, Jack of Diamonds, 10 of Spades
9 of Hearts, 7 of Spades, 3 of Diamonds
7 of Hearts, 7 of Diamonds, King of Diamonds
Ace of Hearts, 10 of Hearts, 8 of Hearts
$ lab17_2.py -p 11
9 of Spades, King of Clubs, 5 of Spades, 6 of Hearts, Queen of Clubs
10 of Spades, 2 of Hearts, 9 of Diamonds, 3 of Clubs, Jack of Hearts
10 of Clubs, 6 of Clubs, Queen of Diamonds, 3 of Hearts, Jack of Spades
5 of Hearts, King of Spades, King of Hearts, Jack of Clubs, 10 of Hearts
8 of Hearts, Ace of Hearts, 8 of Spades, 7 of Spades, 9 of Clubs
Queen of Hearts, 5 of Diamonds, Joker, 7 of Diamonds, 8 of Diamonds
Ace of Spades, 5 of Clubs, 2 of Diamonds, 4 of Clubs, 4 of Spades
Jack of Diamonds, 2 of Clubs, 10 of Diamonds, 6 of Diamonds, 9 of Hearts
Ace of Clubs, 8 of Clubs, Joker, 7 of Clubs, 4 of Hearts
Ace of Diamonds, 3 of Diamonds, 6 of Spades, 2 of Spades, 7 of Hearts
4 of Diamonds, King of Diamonds, 3 of Spades, Queen of Spades, None
$ """
