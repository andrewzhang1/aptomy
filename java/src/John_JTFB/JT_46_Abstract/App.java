package John_JTFB.JT_46_Abstract;

public class App {
    public static void main(String[] args) {
        Camera cam1 = new Camera();

        cam1.setId(5);

        Car car1 = new Car();

        car1.setId(4);

        //Machine machine1 = new Machine();  // what is this used for?

        car1.run();

        cam1.start();
        cam1.doStuff();
        cam1.shutDown();


    }

}

