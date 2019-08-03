
class Person implements JT_23_Interface_Info{

    private String name;

    // Create a constructor from "Code -> Generate -> Constructor
    public Person(String name) {
        this.name = name;
        System.out.println(name);
    }


    public void greet(){
        System.out.println("Hello");
    }

    @Override
    public void showInfo() {
        System.out.println("Person name is: " + name);
    }
}

class Machine23 implements JT_23_Interface_Info{
    private int id = 7;
    public void start(){
        System.out.println("Machine started");
    }

// The following is added automatically when adding "implements the inteface":
    @Override
    public void showInfo() {
        System.out.println("Machine ID is: " + id );
    }
}
public class JT_23_Interface {

    public static void main(String[] args) {

        Person person1 = new Person("Andrew");
        person1.greet();

        Machine23 mach1 = new Machine23();
        mach1.start();

        JT_23_Interface_Info info1 = new Machine23();
        info1.showInfo();

        JT_23_Interface_Info info2 = person1;
        info2.showInfo();
    }

}

