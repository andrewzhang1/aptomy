package CACC_2019.week10_Array;

public class Array5_FindLagest {
    public static void main(String[] args) {

        double[] myList = {2.3, 3.4, 3.5, 4.2, 3.5};
        double max = myList[0];
        for (int i = 1; i < myList.length; i++) {
            if (myList[i] > max) {
                max = myList[i];
            }
        }
        System.out.println("Max is: " + max);
    }
}

/*
Max is: 4.2*/
