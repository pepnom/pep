import java.net.*;
import java.io.*;
import java.util.*;

//-- import EndText;

/**
 *  Provides one or two static methods to alter text
 *  in a string. 
 *
 *  @author http://bumble.sf.net
 */
 
  
public class ReplaceText extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  private String text;  

  //--------------------------------------------
  public ReplaceText()
  {
    this.text = "";
  }

  //--------------------------------------------
  public ReplaceText(String sText)
  {
    this.text = sText;
  } 

  //--------------------------------------------
  /** replaces a character in a string with a string */
  public static String replace(String sText, char cOld, String sNew)
  {
    char cCurrent;
    StringBuffer sbReturn = new StringBuffer("");

    if (sText.indexOf(cOld) == -1)
    {
      return sText;
    }

    for (int ii = 0; ii < sText.length(); ii++)
    {
      cCurrent = sText.charAt(ii);
      if (cCurrent == cOld)
      {
        sbReturn.append(sNew);
      }
      else
      {
        sbReturn.append(cCurrent);
      }
    } //-- for

    return sbReturn.toString();

  } //-- method: replace

  //--------------------------------------------
  /** replaces a string in a string with a string */
  public static String replaceString(String sText, String sOld, String sNew)
  {
    char cCurrent;
    StringBuffer sbReturn = new StringBuffer("");
    String sTemp = "";

    if (sText.indexOf(sOld) == -1)
    {
      return sText;
    }

    for (int ii = 0; ii < sText.length(); ii++)
    {
      cCurrent = sText.charAt(ii);
      sbReturn.append(cCurrent);

      if (sbReturn.toString().endsWith(sOld))
      {

        sTemp = EndText.removeSuffix(sbReturn.toString(), sOld);
        sbReturn.setLength(0);
        sbReturn.append(sTemp);
        sbReturn.append(sNew);
      }

    } //-- for

    return sbReturn.toString();

  } //-- method: replaceString


  //--------------------------------------------
  /** a main method for testing */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java ReplaceText char string");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");


    if (args.length < 2)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    String sText = "This is the old text";
    char cReplace = args[0].charAt(0);
    String sOld = args[0];
    String sNew = args[1];
        
    System.out.println("Using string:");
    System.out.println(sText);

    System.out.println("");
                                         
    System.out.print(".replace()       >");
    System.out.println(ReplaceText.replace(sText, cReplace, sNew));
    System.out.print(".replaceString() >");
    System.out.println(ReplaceText.replaceString(sText, sOld, sNew));
 
  } //-- main()
  
} //-- ReplaceText class
