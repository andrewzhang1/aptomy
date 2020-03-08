package CACC_2019.week19_App3.Polymorphism;

/*
Show how polymorphism in action:

If you have a child class of some parent class, you can always use
the child class anywhere you would normally use the parent class

Added:
1. Plant class added new method
2. plant2.grow();
3. plant1.grow();
4. plant2.shedLeaves();
*/

import CACC_2018.week2.Variable;

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
    When you actually run the method, what matters is not the variable,
    which could be a plant or tree of whatever, what matters is the actual
    type of object that contains the actual code, the variable, the object
    that matters.

    And this object that this reference points out is a treem which is a
    kind of plant. */
        plant2.grow();

        plant1.grow();

        tree.shedLeaves();

        //plant2.shedLeaves(); plant2 failed to call the method, why?

        Plant plant3;
        //Can grow() be called by Plant3?
        //plant3.grow();

        //It's the variable deciding which method to call

        // Question: which variable should give for the doGrow??
        //doGrow(Variable);
        // Answer is: tree|plant1|plant2, either one, why?

        /*polymorphism guarantees me that whatever a parent class is expected,
        I can use a child class of that parent
        */
     }
     /*We create the new method doGrow() that takes a Plant
    call it plant, which is an argument */

    public static void doGrow(Plant plant) {
        plant.grow();
    }
}
/* Output:
Tree growing!
Plant growing
Leaves shedding*/
