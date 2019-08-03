#!/usr/bin/env python
"""lab12_2.py  Reports the ip address of this machine.
Linux only."""
import subprocess

def GetIP():
    output = subprocess.Popen("/sbin/ifconfig",
                              stdout=subprocess.PIPE).stdout
    for line in output:
        address_at = line.find("inet addr:")
        if address_at == -1:
            continue
        return line[address_at + 10:].split()[0]
    
if __name__ == '__main__':
    print GetIP()

"""
$ lab12_2.py
10.0.0.153
$
"""
