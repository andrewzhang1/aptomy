#!/usr/bin/env python
"""lab07_1.py Provides a TranslateToKeypad function that,
when passed a string of alphanumeric characters, returns a
string of digits.  
"""
def TranslateToKeypad(word):
    """Returns the word, translated to the telephone keypad equivalent:
    abc -> 2  ghi -> 4   mno -> 6   tuv -> 8
    def -> 3  jkl -> 5  pqrs -> 7  wxyz -> 9
    Other characters get passed on.
    """

    def KeyMap(ch):
        if ch in 'abcABC':
            return '2'
        if ch in 'defDEF':
            return '3'
        if ch in 'ghiGHI':
            return '4'
        if ch in 'jklJKL':
            return '5'
        if ch in 'mnoMNO':
            return '6'
        if ch in 'pqrsPQRS':
            return '7'
        if ch in 'tuvTUV':
            return '8'
        if ch in 'wxyzWXYZ':
            return '9'
        return ch

    translated_word = ''
    for ch in word:
        translated_word += KeyMap(ch)
    return translated_word


def main():
    """Tests the TranslateToKeypad function."""
    
    DATA = "peanut", "salt", "lemonade", "good time", ":10", "Zilch"
    for word in DATA:
        print ("%10s -> %s" % (word, TranslateToKeypad(word)))

if __name__ == "__main__":
    main()
"""
$ lab07_1.py
    peanut -> 732688
      salt -> 7258
  lemonade -> 53666233
 good time -> 4663 8463
       :10 -> :10
     zilch -> 94524
$"""
