package CACC_2019.week25_LinkedList;

// App4.java
/*

Demo:
1.   Add items from close 100 end of the list,
     ArrayList is still FASTER! Why?
*/


import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class App4 {
    public static void main(String[] args) {
        /*
        ArrayList: Manages arrays internally:
        [0] [1] [2] [3] [4] ...

        If you want to add an item in the middle of the list: you need to move all the following
        items up on unit, and then you can add the item in (takes longer time to shift)

        LinkedList: Consists element has point to link each other
          [0]-> [1]-> [2] -> [3] ->  [4] ...

         Normally, ArrayList is recommended; but if you want add or remove an item
         in the middle or beginning of the list anywhere other than near the end of list,
         use LinkedList

         */
        List<Integer> arrayList = new ArrayList<Integer>();
        //You can initialize the size of the ArrayList:
        //List<Integer> arrayList = new ArrayList<Integer>(1000);

        List<Integer> linkedList = new LinkedList<Integer>();

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

        // Add items from close 100 end of the list,
            // ArrayList is still FASTER! Why?
            for (int i=0; i<1E5; i++){
                list.add(list.size() - 100 ,i);
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
