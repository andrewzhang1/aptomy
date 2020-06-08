package CACC_2019.week25_LinkedList;

// Prog Name: App2a.java
// Note: Comparing the speed: ArrayList vs LinkedList (Prepare a list). This is just a scheleton

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App2a {
    public static void main(String[] args) {
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        LinkedList<Integer> linkedList = new LinkedList<Integer>();

        // We can change anytime

        doTimings("ArrayList", arrayList);
        doTimings("LinkedList", linkedList);

    }
        private static void doTimings(String type, List<Integer> list){
            // 1E5 (1e5 means 1*10^5)
            // First, we just prepared to create a list with 1E5 items:
            for (int i=0; i < 1E6; i++){
                list.add(i);
                //System.out.println(i);
            }
            long start = System.currentTimeMillis();

            long end = System.currentTimeMillis();

            System.out.println("Time taken: " + (end - start) + " ms " + type);
        }
}
/*
Output:
Time taken: 0 ms ArrayList
Time taken: 0 ms LinkedList
*/
