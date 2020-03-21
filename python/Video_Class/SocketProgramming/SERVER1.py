# (56) Socket Programming in Python | Sending and Receiving Data with Sockets in Python | Edureka - YouTube
# https://www.youtube.com/watch?v=T0rYSFPAR0A
# Socket include ip and port

# command line:  "python SERVER1.py"
#              then: "python CLIENT1.py"
import socket
import pickle

a = 10 # Header size at your chice

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((socket.gethostname(), 1024))
s.listen(5)
while True:
    clt, adr = s.accept()
    print(f"Connection to {adr} establisted")

    m={1:"Client", 2:"Server"}
    mymsg = pickle.dumps(m)  # the msg we want to print later
    #clt.send(bytes("Socket Programming in python", "utf-8"))
    mymsg = (bytes(f'{len(mymsg): < {a}}', "utf-8")) + mymsg
    clt.send(mymsg)






# ip = socket.gethostbyname('www.google.com')
# print (ip)
