package CACC_2019.week25_LinkedList;

// Prog Name: App2b.java
// Note: 1. Comparing the speed: ArrayList vs LinkedList
//       2. Add items at the end of the list.

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App2b {
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

            // Add items at the end of the list.
            // If the number is larger, it will take even more time for the
            // LinkedList to add (1E5 to 1E6 to see the differences)
            for(int i=0; i <1E6; i++){
                list.add(i);
            }
            long end = System.currentTimeMillis();

            System.out.println("Time taken: " + (end - start) + " ms " + type);
        }
}
/*
Output:
1E5:
Time taken: 6 ms ArrayList
Time taken: 9 ms LinkedList

1E6:
Time taken: 25 ms ArrayList
Time taken: 189 ms LinkedList
*/
