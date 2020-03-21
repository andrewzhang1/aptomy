import requests

print("Part 1")
r = requests.get('https://xkcd.com/353/')
print(r.status_code)
#print(help(r)) #  ==> text

# Check the html file
# print(r.text)

print("\nPart 2")
# Download the image
r = requests.get('https://imgs.xkcd.com/comics/python.png')
print(r.content)

with open('comic.png', 'wb') as f:
    f.write(r.content)

print(r.status_code)
# 500 server errors

print(r.ok)  # True
print(r.headers)

print("\nPart 3")
# Test httpbin.org, A simple HTTP Request & Response Service.

r = requests.get('https://httpbin.org/get?page=2&count=25')
print(r.headers)

print("\nPart 4")
payload = {'page': 2, 'count': 25}
# Test httpbin.org, A simple HTTP Request & Response Service.

r = requests.get('https://httpbin.org/get', params=payload)
print(r.headers)
print((r.text))
print(r.url)