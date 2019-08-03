import re

str = 'an example word:cat!!'
match = re.search(r'cat', str)
# If-statement after search() tests if it succeeded
if match:
  print('found', match.group())  ## 'found cat'
else:
  print('did not find')

match = re.search(r'word:\w\w\w', str)
if match:
  print('found', match.group()) ## 'found word:cat'
else:
  print('did not find')

match = re.search(r'dog', str)
if match:
  print('found', match.group())
else:
  print('did not find') ## 'did not find'
