#!/usr/bin/env python
"""Using re to print the city and state where Norma lives.
"""
import re  
def GetTownState(text, first_name):
    m = re.search(r"""
    ^%s      # Line starts with the name
    \b       # followed by a non-word character
    (?:      # Un-captured group 
    [^:]+?   # of non-colons 
    :){2}    # followed by a colon, twice
    [^,]+    # everything up to a comma
    ,[ ]+    # a comma and one or spaces in [] 
    (?P<town># capturing a group and naming
             # it "town". This piece cannot 
             # be split for comments.
    [^:\d]   # with no colons or digits
    +?)      # one or more times
    \d       # a digit ends the match
    """ % first_name, text, re.VERBOSE | re.MULTILINE)
    if m:
        return m.group("town")
    return "Not Found"

def ReadFile(file_name):
    try:
        fp = open(file_name)
        try:
            text = fp.read()
        finally:
            fp.close()
    except IOError:
        print "Can't open %s" % file_name
        return None
    return text
def main():
    print GetTownState(open('address.data').read(), "Norma")
if __name__ == '__main__':
    main()
"""
$ norma.py
 Dearborn, MI        """
