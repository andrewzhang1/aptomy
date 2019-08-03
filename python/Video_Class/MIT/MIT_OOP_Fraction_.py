
class Fraction(object):
    '''
    A number represented as fraction
    '''

    def __init__(self, num, denom):
        ''' num and denum are intergers '''
        assert type(num) == int and type(denom) == int
        self.num = num
        self.denom = denom

    def __str__(self):
        """ Returns a string representation of    """
        return str(self.num) + "/" + str(self.denom)
    def __add__(self, other):
        """ Returns a fraction representation of    """
        top = self.num*other.denom + self.denom*other.denom
        bott = self.denom*other.denom
        return Fraction(top, bott)
    def __sub__(self, other):
        """ Returns a fraction representation of    """
        top = self.num*other.denom - self.denom*other.denom
        bott = self.denom*other.denom
        return Fraction(top, bott)
    def __float__(self):
        """ Returns a float value of the fraction    """
        return self.num/self.denom
    def inverse(self):
        ''' Returns a new fraction representing '''
        return Fraction(self.denom, self.num)

a = Fraction(1, 4)
b = Fraction(3, 4)
c = a + b # 20/16
# c is a Fraction object

print(a)
print(b)
print(c)



#print(float(c))
#print(float.)





































































