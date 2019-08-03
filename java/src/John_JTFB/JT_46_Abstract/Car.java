package John_JTFB.JT_46_Abstract;

public class Car extends Machine {
    @Override
    public void start() {
        System.out.println("Starting car.");
    }

    @Override
    public void doStuff() {
        System.out.println("Do stuff.");


    }

    @Override
    public void shutDown() {
        System.out.println("Shutdown car.");
    }


}
