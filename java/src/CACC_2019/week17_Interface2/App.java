package CACC_2019.week17_Interface2;

import jdk.nashorn.internal.ir.IfNode;

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

        //Now we can do this, why?

        Info info1 = new Machine();
        info1.showInfo();

        Info info2 = person;
        info2.showInfo();

//        outPutInfo(mach1);
//        outPutInfo(person);
    }

//    private static void outPutInfo(Info info){
//        info.showInfo();
//    }

}

/*
output:
Hello there!
Machine id is: 7
Person name is: Andrew
Machine id is: 7
Person name is: Andrew

 */