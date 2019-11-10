package CACC_2019.week9_Method_Overload;

public class Person_week9 {
    private String name;

    public Person_week9(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Person [name=" + name + "]";
    }
}
