package CACC_2019.week18_App4_Pub_Pri_Pro.world;

import CACC_2019.week18_App4_Pub_Pri_Pro.world.Plant;

public class Oak extends Plant {
    public Oak(){

        // This will have error; "type" is privat!
        // type = "tree";

        /* If the child class (inhirited class) want to access
        the parent a parent class's variable, the "protect" variable
         must be defined at the parent class
         */

        this.size = "large - from Oak class";

        // No access specifier; it works becuase Oak and Plan
        // in the same package!
        this.height = 8;
    }
}
