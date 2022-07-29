package machine;

import java.net.*;
import java.io.*;
import java.util.*;

/**
 *  
 *  This class represents an infinite array of text strings, where each
 *  array cell can, in theory hold an infinite amount of text. The tape
 *  has a 'pointer' to keep track of the current cell in the array and 
 *  to allow the tape to be accessed without any parameters. For example
 *   get; will obtain the tape cell which is currently pointed to.
 *
 *  @author http://bumble.sf.net
 */
 
  
public class Tape extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  private Vector array;
  //--------------------------------------------
  int pointer;



  //--------------------------------------------
  public Tape()
  {
    this.array = new Vector();
    this.pointer = 0;
  }


  //--------------------------------------------
  /** 
   *   */
  public String toString()
  {
    return this.array.toString();
    /*
    StringBuffer sbReturn = new StringBuffer();
    String currentItem = new String();
    Enumeration ii = this.array.elements();
    while (ii.hasMoreElements())
    {
      currentItem = (String)ii.nextElement();
      sbReturn.append("|" + currentItem);
    }
    return sbReturn.toString();
    */
  } //-- method:

  //--------------------------------------------
  /** 
   *   */
  public String print()
  {
    StringBuffer sbReturn = new StringBuffer();
    String currentItem = new String();
    
    sbReturn.append("Pointer==" + this.pointer + NEWLINE);
    for (int ii = 0; ii < array.size(); ii++)
    {
      currentItem = (String)array.elementAt(ii);
      sbReturn.append(ii + ":" + currentItem + NEWLINE);
    }
    return sbReturn.toString();
    
  } //-- method:

  //--------------------------------------------
  /** 
   *   */
  public void put(String sNewElement)
  {
    if (this.pointer == this.array.size())
    {
      this.array.addElement(sNewElement);
      return;
    }

    this.array.setElementAt(sNewElement, this.pointer);
  } //-- method:

  
  //--------------------------------------------
  /** 
   *   */
  public String get()
  {
    if (this.pointer == this.array.size())
     { return ""; }
    return (String)this.array.elementAt(this.pointer);
  } //-- method:

  //--------------------------------------------
  /** 
   *   */
  public void incrementPointer()
  {
    if (this.pointer == this.array.size())
    {
      this.array.addElement("");
    }

    this.pointer++;
  } //-- method:

  //--------------------------------------------
  /** 
   *   */
  public void decrementPointer()
  {
    if (this.pointer == 0)
     { return; }

    this.pointer--;
  } //-- method:


  //--------------------------------------------
  /** a main method for testing */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java Tape ");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");


    if (args.length > 2)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    //String sText = args[0];
    //char cChar = args[1].charAt(0);


    Tape testTape = new Tape();

    System.out.println("put 'diffle'               ");
    testTape.put("diffle");
    System.out.println(testTape);

    System.out.println("put 'buff'               ");
    testTape.put("buff");
    System.out.println(testTape);

    System.out.println(".incrementPointer()       ");
    testTape.incrementPointer();
    System.out.println(testTape);

    System.out.println("put 'diffle'               ");
    testTape.put("diffle");
    System.out.println(testTape);



  } //-- main()
  
} //-- Tape class
