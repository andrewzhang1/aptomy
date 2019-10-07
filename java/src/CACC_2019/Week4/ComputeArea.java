package CACC_2019.Week4;

public class ComputeArea {
    /**
     * Main method
     */
    public static void main(String[] args) {
        double radius;
        double area;
// Assign a radius
        radius = 20;
// Compute area
        area = radius * radius * 3.14159;
// Display results
        System.out.println("The area for the circle of radius " +
                radius + " is " + area);


// NOTE about floating point numbers p. 16

        System.out.println(1.0 - 0.1 - 0.1 - 0.1 - 0.1 - 0.1);
        System.out.println(1.0 - 0.9);
        System.out.println("1.0 / 3.0 is " + 1.0 / 3.0);

        System.out.println("1.0F / 3.0F is " + 1.0F / 3.0F);

        System.out.println(Math.pow(2, 3));

        //Displays 8.0

        //Exponent Operations
        System.out.println(Math.pow(4, 0.5));
// Displays 2.0

        System.out.println(Math.pow(2.5, 2));
//Displays 6.25
        System.out.println(Math.pow(2.5, -2));
// Displays 0.16
        System.out.println(Math.pow(2, 3));

    }
}