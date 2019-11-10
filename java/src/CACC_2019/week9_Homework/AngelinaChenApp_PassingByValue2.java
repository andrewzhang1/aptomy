package CACC_2019.week9_Homework;

import CACC_2019.week9_Method_Overload.AppPassingByValue2;

class App_PassingByValue2 {
    public static void main(String[] args) {
        AppPassingByValue2 app = new AppPassingByValue2();

        int value = 7;
        app.show(value);

        int fox = 9;
        app.show(fox);
    }
    public void show(int value){
        System.out.println("Value is" + value);
    }
}

//Value is 7
//Value is 9