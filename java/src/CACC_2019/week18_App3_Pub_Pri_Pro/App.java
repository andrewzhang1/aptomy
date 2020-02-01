package CACC_2019.week18_App3_Pub_Pri_Pro;

// App3: This is a better practice!
//       We added a new class Oak

public class App {
    public static void main(String[] args) {
    // We create a Plant instance here:
        Plant plant = new Plant();

        System.out.println(plant.name);
        System.out.println(plant.ID);

        // This will have error; "type" is privat!
        //System.out.println(plant.type);

        System.out.println(plant.size);

        Oak oak = new Oak();
        System.out.println(oak.size);
    }
}

/*
Output:
Freddy
8
medium - from Plant class
large - from Oak class
*/
