package CACC_2019.week27_Sets;


import java.util.HashSet;
import java.util.Set;

/*
Script Name: App2_Hashset.java
Sets: A Collection that installs only unique elements

Note:  1. See what if added duplicated element...
       2. HashSet doesn't retains order

 */
public class App2_Hashset {
    public static void main(String[] args) {
        Set<String> set1 = new HashSet<>();

        set1.add("dog");
        set1.add("cat");
        set1.add("snake");
        set1.add("zebra");
        set1.add("bear");
        set1.add("tiger");
        // Addiong duplicate items does nothing
        set1.add("snake1");
        set1.add("tiger");

        System.out.println(set1);
    }
}

/*
Oputput:
[zebra, cat, tiger, snake, bear, dog]
*/
