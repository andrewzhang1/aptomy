import java.util.ArrayList;

public class CardDeckApp {

    public static void main(String[] args) {
        System.out.println("DECK");
        ArrayList<String> deck = getDeck();
        displayCards(deck);

        System.out.println("SHUFFLED DECK");
        shuffleDeck(deck);
        displayCards(deck);

        int count = 2;
        int hands = 4;
        System.out.println("FOUR HANDS OF " + count + " CARDS");
        for (int i = 0; i < hands; i++) {
            ArrayList<String> hand = dealCards(deck, count);
            displayCards(hand);
        }
        System.out.println("CARDS LEFT IN DECK: " + deck.size());
    }

    private static ArrayList<String> getDeck() {
        String[] suits = {"Spades", "Hearts", "Diamonds", "Clubs"};
        String[] ranks = {"Ace", "2", "3", "4", "5", "6", "7", 
            "8", "9", "10", "Jack", "Queen", "King"};        

        ArrayList<String> deck = new ArrayList<>(52);
        for (String suit : suits) {
            for (String rank : ranks) {
                deck.add(rank + " of " + suit);
            }
        }
        return deck;
    }

    private static void displayCards(ArrayList<String> cards) {
        System.out.print("|");        
        for (String card : cards) {
            System.out.print(card + "|");
        }
        System.out.println();        
    }

    private static void shuffleDeck(ArrayList<String> deck) {
        for (int i = 0; i < deck.size(); i++) {
            String savedCard = deck.get(i);
            int randomIndex = (int) (Math.random() * deck.size() - 1);
            deck.set(i, deck.get(randomIndex));
            deck.set(randomIndex, savedCard);
        }
    }

    private static ArrayList<String> dealCards(ArrayList<String> deck, int count) {
        ArrayList<String> hand = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            hand.add(deck.remove(i));
        }
        return hand;
    }
}