package CACC_2019.week30_PassByValue;
/*
Script Name: App3b.java
Note:   1. A basic prorgram calling a show() method
        2. Create a variable "value" and pass it into the method
        3. Added codes for complexity
        4. Added new method show method (passing non-primitive data type)
 */
public class App3b {

    public static void main(String[] args) {
        App3b app = new App3b();

        // ===========================================
        System.out.println("==== passing primitive data type");
        /* Important:
        1. We're doing here is copying data from one variable to another
        2. The scope of the variable is the closest pair of enclosing pair curly parenthesis.
        3. This is called passing by value, which is passing the value into this method
        4. Call a class Person and created a new method, which is called ??
        */
        int value = 7 ;
        System.out.println("1. Value is: " + value); // output=7, this is easy!

        app.show(value);
        System.out.println("4. Value is: " + value);

        // ===========================================
        System.out.println("\n==== passing non-primitive data type");

        Person person1 = new Person("Andrew2");
        // It will call the Person class and display the name string
        System.out.println("1. Person is: " + person1);

        app.show(person1);  // This will invoke the method we created below
    }

    public void  show(int value){
        System.out.println("2. Value is: " + value);

        value = 8;
        System.out.println("3. Value is: " + value);
    }

    // Review: what is this called??
    public void show(Person person){
        System.out.println("2. Person is: " + person);
    }

}

/*
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Persion is: Person [name=Andrew]
2. Persion is: Person [name=Andrew]

*/
