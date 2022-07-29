
import java.util.*;
//--
//-- these imports are commented out because
//-- modern jdks require classes to be in a package
//-- inorder to import them
//--
//import StringArray;

/**
 *  Provides one or two static methods to alter suffixes
 *  or prefixes in a string. This is just to provide
 *  pleasant method names.
 *
 *  @author http://bumble.sf.net
 */
 
  
public class EndText extends Object
{
  //--------------------------------------------
  private static String NEWLINE = System.getProperty("line.separator");
  //--------------------------------------------
  private String text;  

  //--------------------------------------------
  public EndText()
  {
    this.text = "";
  }

  //--------------------------------------------
  public EndText(String sText)
  {
    this.text = sText;
  }

  //--------------------------------------------
  /** returns the suffix of a string if the suffix is
   *  contained in the list of strings */
  public static String getSuffix(String sText, String[] ssSuffixes)
  {
    for (int ii = 0; ii < ssSuffixes.length; ii++)
    {
      if (sText.toLowerCase().endsWith(ssSuffixes[ii]))
      {
        return ssSuffixes[ii];
      }
    }
    return "";
  }

  //--------------------------------------------
  /** returns the prefix of a string if the suffix is
   *  contained in the list of strings */
  public static String getPrefix(String sText, String[] ssPrefixes)
  {
    for (int ii = 0; ii < ssPrefixes.length; ii++)
    {
      if (sText.toLowerCase().startsWith(ssPrefixes[ii]))
      {
        return ssPrefixes[ii];
      }
    }
    return "";
  }

  //--------------------------------------------
  public static String removeLast(String sText)
  {
    String sReturn = "";

    if (sText.length() == 0)
    {
      return "";
    }

    sReturn = sText.substring(0, sText.length() - 1);
    return sReturn;

  } //-- method: removeLast

  //--------------------------------------------
  /** removes a suffix from a piece of text. the case of
   *  the suffix does not have to match */
  public static String removeSuffix(String sText, String sSuffix)
  {
    String sReturn = "";

    if (!sText.toLowerCase().endsWith(sSuffix.toLowerCase()))
    {
      return sText;
    }

    sReturn = sText
      .substring(0, sText.length() - sSuffix.length());

    return sReturn;
  } //-- method: removeSuffix

  //--------------------------------------------
  /** removes a prefix from a piece of text. */
  public static String removePrefix(String sText, String sPrefix)
  {
    String sReturn = "";

    if (!sText.toLowerCase().startsWith(sPrefix.toLowerCase()))
    {
      return sText;
    }

    sReturn = sText
      .substring(sPrefix.length());

    return sReturn;
  } //-- method: removePrefix
  
  
  //--------------------------------------------
  /** returns all text after the last instance of a particular
   *  character, not including the character, or returns nothing if the 
   *   character does not occur in the string.
   */ 
  public static String textAfter(String sText, char cCharacter)
  {
     if (sText.indexOf(cCharacter) < 0)
       { return ""; }
       
     return sText.substring(sText.lastIndexOf(cCharacter) + 1);
  }

 //--------------------------------------------
  /** removes all text after the last instance of a particular
   *  character, including the character, or returns nothing if the 
   *   character does not occur in the string.
   */ 
  public static boolean stripAfterCharacter(StringBuffer sbText, char cCharacter)
  {
     if (sbText.toString().indexOf(cCharacter) < 0)
       { return false; }

     sbText.setLength(sbText.toString().lastIndexOf(cCharacter));  
     return true;
  }



  //--------------------------------------------
  /** a main method for testing */
  public static void main(String[] args) throws Exception
  {
    
    StringBuffer sbUsageMessage = new StringBuffer("");
    sbUsageMessage.append("test usage: java EndText text suffix");
    sbUsageMessage.append(NEWLINE);

    StringBuffer sbMessage = new StringBuffer("");


    if (args.length < 2)
    {	    
      System.out.println(sbUsageMessage);
      System.exit(-1);
    }

    String sText = args[0];
    String sSuffix = args[1];
    String[] ssSuffixes = {"ed", "con", "de", "re"};    
    System.out.print("Using string:");
    System.out.println(sText);
    System.out.println("Using suffix/prefix array:");
    System.out.println(StringArray.display(ssSuffixes));

    System.out.print(".removeSuffix() >");
    System.out.println(EndText.removeSuffix(sText, sSuffix));
    System.out.print(".removePrefix() >");
    System.out.println(EndText.removePrefix(sText, sSuffix));
    System.out.print(".getPrefix() >");
    System.out.println(EndText.getPrefix(sText, ssSuffixes));
    System.out.print(".getSuffix() >");
    System.out.println(EndText.getSuffix(sText, ssSuffixes));
    System.out.print(".removeLast() >");
    System.out.println(EndText.removeLast(sText));
 
  } //-- main()
  
} //-- EndText class
