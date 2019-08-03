// Polymophism shows:
// 1. How variables and reference work
//      vs how object works?


class Plant{
    public void grow(){
        System.out.println("Plant growing");
    }

    public void shedLeaves(){
        System.out.println("Leavves shedding.");
    }
}

class Tree extends Plant{
    @Override
    public void grow() {
        //super.grow();
        System.out.println("Tree growing");
    }
}

// Polomophism:  you can alwasy use a sub class (child class) as a perent class.

public class JT_26_Polymophism {

    public static void main(String[] args) {
        Plant plant1 = new Plant();
        Tree tree = new Tree();

        Plant plant2 = tree; // Two references refer to the same object of Plant(), as tree is a sub class of Plant
        //Plant plant2 = plant1;

        plant2.grow();
        tree.shedLeaves();

        plant2.shedLeaves();

        Plant plant3; // plant just point a object, but no reference;
        //it knows what object to call if it's pointing to an object

        // plant3.shedLeaves();
        //Error:(37, 9) java: variable plant3 might not have been initialized

        doGrow(tree);
    }

    public static void doGrow(Plant plant){
        plant.grow();

    }
}

