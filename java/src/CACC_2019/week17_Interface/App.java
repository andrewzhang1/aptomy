package CACC_2019.week17_Interface;
/*
1. Machine and person are two completely different arbitrary
objects with nothing in common!
2. However, both class might both have a method called:
"showInfo", what can do?
3. Java gives use a mechanism to formalize this by creating an interface
 */
public class App {
    public static void main(String[] args) {

        Machine mach1 = new Machine();
        mach1.start();

        Person person = new Person("Andrew");
        person.greet();

    }
}

/*
output:
Machine Started.
Hello there!
 */