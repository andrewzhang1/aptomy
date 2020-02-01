package CACC_2019.week17_Interface2;


/*
1. What does "implements" does?

 */
public class Machine implements Info {

    private int id = 7;
    public void start(){
        System.out.println("Machine Started.");
    }

    @Override
    public void showInfo() {
        System.out.println("Machine id is: " + id);
   }
}
