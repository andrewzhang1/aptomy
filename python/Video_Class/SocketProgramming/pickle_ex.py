import pickle
mylist = [1,2,3,4]
ser = pickle.dumps(mylist)   # Serialized
print(ser)

# Use this to translate the obeject from server to the client