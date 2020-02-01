package CACC_2019.week16_App2_Inheritance;

// App2 Extented class Car has no method: s
// howing inheritance

public class App {
    public static void main(String[] args) {
        Machine mach1 = new Machine();
        mach1.start();
        mach1.stop();

        Car car1 = new Car();

        // car1.

        car1.start();
        car1.stop();

    }
}

/*
Output:
Machine Started.
Machine Stopped
Machine Started.
Machine Stopped*/
