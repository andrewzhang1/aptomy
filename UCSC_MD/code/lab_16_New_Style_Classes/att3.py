#!/usr/bin/env python
"""att3.py  (Optional)
'property' gives you total control over a particular attribute.
It is only available in "New Style" classes, which inherit from
the "object" superclass.
"""  
class Secret(object):  

    def __init__(self, secret_word):
        self.__secret = secret_word
        
    def GetSecret(self):
        return "I'll never tell."

    def SetSecret(self, new_secret):
        try:
            self.__secret += new_secret
        except AttributeError:
            raise AttributeError, "You can't start over."

    def DelSecret(self):
        print "No more secrets!"
        del self.__secret

    secret = property(GetSecret, SetSecret, DelSecret, 
                      "I've got the secret.")

    def IsSecret(self, trial):
        return trial == self.__secret

def main():
    word = Secret('fish')
    print "word.secret =", word.secret
    print "word.IsSecret('fish')", word.IsSecret('fish')
    word.secret = 'gills'
    print "word.IsSecret('gills')", word.IsSecret('gills')
    print "word.IsSecret('fishgills')", word.IsSecret('fishgills')
    print Secret.secret.__doc__
    del word.secret
    word.secret = 'flounder'
    
if __name__ == '__main__':
    main()
    
"""    
$ att3.py
word.secret = I'll never tell.
word.IsSecret('fish') True
word.IsSecret('gills') False
word.IsSecret('fishgills') True
I've got the secret.
No more secrets!
Traceback (most recent call last):
  File "./att3.py", line 43, in <module>
    main()
  File "./att3.py", line 40, in main
    word.secret = 'flounder'
  File "./att3.py", line 19, in SetSecret
    raise AttributeError, "You can't start over."
AttributeError: You can't start over.
$"""
