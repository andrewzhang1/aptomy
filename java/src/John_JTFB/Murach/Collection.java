package John_JTFB.Murach;

import com.sun.org.apache.xpath.internal.SourceTree;

import java.util.ArrayList;
import java.util.LinkedList;

public class Collection {
        public static void main(String[] args) {
            ArrayList<String> codes = new ArrayList<>();
            codes.add("Java");
            codes.add("jsp");
            codes.add("mysql");
            for (String s : codes) {
                System.out.println(s);
            }

            System.out.println(codes);

            LinkedList<String> codes1 = new LinkedList<>();
            codes1.add("LL_Andrew");
            codes1.add("LL_Jason");
            codes1.add("Sherry");
            System.out.println(codes1);
        }
}
