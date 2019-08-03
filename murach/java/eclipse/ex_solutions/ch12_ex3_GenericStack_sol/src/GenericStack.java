import java.util.LinkedList;

public class GenericStack<E> {
    private LinkedList<E> list = new LinkedList<E>();

    public void push(E s) {
        list.addFirst(s);
    }

    public E pop() {
        return list.removeFirst();
    }

    public E peek() {
        return list.getFirst();
    }

    public int size() {
        return list.size();
    }    
}
