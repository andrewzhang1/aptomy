package CACC_2019.week15_String;

/*
Note:  Another different way to run toString method
 */

class Frog4{

    private int id;
    private String name;

    public Frog4(int id, String name){
        this.id = id;
        this.name = name;
    }

    public String toString(){
        return String.format("%4d: %s", id, name);
    }
}

public class App8_toStringMethod4 {
    public static void main(String[] args) {

        Frog4 frog4a = new Frog4(3, "Andrew");
        Frog4 frog4b = new Frog4(2, "Jason");
        System.out.println(frog4a);
        System.out.println(frog4b);
    }
}

/*
output:
3: Andrew
2: Jason

or (by use "%-4d: %s"):
3   : Andrew
2   : Jason
 */
