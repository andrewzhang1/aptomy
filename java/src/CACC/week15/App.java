package CACC.week15;

public class App {

    public void chooseDay(Day day) {

        switch (day) {
            case SUNDAY:
            case SATURDAY:
                System.out.println("Weekend");
                break;
            case MONDAY:
                System.out.println("First day of the week!");
                break;

            default:
                System.out.println("Normal working day!");
        }

    }

    public static void main(String[] args) {
        System.out.println("HI, this is to demo the enumerator");
        Day sunday = Day.MONDAY;

        System.out.println(sunday);
        App test = new App();
        test.chooseDay(sunday);

    }
}
