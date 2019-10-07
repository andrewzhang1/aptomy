package CACC_2018.week24;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.TreeSet;

public class CollectionsPractice_Sample {
    static TreeSet<Integer> myTreeSet = new TreeSet<>();

    static LinkedList<String> myLinkedlist = new LinkedList<>();

    static HashMap<String, String> myHashMap = new HashMap<>();

    public static void main(String[] args) {
        // try TreeSet Collection
        /*myTreeSet.add(15);
        myTreeSet.add(2);
        myTreeSet.add(10);
        myTreeSet.add(7);
        myTreeSet.add(3);
        myTreeSet.add(20);
        log(myTreeSet.first().toString());
        log(myTreeSet.toString());
        log("");*/

        // LinkedList
        /*myLinkedlist.add("banana");
        myLinkedlist.add("mango");
        log(myLinkedlist.toString());
        myLinkedlist.addFirst("apple");
        myLinkedlist.add(myLinkedlist.indexOf("mango"), "cherry");
        log(myLinkedlist.toString());
        log("");*/

        // HashMap
        myHashMap.put("2", "Banana");
        myHashMap.put("3", "Mango");
        log(myHashMap.toString());
        myHashMap.put("5", "Apple");
        log(myHashMap.toString());
        log(myHashMap.get("3"));
        log("");
    }

    public static void log(String str) {
        System.out.println(str);
    }
}
