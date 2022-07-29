import java.io.*;
import java.util.*;
//import Tape;
//import Machine;

/**
 *  
 *  prints the script in a non chaotic way.
 *
 *  @author http://bumble.sf.net
 */
 
  
public class PrettyPrint extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------


  //--------------------------------------------
  /**  */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java Script ");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");
    boolean bDebug = true;

    /*
    if (args.length > 2)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    String sText = args[0];
    char cChar = args[1].charAt(0);
    */

    //-- a machine to parse the script
    Machine pp = new Machine();
    Machine ss = new Machine();
    //-- to record descriptions of errors encountered
    //-- during parsing.
    StringBuffer sbErrors = new StringBuffer("");
    StringBuffer sbPartial = new StringBuffer("");

    //-- keep track of which line of the source is being parsed
    int iLineNumber = 0;


    String sText = new String(NEWLINE +
      "#be/;{}g'# /letter|colon/" + NEWLINE +
      "{ add ''; #explain#" + NEWLINE +
      "add '//word'; pint; clear; push; " + NEWLINE +
      " /here/  { bip; push; clear;}" + NEWLINE +
      "}" +
      "");

    char cCurrent;
    for (int ii = 0; ii < sText.length(); ii++)
    {             
       cCurrent = sText.charAt(ii);
       sbPartial.append(cCurrent);
       if (sbPartial.toString().endsWith(NEWLINE))
         { iLineNumber++; }

       pp.clear();
       pp.add(new Character(cCurrent).toString());
       pp.put();

       if (bDebug)
         { System.out.println("character:" + cCurrent); }



       if (Character.isWhitespace(pp.workspace().toString().charAt(0)))
       {
         pp.clear();
         pp.add("space");
         pp.push();
       }

       if (pp.matches("/"))
       {
         pp.clear();
         pp.add("slash");
         pp.push();
       }

       if (pp.matches("{"))
       {
         pp.clear();
         pp.add("open-brace");
         pp.push();
       }

       if (pp.matches("}"))
       {
         pp.clear();
         pp.add("close-brace");
         pp.push();
       }

       if (pp.matches(";"))
       {
         pp.clear();
         pp.add("semi-colon");
         pp.push();
       }

       if (pp.matches("'"))
       {
         pp.clear();
         pp.add("quote");
         pp.push();
       }

       if (pp.matches("#"))
       {
         pp.clear();
         pp.add("hash");
         pp.push();
       }

       if (pp.workspace().length() > 0)
       {
         pp.clear();
         pp.add("character");
         pp.push();
       }

       pp.pop();
       pp.pop();

       if (bDebug)
          { System.out.println(pp.printState()); }

       //-------------------------------------------
       //-- 
       if (pp.workspace().equals("start-test|slash|"))
       {
         pp.clear();
         pp.add("/");
         pp.get();
         pp.add("/");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }

       if (pp.workspace().equals("slash|slash|"))
       {
         pp.clear();
         pp.add("/");
         pp.add("/");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();

         sbErrors.append("empty test condition: //");
         sbErrors.append(" (line " + iLineNumber + ")");
         sbErrors.append(NEWLINE);
       }

       if (pp.workspace().equals("start-test|character|") ||
          pp.workspace().equals("start-test|space|") ||
          pp.workspace().equals("start-test|hash|") ||
          pp.workspace().equals("start-test|semi-colon|") ||
          pp.workspace().equals("start-test|close-brace|") ||
          pp.workspace().equals("start-test|open-brace|") ||
          pp.workspace().equals("start-test|quote|"))
       {
         pp.clear();
         pp.get();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-test|");
         pp.push();
       }

       if (pp.workspace().equals("slash|semi-colon|") ||
          pp.workspace().equals("slash|close-brace|") ||
          pp.workspace().equals("slash|open-brace|") ||
          pp.workspace().equals("slash|character|") ||
          pp.workspace().equals("slash|space|") ||
          pp.workspace().equals("slash|quote|") ||
          pp.workspace().equals("slash|hash|"))
       {
         pp.clear();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-test|");
         pp.push();
       }


       //-------------------------------------------
       //-- 
       if (pp.workspace().equals("start-comment|hash|")) 
       {
         pp.clear();
         pp.add("#");
         pp.get();
         pp.add("#");
         pp.put();
         pp.clear();
         pp.add("comment|");
         pp.push();
       }

       if (pp.workspace().equals("hash|hash|"))
       {
         pp.clear();
         pp.add("comment|");
         pp.push();
         sbErrors.append("empty comment: ##");
         sbErrors.append(" (line " + iLineNumber + ")");
         sbErrors.append(NEWLINE);
       }

       if (pp.workspace().equals("start-comment|character|") ||
          pp.workspace().equals("start-comment|space|") ||
          pp.workspace().equals("start-comment|semi-colon|") ||
          pp.workspace().equals("start-comment|close-brace|") ||
          pp.workspace().equals("start-comment|open-brace|") ||
          pp.workspace().equals("start-comment|quote|") ||
          pp.workspace().equals("start-comment|slash|"))
       {
         pp.clear();
         pp.get();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-comment|");
         pp.push();
       }

       if (pp.workspace().equals("hash|semi-colon|") ||
          pp.workspace().equals("hash|close-brace|") ||
          pp.workspace().equals("hash|open-brace|") ||
          pp.workspace().equals("hash|character|") ||
          pp.workspace().equals("hash|quote|") ||
          pp.workspace().equals("hash|slash|") ||
          pp.workspace().equals("hash|character|") ||
          pp.workspace().equals("hash|space|"))
       {
         pp.clear();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-comment|");
         pp.push();
       }



       //------------------------------------------
       //--
       if (pp.workspace().equals("start-quote|quote|"))
       {
         pp.clear();
         pp.add("'");
         pp.get();
         pp.add("'");
         pp.put();
         pp.clear();
         pp.add("quoted-text|");
         pp.push();
       }

       if (pp.workspace().equals("quote|quote|"))
       {
         pp.clear();
         pp.add("'");
         pp.add("'");
         pp.put();
         pp.clear();
         pp.add("quoted-text|");
         pp.push();
         sbErrors.append("empty test condition: //");
         sbErrors.append(" (line " + iLineNumber + ")");
         sbErrors.append(NEWLINE);
       }

       if (pp.workspace().equals("start-quote|character|") ||
          pp.workspace().equals("start-quote|space|") ||
          pp.workspace().equals("start-quote|semi-colon|") ||
          pp.workspace().equals("start-quote|close-brace|") ||
          pp.workspace().equals("start-quote|open-brace|") ||
          pp.workspace().equals("start-quote|hash|") ||
          pp.workspace().equals("start-quote|slash|"))
       {
         pp.clear();
         pp.get();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-quote|");
         pp.push();
       }

       if (pp.workspace().equals("quote|semi-colon|") ||
          pp.workspace().equals("quote|close-brace|") ||
          pp.workspace().equals("quote|open-brace|") ||
          pp.workspace().equals("quote|character|") ||
          pp.workspace().equals("quote|hash|") ||
          pp.workspace().equals("quote|slash|") ||
          pp.workspace().equals("quote|space|"))
       {
         pp.clear();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("start-quote|");
         pp.push();
       }

       //------------------------------------------


       if (pp.workspace().equals("word|character|"))
       {
         pp.clear();
         pp.get();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("word|");
         pp.push();
       }

       if (pp.workspace().equals("character|character|"))
       {
         pp.clear();
         pp.get();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("word|");
         pp.push();
       }


       pp.push();
       pp.push();

       if (bDebug)
         { System.out.println(pp.printState()); }

       boolean bReduction = true;
       while (bReduction)
       {

        bReduction = false;

        //------------------------------------
        //-- ignore irrelevant spaces
        pp.pop();

        if (pp.workspace().equals("space|"))
        {
          pp.clear();
        }

        pp.pop();

        if (pp.workspace().equals("comment|command|"))
        {
          pp.clear();
          pp.get();
          pp.newline();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;
        }


        if (pp.workspace().equals("command-set|command|"))
        {
          pp.clear();
          pp.get();
          pp.newline();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("command-set|");
          pp.push();
          bReduction = true;
        }

        if (pp.workspace().equals("command|command|"))
        {
          pp.clear();
          pp.get();
          pp.newline();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("command-set|");
          pp.push();
          bReduction = true;
        }

        if (pp.workspace().equals("word|semi-colon|"))
        {
          pp.clear();
          pp.get();


          if (pp.workspace().toString().equals("print"))
          { }
          else if (pp.workspace().toString().equals("clear"))
          { }
          else if (pp.workspace().toString().equals("push"))
          { }
          else if (pp.workspace().toString().equals("pop"))
          { }
          else if (pp.workspace().toString().equals("put"))
          { }
          else if (pp.workspace().toString().equals("get"))
          { }
          else if (pp.workspace().toString().equals("++"))
          { }
          else if (pp.workspace().toString().equals("--"))
          { }
          else if (pp.workspace().toString().equals("newline"))
          { }
          else if (pp.workspace().toString().equals("indent"))
          { }
          else
          {
            sbErrors.append("unrecognized command: ");
            sbErrors.append(pp.workspace().toString());
            sbErrors.append(" (line " + iLineNumber + ")");
            sbErrors.append(NEWLINE);
          }
          pp.add(";");
          pp.put();
          pp.clear();

          pp.add("command|");
          pp.push();
          bReduction = true;
        } 

        pp.pop();

        if (pp.workspace().equals("word|quoted-text|semi-colon|"))
        {
          pp.clear();
          pp.get();

          if (pp.workspace().toString().equals("add"))
          { }
          else
          {
            sbErrors.append("unrecognized command: ");
            sbErrors.append(pp.workspace().toString());
            sbErrors.append(" (line " + iLineNumber + ")");
            sbErrors.append(NEWLINE);
          }

          pp.add(" ");
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.add(";");
          pp.put();
          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;
        }

        pp.pop();

        if (pp.workspace().equals("test|open-brace|command|close-brace|") ||
            pp.workspace().equals("test|open-brace|command-set|close-brace|"))
        {
          //-- indent a code block
          pp.clear();
          pp.incrementTape();
          pp.incrementTape();
          pp.get();
          pp.indent();
          pp.put();
          pp.decrementTape();
          pp.decrementTape();
          pp.clear();

          pp.get();
          pp.newline();
          pp.add("{");
          pp.newline();

          pp.incrementTape();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.decrementTape();

          pp.newline();
          pp.add("}");
          pp.newline();

          pp.put();
          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;
        }

        pp.push();
        pp.push();
        pp.push();
        pp.push();

        if (bDebug)
          { System.out.println(pp.printState()); }

       } //-- while a reduction

    } //-- for 

    System.out.println("Errors encountered:");
    System.out.println(sbErrors);
    System.out.println(pp.printState());

    

  } //-- main()
  
} //-- Script class
