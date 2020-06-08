package CACC_2019.week30_PassByValue;
/*
Script Name: App2a.java
Note:   1. A basic prorgram calling a show() method
        2. Create a variable "value" and pass it into the method
        3. Added codes for complexity
 */
public class App2a {

    public static void main(String[] args) {
        App2a app = new App2a();

        /* Important:
        1. We're doing here is copying data from one variable to another
        2. The scope of the variable is the closest pair of enclosing pair curly parenthesis.
        3. This is called passing by value, which is passing the value into this method
        * */
        int value = 7 ;   // Integer,
        System.out.println("1. Value is: " + value);
//
        app.show(value);
        System.out.println("3. Value is: " + value);
    }
//
    public void  show(int value){
        System.out.println("2. Value is: " + value);
    }
}
/* Output:
1. Value is: 7
2. Value is: 7
1. Value is: 7
*/
