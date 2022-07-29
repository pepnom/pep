import java.io.*;
import java.nio.charset.Charset;

/** 
  A class to test the machine from the command line
  */

public class mtest {

  public static void printHelp()
  {
    StringBuffer text = new StringBuffer();
    text.append(
      "h    - display commands \n" +
      "r    - read one character from the input stream \n" +
      "R    - reset the input stream \n" +
      "st ..- set the text to use to the following \n" +
      "u xx - read the input until the workspace ends with 'xx'\n" +
      "esc x- set the machine escape character to 'x'\n" +
      "ue   - remove escapes in the workspace \n" +
      "w    - read the input while the peep is \n" +
      "W    - show the legal character classes usable with 'w'\n" +
      "teq  - test if the workspace is equal to the text \n" +
      "te   - test if the workspace ends with the text \n" +
      "tc   - test if the 1st workspace char is in the class \n" +
      "ts   - test if the workspace start with the text \n" +
      "tt   - test if the workspace is the same as the tape cell \n" +
      "td   - test if the workspace matches a dictionary\n" +
      "pp   - print the machine \n" +
      "ps   - print the machine storage \n" +
      "++   - increment the tape pointer \n" +
      "--   - decrement the tape pointer \n" +
      "g    - append the current tape cell to the workspace \n" +
      "G    - put the workspace into the current tape cell \n" +
      "co   - append the accumulator to the workspace \n" +
      "inc  - increment the accumulator \n" +
      "dec  - decrement the accumulator \n" +
      "zero - set the accumulator to zero \n" +
      "p    - print the workspace \n" +
      "d    - clear the workspace \n" +
      "clip - clip one character from the end of the workspace \n" +
      "clop - clip one character from the beginning of the workspace \n" +
      "a xx - add 'xx' to the workspace \n" +
      "o    - pop the stack into the workspace \n" +
      "O    - push the workspace onto \n" +
      "q    - exit \n"
    );
    System.out.print(text);
  }

  public static void main(String[] args) throws Exception 
  {
    String text = new String("on1234\"and\\\"is\u53cb\u53cbx\" \t e*two*\"quote\"023three*vvv");
    //BufferedReader buffReader = new BufferedReader(input);
    //InputStream is = new ByteArrayInputStream(text.getBytes()); //getBytes("UTF-8");
    //FileInputStream is = new FileInputStream("data.txt");
    FileReader fr = new FileReader("data.txt");
    Machine mm = new Machine(fr);

    //is.mark(1000);

    System.out.println("Testing the machine");
    System.out.println("may need: java -Dfile.encoding=UTF-8 mtest");
    System.out.println("with text: " + text);
    System.out.println("Default Charset: " + Charset.defaultCharset());

    String input = new String("h");
    String parameter = new String("");

    BufferedReader in = new BufferedReader(
      new InputStreamReader(System.in));
    
    while (!input.equals("q"))
    {
      if (input.equals("r"))
        mm.read(); 

      if (input.equals("R"))
      {
        System.out.println("not implemented");
      }

      if (input.startsWith("st"))
      {
        text = input.substring(2).trim();
        InputStream is = new ByteArrayInputStream(text.getBytes());
        Reader reader = new InputStreamReader(is);
        mm = new Machine(reader);
      }

      if (input.startsWith("esc"))
      {
        parameter = input.substring(3).trim();
        mm.setEscape(parameter); 
      }

      if (input.equals("ue"))
        mm.unescape(); 

      else if (input.startsWith("u"))
      {
        parameter = input.substring(1).trim();
        mm.until(parameter); 
      }

      else if (input.startsWith("w"))
      {
        parameter = input.substring(1).trim();
        mm.whilePeep(parameter); 
      }

      if (input.equals("W"))
        System.out.println(mm.getWhileClasses()); 

      if (input.startsWith("teq"))
      {
        parameter = input.substring(3).trim();
        mm.testEquals(parameter); 
      }

      else if (input.startsWith("te"))
      {
        parameter = input.substring(2).trim();
        mm.testEndsWith(parameter); 
      }

      else if (input.startsWith("tc"))
      {
        parameter = input.substring(2).trim();
        mm.testClass(parameter); 
      }

      else if (input.startsWith("ts"))
      {
        parameter = input.substring(2).trim();
        mm.testBeginsWith(parameter); 
      }

      else if (input.startsWith("tt"))
      {
        parameter = input.substring(2).trim();
        mm.testTape(); 
      }

      else if (input.startsWith("td"))
      {
        parameter = input.substring(2).trim();
        mm.testDictionary(parameter); 
      }

      if (input.equals("pp"))
        mm.printState(); 

      if (input.equals("ps"))
        //mm.printStorage();

      if (input.equals("++"))
        mm.incrementTape();

      if (input.equals("--"))
        mm.decrementTape();
      
      if (input.equals("g"))
        mm.get();
      
      if (input.equals("G"))
        mm.put();
      
      if (input.equals("co"))
      {
        mm.count();
      }

      if (input.equals("zero"))
      {
        mm.zero();
      }

      if (input.equals("inc"))
      {
        mm.inca();
      }

      if (input.equals("dec"))
      {
        mm.deca();
      }

      if (input.equals("clip"))
      {
        mm.clip();
      }
      
      if (input.equals("clop"))
      {
        mm.clop();
      }
      
      if (input.startsWith("a"))
      {
        parameter = input.substring(1).trim();
        mm.add(parameter);
      }

      if (input.equals("p"))
      {
        mm.print();
      }

      if (input.equals("d"))
      {
        mm.clear();
      }

      //Stack commands

      if (input.equals("o"))
      {
        mm.pop();
      }
   
      if (input.equals("O"))
      {
        mm.push();
      }
   
      if (input.equals("h"))
      {
        mtest.printHelp();
      }
   
      if (!input.matches("^ababab[h]$"))
      {
        System.out.println("\nparam:" + parameter + "\ntext:" + text);
        mm.printState();
      }
      System.out.print(">");
      input = in.readLine().trim();
    }

    System.out.println("goodbye!");
  }
}
