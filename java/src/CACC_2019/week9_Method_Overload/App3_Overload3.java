package CACC_2019.week9_Method_Overload;

class App3_Overload3
{
   public void disp(char c, int num)
   {
       System.out.println("I’m the first definition of method disp");
   }
   public void disp(int num, char c)
   {
       System.out.println("I’m the second definition of method disp" );
   }
}
class Sample3
{
   public static void main(String args[])
   {
       App3_Overload3 obj = new App3_Overload3();
       //obj.disp('x', 51 );
       obj.disp(52, 'y');
       // Now you might understand why the method overload for the "nPrintln("Computer Science", 15)"
       // doesn't work!;

   }
}

/*
Output:
I’m the second definition of method disp*/
