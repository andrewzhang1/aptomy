package Laney;

/**
 * Program Name: Cis36aFall2014NastassiaPincukProgramLab1Ex1.java
 * Discussion:   Java Stuff
 * Written By:   Nastassia Pincuk
 * Date:         2014/09/02
 */

class Cis36aFall2014NastassiaPincukLab1Ex1 {
    public static void main(String[] args) {
        int i, j;
        int temp;
        //original array 1, array 2
        int[] ary1 = { -15, 450, 6, -9, 9 };
        int[] ary2 = {100, -15, 450, 6, -91, 9 };
        //printing header
        System.out.println(  "CIS 36A - Java Programming\n" + "Laney College\n" 
                + "Nastassia Pincuk\n" + "\n" + "Assignment Information --\n" + 
                "  Assignment Number: Lab 01,\n" + 
                "                     Coding Assignment -- Exercise #1\n" + 
                "  Written by:        Nastassia Pincuk\n" + 
                "  Submitted Date:    09/02/2014\n"+  "\n"+ "Original ary1[]" );
        {
            //printing original array 1
            for (i = 0; i < ary1.length; i++){
                System.out.print( "  " + ary1[i]  );
            }
            System.out.println("\n" +"\nCalling moveAndSortInt() --\n" + "\n" +
                 "Updated ary1[]") ;
            //calling moveAndSort method
            moveAndSort(ary1);
            {
                //printing original array 2
                System.out.println("\n" +"\nOriginal ary2[]  ");
                {
                    for (i = 0; i < ary2.length; i++){
                        System.out.print("  " + ary2[i] );
                    }
                    System.out.println("\n" + "\nCalling moveAndSortInt() --\n" + "\n"+
                            "Updated ary2[] ") ;
                    //calling moveAndSort method
                    moveAndSort(ary2);
                }
            }
        }
    }
                   
         
public static void moveAndSort(int[] ary) {
    int i, j, temp;
    //sorting array by integer size
    for ( i = 0; i < ary.length - 1; i++){
        for ( j = i+1; j < ary.length; j++ ){
            if (ary[i] > ary [j]){
                temp = ary[i];
                ary[i]=ary[j];
                ary[j]=temp;
            }
        }
    }
    //sorting array by odd and even
    for (i = 0; i < ary.length-1; i++) {
        for ( j = i + 1; j < ary.length; j++) {
            if (ary[i] % 2 == 0) { 
                if (ary[i+1] != 0) {
                    temp = ary[i];
                    ary[i] = ary[j];
                    ary[j]=temp;
                }
            }
        }
    }
    //printing updated array
    for (i = 0; i < ary.length; i++) {
        System.out.print("  " + ary[i] );
    }
}
}

/*
 * Output:
 * CIS 36A - Java Programming
Laney College
Nastassia Pincuk

Assignment Information --
  Assignment Number: Lab 01,
                     Coding Assignment -- Exercise #1
  Written by:        Nastassia Pincuk
  Submitted Date:    09/02/2014

Original ary1[]
  -15  450  6  -9  9

Calling moveAndSortInt() --

Updated ary1[]
  -15  -9  9  450  6

Original ary2[]  
  100  -15  450  6  -91  9

Calling moveAndSortInt() --

Updated ary2[] 
  -91  -15  9  450  100  6
 */
          
       
         

            
               
   
    

     
