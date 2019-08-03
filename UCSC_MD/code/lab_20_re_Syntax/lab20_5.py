#!/usr/bin/env python
"""lab20_5.py Print all lines that don't contain "Boop"."""
import re
import norma  # to collect the data

def GetName(name, text):
    return re.findall(
        r"""^      # at the beginning of a line
        (?!        # must not match
        .*?%s.*?)  # the name anywhere
        (.*?)      # but do mach the whole line
        $          # to the end
        """ % name, text, re.MULTILINE|re.VERBOSE)
    
def main():
    print '\n'.join(GetName('Boop', norma.ReadFile('address.data')))

if __name__ == '__main__':
    main()

"""
$ lab20_5.py
Tommy Savage:408-724-0140:1222 Oxbow Court, Sunnyvale, CA 94087:5/19/66:34200
Lesle Kerstin:408-456-1234:4 Harvard Square, Boston, MA 02133:4/22/62:52600
JonDeLoach:408-253-3122:123 Park St., San Jose, CA 94086:7/25/53:85100
Ephram Hardy:293-259-5395:235 Carlton Lane, Joliet, IL 73858:8/12/20:56700
Wilhelm Kopf:846-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43500
Norma Corder:397-857-2735:74 Pine Street, Dearborn, MI 23874:3/28/45:245700
James Ikeda:834-938-8376:23445 Aster Ave., Allentown, NJ 83745:12/1/38:45000
Lori Gortz:327-832-5728:3465 Mirlo Street, Peabody, MA 34756:10/2/76:35200
Barbara Kerz:385-573-8326:832 Pnce Drive, Gary, IN 83756:12/15/46:26850
$
"""
