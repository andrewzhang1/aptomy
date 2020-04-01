package CACC_2019.Week23_moreSort_0301;

public class App2_SortArryTwoLoop {
    public static void main(String[] args) {
        // Define an array
        int[] arry = {6, 4, 5, 3};

        float[] arryF = {33.3f,  23f, 4f, -3f};
        double[] arryD = {3.44, 2, 3d, 3444499988d};
        // Call the array

//
//        for (int i = 0; i < arry.length; i++){
//            System.out.println(arry[i]);
//        }

        System.out.println("\nprintArryInt(arry): ");
        printArryInt(arry);

        System.out.println("\nSorted arrary is : ");
       arry = sortArryInt(arry);


        for (int i = 0; i < arry.length; i++) {
            System.out.print(arry[i] + ", ");
        }
          // Printing the sorted array.

/*
        System.out.println("\nprintArryF(arry): ");
        printArryF(arryF);

        System.out.println("\nprintArryF(arry): ");
        printArryD(arryD);

*/
    }

    public static void printArryInt(int[] array) {
        for (int i = 0; i < array.length; i++) {
            System.out.print(array[i]);
            if (i < array.length - 1) {
                System.out.print(",");
            }
        }
    }

    public static void printArryF(float[] arrayF) {
        for (int i = 0; i < arrayF.length; i++) {
            System.out.print(arrayF[i]);
            if (i < arrayF.length - 1) {
                System.out.print(",");
            }

        }
    }

    public static void printArryD(double[] arrayD) {
        for (int i = 0; i < arrayD.length; i++) {
            System.out.print(arrayD[i]);
            if (i < arrayD.length - 1) {
                System.out.print(",");
            }
        }
    }

    // A sorting method using a temp variable for swaping two values.
    public static int[] sortArryInt(int[] arr) {
        int length = arr.length;

        for (int i = 0; i < length; i++) {
            int temp = 0;
            for (int j = i + 1; j < length ; j++) {
                if (arr[i] > arr[j]) {
                    temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
        return arr;
    }
}

