#!/usr/bin/env python
"""parser.py -f filename word-to-count [-q]
Counts the number of times word-to-count appears in filename.

Demonstrates the optparse module for parsing the command line options
and putting them into suitably-named identifiers in a namespace.
See: http://www.python.org/lib/optparse-tutorial.html
"""
import optparse  
import string

def CollectCommand(parser):
    # Here we harvest the command line and check that we have an
    # argument left-over.
    (options, args) = parser.parse_args()
    if len(args) != 1:  
        parser.error("I need one word.")
    if not options.filename:
        parser.error("No file name given.")
    return (options, args)

def main():
    parser = SetUpParsing()
    (options, args) = CollectCommand(parser)
    the_word = args[0]
    if options.verbose:
        print "reading %s..." % options.filename,
    count = ProcessFile(options.filename, the_word)
    if options.verbose:
        print "    %d occurances of '%s'" % (count, the_word)

def ProcessFile(filename, word):
    count = 0
    for line in file(filename):
        count += [x.strip(string.punctuation) \
                  for x in line.split()].count(word)
    return count

def SetUpParsing():
    # Here we call add_option repeatedly, once for every unix-style
    # option we need for."""
    
    parser = optparse.OptionParser(
        """%prog -f filename [-q][-v=False] word
    Counts the number of times word-to-count appears in filename.""")
    parser.add_option("-f", "--file", dest="filename", 
                      help="read data from FILENAME")
    parser.add_option("-v", "--verbose", 
                      action="store_true", dest="verbose", default=False)
    parser.add_option("-q", "--quiet", 
                      action="store_false", dest="verbose")
    return parser

if __name__ == "__main__":
    main()
"""
$ ./parser.py -f parser.py in -v
reading parser.py...     5 occurances of 'in'

$ ./parser.py
usage: parser.py -f filename [-q] word
Counts the number of times word-to-count appears in filename.

parser.py: error: I need one word.

$ ./parser.py aaa
usage: parser.py -f filename [-q] word
Counts the number of times word-to-count appears in filename.

parser.py: error: No file name given.

$ ./parser.py -x bb
usage: parser.py -f filename [-q] word
Counts the number of times word-to-count appears in filename.

parser.py: error: no such option: -x

$ ./parser.py -h
usage: parser.py -f filename [-q] word
Counts the number of times word-to-count appears in filename.

options:
  -h, --help            show this help message and exit
  -f FILENAME, --file=FILENAME
                        read data from FILENAME
  -v, --verbose         
  -q, --quiet           
$ """
