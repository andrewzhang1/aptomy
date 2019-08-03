package John_JTFB;

class Robot {
    public void speak(String text) { //passing parameter with variable, a method parameter

        System.out.println(text);
    }

    public void jump(int height) {

        System.out.println("Jump: " + height);
    }
    public void move(String direction, double distance){
        System.out.println("Moving " + direction + " meters in direction " + distance);

    }
}

public class JT_16_Method_Parameters {

    public static void main(String[] args) {

        Robot sam = new Robot();
        String greeting = "Hi, I am 张歌"; // This is a reference
        sam.speak(greeting); //This is called "passing by parameters"

        int value = 9; // This is a value
        sam.jump(value);
        sam.move("West", 8.023232);

    }
}
