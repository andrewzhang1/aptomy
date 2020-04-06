package CACC_2019.week26_Maps;
/*
Script Name: App2_SortedMap.java
Note: 1. If you want to keep your keys sorted, then you need to
          LinkedHashMap.
*/

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

public class App2_SortedMap {
    public static void main(String[] args) {
        // by default, we use integer as key and values string
        // We create three different maps: HashMap, LinkedHashMap, and LinkedHashMap
        HashMap<Integer, String > hashMap = new HashMap<>();
        LinkedHashMap<Integer, String > linkedHashMap = new LinkedHashMap<>();
        TreeMap<Integer, String > treeMap = new TreeMap<Integer, String>();

//      // 1. Test HashMap:
        System.out.println("HashMap");
        testMap(hashMap);

//      // 2. Test linkedHashMap:
        System.out.println("\nLinked Hash Map");
        testMap(linkedHashMap);

//      // 3. Test TreeMap
        System.out.println("\nTree Map");
         testMap(treeMap);
    }

    // Now, we create a method to add values to the map
    public static void testMap(Map<Integer, String> map){
        map.put(6, "dog");
        map.put(9, "fox");
        map.put(1, "swam");
        map.put(4, "tiger");
        map.put(8, "snake");
        map.put(0, "bear");


        // Another way to iterate:
        for (Integer key: map.keySet()){
            String values= map.get(key);
            System.out.println(key + " : " + values);
        }
        // Next week, we will talk about the details for the keySet()
    }
}
/*

Outout:
HashMap
0 : bear
1 : swam
4 : tiger
6 : dog
8 : snake
9 : fox

Linked Hash Map
9 : fox
4 : tiger
8 : snake
0 : bear
1 : swam
6 : dog

Tree Map
0 : bear
1 : swam
4 : tiger
6 : dog
8 : snake
9 : fox
*/
