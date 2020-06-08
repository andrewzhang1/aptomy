package CACC_2019.week27_Sets;

import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

/*
Script Name: App5b_Intersection.java
Sets: A Collection that installs only unique elements

Note:  1. See what if added duplicated element...
       2. HashSet doesn't retains order
       3. LinkedHashset remembers the order you added items in
       4. Treeset sorts sets in natural order
       5. See what the operation is for set
       6. Serach google "java 8 set" for more info on intersection
*/

public class App5b_Intersection {
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

        // Addiong duplicate items does nothing
        set1.add("cat");
        System.out.println(set1);

        //////// Intersecton
        // set2 has some in common with set1, but added something new
        Set<String> set2 = new TreeSet<>();

        set2.add("dog");
        set2.add("cat");
        set2.add("giraffe");
        set2.add("monkey");
        set2.add("bear");
        set2.add("ant");

        // print all
        Set<String> intersection = new HashSet<String>(set1);
        System.out.println(intersection);

        // Return only that has in the sec2
        intersection.retainAll(set2);


        System.out.println("\nWhat common to the both sets:");

        System.out.println(intersection);

        ///////// Differences
        Set<String> differences = new HashSet<String>(set1);
//         differences.removeAll(set2);
        // differences.spliterator()  // Search "java 8 set spliterator()"

        System.out.println("\nWhat the differences to the each set:");
        System.out.println(differences);

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

