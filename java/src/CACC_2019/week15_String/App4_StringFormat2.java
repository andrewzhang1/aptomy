package CACC_2019.week15_String;
/*
Formating integer vs Formating floating point
Make sure to understand: "%f" vs  "%.2f"
 */
public class App4_StringFormat2 {
    public static void main(String[] args) {
        // Formating
        System.out.println("Here is some text. \tIt's a tab. \nIt's a new line");
        System.out.println("More text...");

        // Formating integers
        System.out.printf("Total cost is: %-10d; quantity is: %d\n", 5, 120);

        for (int i = 8; i < 12; i++) {
            System.out.printf("%-2d: some text here\n", i, "Here is some text");
        }
        // Formating floating point
        System.out.printf("Total value1: %f\n", 5.685);
        System.out.printf("Total value2: %.2f\n", 5.685);

        System.out.printf("Total value3: %f\n", 343.23425);
        System.out.printf("Total value4: %.2f\n", 343.23423);
        System.out.printf("Total value5: %.1f\n", 343.23423);
        System.out.printf("Total value6: %5.1f\n", 343.23423);

        System.out.printf("Total value7: %6.2f\n", 799773.23423);
        // 6 is the width, includes all the character
    }
}

/* Output:

Here is some text. 	It's a tab.
It's a new line
More text...
Total cost is: 5         ; quantity is: 120
8 : some text here
9 : some text here
10: some text here
11: some text here
Total value: 5.685000
Total value: 5.69
Total value: 343.234250
Total value: 343.23
Total value: 343.2
Total value: 343.2
Total value:  343.2
 */