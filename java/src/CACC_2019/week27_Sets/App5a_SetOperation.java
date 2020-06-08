package CACC_2019.week27_Sets;

import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

/*
Script Name: App4_SetOperation.java
Sets: A Collection that installs only unique elements

Note:  1. See what if added duplicated element...
       2. HashSet doesn't retains order
       3. LinkedHashset remembers the order you added items in
       4. Treeset sorts sets in natural order
       5. See what the operation is for set
       6. Search google "java 8 set" for more info on iterate.
*/

public class App5a_SetOperation {
    public static void main(String[] args) {
        //Set<String> set1 = new HashSet<>();
        //Set<String> set1 = new LinkedHashSet<>();

        Set<String> set1 = new TreeSet<>();

        if(set1.isEmpty()) {
            System.out.println("Set is Empty at the starts!");
        }

        set1.add("dog");
        set1.add("cat");
        set1.add("snake");
        set1.add("zebra");
        set1.add("bear");
        set1.add("tiger");

        // Addiong duplicate items does nothing
        set1.add("cat");
        System.out.println(set1);

        ///// Operation:////

        // 2. Iteration
        for (String element: set1){
            System.out.println(element);
        }

        // 3. Does set contains a given items?
        if(set1.contains("Mouse")) {
            System.out.println("Contains Mouse");
        }

        if(set1.contains("tiger")) {
            System.out.println("Contains tiger");
        }

        if(set1.isEmpty()) {
            System.out.println("Set is Empty at ending!");
        }
    }
}

/*
Oputput:
Set is Empty at the starts!
[bear, cat, dog, snake, tiger, zebra]
bear
cat
dog
snake
tiger
zebra
Contains cat
[zebra, monkey, ant, giraffe, cat, snake, bear, tiger, dog]
*/

