package CACC_2019.week18_App3_Pub_Pri_Pro;

public class Oak extends Plant {
    public Oak(){

        // This will have error; "type" is private.
        // type = "tree"; // you should comment out this line!

        /* If the child class (an inherited class) want to access
        the parent a parent class's variable, the "protect" variable
         must be defined at the parent class
         */

        size = "large - from Oak class";
    }
}
