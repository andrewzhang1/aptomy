package CACC_2019.week16_App4_Inheritance_MethodOverWrite;

// App4: Overwrite method
// Show how to use method overwrite from the Car class

public class App {
    public static void main(String[] args) {

        Machine mach1 = new Machine();
        mach1.start();
        mach1.stop();

        Car car1 = new Car();
        car1.start();
        car1.stop();
        car1.wipeWinShild();
    }
}

/*
Output:
Machine Started.
Machine Stopped
Car Started.
Machine Stopped
Wiping windshied*/
