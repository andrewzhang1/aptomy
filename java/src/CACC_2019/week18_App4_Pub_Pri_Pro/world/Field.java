package CACC_2019.week18_App4_Pub_Pri_Pro.world;

public class Field {
    private Plant plant= new Plant();

    public Field(){
        // this works because size is protected;
        // Field is in the same packag as Plant.
        System.out.println(plant.size);
    }
}
