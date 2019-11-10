package CACC_2019.week10_Array;

public class Array_misc {
    public static void main(String[] args) {
        double[] mylist;
        mylist = new double[]{1.6, 3.3};

        int[] values = new int[5];

        System.out.println("Array1 is: " + values[2]);

        for (int i =1; i < 5; i ++){
            values[i] = i + values[i - 1];
        }
        values[0] = values[1] + values[4];

    }
}
