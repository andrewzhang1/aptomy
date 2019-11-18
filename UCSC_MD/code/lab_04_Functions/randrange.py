#!/usr/bin/env python
""" randrange.py  Rolls dice, demonstrating random.randrange(),
and a tuple with accessing a particular element with an index.
"""

import random  

def Rollem():
  """Rolls a pair of dice and reports the result."""
  
  DOUBLES = ("Can't happen", "Snake eyes!", "Little joe!",
             "Hard six!", "Hard eight!", "Fever!", "Box cars!")

  dice = random.randrange(1, 7), random.randrange(1, 7)
  print "%d and %d" % dice
  if dice[0] == dice[1]:
    print (DOUBLES[dice[0]])

def main():
  while True:
    response = raw_input("Ready to roll? 'q' to quit. ")
    if response and response[0] in "Qq":
      break
    Rollem()

main()
"""
$ randrange.py
Ready to roll? 'q' to quit. 
5 and 5
Fever!
Ready to roll? 'q' to quit. 
2 and 3
Ready to roll? 'q' to quit. 
3 and 6
Ready to roll? 'q' to quit. 
1 and 1
Snake eyes!
Ready to roll? 'q' to quit. 
3 and 5
Ready to roll? 'q' to quit. q
$ """
