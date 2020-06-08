package CACC_2019.week27_Sets;


import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

/*
Script Name: App3_LinkedHashset.java
Sets: A Collection that installs only unique elements

Note:  1. See what if added duplicated element...
       2. HashSet doesn't retains order
       3. LinkedHashset remembers the order you added items in
 */
public class App3_LinkedHashset {
    public static void main(String[] args) {
        //Set<String> set1 = new HashSet<>();

        Set<String> set1 = new LinkedHashSet<>();
        set1.add("bear");
        set1.add("dog");
        set1.add("cat");
        set1.add("snake");
        set1.add("zebra");

        set1.add("tiger");
        // Addiong duplicate items does nothing
        set1.add("cat");
        System.out.println(set1);
    }
}

/*
Oputput:
[bear, dog, cat, snake, zebra, tiger]
*/
