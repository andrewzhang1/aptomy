package CACC_2019.week10_Array;

public class Array4_SumElement {
    public static void main(String[] args) {
        double[] myList = { 2.3, 3.4, 3.5, 4.2, 3.5 };

        double total = 0;
        for (int i = 0; i < myList.length; i++) {
            total += myList[i];
        }
        System.out.println("Total is: " + total);
    }
}

/*
Total is: 16.9*/
