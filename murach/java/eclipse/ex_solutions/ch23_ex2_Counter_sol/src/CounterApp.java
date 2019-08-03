public class CounterApp {

    // Use these constants as the starting values for the two counter threads
    public static final int ODD = 1;
    public static final int EVEN = 2;
    
    public static void main(String[] args) {
        Thread ct = Thread.currentThread();
        System.out.println(ct.getName() + " started.");
        
        Thread odd = new Thread(new CounterThread(ODD));
        odd.start();
        System.out.println(odd.getName() + " started.");        

        Thread even = new Thread(new CounterThread(EVEN));
        even.start();
        System.out.println(even.getName() + " started.");
        
        System.out.println(ct.getName() + " finished.");        
    }
    
}
