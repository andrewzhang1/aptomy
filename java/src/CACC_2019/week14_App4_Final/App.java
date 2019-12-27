package CACC_2019.week14_App4_Final;

class Thing {
    public final static int LUCKY_NUMBER = 7 ;

    public String name;
    public static String description;

    public static int count = 0;
    // I want the "id" to be unique for each object
    public int id;

    // A contractor here
    public Thing(){
        id = count; // it count at each object is run
        count++;
    }

    public void showName(){
        System.out.println("Object id: " + description + name);
    }

    public static void showInfo(){
        System.out.println("Hello");
        System.out.println(description);
    }
}

public class App {
    //private static Object Math;

    public static void main(String[] args) {
        Thing.description = "I'm a thing!";

        System.out.println("Before creating object, count is: " + Thing.count);

        Thing thing1 = new Thing();
        Thing thing2 = new Thing();
        Thing thing3 = new Thing();

        System.out.println("After creating objec, count is: " + Thing.count);

        thing1.name = "Bob";
        thing2.name = "Sue";

        System.out.println(thing1.name);
        System.out.println(thing2.name);

        Thing.showInfo();

        thing1.showName();
        thing2.showName();

        // See how we make our own constance:
        //Math.PI = 3; // This will give us an error!
        System.out.println(Math.PI);
        System.out.println(Thing.LUCKY_NUMBER);
    }
}
/*output:
Before creating object, count is: 0
After creating objec, count is: 3
Bob
Sue
Hello
I'm a thing!
Object id: I'm a thing!Bob
Object id: I'm a thing!Sue
3.141592653589793
7
*/



