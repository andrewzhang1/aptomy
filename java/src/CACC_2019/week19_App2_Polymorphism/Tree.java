package CACC_2019.week19_App2_Polymorphism;

public class Tree extends Plant {
      /* How to overide a method?
    1. Right click on this area --> Generate --> Overwrite Method
    2. Select the grow() from the Plant class

    */
    @Override
    public void grow() {
        // Comment out the following default method:
        // super.grow();

        System.out.println("Tree growing!");
    }

    public void shedLeaves(){
        System.out.println("Leaves shedding");
    }
}
