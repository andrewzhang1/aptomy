package CACC_2019.week26_Maps;

/*
Map: basically uses put and get
, they are not sorted

 */
import javax.sound.midi.Soundbank;
import java.util.HashMap;
import java.util.Map;

public class App1_HashMap {
    public static void main(String[] args) {
        HashMap<Integer, String> map = new HashMap<Integer, String>();
        map.put(5, "Five");
        map.put(8, "Eight");
        map.put(4, "Four");
        map.put(4, "Four");
        map.put(2, "Two");

        map.put(6, "Hello");

        String text = map.get(4);
        System.out.println(text);

        for (Map.Entry<Integer, String> entry: map.entrySet()){
            int key = entry.getKey();
            String value = entry.getValue();

            System.out.println(key + " : " + value);

        }


    }
}

/* Output:
Four
2 : Two
4 : Four
5 : Five
6 : Hello
8 : Eight
*/
