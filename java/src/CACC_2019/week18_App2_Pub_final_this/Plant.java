package CACC_2019.week18_App2_Pub_final_this;

public class Plant {
    /*
    The idea is usally want to:
    1. Encapsulate the data hide them away from the world.
    2. Make people access them through methods, so we can
       control what's happening with them
    */
    public String name;

    /* This is accepetable practice: it's final.
         */
    public final static int ID = 8;

    // A default construct
    public Plant(){
        this.name = "Freddy";
        /*
        "this" means the same as plant here; it's just that
        if you wanna access an object's member variables from
        within the actual class then you use this dot to get a
        reference to it
     */
    }
}
