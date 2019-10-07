#!/usr/bin/env python
"""lab20_1.py - gives a raise to everyone in the address.data file"""
import re

salary_finder = re.compile("""(\d+)$""", re.VERBOSE | re.MULTILINE)

def GiveRaise(amount, text):
    """Gives a raise to the salaries in the text"""
    def UpIt(match_object):
        return str(int(match_object.group()) + amount)
    return salary_finder.sub(UpIt, text)

def main():
    import norma
    print GiveRaise(250, norma.ReadFile('address.data'))
    
if __name__ == '__main__':
    main()

"""$ lab20_1.py
Tommy Savage:408-724-0140:1222 Oxbow Court, Sunnyvale, CA 94087:5/19/66:34450
Lesle Kerstin:408-456-1234:4 Harvard Square, Boston, MA 02133:4/22/62:52850
JonDeLoach:408-253-3122:123 Park St., San Jose, CA 94086:7/25/53:85350
Ephram Hardy:293-259-5395:235 Carlton Lane, Joliet, IL 73858:8/12/20:56950
Betty Boop:245-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43750
Wilhelm Kopf:846-836-2837:6937 Ware Road, Milton, PA 93756:9/21/46:43750
Norma Corder:397-857-2735:74 Pine Street, Dearborn, MI 23874:3/28/45:245950
James Ikeda:834-938-8376:23445 Aster Ave., Allentown, NJ 83745:12/1/38:45250
Lori Gortz:327-832-5728:3465 Mirlo Street, Peabody, MA 34756:10/2/76:35450
Barbara Kerz:385-573-8326:832 Pnce Drive, Gary, IN 83756:12/15/46:27100

$ """
