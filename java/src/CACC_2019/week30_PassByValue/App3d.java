package CACC_2019.week30_PassByValue;
/*
Script Name: App3d.java
Note:  1. We will see the same patters for the print out, why?
       2. Take your time to understand why it print out:
             "4. Person is: Person [name=Sue]"
            (There're some concept for reference and point, you might need to understand it
            when you move to the advanced programming, or learn C++)
 */
public class App3d {

    public static void main(String[] args) {
        App3d app = new App3d();

        // ===========================================

        int value = 7 ;  // Stored in the memory (vs storing the address for the Non-primitive type)
        System.out.println("1. Value is: " + value); // output=7, this is easy!

        app.show(value);
        System.out.println("4. Value is: " + value);

        // ===========================================
        System.out.println();

        Person person = new Person("Andrew"); // storing the address for the Non-primitive type
        // It will call the Person class and display the name string
        System.out.println("1. Person is: " + person);

        app.show(person);  // This will involk the method we created below

        System.out.println("4. Person is: " + person);  // This might be hard to understand! Don't worry for now...
    }

    public void  show(int value){
        System.out.println("2. Value is: " + value);

        value = 8;
        System.out.println("3. Value is: " + value);
    }

    // Review: what is this called??
    public void show(Person person){
        System.out.println("2. Person is: " + person);

      //   person.setName("Gore");

        person = new Person("Eric");
        // Analogy: We're actually just making a copy of the address of your hours on piece of paper
        // In Java, we always pass by value!

        person.setName("Sue");  // What about we place this line here instead above? Try to play it by yourself!

        System.out.println("3. Person is: " + person);
    }
}

/*
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

1. Person is: Person [name=Andrew]
2. Person is: Person [name=Andrew]
3. Person is: Person [name=Eric]
4. Person is: Person [name=Sue]


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
