/**
 * Program name: Cis36AFall2014BryantJuniorLab4Ex1.java
 * Assignment:   Ex1
 * Written by:   Bryant Junior
 * Date:         2014/09/09
 */

import java.util.Scanner;
public class Cis36AFall2014BryantJuniorLab4Ex1 {
  static int option;
  static int setNum1 = 0;
  static int setNum2 = 0;
  static int setDenom1 = 1;
  static int setDenom2 = 1;
  static int getNum1;
  static int getNum2;
  static int getDenom1;
  static int getDenom2;
  static Scanner sc = new Scanner(System.in);
  static Scanner scanner;
  
  public static void main(String[] args){
    menu();
  }
  public static void menu() {
    getNum1 = setNum1;
    getNum2 = setNum2;
    getDenom1 = setNum1;
    getDenom2 = setDenom2;
    
    System.out.println("CIS 36A - Java Programming\nLaney College");
    System.out.println("BryantJunior\n\nAssignment Information --");
    System.out.println("  Assignment Number:  Lab 04,");
    System.out.println("\t\t      Coding Assignment -- Exercise #1");
    System.out.println("  Written by:\t      Bryant Junior");
    System.out.println("  Submitted Date:     10/14/2014\n\n");
    
    scanner = new Scanner(System.in);
    do{
      System.out.print("********************************"
        + "\n*             MENU             *" 
        + "\n* 1. Calling initBryantJ()     *"
        + "\n* 2. Calling addBryantJ()      *"
        + "\n* 3. Calling subtractBryantJ() *"
        + "\n* 4. Calling multiplyBryantJ() *"
        + "\n* 5. Calling divideBryantJ()   *"
        + "\n* 6. Calling printBryantJ()    *"
        + "\n* 7. Quit                      *"
        + "\n********************************\n");
           
       System.out.print("Select an option (use integer value only): ");
       option = scanner.nextInt();
         switch (option) {
         case 1:
           System.out.println("Calling initBryantJ()");
           System.out.println("Numerical value cannot be 0, "
                   + "Denom Value cannot be 0 and cannot be a (-) number");
           System.out.println("Enter the first numerical value: ");
           setNum1 = sc.nextInt();
           System.out.println("Enter the first denom value: ");
           setDenom1 = sc.nextInt();
           System.out.println("Enter the second numerical value: ");
           setNum2 = sc.nextInt();
           System.out.println("Enter the second denom value: ");
           setDenom2 = sc.nextInt();
         break;
         case 2:
           System.out.println("Calling addBryantJ()");
           addBryantJ();
         break;
         case 3:
           System.out.println("Calling substractBryantJ()");
           substractBryantJ();
         break;
         case 4:
           System.out.println("Calling multiplyBryantJ()");
           multiplyBryantJ();
         break;
         case 5:
           System.out.println("Calling divideBryantJ()");
           divideBryantJ();
         break;
         case 6:
           System.out.println("Calling printBryantJ()");
           printBryantJ();
         break;
         case 7:
           System.out.println("Have Fun!");
         break;
         default :
           System.out.println("Wrong Input!");
    }
    }while (option !=7);
  }
  public static void addBryantJ() {
    int n;
    int d;
    
    n = setNum1 * setDenom2 + setDenom1 * setNum2;
    d = setDenom1 * setDenom2;
    
    System.out.println("\n\t" + n + " / " + d);       
  } 
  
  public static void substractBryantJ() {    
    int ns;
    int ds;
    
    ns = setNum1 * setDenom2 - setDenom1 * setNum2;
    ds = setDenom1 * setDenom2;
    
    System.out.println("\n\t" + ns + " / " + ds);      
  }  
  
  public static void divideBryantJ() {
    int nd;
    int dd;
    
    nd = setNum1 * setDenom2;
    dd = setDenom1 * setNum2;
    
    System.out.println("\n\t" + nd + " / " + dd);
  }  
  
  public static void multiplyBryantJ() {    
    int nm;
    int dm;
    
    nm = setNum1 * setNum2;
    dm = setDenom1 * setDenom2;
    
    System.out.println("\n\t" + nm + " / " + dm);    
  }  
  
  public static void printBryantJ() {
    System.out.println("Fraction 1 : " + setNum1 + " / " + setDenom1);
    System.out.println("Fraction 2 : " + setNum2 + " / " + setDenom2);
  }
}

/** Output
 * 
CIS 36A - Java Programming
Laney College
BryantJunior

Assignment Information --
  Assignment Number:  Lab 04,
		      Coding Assignment -- Exercise #1
  Written by:	      Bryant Junior
  Submitted Date:     10/14/2014


********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 8
Wrong Input!
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 1
Calling initBryantJ()
Numerical value cannot be 0, Denom Value cannot be 0 and cannot be a (-)number
Enter the first numerical value: 
1
Enter the first denom value: 
2
Enter the second numerical value: 
3
Enter the second denom value: 
4
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 2
Calling addBryantJ()

	10 / 8
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 3
Calling substractBryantJ()

	-2 / 8
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 4
Calling multiplyBryantJ()

	3 / 8
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 5
Calling divideBryantJ()

	4 / 6
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 6
Calling printBryantJ()
Fraction 1 : 1 / 2
Fraction 2 : 3 / 4
********************************
*             MENU             *
* 1. Calling initBryantJ()     *
* 2. Calling addBryantJ()      *
* 3. Calling subtractBryantJ() *
* 4. Calling multiplyBryantJ() *
* 5. Calling divideBryantJ()   *
* 6. Calling printBryantJ()    *
* 7. Quit                      *
********************************
Select an option (use integer value only): 7
Have Fun!
 */
/**Notes
 * I lost my data today, so I make a simple version for it, still work but it
 * didn't make num and denom smaller
 */