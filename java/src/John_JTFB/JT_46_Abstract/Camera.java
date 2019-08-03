package John_JTFB.JT_46_Abstract;

public class Camera extends Machine {


    @Override
    public void start() {
                System.out.println("Starting camera.");

    }
    @Override
    public void doStuff() {
                System.out.println("Take photos..");

    }

        @Override
    public void shutDown() {
                System.out.println("Shutdown camera.");

    }
}
