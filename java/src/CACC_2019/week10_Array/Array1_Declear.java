package CACC_2019.week10_Array;

public class Array1_Declear {
    public static void main(String[] args) {
        //int value = 7;  // Primitive type of int, create enough memory to hold the variable

        int[] values;  // This is not a primitive type for array, just a value type of integer and reference for values.
        values = new int[3];  // Tell values to hold 10 integers.

        int x = 1;  // Test 1: Entering x from 0 to 2, the result is alwasy 0, and if x > 9, it will have error, why?
        System.out.println(values[x]);
    }
}

/*
Default is "0"

 */