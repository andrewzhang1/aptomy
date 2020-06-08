package CACC_2019.week25_LinkedList;

// Prog Name: App1b.java

// Note: Just make sure no error for the compilation

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App1b {
    public static void main(String[] args) {

       List<Integer> arrayList = new ArrayList<Integer>();
       List<Integer> linkedList = new LinkedList<Integer>();

       // Collection:

        // Lets say that I want to pass these to a function
        doTimings("ArrayList", arrayList);
        doTimings("LinkedList", linkedList);
    }
    // This can pass anything that implement the list interface to this method
    private static void doTimings(String type, List<Integer> list) {

    }
}

