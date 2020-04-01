package CACC_2019.week24_Collections_CastingIssue;

//import java.util.ArrayList;

import java.util.ArrayList;

// ArrayList can dynamically increase the size
public class App2 {
    public static void main(String[] args) {

        ArrayList names = new ArrayList(4);
        names.add("jack");
        names.add("jill");
        names.add("john");
        // names.add("Eric");
        names.add("Eric");
        names.add("Andrew");
        names.add("Gore");
        names.add("Angelina");

        System.out.println("The length of this ArrayList is:" + names.size());

        System.out.println("\nIteration #1: ");
        for (int i = 0; i < names.size(); i++) {
            System.out.println(names.get(i));
        }

        System.out.println("\nIteration #2: ");
        for (Object value : names) {
            System.out.println(value);
        }

        // How do you remove element:
        names.remove(names.size() - 2);  // 0,  -1

        System.out.println("\nIteration #3: ");
        for (Object value : names) {
            System.out.println(value);
        }

        // It's very slow to remove from the beginning
//        names.remove(0);


    }
}
