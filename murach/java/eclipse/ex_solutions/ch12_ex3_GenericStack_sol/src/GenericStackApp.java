public class GenericStackApp {

    public static void main(String[] args) {
        GenericStack<String> s = new GenericStack<>();

        // push three items onto the stack
        s.push("Apples");
        System.out.println("Push: Apples");
        s.push("Oranges");
        System.out.println("Push: Oranges");
        s.push("Bananas");
        System.out.println("Push: Bananas");
        System.out.println("The stack contains " + s.size() + " items\n");

        // peek at the first item
        System.out.println("Peek: " + s.peek());
        System.out.println("The stack contains " + s.size() + " items\n");

        // pop all three items
        System.out.println("Pop: " + s.pop());
        System.out.println("Pop: " + s.pop());
        System.out.println("Pop: " + s.pop());
        System.out.println("The stack contains " + s.size() + " items\n");
    }
    
}
