package CACC_2019.week24_Collections;

import java.util.ArrayList;

public class App4 {
    public static void main(String[] args) {
              //is not this scary? You can even add newbox in it, WHAT? wait a minute, how
        //can I mix apple and oranges? How do I know what I have stored in there
        listOfValues1.add(new NewBox(10));
        listOfValues1.add(new NewBox(20));
        listOfValues1.add(new NewBox(30));

        //this definitely looks scary to me
        NewBox getBox = (NewBox) listOfValues1.get(3);
        System.out.println(listOfValues1);
        NewBox newBox = new NewBox(30);

        //Ah this is consoling, at least I can test out what is inside the ArrayList
        //before I use it Ok, then looks like it can be used
        if (listOfValues1.contains(newBox)) {
            System.out.println("This Box is present");
        } else
            System.out.println("This Box is not present");
    }
}
