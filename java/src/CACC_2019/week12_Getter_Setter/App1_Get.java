package CACC_2019.week12_Getter_Setter;

// App1: Show no return type: all  "void" methods
class Person{

    String name;
    int age;

    void speak(){
        System.out.println("My name is: " + name);
    }

// Part 1: void method without reture
//    void  cacluateYearsToRetirement(){
//        int yearsLeft = 65 - age;
//        System.out.println(yearsLeft);
//    }

        //==================================
// Part 2: With return type
//    int  cacluateYearsToRetirement() {
//        int yearsLeft = 65 - age;
//        return yearsLeft;
//   }
//}
        //==================================
    // Part 3: Write a get method

    int  cacluateYearsToRetirement() {
        int yearsLeft = 65 - age;
        return yearsLeft;
   }

   int getAge(){
        return age;
   }

   String getName(){
        return name;
   }
}

public class App1_Get {
    public static void main(String[] args) {

        Person person1 = new Person();
        person1.name = "Joe";
        person1.age = 12;

        person1.speak();

        // Part 1
        //person1.cacluateYearsToRetirement();

        //==================================
        //Part 2
//        int year = person1.cacluateYearsToRetirement();
//        System.out.println("Years till retirement " + years);
//
        //==================================

        // Part 3: call by get method

        int year = person1.cacluateYearsToRetirement();
        System.out.println("Years till retirement " + year);

        int age = person1.getAge();
        String name = person1.getName();

        //System.out.println("name is " + name);
       // System.out.println("Age is " + age);

    }
}

// Oputout:
//My name is: Joe
//Years till retirement 53

