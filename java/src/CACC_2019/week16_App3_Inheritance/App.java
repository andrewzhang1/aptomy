package CACC_2019.week16_App3_Inheritance;

// App.java: Extented class Car has a new method

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
Machine Started.
Machine Stopped
Wiping windshied*/
