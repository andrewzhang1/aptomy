package AzhangJUnit;

public class Person {

   // Now give some behavior to this person

   // Instance variable (date or "state")
   String name;
   int age;

   // Class can contain:
   // 1. data
   // 2. subroutines (methods)

   public int getId() {
      return 22;
   }

   public void speak() {
      for (int i = 0; i <= 3; i++) {
         System.out.println("Method Call: Hello, my name is: " + name + "and I'm " + age
                 + " years old.");
      }
   }

   void sayHello(){
      System.out.println("Method Call: Hello there!");
   }

}

