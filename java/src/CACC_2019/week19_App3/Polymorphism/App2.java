package CACC_2019.week19_App3.Polymorphism;

public class App2 {
    public static void main(String[] args) {
        Plant plant1 = new Plant();

        Tree tree = new Tree();
        Plant plant2 = tree;
        plant2.grow();

        plant1.grow();
        tree.shedLeaves();
        Plant plant3;
     }

    public static void doGrow(Plant plant) {
        plant.grow();
    }
}
/* Output:
Tree growing!
Plant growing
Leaves shedding*/
