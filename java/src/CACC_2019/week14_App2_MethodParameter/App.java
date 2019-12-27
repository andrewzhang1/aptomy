package CACC_2019.week14_App2_MethodParameter;
/*
1. Basic method call + Some method parameters
2. Passing a string
*/

class Robot{
    // "text" here is called "parameter" to be declared in the method
    // Why we call it "parameter" - something we can change of tweak
    public void speak(String text)
    {
        // "text" is called variable, which is passed to this particular method
        // call "println"
        System.out.println(text);
    }

    public void jump(int height){
        System.out.println("Jumping: " + height + " feets");
    }

    public void move(String direction, double distance){
        System.out.println("Moving  " + distance + "meters in direction " + direction);
    }
}

public class App {
    public static void main(String[] args) {
        Robot sam = new Robot();

        // This is called "paasing a parameter to the methd
        sam.speak("Hi, I'm Andrew");
        sam.jump(90);

        // Importance: When you pass values, you need to separate them by commas:
        sam.move("West", 12.4);

        // What about the following? Kind of confusing, right?
        String greeting = "Hello there."; // this string is just a lable
        sam.speak(greeting);
        sam.speak("I'm Mike");

        // Please spend time to fig out the different string called
        int value = 4;
        sam.jump(value);
    }
}


