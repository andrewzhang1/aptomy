package CACC_2019.week9_Homework;

import CACC_2019.week9_Method_Overload.AppPassingByValue3;

class PassingByValue3 {
    public static void main(String[] args) {
        AppPassingByValue3 app = new AppPassingByValue3();

        int value = 7;
        System.out.println("1. Value is" + value);

        app.show(value);
        System.out.println("4. Value is" + value);
    }
    public void show(int value){
        System.out.println("2. Value is" + value);
        value = 8;

        System.out.println("3. Value is" + value);

    }
}
/*
1. Value is 7
2. Value is 7
3. Value is 8
4. Value is 7
 */