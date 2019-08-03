

import lab13_exer3 as cards

import optparse


pobj = optparse.OptionParser( "%prog -p players -s handsize")

pobj.add_option( '-p', '--players',  dest='players',  help="Number of players")
pobj.add_option( '-s', '--handsize', dest='handsize', help="Size of hand")

(options, args) = pobj.parse_args()


def test():
    if options.players == None and options.handsize == None:
        cards.Game()
    else:
        cards.Game( int( options.players), int( options.handsize))


if __name__ == '__main__':
    test()


"""
C:\Users\E1HL\Python\exercises>python2 lab17_exer2.py -h
Usage: lab17_exer2.py -p players -s handsize

Options:
  -h, --help            show this help message and exit
  -p PLAYERS, --players=PLAYERS
                        Number of players
  -s HANDSIZE, --handsize=HANDSIZE
                        Size of hand

C:\Users\E1HL\Python\exercises>python2 lab17_exer2.py
Player 0 has hand: ['Queen of Clubs', 'Ace of Spades', 'Jack of Clubs', 'King of Spades', '6 of Hearts']
Player 1 has hand: ['3 of Clubs', 'King of Clubs', '3 of Spades', '9 of Hearts', '2 of Clubs']
Player 2 has hand: ['5 of Spades', 'Queen of Diamonds', '5 of Clubs', '7 of Spades', '2 of Spades']
Player 3 has hand: ['Queen of Spades', '9 of Diamonds', 'Jack of Diamonds', 'Jack of Hearts', '7 of Diamonds']

C:\Users\E1HL\Python\exercises>python2 lab17_exer2.py -p 6 -s 3
Player 0 has hand: ['Ace of Clubs', 'Ace of Hearts', '8 of Clubs']
Player 1 has hand: ['3 of Spades', '4 of Spades', '10 of Spades']
Player 2 has hand: ['5 of Clubs', 'Ace of Spades', '3 of Hearts']
Player 3 has hand: ['5 of Spades', '6 of Hearts', '4 of Clubs']
Player 4 has hand: ['7 of Clubs', '7 of Spades', 'Queen of Hearts']
Player 5 has hand: ['6 of Diamonds', 'King of Clubs', '2 of Clubs']
"""
