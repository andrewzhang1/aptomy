package John_JTFB;

import java.util.ArrayList;
import java.util.HashMap;

class Animal_29{

}

public class JT_30_Using_Generics {
    public static void main(String[] args) {

        /// Java does not jave a genenarics before java 5
        ArrayList list = new ArrayList();

        list.add("apple");
        list.add("banana");
        list.add("oragne");

        String fruit = (String)list.get(1);

        System.out.println(fruit);

        // Modern style

        ArrayList<String> strings = new ArrayList<String>();
        strings.add("cat");
        strings.add("dog");
        strings.add("alligator");

        String animal = strings.get(1);

        System.out.println(animal);

        //// There can be more than one type argument ////

        HashMap<Integer, String> map = new HashMap<Integer, String>();

        //// Java 7 style //////

        ArrayList<Animal_29> someList = new ArrayList<>();

    }
}


