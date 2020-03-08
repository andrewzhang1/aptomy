package CACC_2019.week12_Getter_Setter2;

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
        this.name = name;
        // "this.name" means "private String name;"
    }
    public void setAge(int age){
           this.age = age;
    }
    public String getName(){
        return name;
   }
      int getAge(){
       return age;
   }

   // Beginners might use "this" all over the places...
    public void setInfo(String name, int age){
        setName(name);  // here: "this" is optional, why?
        setAge(age);
    }
}

public class App2_Set_This {
    public static void main(String[] args) {

        Frog frog1 = new Frog();
//        frog1.name = "Jason";
//        frog1.age = 11;

        frog1.setName("Mike");

        frog1.getAge();

        frog1.setAge(11);
        frog1.setAge(14);

        frog1.setInfo("Eric", 15); // Test if uncomment out this...
        System.out.println(frog1.getName());

        System.out.println(frog1.getAge());  // what value do you expect?
    }
}

//output 1:
//Mike
//14

//output 2:
//Eric
//15
