package CACC_2019.week10_Array;

public class Array2_Create_Demo {
    public static void main(String[] args) {
//        // Part 1: Declaration
//        int value = 7;  // Primitive type of int, create enough memory to hold the variable
//        int[] values;  // not a primitive, as it does no create any momory holder, just a value type and reference for values.
//        values = new int[10];  // Tell values to hold 10 integers.
//        int x = 9;  // Test entering x from 0 to 9, the result is alwasy 0, and if x > 9, it will have error, why?
//        System.out.println(values[x]);

        // Part 2: Define array
//        int[] values = new int[10];  // Tell values to hold 10 integers.
//
//        values[0] = 10;
//        System.out.println(values[0]);  // only the values[0] is defined, so it print out 10!
//        System.out.println(values[2]);  //?
//        System.out.println(values[3]);   // ?

        // Part3: How to print array by a loop
        System.out.println("\n1. Traditional loop: ");
        int[] number = {5, 6, 7};
        for (int i=0; i < number.length; i++ ){
            System.out.println(number[i]);
        }

        System.out.println("\n2. Enchance for loop: ");
        for (int i: number){
            System.out.println(i);
        }
    }
}
