import requests, time
r = requests.post('http://requestbin.fullcontact.com/1j9kix01', data={"ts":time.time()})
print (r.status_code)
print (r.content)