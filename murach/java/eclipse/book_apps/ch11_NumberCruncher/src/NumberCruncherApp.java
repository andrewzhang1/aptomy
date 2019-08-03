import java.util.Arrays;

public class NumberCruncherApp {

    public static void main(String[] args) {
        // create array of 11 random integers
        int[] numbers = new int[11];
        for (int i = 0; i < numbers.length; i++) {
            numbers[i] = (int) (Math.random() * 51);  // num is >= 0 and <= 50
        }
        
        // sort the array
        Arrays.sort(numbers);        

        // display numbers
        String numbersString = "";
        for (int number : numbers) {
            numbersString += number + " ";
        }
        System.out.println("Numbers: " + numbersString);
        
        // calculate total and display
        int total = 0;
        for (int number : numbers) {
            total += number;
        }
        System.out.println("Total: " + total);
        
        // get count of numbers and display
        int count = numbers.length;
        System.out.println("Count: " + count);
        
        // calculate average and display
        double average = (double) total / count;
        average = (double) Math.round(average * 10) / 10;
        System.out.println("Average: " + average);
        
        // if count of numbers is odd
        if (count % 2 != 0) {
            int medianIndex = count / 2;
            int median = numbers[medianIndex];
            System.out.println("Median: " + median);            
        }
    }    
}