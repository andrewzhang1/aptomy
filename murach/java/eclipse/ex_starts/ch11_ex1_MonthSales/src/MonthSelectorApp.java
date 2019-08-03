import java.text.NumberFormat;

public class MonthSelectorApp {

    public static void main(String[] args) {
        System.out.println("Monthly Sales\n");
        
        // declare monthNames and monthSales arrays


        // get currency formatting
        NumberFormat currency = NumberFormat.getCurrencyInstance();
        
        // get one or more months
        String choice = "y";
        while (choice.equalsIgnoreCase("y")) {
            // get the input from the user
            int monthNumber = Console.getInt("Enter month number: ");
            
            // validate input
            if (monthNumber < 1 || monthNumber > monthName.length) {
                Console.displayLine("Invalid month number. Try again.");
                continue;                
            }
            
            // get the index number for the month
            // and display the month name and sales            


            // check if the user wants to continue
            choice = Console.getString("Continue? (y/n): ");
            Console.displayLine();
        }
        
        // display the total sales for the year
        
        
        Console.displayLine();
    }    

}
