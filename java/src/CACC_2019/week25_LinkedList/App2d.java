package CACC_2019.week25_LinkedList;

/*
 Prog Name: App2d.java
 Note: 1. Comparing the speed: ArrayList vs LinkedList
       2.  Add items that are 100 elements from the end of the list
*/

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App2d {
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


            // Add items that are 100 elements from the end of the list
            for(int i=0; i<1600; i++){
                 list.add(list.size() - 100, i);
            }
            long end = System.currentTimeMillis();

            System.out.println("Time taken: " + (end - start) + " ms " + type);
        }
}
/*
Output:
1E5:
Time taken: 9 ms ArrayList
Time taken: 35 ms LinkedList

1E6:
Time taken: 46 ms ArrayList
Time taken: 335 ms LinkedList

Test 1:  -100
Time taken: 1 ms ArrayList
Time taken: 15 ms LinkedList

Test2 :  -2100

*/
