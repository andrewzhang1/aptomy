package CACC_2019.week26_Maps;
/*
Script Name: App1_HashMap1.java
Note: Basic Hash Map syntax: put, get, and key - pair
 */
//import java.util.HashMap;

import java.util.HashMap;

public class App1_HashMap1 {
    public static void main(String[] args) {
        HashMap<Integer, String> map = new HashMap<Integer, String>();
        map.put(5, "Five");
//        map.put(8, "Eight");
//        map.put(4, "Four");
//        map.put(2, "Two");

        String text = map.get(5);
        System.out.println(text);
        // Let's try different key.
    }
}

//Output:
//Two
