package CACC_2019.week9_Homework;

import CACC_2019.week9_Method_Overload.App_PassingByValue1;

class AppPassingByValue1 {
    public static void main(String[] args) {
        App_PassingByValue1 app = new App_PassingByValue1();
        app.show(7);
    }
    public void show(int value){
        System.out.println("Value is" + value);
    }
}
//Value is 7