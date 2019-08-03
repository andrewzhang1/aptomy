

class Stack():
    def __init__( self):
        self.stack = []

    def Push( self, item):
#        self.stack += [item]
        self.stack.append( item)
        return None

    def Pop( self):
        item = self.stack.pop(-1)
        return item


if __name__ == '__main__':
    mystack = Stack()

    mystack.Push( 1)
    mystack.Push( 2)
    mystack.Push( 3)

    print mystack.Pop()
    print mystack.Pop()
    print mystack.Pop()


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab14_exer2.py ===========
3
2
1
>>> 
"""
