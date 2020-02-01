package CACC_2019.week18_App4_Pub_Pri_Pro;

import CACC_2019.week18_App4_Pub_Pri_Pro.world.Plant;

public class Grass extends Plant {
    public Grass(){

       // This won't work, because Grass not in the same package
       // as plant, even though it's a subclass
       //System.out.println(this.height);
    }
}
