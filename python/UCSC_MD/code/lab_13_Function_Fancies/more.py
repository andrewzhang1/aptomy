#!/usr/bin/env python
"""Variable length argument lists are supported big time."""
  
es = {}   
          
def NewWords(name, language='Spanish', *more, **and_more):
    print name, 'translating to', language + ':'
    for word in more:
        es[word] = raw_input('%s: ' % word)
    if and_more:
        print "New words:"
        for word in and_more:
            print "%s: %s" % (word, and_more[word])
        es.update(and_more)
    print 'Thank you', name

def PrintEs():
    for word in sorted(es):
        print '%s:%s' % (word, es[word])

def main():
    NewWords('Emeliano')
    NewWords('Pancho', 'espa~ol', 'carrot', 'peanut')
    NewWords('Joaquin', 'carrot', 'grapefruit')
    NewWords('Luis', 'spanish', 'orange', 'butter', bread='pan', 
              cheese='queso')
    NewWords('Maria', strawberry='fresa')
    PrintEs()

if __name__ == '__main__':
    main()










    





"""
$ more.py
Emeliano translating to Spanish:
Thank you Emeliano
Pancho translating to espa~ol:
carrot: zanahoria
peanut: cacajuate
Thank you Pancho
Joaquin translating to carrot:
grapefruit: toronja
Thank you Joaquin
Luis translating to spanish:
orange: naranja
butter: montequilla
New words:
cheese: queso
bread: pan
Thank you Luis
Maria translating to Spanish:
New words:
strawberry: fresa
Thank you Maria
bread:pan
butter:montequilla
carrot:zanahoria
cheese:queso
grapefruit:toronja
orange:naranja
peanut:cacajuate
strawberry:fresa
$
"""
