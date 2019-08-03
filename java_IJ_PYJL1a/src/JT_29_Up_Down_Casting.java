class Machine28{
    public void start() {
        System.out.println("Machine started.");
    }
}

class Camera extends Machine28{
    public void start(){
        System.out.println("Camera started.");
    }

    public void snap(){
        System.out.println("Photo taken");
    }
}

public class JT_29_Up_Down_Casting {
    public static void main(String[] args) {

        Machine28 machine1 = new Machine28();
        Camera camera1 = new Camera();

        machine1.start();
        camera1.start();
        camera1.snap();

        System.out.println();

        // upcasting
        Machine28 machine2 = camera1;
        machine2.start();
        //Camera started.

        // error:         machine2.snap();

        // downcasting

        Machine28 machine3 = new Camera();

        // Error:(39, 26) java: incompatible types: Machine28 cannot be converted to Camera
        // Camera camera2 = machine3;
        Camera camera2 = (Camera)machine3;
        camera2.start();
        camera1.snap();

        // Reason: compared to upcasting, downcasting is quite not safe!
        Machine machine4 = new Machine();
        //Camera camera3 = (Camera)machine4;
        //camera3.start();
        //camera3.snap();



    }
}


