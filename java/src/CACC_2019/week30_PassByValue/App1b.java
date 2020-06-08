package CACC_2019.week30_PassByValue;
/*
Script Name: App1b.java
Note:   1. A basic prorgram calling a show() method
        2. Create a variable "value" and pass it into the method
 */
public class App1b {

    public static void main(String[] args) {
        App1b app = new App1b();

        /* Important:
        1. We're doing here is copying data from one variable to another
        2. The scope of the variable is the closest pair of enclosing pair curly parenthesis.
        3. This is called passing by value, which is passing the value into this method
        * */
//        int value1 = 7 ;
//        app.show(value1);

        //Same as this, right?
        int fox = 7;
        app.show(fox);

    }

    public void  show(int value){
        System.out.println("Value is: " + value);
        // scope: this value is only valid inside this method
    }
}

/*
Output:
Value is: 7
*/
