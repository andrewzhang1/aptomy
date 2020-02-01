package CACC_2019.week9_Method_Overload;

// Basic method overload: different number of parameters

class App1_OverLoad1
{
    public void disp(char c)
    {
         System.out.println(c);
    }
    public void disp(char c, int num)
    {
         System.out.println(c + " "+num);
    }
}
class Sample
{
   public static void main(String args[])
   {
       App1_OverLoad1 obj = new App1_OverLoad1();
      obj.disp('a');
       //obj.disp('a',10);
   }
}

/*
Output:
a
*/
