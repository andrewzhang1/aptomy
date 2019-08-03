
/**
 * Program Name: Cis36aFall2014NastassiaPincukLab4Ex1.java 
 * Discussion: Java Stuff 
 * Written By: Nastassia Pincuk Date: 2014/10/16
 */

import java.util.Scanner;
//import testFraction01.FractionNastassiaP;
//import testFraction01.FractionUtility;

public class Cis36aFall2014NastassiaPincukLab4Ex1 {

    public static void main(String[] args) {
        System.out.println("Class Information --\n"
                + "  CIS 36A – Java Programming\n" + "  Laney College\n"
                + "\n" + "Assignment Information --\n"
                + "  Assignment Number: Lab 04 - Exercise #1\n"
                + "  Written by:        Nastassia Pincuk\n"
                + "  Submitted Date:    10/08/2014\n" + "\n");
        menu01NastassiaPincuk();
    }
    
    public static void menu01NastassiaPincuk() {
        int option;
        int optfr;
        Scanner scanner;
        scanner = new Scanner(System.in);
        FractionNastassiaP fr1 = new FractionNastassiaP();
        FractionNastassiaP fr2 = new FractionNastassiaP();
        FractionNastassiaP fr3 = new FractionNastassiaP();
        FractionUtility fu1;
        
        int n = 0;
        int d = 0;
        do {
            System.out.print("\n***************************"
                    + "*********\n"
                    + "*               MENU 01            *\n"
                    + "* 1. Calling init()                *\n"
                    + "* 2. Calling add()                 *\n"
                    + "* 3. Calling substract()           *\n"
                    + "* 4. Calling multiply()            *\n"
                    + "* 5. Calling divide()              *\n"
                    + "* 6. Calling print()               *\n"
                    + "* 7. Quit                          *\n"
                    + "************************************\n");
            System.out.print("Select the option (use integer value only): ");

            option = scanner.nextInt();
            switch (option) {
                case 1:
                    System.out.print("\n ...Calling init()...\n");
                    
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.init(fr1);
                        fu1.init(fr2);
                        fu1.print(fr1, fr2);
                    } else {
                        System.out.println("\nWould you like to update:");
                        System.out.println("1. Fraction1,");
                        System.out.println("2. Fraction2,");
                        System.out.println("3. Update both,");
                        System.out.println("4. Keep both;");
                        optfr = scanner.nextInt();
                        switch (optfr) {
                            case 1:
                                fu1.init(fr1);
                                System.out.println(fr1.getNum() 
                                        + " / " + fr1.getDenom());
                                break;
                            case 2:
                                fu1.init(fr2);
                                System.out.println(fr2.getNum() 
                                        + " / " + fr2.getDenom());
                                break;
                            case 3:
                                fu1.init(fr1);
                                fu1.init(fr2);
                                fu1.print(fr1, fr2);
                                break;
                            case 4:
                                fu1.print(fr1, fr2);
                                break;
                            default:
                                System.out.print("\nWRONG OPTION!\n\n");
                        }
                    }
                    break;
                
                case 2:
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.printMessage();
                        break;
                    }
                    System.out.print("\n...Calling add()...");
                    fu1.addFraction(fr1, fr2);
                    break;
                
                case 3:
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.printMessage();
                        break;
                    }
                    System.out.print("\n...Calling substract()...");
                    fu1.subFraction(fr1, fr2);
                    break;
                
                case 4:
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.printMessage();
                        break;
                    }
                    System.out.print("\n...Calling multiply()...");
                    fu1.mulFraction(fr1, fr2);
                    break;
                
                case 5:
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.printMessage();
                        break;
                    }
                    System.out.print("\n...Calling divide()...");
                    if (fu1.checkDenom(fr1, fr2) == true ) {
                        //fu1.printMessage();
                        break;
                    }
                    fu1.divFraction(fr1, fr2);
                    break;
                case 6:
                    fu1 = new FractionUtility();
                    if (fu1.ifExists(fr1, fr2) == false) {
                        fu1.printMessage();
                        break;
                    }
                    System.out.print("\n...Calling print()...\n");
                    fu1.print(fr1, fr2);
                    break;
                
                case 7:
                    System.out.print("\n  Have Fun...\n");
                    break;
                
                default:
                    System.out.print("\nWRONG OPTION!\n\n");
            }
        } while (option != 7);
    }
}
/**
 * run:
Class Information --
  CIS 36A – Java Programming
  Laney College

Assignment Information --
  Assignment Number: Lab 04 - Exercise #1
  Written by:        Nastassia Pincuk
  Submitted Date:    10/08/2014



************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 1

 ...Calling init()...
Enter numerator:
1
Enter denominator (can't be 0):
2
Enter numerator:
3
Enter denominator (can't be 0):
4
Fraction 1: 1 / 2
Fraction 2: 3 / 4

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 2

...Calling add()...
1 / 2 + 3 / 4 = 10/8
... Calling Format(Fraction) ...


Formatted fraction is
 5 / 4 = 1 1 / 4
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 3

...Calling substract()...
1 / 2 - 3 / 4 = -2/8
... Calling Format(Fraction) ...


Formatted fraction is
 -1 / 4
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 4

...Calling multiply()...
1 / 2 * 3 / 4 = 3/8
... Calling Format(Fraction) ...


Formatted fraction is
 3 / 8
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 5

...Calling divide()...
1 / 2 : 3 / 4 = 4/6
... Calling Format(Fraction) ...


Formatted fraction is
 2 / 3
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 6

...Calling print()...
Fraction 1: 1 / 2
Fraction 2: 3 / 4

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 1

 ...Calling init()...

Would you like to update:
1. Fraction1,
2. Fraction2,
3. Update both,
4. Keep both;
3
Enter numerator:
-5
Enter denominator (can't be 0):
9
Enter numerator:
7
Enter denominator (can't be 0):
11
Fraction 1: -5 / 9
Fraction 2: 7 / 11

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 6

...Calling print()...
Fraction 1: -5 / 9
Fraction 2: 7 / 11

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 2

...Calling add()...
-5 / 9 + 7 / 11 = 8/99
... Calling Format(Fraction) ...


Formatted fraction is
 8 / 99
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()1
*
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 3

...Calling substract()...
-5 / 9 - 7 / 11 = -118/99
... Calling Format(Fraction) ...


Formatted fraction is
 -118 / 99 = -1 19 / 99
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 4

...Calling multiply()...
-5 / 9 * 7 / 11 = -35/99
... Calling Format(Fraction) ...


Formatted fraction is
 -35 / 99
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 5

...Calling divide()...
-5 / 9 : 7 / 11 = -55/63
... Calling Format(Fraction) ...


Formatted fraction is
 -55 / 63
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 6

...Calling print()...
Fraction 1: -5 / 9
Fraction 2: 7 / 11

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 1

 ...Calling init()...

Would you like to update:
1. Fraction1,
2. Fraction2,
3. Update both,
4. Keep both;
3
Enter numerator:
-1
Enter denominator (can't be 0):
2
Enter numerator:
0
Enter denominator (can't be 0):
1
Fraction 1: -1 / 2
Fraction 2: 0 / 1

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 2

...Calling add()...
-1 / 2 + 0 / 1 = -1/2
... Calling Format(Fraction) ...


Formatted fraction is
 -1 / 2
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 3

...Calling substract()...
-1 / 2 - 0 / 1 = -1/2
... Calling Format(Fraction) ...


Formatted fraction is
 -1 / 2
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 4

...Calling multiply()...
-1 / 2 * 0 / 1 = 0/2
... Calling Format(Fraction) ...


Formatted fraction is
  = 0

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 5

...Calling divide()...Chosen mathematical operation impossible. 0 denominator.
* Please, update Fraction 2

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 6

...Calling print()...
Fraction 1: -1 / 2
Fraction 2: 0 / 1

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 1

 ...Calling init()...

Would you like to update:
1. Fraction1,
2. Fraction2,
3. Update both,
4. Keep both;
3
Enter numerator:
0
Enter denominator (can't be 0):
1
Enter numerator:
7
Enter denominator (can't be 0):
11
Fraction 1: 0 / 1
Fraction 2: 7 / 11

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 2

...Calling add()...
0 / 1 + 7 / 11 = 7/11
... Calling Format(Fraction) ...


Formatted fraction is
 7 / 11
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 3

...Calling substract()...
0 / 1 - 7 / 11 = -7/11
... Calling Format(Fraction) ...


Formatted fraction is
 -7 / 11
************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 4

...Calling multiply()...
0 / 1 * 7 / 11 = 0/11
... Calling Format(Fraction) ...


Formatted fraction is
  = 0

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 5

...Calling divide()...
0 / 1 : 7 / 11 = 0/7
... Calling Format(Fraction) ...


Formatted fraction is
  = 0

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 6

...Calling print()...
Fraction 1: 0 / 1
Fraction 2: 7 / 11

************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 66

WRONG OPTION!


************************************
*               MENU 01            *
* 1. Calling init()                *
* 2. Calling add()                 *
* 3. Calling substract()           *
* 4. Calling multiply()            *
* 5. Calling divide()              *
* 6. Calling print()               *
* 7. Quit                          *
************************************
Select the option (use integer value only): 7

  Have Fun...
BUILD SUCCESSFUL (total time: 4 minutes 15 seconds)
 */
