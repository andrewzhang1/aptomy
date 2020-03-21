# (56) Socket Programming in Python | Sending and Receiving Data with Sockets in Python | Edureka - YouTube
# https://www.youtube.com/watch?v=T0rYSFPAR0A
# Socket include ip and port

import socket
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(socket.gethostbyname(), 9003)
s.listen(5)




# s = socket()
# print('sockect created')
# s.bind('localhost', 9003)
#
# while True:
#     c, add = s.accept()

