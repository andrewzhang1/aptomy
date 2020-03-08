package CACC_2019.week20_Quiz2;

public class Q6_RentalApp
{
   public static void main(String[] args)
   {
      Rental r = new Rental();
      r.setNumOfPersons(5);
      r.addPerson(r);
      System.out.println(r.getNumOfPersons());
   }
}

class Rental {
   private int numOfPersons;

   public int getNumOfPersons()
   {
      return numOfPersons;
   }

   public void setNumOfPersons(int numOfPersons)
   {
      this.numOfPersons = numOfPersons;
   }

   public void addPerson(Rental rental)
   {
      rental.numOfPersons++;
   }
}
