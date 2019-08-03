#!/usr/bin/env python 
"""att2.py  (Optional)
You can override assigning and referencing attributes.

referencing: 

      object.x -> calls __getattr__ (if provided)

  but only if the x attribute does not exist.

assignment:

      object.x = 3  -> calls __setattr__ (if provided)
"""  
class Secret: 
    """The secret can only be set on initialization: s = Secret("rose");
    and only the allowed attributes can be set. """
    
    allowed_attributes = ("members", "purpose")

    def __init__(self, secret):
        self.__dict__['_Secret__secret'] = secret
        # Here we snuck around __setattr__ by adding directly to the
        # __dict__, so that we could disallow the secret to be set 
        # after initialization.  And, we had to do our own name
        # mangling to keep it pseudo-secret.
        
    def IsSecret(self, word):
        return self.__secret == word

    def __getattr__(self, attribute_name):
        if attribute_name == 'secret':
            return "a secret!"
        raise AttributeError, "%s instance has no attribute '%s'" \
              % (self.__class__.__name__, attribute_name)

    def __setattr__(self, attribute_name, value):
        if attribute_name == "secret":
            raise NameError, "You can't change the %s to %s" % \
                  (attribute_name, value)
        elif attribute_name in Secret.allowed_attributes:
            self.__dict__[attribute_name] = value
            # setattr(self, attribute_name) would loop forever!
        else:
            raise AttributeError, "%s is not an attribute for class %s"\
                  % (attribute_name, str(self.__class__).split('.')[1])

def main():
    club = Secret('snake')
    print "club.secret is", club.secret
    print "club.IsSecret('snake')", club.IsSecret('snake')
    try:
        print "club.x is", club.x
    except AttributeError, msg:
        print "\nError: ", msg
    try:
        print "club.members is", club.members
    except AttributeError, msg:
        print "\nError: ", msg
    club.members = 7
    print "club.members is", club.members
    try:
        club.secret = 'lizard'
    except NameError, msg:
        print "\nError: ", msg
    try:
        print "Setting club.x",
        club.x = 'cucumber'
    except AttributeError, msg:
        print "\nError: ", msg
    print dir(club)
if __name__ == '__main__':
    main()
"""$ att2.py
club.secret is a secret!
club.IsSecret('snake') True
club.x is 
Error:  Secret instance has no attribute 'x'
club.members is 
Error:  Secret instance has no attribute 'members'
club.members is 7

Error:  You can't change the secret to lizard
Setting club.x 
Error:  x is not an attribute for class Secret
['_Secret__secret', '__doc__', '__getattr__', '__init__', '__module__',
 '__setattr__', 'allowed_attributes', 'IsSecret', 'members']
$ """
