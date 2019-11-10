package CACC_2019.week11_Class;

// Practice java baisc Object-oriented programming

class PersonA {
    // Instance variables (data or "state")
    String name;
    String school;
    int age;
    // 1. Data
    // 2. Subroutines (methods)

}
public class App1_OOP {
    public static void main(String[] args) {

        // Create a person object
        PersonA person1 = new PersonA();

        person1.name = "Andrew";
        //person1.name = "Joe";
        person1.age = 50;
        person1.school = "AHS";
        //person1.age =  13;

        PersonA person2 = new PersonA();

        person2.name = "Mike";
        person2.age = 14;

        System.out.println(person1.name);
        System.out.println(person1.age + person1.school);

    }
}
