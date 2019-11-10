package CACC_2019.week9_Method_Overload;

public class AppPassingByValue2 {
    public static void main(String[] args) {
        AppPassingByValue2 app = new AppPassingByValue2();

        // call 1:
        int value = 7;
        app.show(value); //Remember: we copy one valuable from one to anther
        // this call is passing by value.App_PassingByValue2

        // call 2:
        // We can use any variables
        char fox = '0';
        app.show(fox);
    }

    public void show(int value){
        System.out.println("Value is: " + value);
    }
}

/*
Value is: 7
Value is: 9
*/
