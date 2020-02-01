package CACC_2019.week13_Constructor_This.This.App1;

class Frog{

    // Part 1: Create a Get method()
    int age;   // age is an instance variable, what if I set this a "private" type? See App2
    String name;

    public int getAge(){

        return age;
   }

   public String getName(){

        return name;
   }

   // Part 2: Create a Set method()

    public void SetName(String newName)  //  "newName" is a local variable
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

        frog.name = "Andrew";  // Set an instance variable with a "=" sign.
        frog.age = 12;

        // Note for the part 1: This is NOT a desirable way to call the name!
        System.out.println(frog.getName());

        System.out.println("Part 2: ============\n" );

        // Part 2: Calling a method
        Frog frog1 = new Frog();
        frog1.name = "Jason";
        frog1.age = 11;

        System.out.println("Mike is now: " + frog1.getName());
        System.out.println(frog.getAge());

        frog1.setAge(15);
        System.out.println("After 3 years later, Mike is now: " + frog1.getAge());

        System.out.println("Call Mile by using Set Method: ");
        frog1.SetName("Jason");
        System.out.println(frog1.getName());



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
