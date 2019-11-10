package CACC_2019.week9_Method_Overload;

public class App_PassingByValue1 {
    public static void main(String[] args) {
        App_PassingByValue1 app = new App_PassingByValue1();
        // This shows how to pass by a value 7;
        // You can create a method to do complicated calculations as we did before.
        app.show(7);
    }

    public void show(int x){
        System.out.println("Value is:" + x);
    }
}

/*
Value is:7
*/
