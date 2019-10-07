#!/usr/bin/env python
"""Test for lab17_1_2.py."""

import unittest
import sys
import lab17_2

# A Deck object is an iterator
print lab17_2.Deck()
whole_deck = sorted(lab17_2.Deck())

class TestPlayCards(unittest.TestCase):
    
    def testSmall(self):
        little = lab17_2.GameDealer(1, 1).DealGame()
        self.assertEqual(len(little), 1)
        self.assertEqual(len(little[0]), 1)
        self.assert_(little[0][0] in whole_deck)

    def testZilch(self):
        self.assertEqual([], lab17_2.GameDealer(0, 1).DealGame())
        self.assertEqual([[]], lab17_2.GameDealer(1, 0).DealGame())
        self.assertEqual([], lab17_2.GameDealer(0, 0).DealGame())
                    
    def testWholeDeck(self):
        all = lab17_2.GameDealer(9, 6).DealGame()
        for hand in all:
            self.assertEqual(len(hand), 6)
        self.assertEqual(len(all), 9)
        all_collapsed = reduce(lambda x,y: x + y, all)
        all_collapsed.sort()
        self.assertEqual(all_collapsed, whole_deck)

    def testTooMany(self):
        too_many = lab17_2.GameDealer(11, 5).DealGame()
        too_many_collapsed = reduce(lambda x,y: x + y, too_many)
        self.assert_('Blank' in too_many_collapsed)
        too_many_collapsed.remove('Blank')
        too_many_collapsed.sort()
        self.assertEqual(too_many_collapsed, whole_deck)

    def testWayTooMany(self):
        way_too_many = lab17_2.GameDealer(11, 6).DealGame()
        way_too_many_collapsed = reduce(lambda x,y: x + y, way_too_many)
        self.assertEqual(len(way_too_many_collapsed), 66)
        self.assertEqual(way_too_many_collapsed.count('Blank'), 12)
        for i in range(12):
            way_too_many_collapsed.remove('Blank')
        way_too_many_collapsed.sort()
        self.assertEqual(way_too_many_collapsed, whole_deck)

if __name__ == '__main__':
    unittest.main()
    
"""
$ test_play_cards.py
.....
----------------------------------------------------------------------
Ran 5 tests in 0.006s

OK
$ 
        
"""
