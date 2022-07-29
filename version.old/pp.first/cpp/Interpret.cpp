
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
#include "Interpret.h" 

using namespace std;
  
  //--------------------------------------------
  /** this program uses the Machine class to parse a script and 
   *  
   */ 
  Interpret::Interpret()
  {
    Program program;
    vector<string> parseErrors;
    vector<string> parseWarnings:
  }

  //--------------------------------------------
  string Interpret::toString()
  {
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "--errors during parsing--" << endl;
    for (int ii = 0; ii < this->parseErrors.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseErrors.at(ii).toString() << endl;
    }
    
    ssReturn << "--warnings during parsing--" << endl;
    for (int ii = 0; ii < this->parseWarnings.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseWarnings.at(ii).toString() << endl;
    }

    ssReturn << this->program.toString() << endl;
    return ssReturn.str();

  } //-- method: toString


  //--------------------------------------------
  string Interpret::print()
  {
  } //-- method:

  void Interpret::execute()
  {
  } //-- method: execute

  //--------------------------------------------
  /* parses and compiles the instructions contained in the input script.
   * These instructions are saved in the instruction vector */
  void Interpret::parse(istream& inputstream)
  {
    
    string sUsageMessage("");
    string sMessage("");
    bool bDebug = false;


    //-- a machine to parse the script
    Machine pp;

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
    //inputstream.get(cCurrent);

    pp.readNext(inputstream);
    if (bDebug)
      { cout << "initial state" << pp.printState(); }
    pp.clear();

    
    while (!inputstream.eof())
    {             
       pp.clear();
       pp.readNext(inputstream);

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
         pp.readUntil(inputstream, "/", "\\/");
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
         pp.readUntil(inputstream, ">", "\\>");
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
         pp.readUntil(inputstream, "]", "\\]");
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
         pp.readUntil(inputstream, "'", "\\'");
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
         pp.readUntil(inputstream, "#", "\\#");
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
         pp.readWhile(inputstream, "+");
	 pp.put();
	 pp.clear();
         pp.add("word|");
         pp.push();
       }

       if (pp.workspace() == "-")
       {
         pp.readWhile(inputstream, "-");
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
         pp.readWhile(inputstream, "[:letter:]");       
         pp.put();
         pp.clear();
         pp.add("word|");
         pp.push();
       }
       
       if (pp.isSpace())
       {
         pp.readWhile(inputstream, "[:space:]");       
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
       
    //-------------------------------------        
    pp.get();
    pp.print();

    if (ssWarnings.str().length() > 0)
    {
      cout << "//--Warnings generated by parser: \n";
      cout << "/* \n" << ssWarnings.str() << "\n*/" << endl;
    }  

    if (bDebug)
     { cout << pp.printState(); }

    

  } //-- method: parse

 
