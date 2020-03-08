package CACC_2019.week20_Quiz2;

import java.util.Scanner;
import java.text.NumberFormat;

public class Q5_WeightConverter
{
    public static void main(String[] args)
    {
        Scanner sc = new Scanner(System.in);
        String prompt = "Enter weight in lbs: ";
        boolean isValid = false;
        double weightInPounds = 0.0;
        while (isValid == false)
        {
            weightInPounds = getDouble(sc, prompt);
            if (weightInPounds > 0)
                isValid = true;
            else
                System.out.println("Weight must be greater than 0.");
        }
        double weightInKilos = weightInPounds / 2.2;
        NumberFormat nf = NumberFormat.getNumberInstance();
        nf.setMaximumFractionDigits(2);
        String message = weightInPounds + " lbs\nequals\n"
            + nf.format(weightInKilos) + " kgs\n";
        System.out.print(message);
    }

    public static double getDouble(Scanner sc, String prompt)
    {
        double d = 0.0;
        boolean isValid = false;
        while (isValid == false)
        {
            System.out.print(prompt);
            if (sc.hasNextDouble())
            {
                d = sc.nextDouble();
                isValid = true;
            }
            else
            {
                System.out.println
                    ("Error! Invalid decimal value. Try again.");
            }
            sc.nextLine();
        }
        return d;
    }
}

