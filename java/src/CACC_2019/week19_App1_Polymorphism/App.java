package CACC_2019.week19_App1_Polymorphism;

/* File Name: App.java
Show how polymorphism in action:
If you have a child class of some parent class, you can always use
the child class anywhere you would normally use the parent class*/

public class App {
    public static void main(String[] args) {
        Plant plant1 = new Plant();

        Tree tree = new Tree();

        //Plant plant2 = plant1;

        /*
        1. plant2 refers to the same object that plant1 refers too!
        2. Now we've got two references here to the same object
        3. And, because of polymorphism, since tree is a subclass or a
        a child of plants, we can always use a tree wherever I have a plant
*/
        Plant plant2 = tree;
    }
}
