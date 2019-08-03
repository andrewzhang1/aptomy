import java.util.Map;
import java.util.TreeMap;

public class WordCounterApp {

    @SuppressWarnings("rawtypes")
	public static void main(String[] args) {
        System.out.println("The Word Counter application\n");

        // define a string that contains text
        String text = "To be or not to be, that is the question.";
        
        // process the string
        text = text.replace(",", "");  // remove commas
        text = text.replace(".", "");  // remove periods
        text = text.toLowerCase();     // convert to lower case
    
        // split the string into an array
        String[] words = text.split(" ");

        // define a map and fill it with words and their counts
        Map<String,Integer> wordMap = new TreeMap<>();
        for (String word : words) {
            if (wordMap.containsKey(word)) {        // word is in map
                int oldCount = wordMap.get(word);
                int newCount = oldCount + 1;
                wordMap.put(word, newCount);
            } else {                                // new word for map
                wordMap.put(word, 1);
            }
        }        

        // print the entries
        for (Map.Entry entry : wordMap.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
    }
}