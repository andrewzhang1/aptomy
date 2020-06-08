package CACC_2019.week30_PassByValue;
/*
Script Name: App1a.java
Note:   1. A basic program calling a show() method

 */
public class App1a {

    public static void main(String[] args) {
        App1a app = new App1a();
        app.show(7);
    }

    public void  show(int value){
        System.out.println("Value is: " + value);
    }
}

/*
Output:
Value is: 7
*/
