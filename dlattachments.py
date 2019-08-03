#  Version 2

import email
import getpass, imaplib
import os
import sys


detach_dir = '.'
if 'attachment' not in os.listdir(detach_dir):
    os.mkdir('attachment')
 
#userName = raw_input('Enter your GMail username:')
#passwd = getpass.getpass('Enter your password: ')
userName="12345@gmail.com"
passwd="password"
 
try:
    imapSession = imaplib.IMAP4_SSL('imap.gmail.com')
    typ, accountDetails = imapSession.login(userName, passwd)
    if typ != 'OK':
        print 'Not able to sign in!'
        raise
    #imapSession.select('[Gmail]/All Mail')
    imapSession.select('Inbox')
    typ, data = imapSession.search(None,'UNSEEN')
    if typ != 'OK':
        print 'Error searching Inbox.'
        raise
# Iterating over all emails
    for msgId in data[0].split():
        typ, messageParts = imapSession.fetch(msgId, '(RFC822)')
        if typ != 'OK':
            print 'Error fetching mail.'
            raise
 
        emailBody = messageParts[0][1]
        mail = email.message_from_string(emailBody)
        fname='details.txt'
        with open(fname,'a') as fout:
            fout.write( "["+mail["From"]+"] :" + mail["Date"])
        #print "["+mail["From"]+"] :" + mail["Date"]
        for part in mail.walk():
            if part.get_content_maintype() == 'multipart':
# print part.as_string()
                continue
            if part.get('Content-Disposition') is None:
# print part.as_string()
                continue
            fileName = part.get_filename()
          
            #print a
            if bool(fileName):
                filePath = os.path.join(detach_dir, 'attachment', fileName)
                if not os.path.isfile(filePath) :
                    print fileName
                    fp = open(filePath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()
    imapSession.close()
    imapSession.logout()
except :
    print 'Not able to download all attachments.' 
