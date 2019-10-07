package CACC_2018.week11.animal;

public class Cat extends Animal {
    private void Meow() {
        System.out.println("cat is Meow");
    }

    public void drink(String abc) {
        System.out.println("Cat is drinking");
    }
    @Override
    public void makeSound(){
        Meow();
    }
}
