package CACC_2019.week13_Constructor_This.Constructor.App1;

// 1. Constructor basics
class Machine{

    public Machine(){
        System.out.println("A Default Constructor running");
    }
}

public class App {
    public static void main(String[] args) {
        // 1. new machine is causing the constructor to run automatically,
        // which is the whole point of it.
        Machine machine1 = new Machine();

    }
}

//output
//A Default Constructor running