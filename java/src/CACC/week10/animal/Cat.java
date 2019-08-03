package CACC.week10.animal;

public class Cat extends Animal {
    private void Meow() {
        System.out.println("cat is Meow");
    }

    @Override
    public void makeSound(){
        Meow();
    }
}
