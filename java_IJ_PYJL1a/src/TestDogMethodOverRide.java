/**
 * Created by Andrew on 2/23/2016.
 *
 * JT_25_Public_Private_Protected.Test method override
 * Azhang
 * Calls called: Animal and Dog
 *
 */
public class TestDogMethodOverRide {

   public static void main(String args[]){
      Animal a = new Animal(); // Animal reference and object
      Animal b = new Dog(); // Animal reference but Dog object

      a.move();// runs the method in Animal class

      b.move();//Runs the method in Dog class
   }
}

/**

Animals can move
Dogs can walk and run*/
