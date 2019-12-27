package CACC_2019.week15_String;

/*
Show toString method: a very useful tool to debug
 */

class Frog{
    public String toString(){
        return "Hello";
    }
}
public class App5_toStringMethod1 {
    public static void main(String[] args) {

        Object obj = new Object();
        // obj.

        Frog frog1 = new Frog();

        System.out.println(frog1);
        /*
        It tries to invoke the two string methods to get a string
        representation of the object.  */
    }
}
/*
Output:
Hello
 */

