package CACC_2019.week9_Method_Overload;


class App2_OverLoad2
{
    public void disp(char c)
    {
        System.out.println(c);
    }
    public void disp(int c)
    {
       System.out.println(c );
    }
}

class Sample2
{
    public static void main(String args[])
    {
        App2_OverLoad2 obj = new App2_OverLoad2();
        //obj.disp('a');
        obj.disp(5);
    }
}