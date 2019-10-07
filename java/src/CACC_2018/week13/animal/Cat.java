package CACC_2018.week13.animal;

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

    @Override
    public void move() {
        System.out.println("Cat is moving");
    }
}
