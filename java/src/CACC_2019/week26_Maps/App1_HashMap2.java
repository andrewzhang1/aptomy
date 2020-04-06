/*
Script Name: App1_HashMap2.java
Note: What if you try to get a value that doesn't exist in you map? it get "null:
2: What if you have duplicated key? The result get overwritten!
*/

import java.util.HashMap;

public class App1_HashMap2 {
    public static void main(String[] args) {
        HashMap<Integer, String> map = new HashMap<Integer, String>();
        map.put(5, "Five");
        map.put(8, "Eight");
        map.put(4, "Four");
        map.put(2, "Two");

        // Try 1: What if you try to get a value that doesn't exist in you map?
        String text1 = map.get(1);
        System.out.println(text1);

        // Try 2: What if you have duplicated key?
         map.put(4, "Andrew");
        String text3 = map.get(4);
        System.out.println(text3);
    }
}

//Output:
//null
//Hello