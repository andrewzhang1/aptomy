#!/usr/bin/env python
"""lab20_6.py Print the file with the first and last names reversed."""
import re
import norma  # to collect the data

def ReverseNames(text):
    compiled_re = re.compile(r"""^(?P<name>[^:]+?)(?P<rest>:)""", re.MULTILINE)
    def DoTheReverse(match_object):
        try:
            first, last = match_object.group('name').split()
        except ValueError:
            return match_object.group('name') +  match_object.group('rest')
        return ', '.join((last, first)) + match_object.group('rest')
    return compiled_re.sub(DoTheReverse, text)

def main():
    print ReverseNames(norma.ReadFile('address.data'))

if __name__ == '__main__':
    main()

"""
$ lab20_6.py
Savage, Tommy:408-724-0140:1222 Oxbow Court, Sunnyvale, CA 94087:5/19/66:34200
Kerstin, Lesle:408-456-1234:4 Harvard Square, Boston, MA 02133:4/22/62:52600
JonDeLoach:408-253-3122:123 Park St., San Jose, CA 94086:7/25/53:85100
Hardy, Ephram:293-259-5395:235 Carlton Lane, Joliet, IL 73858:8/12/20:56700
Boop, Betty:245-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43500
Kopf, Wilhelm:846-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43500
Corder, Norma:397-857-2735:74 Pine Street, Dearborn, MI 23874:3/28/45:245700
Ikeda, James:834-938-8376:23445 Aster Ave., Allentown, NJ 83745:12/1/38:45000
Gortz, Lori:327-832-5728:3465 Mirlo Street, Peabody, MA 34756:10/2/76:35200
Kerz, Barbara:385-573-8326:832 Pnce Drive, Gary, IN 83756:12/15/46:26850
$
"""
