
package machine;

import java.net.*;
import java.io.*;
import java.util.*;
import machine.Tape;

/**
 *  
 *  Is a virtual machine for parsing. It has some ideas
 *  drawn from the sed tool.
 *
 *  @author http://bumble.sf.net
 */
 
  
public class Machine extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  private Stack stack;
  //--------------------------------------------
  private Tape tape;
  //--------------------------------------------
  private StringBuffer workspace;
  //--------------------------------------------
  private StringBuffer lastOperation;
  //--------------------------------------------
  /** todo: */
  private Integer peep;

  //--------------------------------------------
  public Machine()
  {
    this.stack = new Stack();
    this.tape = new Tape();
    this.workspace = new StringBuffer();
    this.lastOperation = new StringBuffer("NEW MACHINE");
  }


  //--------------------------------------------
  public String getWorkspace()
  {
    return this.workspace.toString();
  }  

  //--------------------------------------------
  public String workspace()
  {
    return this.workspace.toString();
  }  

  //--------------------------------------------
  /** this method may not be necessary, can check with pops */
  public int stacksize()
  {
    return this.stack.size();
  } //-- 

  //--------------------------------------------
  public boolean matches(String sTest)
  {
    if (this.workspace.toString().equals(sTest))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* determines if the workspace is a space character */
  public boolean isSpace()
  {
    if (this.workspace.toString().length() != 1)
    {
      return false;
    }	    

    if (Character.isSpace(this.workspace.toString().charAt(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* determines if the workspace is a digit character */
  public boolean isDigit()
  {
    if (this.workspace.toString().length() != 1)
    {
      return false;
    }	    

    if (Character.isDigit(this.workspace.toString().charAt(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* determines if the workspace is a letter character */
  public boolean isLetter()
  {
    if (this.workspace.toString().length() != 1)
    {
      return false;
    }	    

    if (Character.isLetter(this.workspace.toString().charAt(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  public boolean isUnicode()
  {
    if (this.workspace.toString().length() != 1)
    {
      return false;
    }	    

    if (Character.isDefined(this.workspace.toString().charAt(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* to allow simple pattern testing for literal values */
  public boolean workspaceInRange(char cStart, char cEnd)
  {
    if (this.workspace.length() > 1)
     { return false;}

    char cCharacter = this.workspace.toString().charAt(0);

    if (cCharacter < cStart)
     { return false; }

    if (cCharacter > cEnd)
     { return false; }

    return true;
  }

  //--------------------------------------------
  /* to allow simple pattern testing for literal values */
  public boolean matches(char cStart, char cEnd)
  {
    if (this.workspace.length() > 1)
     { return false;}

    char cCharacter = this.workspace.toString().charAt(0);

    if (cCharacter < cStart)
     { return false; }

    if (cCharacter > cEnd)
     { return false; }

    return true;
  }

  //--------------------------------------------
  /** decrements the pointer to the tape by one */
  public void decrementTape()
  {
    this.tape.decrementPointer();
    this.lastOperation.setLength(0);
    this.lastOperation.append("decrement-tape");
  } //-- 

  //--------------------------------------------
  /** increments the pointer to the tape by one */
  public void incrementTape()
  {
    this.tape.incrementPointer();
    this.lastOperation.setLength(0);
    this.lastOperation.append("increment-tape");
  } //-- 

  //--------------------------------------------
  /** puts the workspace into the current item of the tape.
   *  The workspace is not changed  */
  public void put()
  {
    this.tape.put(this.workspace.toString());
    this.lastOperation.setLength(0);
    this.lastOperation.append("put");
  } //-- 

  //--------------------------------------------
  /** gets the current item of the tape and adds it to
   *  the end of the workspace */
  public void get()
  {
    this.workspace.append(this.tape.get());
    this.lastOperation.setLength(0);
    this.lastOperation.append("get");
  } //-- 

  //--------------------------------------------
  /** inserts the last item of the stack at the front of the workspace,
   * adding a bar character "|" to separate the token. If the
   * stack is empty, there is no change to the machine.
   */
  public void pop()
  {
    if (this.stack.empty())
    {
      this.lastOperation.setLength(0);
      this.lastOperation.append("pop [stack empty]");
      return;
    }

    String sSymbol = new String((String)this.stack.pop());
    String sText = new String(ReplaceText.replace(sSymbol, '|', "&bar;"));
    this.workspace.insert(0, sText + "|");
    this.tape.decrementPointer();
    this.lastOperation.setLength(0);
    this.lastOperation.append("pop");
  } //-- 

  //--------------------------------------------
  /** pushes the contents of the workspace onto the stack.
   *  The first token on the workspace is deleted.
   */ 
  public void push()
  {

    if (this.workspace.toString().length() < 1)
    {
      this.lastOperation.setLength(0);
      this.lastOperation.append("push [workspace empty]");
      return;
    }

    this.lastOperation.setLength(0);
    this.lastOperation.append("push");

    int iFirstBar = this.workspace.toString().indexOf('|');

    if (iFirstBar < 0)
    {
      String sText = new String(
        ReplaceText.replaceString(this.workspace.toString(), "&bar;", "|"));
      this.stack.push(sText);
      this.tape.incrementPointer();
      this.workspace.setLength(0);
      return;
    }

    String sFirstToken = new String(
      this.workspace.toString().substring(0, iFirstBar));
    String sText = new String(ReplaceText.replaceString(sFirstToken, "&bar;", "|"));
    this.stack.push(sText);
    this.workspace = new StringBuffer(
      this.workspace.toString().substring(iFirstBar + 1));
    this.tape.incrementPointer();

  } //-- method: push


  //--------------------------------------------
  /** prints the workspace to standard out */
  public void print()
  {
    System.out.print(this.workspace.toString());
    this.lastOperation.setLength(0);
    this.lastOperation.append("print");
  } 

  //--------------------------------------------
  /** adds a piece of text to the end of the workspace */
  public void add(String sText)
  {
    this.workspace.append(sText);
    this.lastOperation.setLength(0);
    this.lastOperation.append("add");

  } 

  //--------------------------------------------
  /** clears the workspace */
  public void clear()
  {
    this.workspace.setLength(0);
    this.lastOperation.setLength(0);
    this.lastOperation.append("clear");
  } 

  //--------------------------------------------
  /**  anyade una nueva linea al espacio */
  public void newline()
  {
    this.workspace.append(NEWLINE);
    this.lastOperation.setLength(0);
    this.lastOperation.append("newline");
  } 

  //--------------------------------------------
  /** todo: read the input stream until the workspace ends with the text */
  public void until(String sText)
  {
  }

  public void until(String sText, String sNotText)
  {}

  /** reads the input stream until the workspace ends with the 
   *  text in the current element of the tape */
  public void until()
  {}

  //--------------------------------------------
  /** todo: */
  public void while()
  {
  }

  
  //--------------------------------------------
  /** todo: */
  public void whileNot()
  {
  }

  /** todo: */
  public void crash()
  {
  }

  //--------------------------------------------
  /** indents each line of the workspace, which may
   *  be useful for print code fragments */
  public void indent()
  {
    String sText = new String(this.workspace.toString());
    this.workspace.setLength(0);
    char cCurrent;

    this.workspace.append("  ");
    for (int ii = 0; ii < sText.length(); ii++)
    {
      cCurrent = sText.charAt(ii);
      this.workspace.append(cCurrent);
      if (this.workspace.toString().endsWith(NEWLINE))
       { this.workspace.append("  "); }

    } //-- for
    this.lastOperation.setLength(0);
    this.lastOperation.append("indent");

  } //-- method: indent 

  //--------------------------------------------
  /**  */
  public String toString()
  {
    return "";
  } //-- method:

  //--------------------------------------------
  /** returns a description of the current state of the machine, displays the 
   *  contents of the stack, tape and the workspace.
   */ 
  public String printState()
  {
    StringBuffer sbMessage = new StringBuffer();
    sbMessage.append(NEWLINE);
    sbMessage.append("last operation:" + this.lastOperation);
    sbMessage.append(NEWLINE);
    sbMessage.append("WORKSPACE:[");
    sbMessage.append(this.workspace.toString());
    sbMessage.append("]");
    sbMessage.append(NEWLINE);

    sbMessage.append("STACK    :");
    sbMessage.append(this.stack.toString());
    sbMessage.append(NEWLINE);
    sbMessage.append("TAPE     :");
    sbMessage.append(NEWLINE);
    sbMessage.append(this.tape.print());

    sbMessage.append(NEWLINE);
    return sbMessage.toString();
  } //-- method:


  //--------------------------------------------
  /** provides a command loop to test the machine operations and view the machine */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java Machine ");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");


    if (args.length > 2)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    //String sText = args[0];
    //char cChar = args[1].charAt(0);


    Machine testMachine = new Machine();

    BufferedReader brUserInput = new BufferedReader(
        new InputStreamReader(System.in));

     String sCommand = "";
     // SoundDownload sdCurrent = (SoundDownload)ee.nextElement();

     StringBuffer sbUserMessage = new StringBuffer("");
     sbUserMessage.setLength(0);

     sbUserMessage.append("Commands;");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" a - add to the workspace");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" c - clear the work space [clear, cl]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" i - indents the work space [indent]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" n - add newline to the work space [newline, nl]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" p - push the workspace onto the stack [push]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" o - pop the stack into the workspace [pop]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" u - put the workspace on the tape [put]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" g - get the tape item into the workspace ");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" - - decrement the tape pointer");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" + - increment the tape pointer");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" h - help, show this message [?]");
     sbUserMessage.append(NEWLINE);
     sbUserMessage.append(" q - quit");
     sbUserMessage.append(NEWLINE);
     System.out.println(sbUserMessage);

     //----------------------------------
     //-- the command loop
     //--
     while (!sCommand.equals("q"))
     {
       //--------------------------------
       // 
       if (sCommand.startsWith("a"))
       {
         testMachine.add(sCommand.substring(1));               
       }

       //--------------------------------
       // 
       if (sCommand.equals("c") || sCommand.equals("clear"))
       {
         testMachine.clear();
       }

       //--------------------------------
       // 
       if (sCommand.equals("n") || sCommand.equals("newline"))
       {
         testMachine.newline();
       }

       //--------------------------------
       // 
       if (sCommand.equals("i") || sCommand.equals("indent"))
       {
         testMachine.indent();
       }

       //--------------------------------
       // 
       if (sCommand.equals("p") || sCommand.equals("push"))
       {
         testMachine.push();               
       }

       //--------------------------------
       // 
       if (sCommand.equals("o") || sCommand.equals("pop"))
       {
         testMachine.pop();               
       }

       //--------------------------------
       // 
       if (sCommand.equals("u") || sCommand.equals("put"))
       {
         testMachine.put();
       }

       //--------------------------------
       // 
       if (sCommand.equals("g") || sCommand.equals("get"))
       {
         testMachine.get();
       }

       //--------------------------------
       // 
       if (sCommand.equals("-"))
       {
         testMachine.decrementTape();               
       }

       //--------------------------------
       // 
       if (sCommand.equals("+"))
       {
         testMachine.incrementTape();               
       }

       //--------------------------------
       // 
       if (sCommand.equals("?") || sCommand.equals("h"))
       {
         System.out.println(sbUserMessage);               
       }


       System.out.print(testMachine.printState());
       System.out.print(">");
       sCommand = brUserInput.readLine();
     } //-- while


    System.out.println(testMachine.printState());
    

  } //-- main()
  
} //-- Machine class
