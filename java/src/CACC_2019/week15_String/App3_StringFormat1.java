package CACC_2019.week15_String;
/*String Format2:
Make sure to understand the difference between "%2d" and "%-2d"
 */
public class App3_StringFormat1 {

    public static void main(String[] args) {
         // Formating
        System.out.println("Here is some text. \tIt's a tab. \nIt's a new line");
        System.out.println("More text...");

        // Formating char: %d is a self-contained formating character with a
        // corresponding argument
        System.out.println("\nFormat 1:");
        System.out.printf("Total cost %d; quantity is %d", 5, 120);
        System.out.println("");

        System.out.println("\nFormat 2: %d only");
        System.out.printf("Total cost %d; quantity is %d\n", 5, 120);

        // %10d: means 10 char wide:
        System.out.println("\nFormat 3: %10d");
        System.out.printf("Total cost is: %10d; quantity is: %d\n", 5, 120);

        // %-10d: means 10 char wide:
        System.out.println("\nFormat 4: %-10d");
        System.out.printf("Total cost is: %-10d; quantity is: %10d\n", 5, 120);

        for (int i = 9; i < 12; i++ ){
            System.out.printf("%2d: some text here\n", i);
        }

        System.out.println("");
        // comapre to: %-2d:
        for (int i = 8; i < 12; i++ ){
            System.out.printf("%-3d: some text here\n", i);
        }
        // Question: When do we should to use "%-3d"?
    }
}

/*
Output:

Here is some text. 	It's a tab.
It's a new line
More text...

Format 1:
Total cost 5; quantity is 120

Format 2: %d only
Total cost 5; quantity is 120

Format 3: %10d
Total cost is:          5; quantity is: 120

Format 4: %-10d
Total cost is: 5         ; quantity is:        120
 8: some text here
 9: some text here
10: some text here
11: some text here

8 : some text here
9 : some text here
10: some text here
11: some text here
*/

