/**
 * Created by Andrew on 6/20/2017.
 */

class Machine_JT {

    protected String name = "Machine Type 1";
    public void start() {
        System.out.println("Machine Started.");
    }

    public void stop() {
        System.out.println("Machine Stop.");
    }
}

class Car extends Machine_JT {

// car inheritate the Machine class


    @Override
    public void start() {
        // super.start();  //We can comment out this on.
        System.out.println("Car starts again - 2018");
    }

    public void wipeWindShield() {

    }

    public void showInfo(){
        System.out.println("Car name" + name );
    }
    //Get a method from the parent class and overwite its method (the head must be the same!)
/*
    public void start() {
        System.out.println("Car Started.");
    }
*/


}

public class JT_22_Inheritance {

    public static void main(String[] args) {
        Machine_JT mach1 = new Machine_JT();
        Machine_JT mach2 = new Machine_JT();

        mach1.start();
        mach2.stop();

        Car car1 = new Car();

        car1.start();
        car1.wipeWindShield();
        car1.stop();

        car1.showInfo();
        // System.out.println();

    }

}

