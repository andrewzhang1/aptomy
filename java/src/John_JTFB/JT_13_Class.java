package John_JTFB;

class Person {
    // Instance variables (data or "state")
    String name;
    int age;
    // 1. Data
    // 2. Subroutines (methods)

}

class App1 {
    public static void main(String[] args) {

        // Create a person object
        Person person1 = new Person();
        person1.name = "Joe";
        person1.age =  13;

        Person person2 = new Person();

        person2.name = "Mike";
        person2.age = 14;

        System.out.println(person1.name);
        System.out.println(person2.name);


    }

}
