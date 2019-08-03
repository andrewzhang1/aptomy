package CACC.week13.animal;

public class Dog extends Animal {
    private void bark() {
        System.out.println("dog is barking");
    }

    public void drink(String abc) {
        System.out.print("dog is drinking");
    }
    @Override
    public void makeSound() {
        bark();
    }

    @Override
    public void move() {
        System.out.println("Dog is moving");
    }
}
