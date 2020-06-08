package CACC_2019.week30_PassByValue;
/*
Script Name: App3c.java
Note:  We will see the same patters for the print out between primitive and non-primitive data type, why?
 */
public class App3c {

    public static void main(String[] args) {
        App3c app = new App3c();

        // ===========================================

        int value = 7 ;  // Stored in the memory (vs storing the address for the Non-primitive type)
        System.out.println("1. Value is: " + value); // output=7, this is easy!

        app.show(value);
        System.out.println("4. Value is: " + value);

        // ===========================================
        System.out.println();

        Person person = new Person("Andrew2"); // storing the address for the Non-primitive type
        // It will call the Person class and display the name string
        System.out.println("1. Persion is: " + person);

        app.show(person);  // This will invoke the method we created below

        System.out.println("4. Person is: " + person);
    }

    public void  show(int value){
        System.out.println("2. Value is: " + value);

        value = 8;
        System.out.println("3. Value is: " + value);
    }

    // Review: what is this called??
    public void show(Person person){
        System.out.println("2. Persion is: " + person);

        person = new Person("Andy");
        // Analogy: We're actually just making a copy of the address of your hours on piece of paper
        // In Java, we always pass by value!

        System.out.println("3. Person is: " + person);
    }
}


/*
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Persion is: Person [name=Andrew]
2. Persion is: Person [name=Andrew]
3. Person is: Person [name=Eric]
4. Person is: Person [name=Andrew]

So what is passing by reference?

    public void show(Person& person){
        System.out.println("2. Persion is: " + person);

        // ==> changing the varialbe "person" will change the variable you will call in your method, which could be
        very confused (in C++), which is called passing by reference!!

        person = new Person("Eric");
        // Analogy: We're actually just making a copy of the address of your hours on piece of paper
        // In Java, we always pass by value!

        System.out.println("3. Person is: " + person);
    }
*/
