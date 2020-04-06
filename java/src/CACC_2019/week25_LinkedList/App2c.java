package CACC_2019.week25_LinkedList;

// Prog Name: App2c.java
// Note: 1. Comparing the speed: ArrayList vs LinkedList
//       2. Add items in the beginner of the list...

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App2c {
    public static void main(String[] args) {
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        LinkedList<Integer> linkedList = new LinkedList<Integer>();

        // We can change anytime

        doTimings("ArrayList", arrayList);
        doTimings("LinkedList", linkedList);

    }
        private static void doTimings(String type, List<Integer> list){
            // 1E5 (1e5 means 1*10^5)
            // First, we just create a list with 1E5 items:
            for (int i=0; i < 1E5; i++){
                list.add(i);
                //System.out.println(i);
            }
            long start = System.currentTimeMillis();

            // Add items elsewhere in list
            for(int i=0; i<1E5; i++){
                // Takes index as the first parameter, which is the location
                // where you'll wnat to add the items:
                // ArrayList: VERY SLOW!!!
                list.add(0, i);
            }
            long end = System.currentTimeMillis();

            System.out.println("Time taken: " + (end - start) + " ms " + type);
        }
}
/*
Output:
1E5:
Time taken: 3497 ms ArrayList
Time taken: 10 ms LinkedList

1E6:
Time taken: almost hanging
Time taken: 36 ms LinkedList


*/
