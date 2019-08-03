#!/usr/bin/env python
"""This exercise is from the book "Perl by Example" by Ellie Quigley.
The exercise in Ellie's book asks us to print the city and state
where Norma lives.

I used this little program to develop the regular expression."""
import re  
import sys

def ReTest(re_str, data, flags):
    """Test the re_str against the data with flags.

    If it doesn't find a hit, try again with one character trimmed off
    the end, and again, and again, until a hit is found.  Then give
    a report.
    """
    for i in range(len(re_str), 0, -1):
        try:
            m = re.search(re_str[:i], data, flags)
            m.groups() # generate an error or not
        except:
            continue
        else:
            if i == len(re_str):
                print "It worked!"
                print "Groups:", m.groups()
            else:
                print "This much worked:"
                print re_str[:i]
                print "Groups:", m.groups()
                print "It broke here:"
                print re_str[i:]
            break
def main():        
    data = """
Tommy Savage:408-724-0140:1222 Oxbow Court, Sunnyvale, CA 94087:5/19/66:34200
Lesle Kerstin:408-456-1234:4 Harvard Square, Boston, MA 02133:4/22/62:52600
JonDeLoach:408-253-3122:123 Park St., San Jose, CA 94086:7/25/53:85100
Ephram Hardy:293-259-5395:235 Carlton Lane, Joliet, IL 73858:8/12/20:56700
Betty Boop:245-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43500
Wilhelm Kopf:846-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43500
Norma Corder:397-857-2735:74 Pine Street, Dearborn, MI 23874:3/28/45:245700
James Ikeda:834-938-8376:23445 Aster Ave., Allentown, NJ 83745:12/1/38:45000
Lori Gortz:327-832-5728:3465 Mirlo Street, Peabody, MA 34756:10/2/76:35200
Barbara Kerz:385-573-8326:832 Pnce Drive, Gary, IN 83756:12/15/46:26850
"""
    re_str = r"""
    ^%s      # Line starts with the name
    \b       # followed by a non-word character
    (?:      # Un-captured group 
    [^:]+?   # of non-colons 
    :){2}    # followed by a colon, twice
    x        # a mistake!!!
    [^,]+    # everything up to a comma
    ,[ ]+    # a comma and one or spaces in [] 
    (?P<town># capturing a group and naming
             # it "town". This sequence cannot 
             # be split for comments.
    [^:\d]   # with no colons or digits
    +?)      # one or more times
    \d       # a digit ends the match
    """ % 'Norma'
    ReTest(re_str, data, re.VERBOSE + re.MULTILINE)
        
if __name__ == '__main__':
    main()
"""
$ ./re_test.py
This much worked:

    ^Norma      # Line starts with the name
    \b       # followed by a non-word character
    (?:      # Un-captured group 
    [^:]+?   # of non-colons 
    :){2}    # followed by a colon, twice
    
Groups: ()
It broke here:
x        # a mistake!!!
    [^,]+    # everything up to a comma
    ,[ ]+    # a comma and one or spaces in [] 
    (?P<town># capturing a group and naming
             # it "town". This sequence cannot 
             # be split for comments.
    [^:\d]   # with no colons or digits
    +?)      # one or more times
    \d       # a digit ends the match
"""
