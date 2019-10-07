package CACC_2018.week10.animal;

public class Dog extends Animal{
    private void bark() {
        System.out.println("dog is barking");
    }

    @Override
    public void makeSound() {
        bark();
    }
}
