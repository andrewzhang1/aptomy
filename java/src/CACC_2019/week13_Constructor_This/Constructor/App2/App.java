package CACC_2019.week13_Constructor_This.Constructor.App2;

// 2. How to involk a constructor:
class Machine{

    private String name;
    public Machine(){
        System.out.println("A Default Constructor running");
        name = "Arnie";
    }
}
public class App {
    public static void main(String[] args) {

        Machine machine1 = new Machine();

        // Involking a constructor:
        new Machine();
    }
}

//Output:
//
//A Default Constructor running
//A Default Constructor running
//
