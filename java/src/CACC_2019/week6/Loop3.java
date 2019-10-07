package CACC_2019.week6;

public class Loop3 {
    public static void main(String[] args) {

        int value = 0;
        System.out.println("part 1: Basic boolean handling: ");
        boolean loop1 = true;
        System.out.println(loop1);
        System.out.println("");

        System.out.println("part 2: Basic boolean handling: 4 > 5 ");
        boolean loop2 = 4 > 5;
        System.out.println(loop2);
        System.out.println("");

        //part 3: Basic boolean handling: 10 < 20
        System.out.println("part 3: Basic boolean handling: 10 < 20 ");
        boolean loop3 = value < 20;
        System.out.println(loop3);
        System.out.println("");

        //part 4: Basic While Loop:
        System.out.println("Hello");
        System.out.println("part 4: Basic While Loop: ");


        value = 3;
        while (value <= 3){
            System.out.println("Hello," + "it's " + value + " th time now.");
            value = value +1;
        }
        System.out.println("");

        //part 5: For loop:
        System.out.println("part 5: Basic FOR loop: ");

        for ( int i = 1; i <= 5 ; i++ ) {
            System.out.println("This is \"for\" loop No. " + i);
            System.out.printf("The value is:     %d\n", i);
        }

        System.out.println();
        //part 6: if statement:
        boolean cond1 = 1 != 2;
        System.out.println(cond1);

        boolean cond2 = 4 == 3;
        System.out.println(cond2);

        System.out.println();
        int sum = 0;
        for ( int i = 0; i < 5 ; i++){
            sum  = sum + i;
        }
        System.out.println("Sum of the first 5 numbers is: " + sum );

    }
}
