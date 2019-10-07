#!/usr/bin/env python
"""Makes an ascii chart."""

START = 32
END = 126

def GiveAscii(start=START, end=END, width=4):
    """Returns an ascii chart as a string.  Readable."""
    entries = end - start + 1
    entries_per_column = entries/width
    if entries % width:
        entries_per_column += 1
    ret = []
    for row in range(entries_per_column):
        for column in range(width):
            entry = entries_per_column * column + row + start
            if entry > end:
                break
            ret += ["%3d = %-6s" % (entry, chr(entry))]
        ret += ['\n']
    return ''.join(ret)

def GiveAscii(start=START, end=END, width=4):
    "Returns an ascii chart as a string.  NOT readable."
    entries = end - start + 1
    entries_per_column = entries/width + (1 if entries % width else 0)
    entries = [[entries_per_column * column + row + start \
                for column in range(width)] \
               for row in range(entries_per_column)]
    return '\n'.join([''.join(['%3d = %-6s' % (e, chr(e))\
                               for e in entries[r] if e <= end])\
                      for r in range(entries_per_column)])

def main():
    print GiveAscii()

if __name__ == '__main__':
    main()
"""
$ ./hw11_1.py
 32 =        56 = 8      80 = P     104 = h     
 33 = !      57 = 9      81 = Q     105 = i     
 34 = "      58 = :      82 = R     106 = j     
 35 = #      59 = ;      83 = S     107 = k     
 36 = $      60 = <      84 = T     108 = l     
 37 = %      61 = =      85 = U     109 = m     
 38 = &      62 = >      86 = V     110 = n     
 39 = '      63 = ?      87 = W     111 = o     
 40 = (      64 = @      88 = X     112 = p     
 41 = )      65 = A      89 = Y     113 = q     
 42 = *      66 = B      90 = Z     114 = r     
 43 = +      67 = C      91 = [     115 = s     
 44 = ,      68 = D      92 = \     116 = t     
 45 = -      69 = E      93 = ]     117 = u     
 46 = .      70 = F      94 = ^     118 = v     
 47 = /      71 = G      95 = _     119 = w     
 48 = 0      72 = H      96 = `     120 = x     
 49 = 1      73 = I      97 = a     121 = y     
 50 = 2      74 = J      98 = b     122 = z     
 51 = 3      75 = K      99 = c     123 = {     
 52 = 4      76 = L     100 = d     124 = |     
 53 = 5      77 = M     101 = e     125 = }     
 54 = 6      78 = N     102 = f     126 = ~     
 55 = 7      79 = O     103 = g     
$"""
