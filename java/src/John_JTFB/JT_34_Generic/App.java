package John_JTFB.JT_34_Generic;

import java.util.ArrayList;
import java.util.HashMap;

class Animal{

}

public class App {
    public static void main(String[] args) {
/////////////////// Before Java 5 ////////////////////////


        /////////////////// Before Java 5 ////////////////////////
        ArrayList list = new ArrayList();

        list.add("apple");
        list.add("banana");
        list.add("orange");

        // down cast from object
        String fruit = (String) list.get(1);

        System.out.println(fruit);

        /// Modern style

        ArrayList<String> strings = new ArrayList<String>();
        strings.add("cat");
        strings.add("dog");
        strings.add("alligator");

        String animal = strings.get(1);
        System.out.println(animal);

        // One more type
        HashMap<Integer, String > map = new HashMap<Integer, String>();

        //// java 7 style
        ArrayList<Animal> someList = new ArrayList<>();


    }
}
