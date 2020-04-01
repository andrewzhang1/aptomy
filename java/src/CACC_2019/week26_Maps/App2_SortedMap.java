package CACC_2019.week26_Maps;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

public class App2_SortedMap {
    public static void main(String[] args) {
        // by default, we use integer as key and values string
        HashMap<Integer, String > hashMap = new HashMap<>();
        LinkedHashMap<Integer, String > linkedHashMap = new LinkedHashMap<>();
        TreeMap<Integer, String > treeMap = new TreeMap<Integer, String>();

        testMap(hashMap);
    }

    public static void testMap(Map<Integer, String> map){
        map.put(9, "fox");
        map.put(4, "tiger");
        map.put(8, "snake");
        map.put(0, "bear");
        map.put(1, "swam");
        map.put(6, "dog");

        for (Integer key: map.keySet()){
            String values= map.get(key);
            System.out.println(key + " : " + values);
        }
    }
}
