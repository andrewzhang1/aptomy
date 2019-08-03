class Plant27 {

    public static final int ID = 7;
    private String name;
    //Try to use private as much as possible;
    // use set and get to ...

    // don't make data public except for constance so make everything as private as you can't keep everything hidden
    // withint the class and the idea is to reduce cross linkages in your project, so you don't want one class
    // kind of getting into another class's stuff and using it and you don't want to avoid creating a tangled nest
    // that you just want to have a few methods that defined public and clearly documented to then don't change very
    // often, and the rest of the stuff should be kept within the class so that's the idea behind encapsulation
    // - You hide away the  implementation details within your class and just provide public API application programing
    //   interface in other words just some public methods .


    public String getData() {
        String data = "some stuff" + calculateGrowthForecas();

        return data;
    }

    private int calculateGrowthForecas() {
        return 9;
    }


    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

public class JT_27_Encapsulation_API_Doc {
    public static void main(String[] args) {

    }
}


