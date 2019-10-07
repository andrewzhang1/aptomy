package CACC_2018.week11.animal;

public abstract class Animal {
    private float weight;
    private int age;
    private String name;

    public static int count=0;

    public void eat() {
        System.out.println("animal is eating");
    }

    public void move() {
        System.out.println("animal is moving");
    }
    public void makeSound() {
        System.out.println("animal is make sound");
    }

    public abstract void drink(String abc);
}