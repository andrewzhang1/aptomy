package CACC_2019.week16_App4_Inheritance_MethodOverWrite;

public class Car extends Machine {
    /*
    1. The Car is a machine or that car inherits from machine
    2. Now the Car is indentical to the Machine.
    3. Car got all the methods the Machine has!
    4. Car has a new overwritten method start() from Machine class
    */

    //@Override   // This is called annotation; Overwrite is a class
                // name! Note: annotation is optional!

    public void start() {
        //super.start();
        System.out.println("Car " +
                "Started.");
    }
    //  A better way to create an overwritten method:

    // What about if create a new method?
    public void wipeWinShild(){

        System.out.println("Wiping windshied");
    }
}
