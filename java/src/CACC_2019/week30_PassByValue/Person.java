package CACC_2019.week30_PassByValue;

public class Person {
    private  String name;
// Constructor: same name as the class
    public Person(String name){
        this.name = name;
    }

    public String getName(){
        return name;
    }

    public void setName(String name){
        this.name = name;
    }

    @Override
    public String toString() {
        return "Person [name=" + name + "]";
    }
}
