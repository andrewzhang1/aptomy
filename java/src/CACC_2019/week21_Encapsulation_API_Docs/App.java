package CACC_2019.week21_Encapsulation_API_Docs;

class plant {
/*
App1: Why using private?
you always need to try to encapsulate tje inner workings of that
class within the calss.
*/


    public static final int ID = 7;

    private String name;

    public String getData() {
        String data = "some stuff" + calculateGrowthForecast();
        return data;

    }

    private int calculateGrowthForecast() {
        return 9;

    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

public class App {
    public static void main(String[] args) {

    }
}
