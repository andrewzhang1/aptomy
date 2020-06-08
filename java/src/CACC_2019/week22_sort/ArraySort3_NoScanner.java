package CACC_2019.week22_sort;

// Sort any array without using scanner

public class ArraySort3_NoScanner {
    public static void main(String[] args) {
        int count, temp;

        int[] num = {2, 8, -2, 8, 5};

        for (int i = 0; i < num.length; i++) {
            for (int j = i + 1; j < num.length; j++) {
                if (num[i] < num[j]) {
                    temp = num[i];
                    num[i] = num[j];
                    num[j] = temp;
                }
            }
        }

        System.out.print("Array Elements in Ascending Order: ");
        for (int i = 0; i < num.length - 1; i++) {
            System.out.print(num[i] + ", ");
        }
        System.out.print(num.length - 1);
    }
}
