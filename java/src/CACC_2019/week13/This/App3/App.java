package CACC_2019.week13.This.App3;

// This program inrtroduces the concept "this"
class Frog{
    private String name;
    private int age;

//    public void SetName(String newName){
//           name  = newName;
//    }

// Modified above code into by adding "this" for the local variable name be refered by
// above definations
// Local variables masks the instance variables if the have the same name.
    public void setName(String name){

        // What about one?
       // name = name;

        this.name = name;
        // "this.name" means "private String name;"
    }
    public  void setAge(int age){
           this.age = age;
    }
    public  String getName(){
        // Why we don't "this" key word here?
        return name;
   }
      int getAge(){
       return age;
   }

   // Beginners might use "this" all over the places...
    public void setInfo(String name, int age){
        this.setName(name);  // here: "this" is optional, why? // You call methods from with other methods

        setAge(age);  // What if we put "this" ahead of age here, like this: "setAge(this.age)" ?
    }
}

public class App {
    public static void main(String[] args) {

        Frog frog1 = new Frog();
//        frog1.name = "Jason";
//        frog1.age = 11;

        frog1.setName("Jason");
        frog1.getName();

        System.out.println("1. Get Jason name after calling the setName method: " + frog1.getName());

        frog1.setAge(14);
        System.out.println("2. Get Jason's age after calling the setAge method: " + frog1.getAge());


        System.out.println("\n3. setInfo method");

        frog1.setInfo("Eric", 15); // Test if uncomment out this...
        System.out.println(frog1.getName());
        System.out.println(frog1.getAge());  // what value do you expect?

    }
}

//output 1:
//1. Get Jason name after calling the setName method: Jason
//2. Get Jason's age after calling the setAge method: 14
//
//3. setInfo method
//Eric
//15