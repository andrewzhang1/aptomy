package CACC_2019.week13_Constructor_This.Constructor.App3;

// 3. Multiple constructrors: different methods with the same method name
//      as long as you have different parameters to the method you call,
//      because Java will fig out which method to call when you acturally call it

class Machine{

    private String name;
    private int code;

    public Machine(){
        System.out.println("A Default Constructor running");
        name = "Arnie";
    }

     public Machine(String name){

       System.out.println("A Second Constructor running");
        this.name = "Arnie";
    }
}

public class App {
    public static void main(String[] args) {
        // 1. new machine is causing the constructor to run automatically,
        // which is the whole point of it.
        Machine machine1 = new Machine();


        // Involking a constructor:
        new Machine("Eric");

        new Machine();

    }
}
//
//Output:
//
//A Default Constructor running
//A Second Constructor running
