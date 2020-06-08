package CACC_2019.week30_PassByValue;
/*
Script Name: App3a.java
Note:   1. A basic prorgram calling a show() method
        2. Create a variable "value" and pass it into the method
        3. Added codes for complexity
        4. Added new method show method (passing non-primitive data type)
 */
public class App3a {

    public static void main(String[] args) {
        App3a app = new App3a();

        // ===========================================

        /* Important:
          Call a class Person and created a new method, which is is called ??
        */
        int value = 7 ;
        System.out.println("1. Value is: " + value); // output=7, this is easy!

        app.show(value);
        System.out.println("4. Value is: " + value);   // What will the this value equals to after the run and why?

        // ===========================================
        System.out.println();

        Person person = new Person("Andrew");
        // It will call the Person class and display the name string
        System.out.println(person);
    }

    public void  show(int value){
        System.out.println("2. Value is: " + value);

        value = 8;
        System.out.println("3. Value is: " + value);
    }

    // Review: what is this called?? Method over ride or method overload?
    public void show(Person person){
    }
}


/*
1. Value is: 7
2. Value is: 7
3. Value is: 8
4. Value is: 7

Person [name=Andrew]
*/
