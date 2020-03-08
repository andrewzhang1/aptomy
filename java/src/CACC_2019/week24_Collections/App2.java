package CACC_2019.week24_Collections;
import java.util.ArrayList;
import java.util.Arrays;
public class App2 {
    public static void main(String[] args) {
        ArrayList names = new ArrayList();
        names.add("jack");
        names.add("jill");
        names.add("john");
       // names.add("Eric");
        names.add("Andrew");
        for (int i = 0; i < names.size(); i++) {
            System.out.println(names.get(i));

        }
    }
}
