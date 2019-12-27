package CACC_2019.week13_Constructor.This.App2;

class Frog{

    // Part 1: Create a Get method()
    private int age;   // age is an instance variable, what if I set this a "private" type?
    // Now you won't be access the age and name outside this class: "encapsulation"
    private String name;

    public int getAge(){

        return age;
   }

   public String getName(){

        return name;
   }

   // Part 2: Create a Set method()

    public void setName(String newName)  //
    {
           name  = newName;
    }

    public  void setAge(int newAge){

        age = newAge;
    }
}

public class App {
    public static void main(String[] args) {

        // Part 1:  // Set an instance variable with a "=" sign.
        System.out.println("Part 1: ============\n" );
        Frog frog = new Frog();

        // frog.name = "Andrew";  // Set an instance variable with a "=" sign.
        // frog.age = 12;

        // Note for the part 1: This is NOT a desirable way to call the name!
        System.out.println(frog.getName());

        System.out.println("Part 2: ============\n" );

        // Part 2: Calling a method
        Frog frog1 = new Frog();
        //frog1.name = "Jason";
        // frog1.age = 11;

        System.out.println("Jason is now: " + frog1.getName());
        System.out.println(frog.getAge());

        // We need to use set and get to obtain the age and name now becase we can not directly
        // access the name and age!

        frog1.setAge(17);
        System.out.println("After 3 years later, Mike is now: " + frog1.getAge());
        System.out.println(frog1.getAge());

        System.out.println("Call Jason by using Set Method: ");
        frog1.setName("Jason");
        System.out.println(frog1.getName());

        frog1.setAge(14);
        System.out.println(frog1.getAge());
        // Note: By now, you should have know how to encapsulate the data because you're
        // hiding away the kind of instance data here

    }
}
// Output:
//Part 1: ============
//
//Andrew
//Part 2: ============
//
//Mike is now: Jason
//12
//After 3 years later, Mike is now: 15
