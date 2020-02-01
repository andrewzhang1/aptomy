package CACC_2019.week18_App4_Pub_Pri_Pro;
/*
 App4: More demo for the error cases.
 1. Added a new package: world.
 2. Added new classes: Field, Grass
*/

import CACC_2019.week18_App4_Pub_Pri_Pro.world.Plant;

public class App {
    public static void main(String[] args) {
    // We create a Plant instance here:
        Plant plant = new Plant();
// python way: plant1 = Plant()
        System.out.println(plant.name);
        System.out.println(plant.ID);

        // This will have error; "type" is private!
        //System.out.println(plant.type);

        /* This won't work, because:
        1. size is protected;
        2. App is not in the same package. */
        //System.out.println(plant.size);

        // This won't work; because App and Plan in different package,
        // height has package-level visibility
        //System.out.println(plant.height);
    }
}
