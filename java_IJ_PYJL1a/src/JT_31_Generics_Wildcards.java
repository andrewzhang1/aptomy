import java.util.ArrayList;
import java.util.HashMap;

class Machine_31 {

    @Override
    public String toString() {
        return "I'm a machine.";
    }
}

class Camera_31 extends Machine_31 {
    @Override
    public String toString() {
        return "I'm a camera!";
    }
}

public class JT_31_Generics_Wildcards {
    public static void main(String[] args) {

/*      Try one:
        ArrayList<String > list = new ArrayList<String>();
        list.add("one");
        list.add("two");

        showList(list);
    }
    public static void showList(ArrayList<String> list){
        for(String value: list){
            System.out.println(value);
        }
    }*/

// Print out:
/*one
two*/

//     Tru two:

        ArrayList<Machine_31> list1 = new ArrayList<Machine_31>();

        list1.add(new Machine_31()); // Machine does not have any instance variables
        list1.add(new Machine_31());

        ArrayList<Machine_31> list2 = new ArrayList<Machine_31>();

        list2.add(new Camera_31()); // Machine does not have any instance variables
        list2.add(new Camera_31());

        showList(list1);

        //  The tempetations is


    }

    public static void showList(ArrayList<Machine_31> list) {
        for (Machine_31 value : list) {
            System.out.println(value);
        }
    }

}


