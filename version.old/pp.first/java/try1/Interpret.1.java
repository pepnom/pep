import java.io.*;
import java.util.*;
//import Tape;
//import Machine;

/**
 *  
 *  generates a program to execute a script
 *
 *  @author http://bumble.sf.net
 */
 
  
public class Interpret extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  /** this program uses the Machine.class to parse a script and 
   *  generate java code which is capable of executing the script
   */ 
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java Script ");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");
    boolean bDebug = false;

    
    if (args.length == 1)
    {
      bDebug = true;
    }

    InputStreamReader is = new InputStreamReader(System.in);
    BufferedReader in = new BufferedReader(is);
    //System.out.println(in.readLine() + "--- ");

    //-- a machine to parse the script
    Machine pp = new Machine();
    Machine ss = new Machine();

    //-- to record descriptions of errors encountered
    //-- during parsing.
    StringBuffer sbErrors = new StringBuffer("");
    StringBuffer sbWarnings = new StringBuffer("");
    StringBuffer sbPartial = new StringBuffer("");

    //-- keep track of which line of the source is being parsed
    int iLineNumber = 0;


    String sText = new String(NEWLINE +
      "#be/;{}g'# /letter|colon/" + NEWLINE +
      "{ add ''; #explain#" + NEWLINE +
      "add '//word'; pint; clear; push; " + NEWLINE +
      " /here/  { bip; push; clear;}" + NEWLINE +
      " " +
      "");

    char cCurrent;
    int iCurrent = in.read();

    while (iCurrent != -1)
    {             
       // cCurrent = sText.charAt(ii);
       cCurrent = (char)iCurrent;

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
         pp.add("(mm.workspace().equals(\"");
         pp.get();
         pp.add("\"))");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }

       //-------------------------------------------
       /*  allow multiple tests for one block, for example
           /noun|verb|/
           /article|noun|verb/ { clear; add 'sentence'; push; }
        */

       if (pp.workspace().equals("test|test|"))
       {
         pp.clear();
         pp.get();
         pp.add(" ||");
         pp.newline();
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }

       //-- this can be used to check for whitepace 
       if (pp.workspace().equals("slash|slash|"))
       {
         pp.clear();
         pp.add("(Character.isWhitespace(mm.workspace().toString().charAt(0)))");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();

         //sbErrors.append("empty test condition: //");
         //sbErrors.append(" (line " + iLineNumber + ")");
         //sbErrors.append(NEWLINE);
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
         pp.add("/*");
         pp.get();
         pp.add("*/");
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
         sbWarnings.append("empty comment: ##");
         sbWarnings.append(" (line " + iLineNumber + ")");
         sbWarnings.append(NEWLINE);
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
         pp.add("\"");
         pp.get();
         pp.add("\"");
         pp.put();
         pp.clear();
         pp.add("quoted-text|");
         pp.push();
       }

       if (pp.workspace().equals("quote|quote|"))
       {
         pp.clear();
         pp.add("\"");
         pp.add("\"");
         pp.put();
         pp.clear();
         pp.add("quoted-text|");
         pp.push();
         sbWarnings.append("empty quote: ''");
         sbWarnings.append(" (line " + iLineNumber + ")");
         sbWarnings.append(NEWLINE);
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

        if (pp.workspace().equals("comment|command|") ||
            pp.workspace().equals("command|comment|"))
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
          {
            pp.clear();
            pp.add("mm.print();");
          }
          else if (pp.workspace().toString().equals("clear"))
          {
            pp.clear();
            pp.add("mm.clear();");
          }
          else if (pp.workspace().toString().equals("push"))
          {
            pp.clear();
            pp.add("mm.push();");
          }
          else if (pp.workspace().toString().equals("pop"))
          {
            pp.clear();
            pp.add("mm.pop();");
          }
          else if (pp.workspace().toString().equals("put"))
          {
            pp.clear();
            pp.add("mm.put();");            
          }
          else if (pp.workspace().toString().equals("get"))
          {
            pp.clear();
            pp.add("mm.get();");
          }
          else if (pp.workspace().toString().equals("++"))
          {
            pp.clear();
            pp.add("mm.incrementTape();");
          }
          else if (pp.workspace().toString().equals("--"))
          {
            pp.clear();
            pp.add("mm.decrementTape();");
          }
          else if (pp.workspace().toString().equals("newline"))
          {
            pp.clear();
            pp.add("mm.newline();");
          }
          else if (pp.workspace().toString().equals("indent"))
          {
            pp.clear();
            pp.add("mm.indent();");
          }
          else if (pp.workspace().toString().equals("state"))
          {
            pp.clear();
            pp.add("System.out.println(mm.printState());");
          }
          else if (pp.workspace().toString().equals("add"))
          {
            sbErrors.append("incorrect syntax: ");
            sbErrors.append("the 'add' command requires an argument.");
            sbErrors.append(" (line " + iLineNumber + ")");
            sbErrors.append(NEWLINE);
          }
          else
          {
            sbErrors.append("unrecognized command: ");
            sbErrors.append(pp.workspace().toString());
            sbErrors.append(" (line " + iLineNumber + ")");
            sbErrors.append(NEWLINE);
          }
          pp.put();
          pp.clear();

          pp.add("command|");
          pp.push();
          bReduction = true;

        } //--if word,semi-colon 

        pp.pop();

        if (pp.workspace().equals("word|quoted-text|semi-colon|"))
        {
          pp.clear();
          pp.get();

          if (pp.workspace().toString().equals("add"))
          { 
            pp.clear();
            pp.add("mm.add(");
            pp.incrementTape();
            pp.get();
            pp.decrementTape();
            pp.add(");");
            pp.put();            
          }
          else
          {
            sbErrors.append("unrecognized command: ");
            sbErrors.append(pp.workspace().toString());
            sbErrors.append(" (line " + iLineNumber + ")");
            sbErrors.append(NEWLINE);
          }

          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;

        } //--if word, text, semi-colon

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

          //-- put the if around the tests
          pp.add("if (");
          pp.get();
          pp.add(")");
          pp.newline();
          //--pp.add("bReduction = true;");
          //--pp.newline();
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
        } //--if test, block

        pp.push();
        pp.push();
        pp.push();
        pp.push();

        if (bDebug)
          { System.out.println(pp.printState()); }

       } //-- while a reduction

       iCurrent = in.read();      
    } //-- for each letter
    
    if (pp.stacksize() != 1)
    {
      System.out.println("*** error parsing script ***");
      System.out.println("Errors:");
      System.out.println(sbErrors.toString());
      if (sbWarnings.toString().length() > 0)
       { System.out.println("Warnings:"); }

      System.out.println(sbWarnings.toString());
      System.out.println("*** final parse state ***");
      System.out.println(pp.printState());
      System.exit(-1);
    }
    
    pp.clear();
    pp.pop();
    if (!pp.workspace().equals("command|") &&
        !pp.workspace().equals("command-set|"))
    {
      System.out.println("*** error parsing script ***");
      System.out.println("Errors:");
      System.out.println(sbErrors.toString());
      if (sbWarnings.toString().length() > 0)
       { System.out.println("Warnings:"); }

      System.out.println(sbWarnings.toString());
      System.out.println("*** final parse state ***");
      System.out.println(pp.printState());
      System.exit(-1);
    }
    
    if (sbErrors.toString().length() > 0)  
    {
      System.out.println("*** error in script ***");
      System.out.println("Errors:");
      System.out.println(sbErrors.toString());

      if (sbWarnings.toString().length() > 0)
       { System.out.println("Warnings:"); }

      System.out.println(sbWarnings.toString());
      System.out.println("*** final parse state ***");
      System.out.println(pp.printState());
      System.exit(-1);
    }

    System.out.println("//-- script successfully parsed.");
    pp.clear();
       
    pp.get();
    pp.indent();
    pp.indent();
    pp.indent();
    pp.indent();
    pp.indent();
    pp.put();

    pp.clear();
    //-- add the skeleton code
    //
    pp.add("import java.io.*;"); pp.newline();
    pp.add("import java.util.*;"); pp.newline();
    pp.add("//import Tape;"); pp.newline();
    pp.add("//import Machine;"); 
    pp.newline(); pp.newline();

    pp.add("public class SomeScript extends Object"); pp.newline();
    pp.add("{"); 
    pp.newline(); pp.newline();

    pp.add("  private static String NEWLINE = ");
    pp.add("  System.getProperty(\"line.separator\");"); pp.newline();
    pp.add("  public static void main(String[] args) throws Exception"); 
    pp.newline();
    pp.add("  {"); pp.newline();
    pp.add("    StringBuffer sbUsageMessage = new StringBuffer(\"\");"); 
    pp.newline();
    pp.add("    sbUsageMessage.append(\"usage: java SomeScript \");");
    pp.newline();
    pp.add("    sbUsageMessage.append(NEWLINE);"); pp.newline();
    pp.add("    InputStreamReader is = new InputStreamReader(System.in);"); 
    pp.newline();
    pp.add("    BufferedReader in = new BufferedReader(is);");
    pp.newline();
    pp.add("    Machine mm = new Machine();"); pp.newline();

    pp.add("    StringBuffer sbErrors = new StringBuffer(\"\");"); pp.newline();
    pp.add("    StringBuffer sbPartial = new StringBuffer(\"\");"); pp.newline();        
    pp.add("    boolean bReduction = false;"); pp.newline();
    pp.add("    char cCurrent;"); pp.newline();
    pp.add("    int iCurrent = in.read();");
    pp.newline(); pp.newline();

    pp.add("    while (iCurrent != -1)"); pp.newline();
    pp.add("    {"); pp.newline();
    pp.add("       cCurrent = (char)iCurrent;"); pp.newline();
    pp.add("       mm.clear();"); pp.newline();
    pp.add("       mm.add(new Character(cCurrent).toString());"); pp.newline();
    pp.add("       mm.put();"); pp.newline();
    pp.add("       if (bDebug)"); pp.newline();
    pp.add("       {"); pp.newline();
    pp.add("         System.out.println(\"character:\" + cCurrent); ");
    pp.newline();
    pp.add("         System.out.println(mm.printState());"); pp.newline();
    pp.add("       }"); pp.newline();
    pp.add("       boolean bReduction = true;"); pp.newline();
    pp.add("       while (bReduction)"); pp.newline();
    pp.add("       {"); pp.newline();
    pp.add("          bReduction = false;"); pp.newline();

    //-------------------------------------        
    pp.get();
    pp.add("       } //-- while reduction"); pp.newline();
    pp.add("       iCurrent = in.read();"); pp.newline();  
    pp.add("     } //-- for each letter"); pp.newline();
    pp.add("  } //-- main()"); pp.newline();
    pp.add("} //-- SomeScript class"); pp.newline();
 
    /* open for append */
    //BufferedWriter out = 
    //  new BufferedWriter(new FileWriter("g:/machine/proj/SomeScript.java"));
    //out.write(pp.workspace());
    //out.close();
    //Runtime.getRuntime().exec("c:/jdk1.1.8/bin/javac.exe g:/machine/proj/SomeScript.java"); 

    pp.print();


    if (sbWarnings.toString().length() > 0)
    {
      System.out.println("//--Warnings:");
      System.out.println("/*");
      System.out.println(sbErrors);
      System.out.println("*/");
    }  

    if (bDebug)
     { System.out.println(pp.printState()); }

    

  } //-- main()
  
} //-- Script class
