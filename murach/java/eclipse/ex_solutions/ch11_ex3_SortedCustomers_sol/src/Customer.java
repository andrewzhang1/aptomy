@SuppressWarnings("rawtypes")
public class Customer implements Comparable {
    private String email;
    private String firstName;
    private String lastName;

    public Customer(String email, String firstName, String lastName) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getEmail() {
        return email;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getLastName() {
        return lastName;
    }

    @Override
    public int compareTo(Object o) {
        Customer c = (Customer) o;
        int sortResult = this.getEmail().compareToIgnoreCase(c.getEmail());
        if (sortResult < 0) {
            return -1;
        } else if (sortResult > 0) {
            return 1;
        }
        return 0;
    }
}