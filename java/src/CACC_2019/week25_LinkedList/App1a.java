package CACC_2019.week25_LinkedList;

// Prog Name: App1a.java
// Note: Basic List types

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App1a {
    public static void main(String[] args) {

       ArrayList<Integer> arrayList = new ArrayList<Integer>();
       LinkedList<Integer> linkedList = new LinkedList<Integer>();

//       <>
//        []
//
       /* The idea is: after you created a type of list you wanna use, but afterwards
       you don't care; so late you could use the common list methods to manipulate the list:
       getItems, setItems, and so on..
        */


        // Lets say that I want to pass these to a function
        doTimings("ArrayList", arrayList);
        doTimings("LinkedList", linkedList);
    }
    // This can pass anything that implement the list interface to this method
    private static void doTimings(String type, List<Integer> list) {

    }
}

