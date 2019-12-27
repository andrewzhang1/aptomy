package CACC_2019.week15_App2_toString.App2;

class Frog{

    public int id;
    public String name;

//    public Frog(int id, String name){
//
//    }

    public String toString(){
        return id + ":" + name;

    }
}

public class App2 {
    public static void main(String[] args) {
        Frog frog1 = new Frog();
        frog1.id = 23;
        frog1.name = "Andrew";
        System.out.println(frog1.id);
        System.out.println(frog1.name);

    }
}
