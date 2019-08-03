# Learn "zip" function


geek = {"404": "clueless.  From the web error message 404, meaning page not found.","Googling": "searching the Internet for background information on a person.","Keyboard Plaque" : "the collection of debris found in computer keyboards."}

geek=dict(Googling="searching the Internet for background information on a person.", jack=4098)

for k,v in geek.items():
    print(k, '->', v)
print('------')
geek=dict([('404','clueless'),('Googling','searching the Internet for background information on a person.')])
print(geek)

print('------')
keys=['404', 'Keyboard', 'another key']
values=['clueless', 'the collection of debris found in computer keyboards']
for k, v in zip(keys,values):
    print(k,'->', v)
print('------')

l = ['tic', 'tac', 'toe']
for item in l:
    print(item)


print('------')
for idx, item in enumerate(l):
    print(idx, '->', item)
