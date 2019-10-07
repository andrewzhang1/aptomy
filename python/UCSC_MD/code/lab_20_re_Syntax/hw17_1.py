#!/usr/bin/env python
"""
hw17_1.py - Classes for a Tree.
"""

class Node:
    """Node(name, id, parent_id) creates a node for the tree.
    """

    def __init__(self, tree, **characteristics):
        """Node(tree, name="xx", id=x, parent_id=x)
        makes a new node in the tree.
        """
        self.tree = tree
        if characteristics['parent_id']:
            try:
                self.parent = tree.FindNode(id=
                                            characteristics['parent_id'])
            except ValueError:
                raise ValueError, ("parent_id = %d doesn't exist."
                                   % (characteristics['parent_id']))
            self.parent.children += [self]
        else:
            self.parent = 0
        self.id = int(characteristics['id'])
        self.name = characteristics['name']
        self.children = []

    def DumpData(self):
        """Returns the data tuple."""
        return (self.name, self.id, 0 if not self.parent else self.parent.id)

    def __eq__(self, other):
        for attr in Tree.dont_duplicate:
            if getattr(self, attr) != getattr(other, attr):
                return False
        return True

    def Remove(self):
        """Removes this node from the tree, making it's
        children be the children of it's parent instead."""
        
        if type(self.parent) == int: # Root
            if self.children:
                raise ValueError, "Cannot remove tree root " + \
                      "while branches are still alive."
            self.tree.root = None
            self.tree.nodes.remove(self)
            return
        
        self.tree.nodes.remove(self)
        for child in self.children:
            child.parent = self.parent
        if self.parent:
            self.parent.children.remove(self)
            self.parent.children += self.children

    def __str__(self):
        """Returns the dont_duplicate attributes for easy printing"""
        return ":".join(str(getattr(self, x)) for x in Tree.dont_duplicate)

    
class Tree:
    """Tree(sequence of data_tuples)
    Creates a tree of hierachical data.

    Each data_tuple becomes a node in the tree:
    (name, this_id, parent_id)

    The tuple with parent_id == 0 is the node without a
    parent, or root of the tree.
    """

    dont_duplicate = ("name", "id") # nodes cannot have duplicates
                                    # of these attributes.  They
                                    # need to be first in the data
                                    # for unittest.
    
    def __init__(self, data=None):
        """data = ((name, id, parent_id), (name, id, parent_id), ...
        Sets up the tree."""
        self.nodes = []
        self.root = None
        if not data:
            return
        for datum in data:
            name, id, parent_id = datum
            self.AddNode(name=name, id=id, parent_id=parent_id)

    def AddNode(self, **characteristics):
        """tree.AddNode(id=x, parent_id=y, name="something")
        to add a Node to the tree.
        """
        dup = self.IsDuplicate(**characteristics)
        if dup:
            raise ValueError,"%s=%s already exists." % (dup, characteristics[dup])
        new_node = Node(self, **characteristics)
        self.nodes += [new_node]
        if not new_node.parent:
            self.root = new_node

    def DropFamily(self, id):
        """Drops node where id=id, and all the children."""
        global droppers
        droppers = []
        
        def DropFamilyNodes(node):
            global droppers
            droppers += [node]
            for child in node.children:
                DropFamilyNodes(child)
                
        DropFamilyNodes(self.FindNode(id=id))
        for node in reversed(droppers):
            node.Remove()

    def DropNode(self, **characteristics):
        """Removes the node from the tree and makes all the children
        have it's parent as the first parent.
        Expect keyword arguements which can be just node=some_node.
        """
        try:
            the_node = characteristics['node']
        except KeyError:
            the_node = self.FindNode(**characteristics)
        if not the_node:
            raise ValueError, "Node= %s does not exist." % (characteristics)
        the_node.Remove()

    def IsDuplicate(self, **characteristics):
        for attr in characteristics:
            if attr not in Tree.dont_duplicate:
                continue
            for node in self.nodes:
                if getattr(node, attr) == characteristics[attr]:
                    return attr
        return False

    def __iter__(self):
        class NodeIterator:
            def __init__(i_self):
                i_self.nodes = []
                def AddChildren(node):
                    i_self.nodes += [node]
                    for child in node.children:
                        AddChildren(child)
                try:
                    AddChildren(self.root)
                except AttributeError: # no root yet
                    pass
                
            def __iter__(i_self):
                return i_self

            def next(i_self):
                try:
                    return i_self.nodes.pop(0)
                except IndexError:
                    raise StopIteration

        return NodeIterator()
        
    def MakeDiagram(self, width):
        """Returns a Tree diagram of the data."""
        
        def AddGraphingAttributes(node, y, x, width):
            node.x = x
            node.y = y
            node.width = width
            if len(node.children):
                width = width/len(node.children)
            else:
                return
            y = y + 1
            for child in node.children:
                AddGraphingAttributes(child, y, x, width)
                x += width
                
        AddGraphingAttributes(self.root, 0, 0, width)

        # Now, arrange string 
        def ByDimensions(node):
            return (node.y, node.x)
        old_y = 0
        at_x = 0
        return_string = ''
        for node in sorted(self, key=ByDimensions):
            if node.y > old_y:
                old_y = node.y
                at_x = 0
                return_string += '\n'
            return_string += ' ' * (node.x - at_x)
            at_x = node.x
            return_string += str(node.id).center(node.width)
            at_x += node.width
            del node.x
            del node.y
            del node.width
        return_string += '\n'
        return return_string

    def DrawTree(self):
        global return_string
        return_string = ''
        def PrintFamily(node, depth):
            global return_string
            if not node: # empty tree
                return_string = 'No nodes'
                return
            return_string += depth * '  ' + str(node) + '\n'
            for child in node.children:
                PrintFamily(child, depth + 1)
        PrintFamily(self.root, 0)
        return return_string
    
    def DumpData(self):
        """Returns ((name, id, parent_id), (name, id, parent_id), ...)"""
        data = ()
        for node in self.nodes:
            data += (node.DumpData(),)
        return data

    def __eq__(self, other):
        return self.DumpData() == other.DumpData()

    def FindNode(self, **characteristics):
        """Returns the node, or False, if it isn't found.

        FindNode(name="what", id="what"[, name="17"]),
        or just give one of the dont_duplicate attributes.
        """
        # Input check -- look for a dont_duplicate attribute
        for k in characteristics:
            if k in Tree.dont_duplicate:
                get_this_attr = k
                break
        else:
            raise AttributeError, \
                  ("One of the keywords must be "
                   + ' or '.join(Tree.dont_duplicate) + '.')
            
        # Find the attribute
        for node in self.nodes:
            if getattr(node, get_this_attr) == characteristics[get_this_attr]:
                break
        else:
            raise ValueError, "%s not found" % (characteristics)

        # Check the other attributes
        for att in characteristics:
            if att == 'parent_id':
                if node.parent and node.parent.id \
                       != characteristics['parent_id']:
                    return False
                if not node.parent and characteristics['parent_id'] != 0:
                    return False
                continue
            if getattr(node, att) != characteristics[att]:
                return False
        return node

    def __repr__(self):
        return "Tree(" + str(self.DumpData()) + ")"
    
    def __str__(self):
        return self.DrawTree()
    # return self.MakeDiagram(60)

    
def main():
    import homework_data
    null_tree = Tree()
    print null_tree
    the_tree = Tree(homework_data.data)
    for node in the_tree: # testing the iterator
        print node
    the_tree.AddNode(id=14, parent_id=8, name="Lemon Drop")
    print "After AddNode(id=14):\n", the_tree
    the_tree.DropNode(id=14, parent_id=8, name="Lemon Drop")
    print "After Dropping it again:\n", the_tree
    try:
        the_tree.AddNode(id=14, parent_id=20, name="shouldn't work")
    except ValueError:
        pass
    try:
        the_tree.DropNode(id=88)
    except ValueError:
        pass
    the_tree.DropFamily(id=7)
    print "After Dropping the whole id=7 family:\n", the_tree
    assert eval(repr(the_tree)) == the_tree
    the_tree.DropFamily(the_tree.root.id)
    print 'After dropping from root: ', the_tree
    assert eval(repr(the_tree)) == Tree()

if __name__ == '__main__':
    main()

"""
OUTPUT:

$ hw17_1.py
No nodes
Jane Dolittle:12
Frances Jones:4
Diane Johnson:5
Judi Kades:6
Clint Dante:7
Jacqueline Star:8
Lori Amde:9
Chuck Arts:10
Raul Pack:11
After AddNode(id=14):
Jane Dolittle:12
  Frances Jones:4
    Diane Johnson:5
    Judi Kades:6
  Clint Dante:7
    Jacqueline Star:8
      Louise Drop:14
    Lori Amde:9
      Chuck Arts:10
      Raul Pack:11

After Dropping it again:
Jane Dolittle:12
  Frances Jones:4
    Diane Johnson:5
    Judi Kades:6
  Clint Dante:7
    Jacqueline Star:8
    Lori Amde:9
      Chuck Arts:10
      Raul Pack:11

After Dropping the whole id=7 family:
Jane Dolittle:12
  Frances Jones:4
    Diane Johnson:5
    Judi Kades:6
$"""
