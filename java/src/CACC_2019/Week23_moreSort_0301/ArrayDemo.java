package CACC_2019.Week23_moreSort_0301;

// https://www.geeksforgeeks.org/arrays-sort-in-java-with-examples/

import java.util.Arrays;

public class ArrayDemo {
    public static void main(String[] args) {

        {
            // Our arr contains 8 elements
            int[] arr = {13, 7, 6, 45, 21, 9, 101, 102};

            Arrays.sort(arr);

            // Print out the sorted array usoing toString, which
            // returns the string representation of the object:
            System.out.printf(Arrays.toString(arr));

        }

        String[] names = new String[3];
        names[0] = "jack";
        names[1] = "jill";
        names[2] = "john";
        System.out.println();
        for (int i = 0; i < names.length; i++)
            System.out.println(names[i]);
    }
}