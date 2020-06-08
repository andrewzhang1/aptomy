package CACC_2019.week30_PassByValue;
/*
Script Name: App2b.java
Note:   1. A basic prorgram calling a show() method
        2. Create a variable "value" and pass it into the method
        3. Added codes for complexity
        4.  "4. Value is" going to print 7 or 8, why? Guess first please!!!
 */
public class App2b {

    public static void main(String[] args) {
        App2b app = new App2b();

        /* Important:
        1. We're doing here is copying data from one variable to another
        2. The scope of the variable is the closest pair of enclosing pair curly parenthesis.
        3. This is called passing by value, which is passing the value into this method
        * */
        int value = 7 ;
        System.out.println("1. Value is: " + value); // output=7, this is easy!

        app.show(value);  // 7
        System.out.println("4. Value is: " + value);
        // Is above "4. Value is" going to print 7 or 8, why? Guess first please!!!
    }

    public void  show(int  value){
        System.out.println("2. Value is: " + value);  // 7

        value = 9;
        /* The scope of value 8 changed within the method show() won't affect the variable outside
          the scope */
        System.out.println("3. Value is: " + value);    // 8
    }
}



/*
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7
*/
