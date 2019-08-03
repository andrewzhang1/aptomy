d = {"first_name": "Alfred", "last_name":"Hitchcock"}

for key in d:
    print("{} = {}".format(key, d[key]))


for key,val in d.items():
    print("{} = {}".format(key, val))
