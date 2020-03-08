package CACC_2019.week19_App2_Polymorphism;
/*
Show how polymorphism in action:
If you have a child class of some parent class, you can always use
the child class anywhere you would normally use the parent class

Added:
1. Error case: plant2.shedLeaves();
2. plant2.grow
*/

public class App {
    public static void main(String[] args) {
        Plant plant1 = new Plant();

        Tree tree = new Tree();
    //Plant plant2 = plant1;

    /*
    1. plant2 refers to the same object that plant1 refers too!
    2. Now we've got two references here to the same object
    3. And, because of polymorphism, since tree is a subclass or a
    a child of plants, we can always use a tree wherever I have a plant*/
        Plant plant2 = tree;


    /* Guess which method will be called?
    When you acturally run the method, what matters is not the variable,
    which could be a plant or tree of whatever, what matters is the actual
    type of object that contains the actual code, the variable, the object
    that matters.

    And this object that this reference points out is a tree which is a
    kind of plant. */
        plant2.grow();

        plant1.grow();
        tree.shedLeaves();

        // Error case 1:
        //plant2.shedLeaves(); Failed to call the method, why?

        // Error Case 2: Will the following case work?
        Plant plant3; // = new Plant();
        //plant3.grow();
    }
}

/* output:
Tree growing!
Plant growing
Leaves shedding
*/
