package CACC_2019.week15_String;

/*
Note:  "@", looks like a memory address,
      acturally a hash code - an unique idendifier for all
 */

class Frog2{
}

public class App6_toStringMethod2 {
    public static void main(String[] args) {

        Object obj = new Object();
        //obj.

        Frog2 frog1 = new Frog2();
        //frog.

        System.out.println(frog1);
        /*
        It tries to invoke the two string methods to get a string
        representation of the object, and if you don't have any two string methods
        defined for your object, you get something here that looks like
        a memory address "@", acturally a hash code - an unique idendifier for all
        your object in java
         */
    }
}

/*
output:
CACC_2019.week15_String.Frog2@1540e19d
 */
