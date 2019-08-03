package John_JTFB;// toString important for debug!

class Frog_21 {

    private int id;
    private String name;

    public Frog_21(int id, String name) {
        this.id = id;
        this.name = name;
    }


    public String toString() {
        return String.format("%9d: %s", id, name);

/*        StringBuilder sb = new StringBuilder();
        sb.append(id).append(":" ).append(name); // This is more efficient!
        return sb.toString();*/
    }

}

public class JT_21_toString {

    public static void main(String[] args) {
        Frog_21 frog1 = new Frog_21(7, "Freddy");
        Frog_21 frog2 = new Frog_21(2, "Roger");

        System.out.println(frog1);
        System.out.println(frog2);


    }
}
/*

        7: Freddy
        2: Roger*/
