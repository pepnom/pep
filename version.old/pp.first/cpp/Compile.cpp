
/**
 *  
 *  generates a program to execute a script
 *
 *  @author http://bumble.sf.net
 */
 
#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <ctype.h>
#include "Machine.h" 

using namespace std;
  
  //--------------------------------------------
  /** this program uses the Machine class to parse a script and 
   *  generate c++ code which is capable of executing the script
   */ 
  int main(int argc, char* argv[]) 
  {
    
    string sUsageMessage("");
    sUsageMessage.append("ms windows-- \n");
    sUsageMessage.append("usage: echo script | Interpret debugflag \n");
    sUsageMessage.append("usage: type scriptfile | Interpret debugflag \n");
    sUsageMessage.append("unix-- \n");
    sUsageMessage.append("usage: echo script | Interpret debugflag \n");
    sUsageMessage.append("usage: cat scriptfile | Interpret debugflag \n");
    ifstream in;
    string sMessage("");
    bool bDebug = true;

    if (argc == 1) 
    {
      bDebug = false;
    }
    else if (argc == 2)
    {
      if ((strcmp(argv[1], "-h") == 0) || (strcmp(argv[1], "-?") == 0))
      {
        cout << sUsageMessage;
	exit(0);
      }
      bDebug = true;
    } 
    else
    {
      bDebug = true;
    }

    //-- a machine to parse the script
    Machine pp;
    Machine ss;

    //-- to record descriptions of errors encountered
    //-- during parsing.
    stringstream ssErrors("");
    stringstream ssWarnings("");
    stringstream ssCommandList("");
    ssCommandList <<
      "crash, flag, print, clear, read, push, pop, put, get, ++, \n" <<
      "--, newline, indent, clip, state, add 'text', while 'text'\n" <<
      "whilenot 'text', until 'text' 'nottext'\n"; 
     
    //-- keep track of which line of the source is being parsed
    int iLineNumber = 0;

    char cCurrent;
    //cin.get(cCurrent);

    pp.readNext(cin);
    if (bDebug)
      { cout << "initial state" << pp.printState(); }
    pp.clear();

    while (!cin.eof())
    {             
       pp.clear();
       pp.readNext(cin);

       if (pp.workspace() == "\n")
         { iLineNumber++; }

       if (bDebug)
        { cout << pp.printState(); }

       if (pp.workspace() == ";")
       {
         pp.clear();
         pp.add("semi-colon|");
         pp.push();
       }

       if (pp.workspace() == "!")
       {
         pp.clear();
         pp.add("not|");
         pp.push();
       }

       if (pp.matches("{"))
       {
         pp.clear();
         pp.add("open-brace|");
         pp.push();
       }

       if (pp.matches("}"))
       {
         pp.clear();
         pp.add("close-brace|");
         pp.push();
       }

       //--------------------------------
       /* test */
       if (pp.workspace() == "/")
       {
	 /* escape double quotes */
         pp.clear();
         pp.readUntil(cin, "/", "\\/");
         if (!pp.endsWith("/"))
         {
           ssErrors << "unterminated test: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         pp.clip();
	 pp.replace("\"", "\\\"");
	 pp.put();
         pp.clear();
	 pp.add("(mm.workspace() == \"");
	 pp.get();
	 pp.add("\")");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }

       //--------------------------------
       /* begins with test */
       if (pp.workspace() == "<")
       {
         pp.clear();
         pp.readUntil(cin, ">", "\\>");
         if (!pp.endsWith(">"))
         {
           ssErrors << "unterminated begins with test: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         pp.clip();
	 /* escape double quotes */
	 pp.replace("\"", "\\\"");
	 pp.put();
         pp.clear();
	 pp.add("(mm.beginsWith(\"");
	 pp.get();
	 pp.add("\"))");
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }
       
       if (pp.workspace() == ("["))
       {
         pp.clear();
         pp.readUntil(cin, "]", "\\]");
         if (!pp.endsWith("]"))
         {
           ssErrors << "unterminated class: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         pp.clip();
         pp.put();
         pp.clear();
         pp.add("class|");
         pp.push();
       }

       if (pp.workspace() == "'")
       {
         pp.clear();
         pp.readUntil(cin, "'", "\\'");
         if (!pp.endsWith("'"))
         {
           ssErrors << "unterminated quote: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         pp.clip();
	 if (pp.workspace() == "")
	 { 
           ssWarnings << "empty quoted text: ";
           ssWarnings << " (line " << iLineNumber << ")" << "\n";
         }

	 pp.replace("\"", "\\\"");
         pp.put();
         pp.clear();
         pp.add("quoted-text|");
         pp.push();
       }

       if (pp.workspace() == "#")
       {
	 /* escape double quotes */
         pp.clear();
         pp.readUntil(cin, "#", "\\#");
         if (!pp.endsWith("#"))
         {
           ssErrors << "unterminated comment: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         pp.clip();
	 if (pp.workspace() == "")
	 { 
           ssWarnings << "empty comment: ";
           ssWarnings << " (line " << iLineNumber << ")" << "\n";
           pp.put();
           pp.clear();
         }

	 pp.replace("\"", "\\\"");
	 pp.put();
         pp.clear();

	 pp.add("/*");
         pp.get();
         pp.add("*/");
         pp.put();
         pp.clear();
         pp.add("comment|");
         pp.push();

       }

       if (pp.workspace() == "+")
       {
         pp.readWhile(cin, "+");
	 pp.put();
	 pp.clear();
         pp.add("word|");
         pp.push();
       }

       if (pp.workspace() == "-")
       {
         pp.readWhile(cin, "-");
	 pp.put();
	 pp.clear();
         pp.add("word|");
         pp.push();
       }

       if (pp.workspace() == "\\")
       {
         pp.clear();
         pp.add("back-slash");
         pp.push();
       }

       if (pp.isLetter())
       {
         pp.readWhile(cin, "[:letter:]");       
         pp.put();
         pp.clear();
         pp.add("word|");
         pp.push();
       }
       
       if (pp.isSpace())
       {
         pp.readWhile(cin, "[:space:]");       
         pp.clear();
       }

       bool bReduction = true;
       while (bReduction)
       {
                  
        bReduction = false;

               
         pp.pop();
     
         //-------------------------------------------
         //-- 
         if ((pp.workspace() == "class|"))
         {
           pp.clear();
           pp.get();
  
           if ((pp.workspace() == ":unicode:"))     
           {       
             pp.clear();
             pp.add("mm.isUnicode()");
             pp.put();
           }
           else if ((pp.workspace() == ":space:"))     
           {       
             pp.clear();
             pp.add("mm.isSpace()");
             pp.put();
           }
           else if ((pp.workspace() == ":digit:"))     
           {         
             pp.clear();
             pp.add("mm.isDigit()");
             pp.put();
           }
           else if ((pp.workspace() == ":letter:"))       
           {         
             pp.clear();
             pp.add("mm.isLetter()");
             pp.put();
           }
           else
           {
             ssErrors << "unrecognized character class";
             ssErrors << "[" << pp.workspace() << "]" << endl;
             ssErrors << "legal classes [:space:], [:digit:], [:letter:]" << endl;
           }

 	   pp.clear();
           pp.add("test|");
           bReduction = true;
        } //-- if class

        if (bDebug)
         { cout << pp.printState(); }

        //------------------------------------

        pp.pop();

        //------------------------------------
	/* Errors */
        if (pp.workspace() == "quoted-text|close-brace|") 
        {
          pp.clear();
	  pp.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << pp.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          pp.clear();
          pp.get();
	  pp.add(" #*** missing semi-colon ? ***#");
          pp.newline();
	  pp.add("}");
          pp.put();
          pp.clear();
          pp.add("quoted-text|close-brace|");
        }
	
        //------------------------------------
	/* Errors */
        if (pp.workspace() == "word|close-brace|") 
        {
          pp.clear();
	  pp.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << pp.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          pp.clear();
          pp.get();
	  pp.add(" #*** missing semi-colon ? ***#");
          pp.newline();
	  pp.add("}");
          pp.put();
          pp.clear();
          pp.add("word|close-brace|");
        }

	//------------------------------------
	/* Errors */
        if (pp.workspace() == "word|word|") 
        {
          pp.clear();
	  pp.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << pp.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          pp.clear();
          pp.get();
	  pp.add(" #*** missing semi-colon ? ***#");
          pp.newline();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("word|word|");
        }

	//------------------------------------
	/* Errors */
        if (pp.workspace() == "test|word|") 
        {
          pp.clear();
	  pp.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing open brace after '" << pp.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          pp.clear();
          pp.get();
	  pp.add(" #*** missing open brace ? ***#");
          pp.newline();
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("test|word|");
        }

	if ((pp.workspace() == "comment|command-set|") ||
            (pp.workspace() == "command-set|comment|"))
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

	if ((pp.workspace() == "comment|command|") ||
            (pp.workspace() == "command|comment|"))
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

        if ((pp.workspace() == "comment|test|") ||
            (pp.workspace() == "test|comment|"))
        {
          pp.clear();
          pp.get();
	  pp.add(" ");
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("test|");
          pp.push();
          bReduction = true;
        }

        if (pp.workspace() == "not|test|")
        {
          pp.clear();
	  pp.add("!");
          pp.incrementTape();
          pp.get();
          pp.decrementTape();
          pp.put();
          pp.clear();
          pp.add("test|");
          pp.push();
          bReduction = true;
        }
	
        if ((pp.workspace() == "command-set|command|"))
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

        if ((pp.workspace() == "command|command|"))
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

       //-------------------------------------------
       /*  allow multiple tests for one block, for example
           /noun|verb|/
           /article|noun|verb/ { clear; add 'sentence'; push; }
        */

       if ((pp.workspace() == "test|test|"))
       {
         pp.clear();
         pp.get();
         pp.add(" ||");
         pp.newline();
	 pp.add("    ");
         pp.incrementTape();
         pp.get();
         pp.decrementTape();
         pp.put();
         pp.clear();
         pp.add("test|");
         pp.push();
       }
      
        if ((pp.workspace() == "word|comment|"))
        {
          pp.clear();

          ssWarnings << "badly placed comment: ";
          ssWarnings << " (line " << iLineNumber << ")" << "\n";

          pp.add("word|");
          pp.push();
          bReduction = true;

        } //--if word, comment 
        
        if ((pp.workspace() == "word|semi-colon|"))
        {
          pp.clear();
          pp.get();


          if ((pp.workspace() == "print"))
          {
            pp.clear();
            pp.add("mm.print();");
          }
          else if ((pp.workspace() == "flag"))
          {
            pp.clear();
            pp.add("mm.setFlag();");
          }
          else if ((pp.workspace() == "crash"))
          {
            pp.clear();
            pp.add("exit(-1);");
          }
          else if ((pp.workspace() == "clear"))
          {
            pp.clear();
            pp.add("mm.clear();");
          }
          else if ((pp.workspace() == "read"))
          {
            pp.clear();
	    /* if the script is in a stack reduction loop, it shouldnt
	     * read another character from standard in */
            pp.add("if (!mm.stackFlag())"); pp.newline();
	    pp.add("{"); pp.newline();
	    pp.add("  mm.readNext(cin);"); pp.newline();
	    pp.add("}");
          }
          else if ((pp.workspace() == "push"))
          {
            pp.clear();
            pp.add("mm.push();");
          }
          else if ((pp.workspace() == "pop"))
          {
            pp.clear();
            pp.add("mm.pop();");
          }
          else if ((pp.workspace() == "put"))
          {
            pp.clear();
            pp.add("mm.put();");            
          }
          else if ((pp.workspace() == "get"))
          {
            pp.clear();
            pp.add("mm.get();");
          }
          else if ((pp.workspace() == "++"))
          {
            pp.clear();
            pp.add("mm.incrementTape();");
          }
          else if ((pp.workspace() == "--"))
          {
            pp.clear();
            pp.add("mm.decrementTape();");
          }
          else if ((pp.workspace() == "newline"))
          {
            pp.clear();
            pp.add("mm.newline();");
          }
          else if ((pp.workspace() == "indent"))
          {
            pp.clear();
            pp.add("mm.indent();");
          }
          else if ((pp.workspace() == "clip"))
          {
            pp.clear();
            pp.add("mm.clip();");
          }
          else if ((pp.workspace() == "state"))
          {
            pp.clear();
            pp.add("cout << mm.printState();");
          }
          else if ((pp.workspace() == "add"))
          {
	    pp.add(";");
	    pp.add(" # command requires argument #");
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'add' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((pp.workspace() == "while"))
          {
	    pp.add(";");
	    pp.add(" # command requires argument #");
            ssErrors << "incorrect syntax: ";
            ssErrors << "'while' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((pp.workspace() == "whilenot"))
          {
	    pp.add(";");
	    pp.add(" # command requires argument #");
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'whilenot' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((pp.workspace() == "until"))
          {
	    pp.add(";");
	    pp.add(" # command requires argument #");
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'until' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else
          {
            ssErrors << "unrecognized command: '" << pp.workspace();
            ssErrors << "' (line " << iLineNumber << ") \n";
            ssErrors << "legal commands: \n" << ssCommandList.str(); 
	    pp.add(";");
	    pp.add(" #-- unknown command --#");
          }
          pp.put();
          pp.clear();

          pp.add("command|");
          pp.push();
          bReduction = true;

        } //--if word,semi-colon 

        pp.pop();

        if ((pp.workspace() == "word|quoted-text|semi-colon|"))
        {
          pp.clear();
          pp.get();

          if ((pp.workspace() == "add"))
          { 
            pp.clear();
            pp.add("mm.add(\"");
            pp.incrementTape();
            pp.get();
            pp.decrementTape();
            pp.add("\");");
            pp.put();            
          }
	  else if ((pp.workspace() == "until"))
          { 
            pp.clear();
            pp.add("mm.readUntil(cin, \"");
            pp.incrementTape();
            pp.get();
            pp.decrementTape();
            pp.add("\");");
            pp.put();            
          }
	  else if ((pp.workspace() == "while"))
          { 
            pp.clear();
            pp.add("mm.readWhile(cin, \"");
            pp.incrementTape();
            pp.get();
            pp.decrementTape();
            pp.add("\");");
            pp.put();            
          }
	  else if ((pp.workspace() == "whilenot"))
          { 
            pp.clear();
            pp.add("mm.readWhileNot(cin, \"");
            pp.incrementTape();
            pp.get();
            pp.decrementTape();
            pp.add("\");");
            pp.put();            
          }
	  else if 
	  ((pp.workspace() == "crash") ||
	   (pp.workspace() == "clip") ||
	   (pp.workspace() == "flag") ||
	   (pp.workspace() == "read") ||
	   (pp.workspace() == "print") ||
	   (pp.workspace() == "push") ||
	   (pp.workspace() == "pop") ||
	   (pp.workspace() == "get") ||
	   (pp.workspace() == "put") ||
	   (pp.workspace() == "newline") ||
	   (pp.workspace() == "state") ||
	   (pp.workspace() == "indent"))
          { 
	    pp.add(";");
	    pp.add(" #-- command does not have argument --#");
            ssErrors << "incorrect syntax: ";
            ssErrors << "the command do an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else
          {
            ssErrors << "unrecognized command: '" << pp.workspace();
            ssErrors << "' (line " << iLineNumber << ")" << "\n";
	    pp.add(";");
	    pp.add(" #-- unknown command --#");
	  }

          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;

        } //--if word, text, semi-colon

        pp.pop();

	/*  two parameters */
        if ((pp.workspace() == "word|quoted-text|quoted-text|semi-colon|"))
        {
          pp.clear();
          pp.get();

	  if ((pp.workspace() == "until"))
          { 
            pp.clear();
            pp.add("mm.readUntil(cin, \"");
            pp.incrementTape();
            pp.get();
	    pp.add("\", \"");
            pp.incrementTape();
            pp.get();
            pp.add("\");");
            pp.decrementTape();
            pp.decrementTape();
            pp.put();            
          }
	  else if ((pp.workspace() == "replace"))
          { 
            pp.clear();
            pp.add("mm.replace(\"");
            pp.incrementTape();
            pp.get();
	    pp.add("\", \"");
            pp.incrementTape();
            pp.get();
            pp.add("\");");
            pp.decrementTape();
            pp.decrementTape();
            pp.put();            
          }
          else
          {
            ssErrors << "unrecognized command: " << pp.workspace();
            ssErrors << " (line " << iLineNumber << ") \n";
            ssErrors << "legal commands: \n";
	    ssErrors << ssCommandList.str();
	    pp.add(";");
	    pp.add(" # unknown command #");
	  }

          pp.clear();
          pp.add("command|");
          pp.push();
          bReduction = true;

        } //--if word, text, text, semi-colon

	
        if ((pp.workspace() == "test|open-brace|command|close-brace|") ||
            (pp.workspace() == "test|open-brace|command-set|close-brace|"))
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
          { cout << pp.printState(); }

       } //-- while a reduction

    } //-- for each letter
    
    if (pp.stacksize() != 1)
    {
      pp.pop();

      if ((pp.workspace() == "quoted-text|") ||
	  (pp.workspace() == "word|"))
      {
         pp.clear();
         pp.get();
         ssErrors << "incorrect syntax: ";
         ssErrors << "missing semicolon after '" << pp.workspace() << "' ?";
         ssErrors << " (line " << iLineNumber << ")" << "\n";
         pp.clear();
      }

      cout << "*** error parsing script (no start symbol) ***\n\n";
      if (ssErrors.str().length() > 0)
      {
        cout << "--errors--" << endl;
        cout << ssErrors.str();
      }

      if (ssWarnings.str().length() > 0)
      {
        cout << "--warnings--" << endl;
        cout << ssWarnings.str();
      }

      cout << "*** final parse state ***" << endl;
      cout << pp.printState();
      exit(-1);
    }
    
    pp.clear();
    pp.pop();

    if ((pp.workspace() != "command|") &&
        (pp.workspace() != "command-set|"))
    {
      cout << "*** error parsing script (neither command nor list of commands) ***\n\n";
      if (ssErrors.str().length() > 0)
      {
        cout << "--errors--" << endl;
        cout << ssErrors.str();
      }

      if (ssWarnings.str().length() > 0)
      {
        cout << "--warnings--" << endl;
        cout << ssWarnings.str();
      }

      cout << "*** final parse state ***" << endl;
      cout << pp.printState();
      exit(-1);
    }
    
    if (ssErrors.str().length() > 0)  
    {
      cout << "*** error in script \n\n";
      cout << ssErrors.str();

      if (ssWarnings.str().length() > 0)
      {
        cout << "Warnings:" << endl;
        cout << ssWarnings.str();
      }

      pp.clear();
      pp.newline();
      pp.get();
      pp.print();
      //cout << "*** final parse state ***" << endl;
      //cout << pp.printState();
      exit(-1);
    }

    cout << "//-- script successfully parsed." << endl;
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
    pp.add("#include <iostream>"); pp.newline();
    pp.add("#include <fstream>"); pp.newline();
    pp.add("#include <vector>"); pp.newline();
    pp.add("#include <stack>"); pp.newline();
    pp.add("#include <string>"); pp.newline();
    pp.add("#include <sstream>"); pp.newline();
    pp.add("#include <ctype.h>"); pp.newline();
    pp.add("#include \"Machine.h\""); pp.newline();

    pp.newline(); pp.newline();

    pp.newline(); pp.newline();

    pp.add("  int main(int argc, char* argv[])"); 
    pp.newline();
    pp.add("  {"); pp.newline();
    pp.add("    string sbUsageMessage(\"\");"); 
    pp.newline();
    pp.add("    sbUsageMessage.append(\"usage: \");"); pp.newline();
    pp.add("    sbUsageMessage.append(\"\\n\");"); pp.newline();
    pp.add("    if (argc == 1)"); pp.newline(); 
    pp.add("    {"); pp.newline();
    pp.add("    }"); pp.newline();
    pp.add("    else"); pp.newline();
    pp.add("    {"); pp.newline();
    pp.add("    }"); pp.newline();
    pp.newline();
    pp.add("    Machine mm;"); pp.newline();

    pp.add("    string ssErrors(\"\");"); pp.newline();
    pp.add("    string sbPartial(\"\");"); pp.newline();        
    pp.add("    bool bReduction = false;"); pp.newline();
    pp.add("    bool bDebug = false;"); pp.newline();
    pp.add("    char cCurrent;"); pp.newline();
    pp.newline(); pp.newline();
    pp.add("    mm.readNext(cin);"); pp.newline();
    pp.add("    mm.clear();"); pp.newline();
    pp.add("    while (!cin.eof())"); pp.newline();
    pp.add("    {"); pp.newline();             
    //pp.add("       mm.readNext(cin);"); pp.newline(); 
    pp.add("       if (bDebug)"); pp.newline();
    pp.add("       {"); pp.newline();
    pp.add("         cout << \"character:\" << cCurrent << endl; ");
    pp.newline();
    pp.add("         cout << mm.printState();"); pp.newline();
    pp.add("       }"); pp.newline();
    pp.add("       mm.setFlag();"); pp.newline();
    pp.add("       while (mm.stackFlag())"); pp.newline();
    pp.add("       {"); pp.newline();
    pp.add("          mm.resetFlag();"); pp.newline();

    //-------------------------------------        
    pp.get();
    pp.newline();
    pp.add("       } //-- while reduction"); pp.newline();
    pp.add("     } //-- for each letter"); pp.newline();
    pp.add("  } //-- main()"); pp.newline();
 
    pp.print();

    if (ssWarnings.str().length() > 0)
    {
      cout << "//--Warnings generated by parser: \n";
      cout << "/* \n" << ssWarnings.str() << "\n*/" << endl;
    }  

    if (bDebug)
     { cout << pp.printState(); }

    

  } //-- main()
  
