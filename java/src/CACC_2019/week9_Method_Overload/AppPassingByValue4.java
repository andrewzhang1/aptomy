package CACC_2019.week9_Method_Overload;

        // What about non-primitive data type?

public class AppPassingByValue4 {
    public static void main(String[] args) {

        AppPassingByValue4 app = new AppPassingByValue4();
        // ==================================
        int value = 7;  // We name this variable of "value" ==> A
        System.out.println("1. Value is: " + value);

        app.show(value);
        System.out.println("4. Value is: " + value); // Do you what to be printed for this value? still 7!

        // ===================================
        // Passing non-primitive data type:
        // This is the non-primitive data type, this is a reference.

        System.out.println();

        Person_week9 person = new Person_week9("Bob");
        // Storing the address in some sense of this object here; and this allocating a bunch of memory for this
        // Statement here
        System.out.println("1. Person is: " + person);

        app.show(person);
        System.out.println("4. Person is: " + person);
    }

    public void show(int value){
        System.out.println("2. Value is: " + value);
        value = 8;  // Changing this variable won't change above variable ==> A

        System.out.println("3. Value is: " + value);
    }

    public void show(Person_week9 person){
        //This is called method Overloading with different argument type(s)!!
        System.out.println("2. Person is: " + person);

        // ==> This is last step:
        // Finally, let's do a little more:

        //person.setName("Sue"); // ==> Line "Sue"

        // We put a new address for person
        person = new Person_week9("Andrew");

        person.setName("Sue"); // ==> Line "Sue"

        // Passing by value, it means that we're acturally maing a copy of the value.
        // Is's just that the value, the value contained in this varialbe is an address!

        // What means passing by reference (C++) ==> [void show(Person_week9& person)] (using & sign)"
        // Changing this variable here would also change the above one --> Passing by Reference!
        // In Java, where you're actually making a copy of what's in the variable

        System.out.println("3. Person is: " + person);

    }
}

/* Run 1: Without ==> line 45 "Line "Sue""
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Person is: Person [name=Bob]
2. Person is: Person [name=Bob]
3. Person is: Person [name=Andrew]
4. Person is: Person [name=Bob]
*/


/* Run 2: With ==> line 45 "Line "Sue""

1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Person is: Person [name=Bob]
2. Person is: Person [name=Bob]
3. Person is: Person [name=Andrew]
4. Person is: Person [name=Sue]
*/


/* Run 3: If we move line 45 to line 50: ==> line 45 "Line "Sue""
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Person is: Person [name=Bob]
2. Person is: Person [name=Bob]
3. Person is: Person [name=Sue]
4. Person is: Person [name=Bob]

*/
