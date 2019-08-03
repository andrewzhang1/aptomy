#!/usr/bin/python

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email import Encoders
import os

#gmail_user = "Put the senders email here"
#gmail_pwd = "put the password here"
gmail_user = "2001@gmail.com"
gmail_pwd = "password"

detach_dir = '.'
if 'resultfolder' not in os.listdir(detach_dir):
    os.mkdir('resultfolder')

def mail(to, subject, text, attach):
    msg = MIMEMultipart()

    msg['From'] = gmail_user
    msg['To'] = to
    msg['Subject'] = subject

    msg.attach(MIMEText(text))

    part = MIMEBase('application', 'octet-stream')
    part.set_payload(open(attach, 'rb').read())
    Encoders.encode_base64(part)
    part.add_header('Content-Disposition',
           'attachment; filename="%s"' % os.path.basename(attach))
    msg.attach(part)

    mailServer = smtplib.SMTP("smtp.gmail.com", 587)
    mailServer.ehlo()
    mailServer.starttls()
    mailServer.ehlo()
    mailServer.login(gmail_user, gmail_pwd)
    mailServer.sendmail(gmail_user, to, msg.as_string())
   # Should be mailServer.quit(), but that crashes...
    mailServer.close()
#from sendattach import mail
#mail("put the users email addres here","Subject","Any text","outut.jpg")
mail("agz1117@hotmail.com","Subject: Mail sent from python","Hi, An attachment is enclose. - Andrew", "v0.51_dlattachments.sh")

# Modify above mail code into: 
mail("agz1117@hotmail.com","Subject: Mail sent from python","Hi, An attachment is enclose. - Andrew", "v0.51_process.sh")

mail("agz1117@hotmail.com","Subject: Mail sent from python","Hi, An attachment is enclose. - Andrew", "v0.51_sendattachMain.sh")

