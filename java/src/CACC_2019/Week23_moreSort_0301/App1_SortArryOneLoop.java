package CACC_2019.Week23_moreSort_0301;

public class App1_SortArryOneLoop {
    public static void main(String[] args) {
        // Define an array
        int[] arry = {6, 4, 5, 3};

        float[] arryF = {33.3f, 23f, 4f, -3f};
        double[] arryD = {3.44, 2, 3d, 3444499999999999999999999999994556d};

        System.out.println("\nprintArryInt(arry): ");
        printArryInt(arry);

        System.out.println("\nSorted arrary is : ");
       arry = sortArryInt(arry);

       // Printing the sorted array.
        for (int i = 0; i < arry.length; i++) {
            System.out.print(arry[i] + ", ");
        }
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
    public static int[] sortArryInt(int[] arr) {
        // Finding the length of array 'arr'
        int length = arr.length;

        // Sorting using a single loop
        //
        for (int j = 0; j < length - 1; j++) {

            // Checking the condition for two
            // simultaneous elements of the array
        if (arr[j] > arr[j + 1]) {

                // Swapping the elements.
                int temp = arr[j];
            arr[j] = arr[j + 1];
                arr[j + 1] = temp;

                // updating the value of j = -1
                // so after getting updated for j++
                // in the loop it becomes 0 and
                // the loop begins from the start.
                j = -1;
            }
        }
        return arr;
    }
}

