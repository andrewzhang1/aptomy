package CACC.week24;

/**
 *  An object of type Deck represents a deck of playing cards.  The deck
 *  is a regular poker deck that contains 52 regular cards and no Jokers.
 */
public class Deck {

    /**
     * An array of 52 cards.
     */
    private Card[] deck;

    /**
     * Keeps track of the number of cards that have been dealt from
     * the deck so far.
     */
    // TODO: define a private variable "cardsUsed", which has a type of int
    private int cardsUsed;

    /**
     * Constructs a poker deck of playing cards, The deck contains
     * the usual 52 cards. Initially the cards are in a sorted order.
     * The shuffle() method can be called to randomize the order.
     */
    public Deck() {
        deck = new Card[52];
        int cardCt = 0; // How many cards have been created so far.

        // TODO: create all cards
        for ( int suit = 0; suit <= 3; suit++ ) {
            for ( int value = 1; value <= 13; value++ ) {
                deck[cardCt] = new Card(value,suit);
                cardCt++;
            }
        }

        // TODO: initialize "cardsUsed"
        cardsUsed = 0;
    }

    /**
     * Put all the used cards back into the deck (if any), and
     * shuffle the deck into a random order.
     */
    public void shuffle() {
        for ( int i = deck.length-1; i > 0; i-- ) {
            int rand = (int)(Math.random()*(i+1));
            Card temp = deck[i];
            deck[i] = deck[rand];
            deck[rand] = temp;
        }
        // TODO: uncomment below line to reset "cardsUsed"
        cardsUsed = 0;
    }

    /**
     * As cards are dealt from the deck, the number of cards left
     * decreases.  This function returns the number of cards that
     * are still left in the deck.  The return value would be
     * 52 when the deck is first created or after the deck has been
     * shuffled.  It decreases by 1 each time the dealCard() method
     * is called.
     */
    public int cardsLeft() {
        // TODO: change below statement to return cards left
        return deck.length - cardsUsed;
    }

    /**
     * Removes the next card from the deck and return it.  It is illegal
     * to call this method if there are no more cards in the deck.  You can
     * check the number of cards remaining by calling the cardsLeft() function.
     * @return the card which is removed from the deck.
     * @throws IllegalStateException if there are no cards left in the deck
     */
    public Card dealCard() {
        // TODO: change below statement to return next card in deck;
        // BONUS: think about what to do if there's no more card.
        if (cardsUsed == deck.length)
            throw new IllegalStateException("No cards are left in the deck.");
        cardsUsed++;
        return deck[cardsUsed - 1];

        // Programming note:  Cards are not literally removed from the array
        // that represents the deck.  We just keep track of how many cards
        // have been used.
    }
}