
import java.util.*;

/**
 *  Provides one or two static methods to display
 *  an array consisting of strings
 *
 *  @author http://bumble.sf.net
 */
 
  
public class StringArray extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  private String[] ssArray;  

  //--------------------------------------------
  public StringArray()
  {
  }

  //--------------------------------------------
  public static String display(String[] ssArray)
  {
    StringBuffer sbReturn = new StringBuffer("");

    for (int ii = 0; ii < ssArray.length; ii++)
    {
      sbReturn.append("[");
      sbReturn.append(ii);
      sbReturn.append("] ");
      sbReturn.append(ssArray[ii]);
      sbReturn.append(NEWLINE);
    }
    return sbReturn.toString();
  }

  //--------------------------------------------
  public static String printHtml(String[] ssArray)
  {
    StringBuffer sbReturn = new StringBuffer("");

    sbReturn.append("<ul>");
    sbReturn.append(NEWLINE);
    for (int ii = 0; ii < ssArray.length; ii++)
    {
      sbReturn.append("<li>");
      sbReturn.append("[");
      sbReturn.append(ii);
      sbReturn.append("] ");
      sbReturn.append(ssArray[ii]);
      sbReturn.append("</li>");
      sbReturn.append(NEWLINE);
    }
    sbReturn.append("</ul>");
    return sbReturn.toString();
  }

  //--------------------------------------------
  /** a main method for testing */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java StringArray .");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");


    if (args.length == 0)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    String[] ssTest = {"ed", "con", "de", "re", "again", "aussi"};    

    System.out.println(".display()");
    System.out.println(StringArray.display(ssTest));
    System.out.println(".printHtml()");
    System.out.println(StringArray.printHtml(ssTest));
 
  } //-- main()
  
} //-- StringArray class
