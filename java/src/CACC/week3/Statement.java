package CACC.week3;

public class Statement {
    public static void main(String[] args) {
      /*
        statement
      */

        int size = 10;
        size = size * 100;

        int length = 15;
        int width, area;
        width = 30;
        area = length * width;

        System.out.println("size is: " + size);
        System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
      /*
        code block. A code block is a series of statements surrounded by curly braces
      */
        {
            int x = 20;
            System.out.println("x is: " + x);
        }

      /*
        scope
      */
        //System.out.println("x is: " + x);

      /*
        conditional
        based on condition
      */

        if (length > 10) {
            width = 70;
            area = length * width;
            System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
        } else {
            System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
        }
        System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));

        if (length < 10) {
            width = 70;
            area = length * width;
            System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
        } else if (length < 20){
            width = 30;
            area = length * width;
            System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
        } else {
            System.out.println(String.format("length is: %s; width is: %s; area is: %s", length, width, area));
        }

      /*
        loop statement
      */
        int count = 10;
        do {
            System.out.println("do-while loop: " + count--);
        } while(count > 0);

        count =10;
        while(count > 0) {
            System.out.println("while loop: " + count--);
        }

        for(int i = 0; i < 10; i++) {
            System.out.println("for loop: " + i);
        }

        int [] arrayOfInts = new int [] { 1, 2, 3, 4 };
        for( int i : arrayOfInts )
            System.out.println("enhanced for loop: " + i );

      /*
        break and continue
      */
        count = 0;
        while(true) {
            if (count++%2 == 0)
                continue;

            if (count > 20) break;
            System.out.println("break-continue: " + count);
        }
      /*
        switch
      */
        int value = 2;
        switch( value ) {
            case 1:
                System.out.println( 1 );
            case 2:
                System.out.println( 2 );
            case 3:
                System.out.println( 3 );
        }
    }
}
