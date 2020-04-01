package CACC_2019.week25_LinkedList;

// Or: Alt + Enter
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App3 {
    public static void main(String[] args) {
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        LinkedList<Integer> linkedList = new LinkedList<Integer>();

        // We can change anytime
        List<Integer> linkedList2 = new LinkedList<Integer>();

        doTimings("ArrayList", arrayList);
        doTimings("LinkedList", linkedList);

    }
        private static void doTimings(String type, List<Integer> list){
            for (int i=0; i < 1E5; i++){
                list.add(i);
              //  System.out.println(i);
            }
            long start = System.currentTimeMillis();


/*            for (int i=0; i < 1E5; i++){
                list.add(i);
            }*/

        // Add items elsewhere it list:
            for (int i=0; i<1E5; i++){
                list.add(0,i);
            }
            long end = System.currentTimeMillis();

            System.out.println("Time taken: " + (end - start) + " ms " + type);
        }

        // If you add items to the end of the list
/*
     A golden rule to rememberL for the list:
     1. When you need to user linkedList,
     LinkedList doen't really care where you want to add the items, but arrayList does!
     2. If you want to add items in the middle of a list, you should use LinkedList!
     3. If you just want add items in the end of the list, you may use ArrayList!
     4. If you want o add items near the end of the list, ArrayList could be more efficient than LinkedList

     a*/
}
/*
Output:
Time taken: 2454 ms ArrayList
Time taken: 9 ms LinkedList
*/
