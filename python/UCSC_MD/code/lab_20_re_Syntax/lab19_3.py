#!/usr/bin/env python
"""lab19_3.py This evil program crawls around on the web and
collects email addresses. """
import sys, re, urllib, httplib

if __name__ == '__main__':
    sys.path.insert(0, "..") 
else:                        
    sys.path.insert(0, os.path.join(os.path.split(__file__)[0], '..'))
import lab_13_Function_Fancies.timeout_decorator as time_out

@time_out.TimeOut(3)
def CollectPage(url):
    text=None
    try:
        urlpage=urllib.urlopen(url)
    except (IOError, httplib.InvalidURL):
        return []
    try:
        try:
            text=urlpage.read()
        finally:
            urlpage.close()
    except:
        pass
    return text

def HarvestEmailAddresses(start_with, addresses, max_pages=100):
    pages = [start_with]
    page_working_on = 0
    while page_working_on < max_pages:
        try:
            pages += [url for url in ParsePage(pages[page_working_on],
                                               addresses)\
                      if url not in pages]
        except IndexError:
            print "Only %d url pages found starting at %s"\
                      % (page_working_on, start_with)
            break
        page_working_on += 1
    return addresses

def ParsePage(url, addresses):
    try:
        text = CollectPage(url)
    except RuntimeError:
        text = []
    if not text:
        return []
    email_catcher = re.compile(r"""
    [\s,:;(<\['\"]+([^@\s,;:\"]+)@
    ([^@\-\s,:;>\)'\"]+\.[a-z,A-Z]{2,3})[\s,;:\"'>\)]""",
                               re.VERBOSE)
    for new_one in [local_part + '@' + domain \
                    for local_part, domain \
                    in email_catcher.findall(text)]:
        if new_one not in addresses:
            print new_one
            addresses += [new_one]
    url_catcher=re.compile(r"http://[^\s\"<>()']*\b")
    return Uniquify(url_catcher.findall(text))
    
def Uniquify(a_list):
    a_list.sort()
    try:
        new_list = [a_list[0]]
    except IndexError:
        return []
    for each in a_list[1:]:
        if each not in new_list:
            new_list += [each]
    return new_list

def main():
    start_with='www.ngc.com'
    if len(sys.argv)>1:
        start_with=sys.argv[1]
    if start_with[:7] !='http://':
        start_with='http://' + start_with
    addresses = []
    HarvestEmailAddresses(start_with, addresses, 500)

if __name__=='__main__':
    main()
"""
$ lab19_3.py
onewebmaster@ngc.com  [and many more] """

