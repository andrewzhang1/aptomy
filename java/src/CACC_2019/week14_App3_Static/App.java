package CACC_2019.week14_App3_Static;

class Thing {
    public final static int LUCKY_NUMBER = 7;

    public String name;
    public static String description;
    // Do you see the differences?

    public void showName(){
        System.out.println(name);
    }

    public static void showInfo(){
        System.out.println("Hello");
        System.out.println(description);

        // But I static methods can't output instance variables like name;
        // and this will get an error:
        // Error:(19, 28) java: non-static variable name cannot be referenced from a static context
        //System.out.println(name);
    }
}

public class App {
    //private static Object Math;

    public static void main(String[] args) {
        Thing.description = "Im a thing!";

        Thing.showInfo();
        Thing thing1 = new Thing();
        Thing thing2 = new Thing();

        thing1.name = "Bob";
        thing2.name = "Sue";

        System.out.println(thing1.name);
        System.out.println(thing2.name);

        System.out.println("==> showInfo:");
        Thing.showInfo();

        System.out.println("==> showInfo - End");
        thing1.showName();
        thing2.showName();

        System.out.println(Math.PI);
    }

}





