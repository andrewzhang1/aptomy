package CACC_2019.week15_String;
/*
Note:  The real use of the string representaion of your object
that enables you to indentify the object, which is helpful for debugging
 */
class Frog3{
    private int id;
    private String name;

    public Frog3(int id, String name){
        this.id = id;
        this.name = name;
    }
    public String toString(){

        // Practice 1:
        // return id + " : " + name;
        /*Nothing wrong to write this way; however it's not efficient!! */

        // Practice 2:
        // /*
        StringBuilder sb = new StringBuilder();
        sb.append(id).append(": ").append(name);
        return sb.toString();
        //  */
    }
}

public class App7_toStringMethod3 {
    public static void main(String[] args) {

        Frog3 frog3a = new Frog3(3, "Andrew");
        Frog3 frog3b = new Frog3(2, "Jason");
        System.out.println(frog3a);
        System.out.println(frog3b);
    }
}

/*
output:
3: Andrew
2: Jason

 */
