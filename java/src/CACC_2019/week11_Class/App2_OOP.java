package CACC_2019.week11_Class;

// this app expand the class and add a method

class PersonB {
    // Instance variables (data or "state")
    String name;
    int age;
    String school;

    // Class can contain
    // 1. Data
    // 2. Subroutines (methods)
    void speak(){
        // for(int i =0; i < 3; i++)
        System.out.println("My name is " + name + " and " + age + " years old ");
    }

    void sayHell(){
        System.out.println("Hello World");
    }

    void play(){
        System.out.println("I play football!");
    }
    void sayHello(){
        System.out.println("Hello!");
    }

 }

public class App2_OOP {
    public static void main(String[] args) {

        // Create a Person object using the PersonB class
        PersonB personB1 = new PersonB();
        personB1.name = "Joe";
        personB1.age =  13;

        // This is the way to involk a method
        personB1.speak();
        personB1.sayHello();

        // Create a second Person object
        PersonB personB2 = new PersonB();

        personB2.name = "Mike";
        personB2.age = 14;
        personB2.play();
        System.out.println(personB1.name);

    }
}


