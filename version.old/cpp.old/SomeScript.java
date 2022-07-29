//-- script successfully parsed.
import java.io.*;
import java.util.*;
//import Tape;
//import Machine;

public class SomeScript extends Object
{

  private static String NEWLINE =   System.getProperty("line.separator");
  public static void main(String[] args) throws Exception
  {
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("usage: java SomeScript ");
    sbUsageMessage.append(NEWLINE);
    InputStreamReader is = new InputStreamReader(System.in);
    BufferedReader in = new BufferedReader(is);
    Machine mm = new Machine();
    StringBuffer sbErrors = new StringBuffer("");
    StringBuffer sbPartial = new StringBuffer("");
    boolean bReduction = false;
    boolean bDebug = false;
    char cCurrent;
    int iCurrent = in.read();

    while (iCurrent != -1)
    {
       cCurrent = (char)iCurrent;
       mm.clear();
       mm.add(new Character(cCurrent).toString());
       mm.put();
       if (bDebug)
       {
         System.out.println("character:" + cCurrent); 
         System.out.println(mm.printState());
       }
       bReduction = true;
       while (bReduction)
       {
          bReduction = false;
          /*parses algebra*/
          if (mm.isSpace())
          {
            mm.put();
            mm.clear();
            mm.add("whitespace|");
            mm.push();
          }
          
          if (mm.isDigit())
          {
            mm.put();
            mm.clear();
            mm.add("numeral|");
            mm.push();
          }
          
          if ((mm.workspace().equals(")")))
          {
            mm.put();
            mm.clear();
            mm.add("close-bracket|");
            mm.push();
          }
          
          if ((mm.workspace().equals("(")))
          {
            mm.put();
            mm.clear();
            mm.add("open-bracket|");
            mm.push();
          }
          
          if ((mm.workspace().equals(";")))
          {
            mm.put();
            mm.clear();
            mm.add("semi-colon|");
            mm.push();
          }
          
          if (mm.isLetter())
          {
            mm.put();
            mm.clear();
            mm.add("word|");
            mm.push();
          }
          
          if ((mm.workspace().equals("+")) ||
          (mm.workspace().equals("-")) ||
          (mm.workspace().equals("*")) ||
          (mm.workspace().equals("/")))
          {
            mm.put();
            mm.clear();
            mm.add("operand|");
            mm.push();
          }
          
          if (mm.isUnicode())
          {
            mm.put();
            mm.clear();
            mm.add("character|");
            mm.push();
          }
          
          mm.pop();
          mm.pop();
          if ((mm.workspace().equals("numeral|numeral|")))
          {
            mm.clear();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("numeral|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|open-bracket|")))
          {
            mm.clear();
            mm.add("term|open-bracket|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|close-bracket|")))
          {
            mm.clear();
            mm.add("term|close-bracket|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|whitespace|")))
          {
            mm.clear();
            mm.add("term|whitespace|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|operand|")))
          {
            mm.clear();
            mm.add("term|operand|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|word|")))
          {
            mm.clear();
            mm.add("term|word|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("numeral|semi-colon|")))
          {
            mm.clear();
            mm.add("term|semi-colon|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          /* -------------------------- */
          if ((mm.workspace().equals("word|word|")))
          {
            mm.clear();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("word|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|open-bracket|")))
          {
            mm.clear();
            mm.add("term|open-bracket|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|close-bracket|")))
          {
            mm.clear();
            mm.add("term|close-bracket|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|whitespace|")))
          {
            mm.clear();
            mm.add("term|whitespace|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|operand|")))
          {
            mm.clear();
            mm.add("term|operand|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|numeral|")))
          {
            mm.clear();
            mm.add("term|numeral|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("word|semi-colon|")))
          {
            mm.clear();
            mm.add("term|semi-colon|");
            mm.push();
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          /* -------------------------- */
          if ((mm.workspace().equals("semi-colon|whitespace|")))
          {
            mm.clear();
            mm.add("semi-colon|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("operand|whitespace|")))
          {
            mm.clear();
            mm.add("operand|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("term|whitespace|")))
          {
            mm.clear();
            mm.add("term|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("open-bracket|whitespace|")))
          {
            mm.clear();
            mm.add("open-bracket|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("close-bracket|whitespace|")))
          {
            mm.clear();
            mm.add("close-bracket|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          if ((mm.workspace().equals("whitespace|whitespace|")))
          {
            mm.clear();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("whitespace|");
            mm.push();
            mm.pop();
            mm.pop();
          }
          
          mm.push();
          mm.push();
          mm.pop();
          mm.pop();
          mm.pop();
          mm.pop();
          mm.pop();
          if ((mm.workspace().equals("open-bracket|term|operand|term|close-bracket|")))
          {
            mm.clear();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.decrementTape();
            mm.decrementTape();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("term|");
            mm.pop();
            mm.pop();
          }
          
          mm.push();
          mm.push();
          mm.push();
          mm.push();
          mm.push();
          mm.pop();
          mm.pop();
          mm.pop();
          mm.pop();
          if ((mm.workspace().equals("term|operand|term|semi-colon|")))
          {
            mm.clear();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.decrementTape();
            mm.decrementTape();
            mm.put();
            mm.print();
            mm.clear();
            mm.add("expression|");
            mm.push();
          }
          
          mm.push();
          mm.push();
          mm.push();
          mm.push();
          mm.pop();
          mm.pop();
          if ((mm.workspace().equals("term|semi-colon|")))
          {
            mm.clear();
            mm.add("expression|");
            mm.push();
            mm.get();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.print();
            mm.clear();
          }
          
          mm.push();
          mm.push();
          mm.pop();
          mm.pop();
          if ((mm.workspace().equals("whitespace|expression|")))
          {
            mm.clear();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("expression|");
            mm.push();
          }
          
          if ((mm.workspace().equals("expression|whitespace|")))
          {
            mm.clear();
            mm.incrementTape();
            mm.get();
            mm.decrementTape();
            mm.put();
            mm.clear();
            mm.add("expression|");
            mm.push();
          }
          
          mm.push();
          mm.push();       } //-- while reduction
       iCurrent = in.read();
     } //-- for each letter
  } //-- main()
} //-- SomeScript class
