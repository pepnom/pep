   import java.util.*;
   import java.awt.*;
   public class FontHelp {
     public static String[] getGlyphFonts(char c) {
       java.util.List<String> names = new ArrayList<String>();
       GraphicsEnvironment gre =
         GraphicsEnvironment.getLocalGraphicsEnvironment();
       for (Font f: gre.getAllFonts()) {
         if (f.canDisplay(c)) names.add(f.getName());
       }
       return (String[])names.toArray(new String[names.size()]);
     }
     public static void main(String[] args) {
       for (String s: FontHelp.getGlyphFonts('\u269c'))
         System.out.println(s);
     }
   }
