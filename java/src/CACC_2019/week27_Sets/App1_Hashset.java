package CACC_2019.week27_Sets;


import javafx.scene.effect.SepiaTone;

import java.util.HashSet;
import java.util.Set;

/*
Script Name: App1_Hashset.java
Sets: A Collection that installs only unique elements
 */
public class App1_Hashset {
    public static void main(String[] args) {
        Set<String> set1 = new HashSet<>();

        set1.add("dog");
        set1.add("cat");
        set1.add("snake");
        set1.add("bear");
        set1.add("mice");

        System.out.println(set1);
    }
}

/*
Oputput:
[cat, snake, bear, dog]*/
