package CACC_2019.week27_Sets;

import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;

/*
Script Name: App4_Tresset.java
Sets: A Collection that installs only unique elements

Note:  1. See what if added duplicated element...
       2. HashSet doesn't retains order
       3. LinkedHashset remembers the order you added items in
       4. Treeset sorts sets in natural order
 */
public class App4_Treeset {
    public static void main(String[] args) {
        //Set<String> set1 = new HashSet<>();
        //Set<String> set1 = new LinkedHashSet<>();

        Set<String> set1 = new TreeSet<>();
        set1.add("dog");
        set1.add("cat");
        set1.add("snake");
        set1.add("zebra");
        set1.add("bear");
        set1.add("tiger");
        set1.add("tiger");
        // Addiong duplicate items does nothing
        set1.add("cat");
        System.out.println(set1);
    }
}

/*
Oputput:
[bear, cat, dog, snake, tiger, zebra]
*/
