package CACC_2019.week18_App4_Pub_Pri_Pro.world;

class Something{
        }

public class Plant {
    /*  Bad practice!
    The idea is usally want to:
    1. Encapsulate the data hide them away from the world.
    2. Make people access them through methods, so we can
       control what's happening with them
    */
    public String name;

    /* This is accepetable practice: it's final.
         */
    public final static int ID = 8;

    /*
    Normally, when you have an instance member or class variable,
    static variable, you usally you should declare it private,
    becuase you want to stop people accessing from ourside the class
    */

    // Priave: means you can only acces it from with this class
    private String type;

    protected String size;

    // No pub, pri, and pro: can only be accessed within the same class:
    int height;

    // A default construct
    public Plant(){
        this.name = "Freddy";
        this.type = "plant";
        this.size = "medium - from Plant class";

        this.height = 9;
    }

}
