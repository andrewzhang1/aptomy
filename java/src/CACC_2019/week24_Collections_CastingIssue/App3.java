package CACC_2019.week24_Collections_CastingIssue;
import java.util.ArrayList;

// ArrayList: A more comprehensive demo

public class App3 {
    public static void main(String[] args) {
        //will dynamically grow
        ArrayList listOfValues1 = new ArrayList();
        listOfValues1.add(1); //add integer to it

        //(it eventually converts to Inter object)
        listOfValues1.add(2);
        listOfValues1.add('w');
        System.out.println("listOfValues1 is now: " + listOfValues1);

//      remove all of the members
        listOfValues1.clear();
//
        System.out.println("\nAfter runing  listOfValues1.clear(): " + listOfValues1);
//
//        //now add another type of object to same
//        //ArrayList
        listOfValues1.add("John");
        listOfValues1.add("Jack");
        listOfValues1.add("Jill");
        System.out.println("\nAfter inserted values into listOfValues1: " + listOfValues1);
//
        System.out.println("\nThe 3rd of the list is: " + listOfValues1.get(2));
//        //find who is there in third position
    }
}
