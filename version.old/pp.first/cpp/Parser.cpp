
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
#include <time.h>
#include "Parser.h" 

using namespace std;
  
  //--------------------------------------------
  /** this program uses the Machine class to parse a script and 
   *  
   */ 
  Parser::Parser()
  {
    Program program;
    Machine mm;
    vector<string> parseErrors;
    vector<string> parseWarnings;
  }

  //--------------------------------------------
  string Parser::toString()
  {
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "--errors during parsing--" << endl;
    for (int ii = 0; ii < this->parseErrors.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseErrors.at(ii) << endl;
    }
    
    ssReturn << "--warnings during parsing--" << endl;
    for (int ii = 0; ii < this->parseWarnings.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseWarnings.at(ii) << endl;
    }

    ssReturn << "--parsing time--" << endl;
    ssReturn << this->parseTime() << endl;
    ssReturn << this->program.toString() << endl;
    return ssReturn.str();

  } //-- method: toString

  //--------------------------------------------
  string Parser::showErrors()
  {
    stringstream ssReturn;
    for (int ii = 0; ii < this->parseErrors.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseErrors.at(ii) << endl;
    }
    return ssReturn.str();
  } //-- method:

  //--------------------------------------------
  //
  string Parser::showWarnings()
  {
    stringstream ssReturn;
    for (int ii = 0; ii < this->parseWarnings.size(); ii++)
    {
      ssReturn << ii << ":" << this->parseWarnings.at(ii) << endl;
    }
    return ssReturn.str();
  } //-- method:

  //--------------------------------------------
  string Parser::print()
  {
  } //-- method:

  //--------------------------------------------
  Program Parser::getProgram()
  {
    return this->program;
  } //-- method:

  //--------------------------------------------
  Machine Parser::getMachine()
  {
    return this->mm;
  } //-- method:
  
  bool Parser::parse(istream& inputstream)
  {
    this->parse(inputstream, false);
  }

  long Parser::parseTime()
  {
    return this->parseDuration;
  }

  //--------------------------------------------
  /* parses and compiles the instructions contained in the input script.
   * These instructions are saved in the instruction vector */
  bool Parser::parse(istream& inputstream, bool bDebug)
  {

    clock_t tStartParsing;
    clock_t tEndParsing;
    tStartParsing = clock();
    //while (clock() < tStartParsing + 1000) {}
    //tEndParsing = clock();
    //cout << "cps " << CLOCKS_PER_SEC << endl;
    //cout << "start:" << tStartParsing << "end:" << tEndParsing;

    
    string sUsageMessage("");
    string sMessage("");

    string sParameterA;
    string sParameterB;

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
    //-- used to calculate jumps after if blocks
    int iJump = 0;

    char cCurrent;
    //inputstream.get(cCurrent);

    this->mm.readNext(inputstream);
    if (bDebug)
      { cout << "initial state" << this->mm.printState(); }
    this->mm.clear();

    
    while (!inputstream.eof())
    {             
       this->mm.clear();
       this->mm.readNext(inputstream);

       if (this->mm.workspace() == "\n")
         { iLineNumber++; }

       if (bDebug)
        { cout << this->mm.printState(); }

       if (this->mm.workspace() == ";")
       {
         this->mm.clear();
         this->mm.add("semi-colon|");
         this->mm.push();
       }

       if (this->mm.workspace() == "!")
       {
         this->mm.clear();
         this->mm.add("not|");
         this->mm.push();
       }

       if (this->mm.matches("{"))
       {
         this->mm.clear();
         this->mm.add("open-brace|");
         this->mm.push();
       }

       if (this->mm.matches("}"))
       {
         this->mm.clear();
         this->program.addInstruction("nop");
         this->mm.add("close-brace|");
         this->mm.push();
       }

       //--------------------------------
       /* test */
       if (this->mm.workspace() == "/")
       {
         /* escape double quotes */
         this->mm.clear();
         this->mm.readUntil(inputstream, "/", "\\/");
         if (!this->mm.endsWith("/"))
         {
           ssErrors << "unterminated test: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         this->mm.clip();
         this->mm.replace("\"", "\\\"");
         Instruction inst("test-is", this->mm.workspace());
         inst.setShortJump(this->program.size());
         this->program.addInstruction(inst);
       
         this->mm.clear();
         char sCurrentInstruction[100];
	 sprintf(sCurrentInstruction, "%d", this->program.size() - 1);
         this->mm.add(sCurrentInstruction);
         this->mm.add(":");
	 this->mm.put();
         this->mm.clear();
         this->mm.add("test|");
         this->mm.push();
       }

       //--------------------------------
       /* begins with test */
       if (this->mm.workspace() == "<")
       {
         this->mm.clear();
         this->mm.readUntil(inputstream, ">", "\\>");
         if (!this->mm.endsWith(">"))
         {
           ssErrors << "unterminated begins with test: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         this->mm.clip();
              /* escape double quotes */
         this->mm.replace("\"", "\\\"");
         Instruction inst("test-begins-with", this->mm.workspace());
         inst.setShortJump(this->program.size());
         this->program.addInstruction(inst);

         this->mm.clear();
         char sCurrentInstruction[100];
	 sprintf(sCurrentInstruction, "%d", this->program.size() - 1);
         this->mm.add(sCurrentInstruction);
         this->mm.add(":");
	 this->mm.put();
         this->mm.clear();
         this->mm.add("test|");
         this->mm.push();
       }
       
       //-----------------------------
       if (this->mm.workspace() == ("["))
       {
         this->mm.clear();
         this->mm.readUntil(inputstream, "]", "\\]");
         if (!this->mm.endsWith("]"))
         {
           ssErrors << "unterminated class: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         this->mm.clip();
         this->mm.put();
         this->mm.clear();
         this->mm.add("class|");
         this->mm.push();
       }

       //-----------------------------
       if (this->mm.workspace() == "'")
       {
         this->mm.clear();
         this->mm.readUntil(inputstream, "'", "\\'");
         if (!this->mm.endsWith("'"))
         {
           ssErrors << "unterminated quote: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         this->mm.clip();
         if (this->mm.workspace() == "")
         { 
           ssWarnings << "empty quoted text: ";
           ssWarnings << " (line " << iLineNumber << ")" << "\n";
         }

         this->mm.replace("\"", "\\\"");
         this->mm.put();
         this->mm.clear();
         this->mm.add("quoted-text|");
         this->mm.push();
       }

       //-----------------------------
       if (this->mm.workspace() == "#")
       {
         /* escape double quotes */
         this->mm.clear();
         this->mm.readUntil(inputstream, "#", "\\#");
         if (!this->mm.endsWith("#"))
         {
           ssErrors << "unterminated comment: ";
           ssErrors << " (line " << iLineNumber << ")" << "\n";
         }
         this->mm.clip();
         if (this->mm.workspace() == "")
         { 
           ssWarnings << "empty comment: ";
           ssWarnings << " (line " << iLineNumber << ")" << "\n";
           this->mm.put();
           this->mm.clear();
         }

         this->mm.replace("\"", "\\\"");
         this->mm.put();
         this->mm.clear();

         this->mm.add("comment|");
         this->mm.push();

       }

       if (this->mm.workspace() == "+")
       {
         this->mm.readWhile(inputstream, "+");
         this->mm.put();
         this->mm.clear();
         this->mm.add("word|");
         this->mm.push();
       }

       if (this->mm.workspace() == "-")
       {
         this->mm.readWhile(inputstream, "-");
         this->mm.put();
         this->mm.clear();
         this->mm.add("word|");
         this->mm.push();
       }

       if (this->mm.workspace() == "\\")
       {
         this->mm.clear();
         this->mm.add("back-slash|");
         this->mm.push();
       }

       if (this->mm.isLetter())
       {
         this->mm.readWhile(inputstream, "[:letter:]");       
         this->mm.put();
         this->mm.clear();
         this->mm.add("word|");
         this->mm.push();
       }
       
       if (this->mm.isSpace())
       {
         this->mm.readWhile(inputstream, "[:space:]");       
         this->mm.clear();
       }

       bool bReduction = true;
       while (bReduction)
       {
                  
        bReduction = false;

               
         this->mm.pop();
     
         //-------------------------------------------
         //-- 
         if ((this->mm.workspace() == "class|"))
         {
           this->mm.clear();
           this->mm.get();
  
           if ((this->mm.workspace() == ":unicode:"))     
           {       
             this->mm.clear();
             this->mm.put();
           }
           else if ((this->mm.workspace() == ":space:"))     
           {       
             this->mm.clear();
             this->mm.put();
           }
           else if ((this->mm.workspace() == ":digit:"))     
           {         
             this->mm.clear();
             this->mm.put();
           }
           else if ((this->mm.workspace() == ":letter:"))       
           {         
             this->mm.clear();
             this->mm.put();
           }
           else
           {
             ssErrors << "unrecognized character class";
             ssErrors << "[" << this->mm.workspace() << "]" << endl;
             ssErrors << "legal classes [:space:], [:digit:], [:letter:]" << endl;
           }

            this->mm.clear();
           this->mm.add("test|");
           bReduction = true;
        } //-- if class

        if (bDebug)
         { cout << this->mm.printState(); }

        //------------------------------------

        this->mm.pop();

        //------------------------------------
        /* Errors */
        if (this->mm.workspace() == "quoted-text|close-brace|") 
        {
          this->mm.clear();
          this->mm.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << this->mm.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          this->mm.clear();
          this->mm.add("quoted-text|close-brace|");
        }
        
        //------------------------------------
        /* Errors */
        if (this->mm.workspace() == "word|close-brace|") 
        {
          this->mm.clear();
          this->mm.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << this->mm.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          this->mm.clear();
          this->mm.add("word|close-brace|");
        }

        //------------------------------------
        /* Errors */
        if (this->mm.workspace() == "word|word|") 
        {
          this->mm.clear();
          this->mm.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing semicolon after '" << this->mm.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          this->mm.clear();
          this->mm.add("word|word|");
        }

        //------------------------------------
        /* Errors */
        if (this->mm.workspace() == "test|word|") 
        {
          this->mm.clear();
          this->mm.get();
          ssErrors << "incorrect syntax: ";
          ssErrors << "missing open brace after '" << this->mm.workspace() << "' ?";
          ssErrors << " (line " << iLineNumber << ")" << "\n";
          this->mm.clear();
          this->mm.add("test|word|");
        }

        if ((this->mm.workspace() == "comment|command-set|") ||
            (this->mm.workspace() == "command-set|comment|"))
        {
          this->mm.clear();
          this->mm.add("command-set|");
          this->mm.push();
          bReduction = true;
        }

        if ((this->mm.workspace() == "comment|command|") ||
            (this->mm.workspace() == "command|comment|"))
        {
          this->mm.clear();
          this->mm.add("command|");
          this->mm.push();
          bReduction = true;
        }

        if ((this->mm.workspace() == "comment|test|") ||
            (this->mm.workspace() == "test|comment|"))
        {
          this->mm.clear();
          this->mm.add("test|");
          this->mm.push();
          bReduction = true;
        }

        if (this->mm.workspace() == "not|test|")
        {
          this->mm.clear();
          this->mm.add("test|");
          this->mm.push();
          //? this->program.toggleNegation(...)
          bReduction = true;
        }
        
        if ((this->mm.workspace() == "command-set|command|"))
        {
          iJump++;
          this->mm.clear();
          this->mm.add("command-set|");
          this->mm.push();
          bReduction = true;
        }

        if ((this->mm.workspace() == "command|command|"))
        {
          /* jump counter for if tests */
          iJump++;
          this->mm.clear();
          this->mm.add("command-set|");
          this->mm.push();
          bReduction = true;
        }

       //-------------------------------------------
       /*  allow multiple tests for one block, for example
           /noun|verb|/
           /article|noun|verb/ { clear; add 'sentence'; push; }
        */

       if ((this->mm.workspace() == "test|test|"))
       {
	 /* add the jump pointers */
         this->mm.clear();
	 this->mm.get();
	 this->mm.incrementTape();
	 this->mm.get();
	 this->mm.decrementTape();
	 this->mm.put();
     this->mm.clear();

     this->mm.add("test|");
     this->mm.push();
     this->mm.clear();
          
          int iInstruction = this->program.size() - 1;
          this->mm.get();
          string sJumpPointers = this->mm.workspace();

    Instruction instruc;
     
       while (sJumpPointers.find(":") != string::npos)
	   {
         int iFirst = atoi(sJumpPointers.c_str()); 
         //cout << "jump pointers=" << sJumpPointers << endl;
 	     //cout << "iFirst=" << iFirst << endl;
         //cout << "iInstruction=" << iInstruction << endl;

         this->program.setShortJump(iFirst, this->program.getInstruction(iFirst).getShortJump() + 1);
         sJumpPointers = sJumpPointers.substr(sJumpPointers.find(":") + 1);

        } //--while
         
       } //--if test,test
      
        if ((this->mm.workspace() == "word|comment|"))
        {
          this->mm.clear();

          ssWarnings << "badly placed comment: ";
          ssWarnings << " (line " << iLineNumber << ")" << "\n";

          this->mm.add("word|");
          this->mm.push();
          bReduction = true;

        } //--if word, comment 
        
        if ((this->mm.workspace() == "word|semi-colon|"))
        {
          this->mm.clear();
          this->mm.get();


          if ((this->mm.workspace() == "print"))
          {
            this->mm.clear();
            this->program.addInstruction("print");
          }
          else if ((this->mm.workspace() == "flag"))
          {
            this->mm.clear();
            this->program.addInstruction("flag");
          }
          else if ((this->mm.workspace() == "crash"))
          {
            this->mm.clear();
            this->program.addInstruction("crash");
          }
          else if ((this->mm.workspace() == "clear"))
          {
            this->mm.clear();
            this->program.addInstruction("clear");
          }
          else if ((this->mm.workspace() == "read"))
          {
            this->mm.clear();
            this->program.addInstruction("read");
            /* if the script is in a stack reduction loop, it shouldnt
             * read another character from standard in */
          }
          else if ((this->mm.workspace() == "push"))
          {
            this->mm.clear();
            this->program.addInstruction("push");
          }
          else if ((this->mm.workspace() == "pop"))
          {
            this->mm.clear();
            this->program.addInstruction("pop");
          }
          else if ((this->mm.workspace() == "put"))
          {
            this->mm.clear();
            this->program.addInstruction("put");
          }
          else if ((this->mm.workspace() == "get"))
          {
            this->mm.clear();
            this->program.addInstruction("get");
          }
          else if ((this->mm.workspace() == "++"))
          {
            this->mm.clear();
            this->program.addInstruction("++");
          }
          else if ((this->mm.workspace() == "--"))
          {
            this->mm.clear();
            this->program.addInstruction("--");
          }
          else if ((this->mm.workspace() == "newline"))
          {
            this->mm.clear();
            this->program.addInstruction("newline");
          }
          else if ((this->mm.workspace() == "indent"))
          {
            this->mm.clear();
            this->program.addInstruction("indent");
          }
          else if ((this->mm.workspace() == "clip"))
          {
            this->mm.clear();
            this->program.addInstruction("clip");
          }
          else if ((this->mm.workspace() == "state"))
          {
            this->mm.clear();
            this->program.addInstruction("state");
          }
          else if ((this->mm.workspace() == "add"))
          {
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'add' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((this->mm.workspace() == "while"))
          {
            ssErrors << "incorrect syntax: ";
            ssErrors << "'while' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((this->mm.workspace() == "whilenot"))
          {
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'whilenot' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else if ((this->mm.workspace() == "until"))
          {
            ssErrors << "incorrect syntax: ";
            ssErrors << "the 'until' command requires an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else
          {
            ssErrors << "unrecognized command: '" << this->mm.workspace();
            ssErrors << "' (line " << iLineNumber << ") \n";
            ssErrors << "legal commands: \n" << ssCommandList.str(); 
          }
          this->mm.put();
          this->mm.clear();

          this->mm.add("command|");
          this->mm.push();
          bReduction = true;

        } //--if word,semi-colon 

        this->mm.pop();

        if ((this->mm.workspace() == "word|quoted-text|semi-colon|"))
        {
          this->mm.clear();
          this->mm.get();

          if ((this->mm.workspace() == "add"))
          { 
            
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            this->mm.decrementTape();
            this->program.addInstruction("add", this->mm.workspace());
            
            this->mm.clear();
          }
          else if ((this->mm.workspace() == "until"))
          { 
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            this->mm.decrementTape();
            this->program.addInstruction("until", this->mm.workspace());

            this->mm.clear();
          }
          else if ((this->mm.workspace() == "while"))
          {
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            this->mm.decrementTape();
            this->program.addInstruction("while", this->mm.workspace());
           
            this->mm.clear();
          }
          else if ((this->mm.workspace() == "whilenot"))
          { 
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            this->mm.decrementTape();
            this->program.addInstruction("whilenot", this->mm.workspace());

            this->mm.clear();
          }
          else if 
          ((this->mm.workspace() == "crash") ||
           (this->mm.workspace() == "clip") ||
           (this->mm.workspace() == "flag") ||
           (this->mm.workspace() == "read") ||
           (this->mm.workspace() == "print") ||
           (this->mm.workspace() == "push") ||
           (this->mm.workspace() == "pop") ||
           (this->mm.workspace() == "get") ||
           (this->mm.workspace() == "put") ||
           (this->mm.workspace() == "newline") ||
           (this->mm.workspace() == "state") ||
           (this->mm.workspace() == "indent"))
          { 
            this->mm.add(";");
            this->mm.add(" #-- command does not have argument --#");
            ssErrors << "incorrect syntax: ";
            ssErrors << "the command '" << this->mm.workspace() << "' does not require an argument.";
            ssErrors << " (line " << iLineNumber << ")" << "\n";
          }
          else
          {
            ssErrors << "unrecognized command: '" << this->mm.workspace();
            ssErrors << "' (line " << iLineNumber << ")" << "\n";
            this->mm.add(";");
            this->mm.add(" #-- unknown command --#");
          }

          this->mm.clear();
          this->mm.add("command|");
          this->mm.push();
          bReduction = true;

        } //--if word, text, semi-colon

        this->mm.pop();

        /*  two parameters */
        if ((this->mm.workspace() == "word|quoted-text|quoted-text|semi-colon|"))
        {
          this->mm.clear();
          this->mm.get();

          if ((this->mm.workspace() == "until"))
          { 
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            sParameterA = this->mm.workspace();
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            sParameterB = this->mm.workspace();
            this->mm.decrementTape();
            this->mm.decrementTape();
            this->mm.clear();

            this->program.addInstruction("until", sParameterA, sParameterB);

            this->mm.clear();
          }
          else if ((this->mm.workspace() == "replace"))
          { 
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            sParameterA = this->mm.workspace();
            this->mm.clear();
            this->mm.incrementTape();
            this->mm.get();
            sParameterB = this->mm.workspace();
            this->mm.decrementTape();
            this->mm.decrementTape();
            this->mm.clear();
           
            this->program.addInstruction("replace", sParameterA, sParameterB);

            this->mm.clear();
          }
          else
          {
            ssErrors << "unrecognized command: " << this->mm.workspace();
            ssErrors << " (line " << iLineNumber << ") \n";
            ssErrors << "legal commands: \n";
            ssErrors << ssCommandList.str();
          }

          this->mm.clear();
          this->mm.add("command|");
          this->mm.push();
          bReduction = true;

        } //--if word, text, text, semi-colon

        
        if ((this->mm.workspace() == "test|open-brace|command|close-brace|") ||
            (this->mm.workspace() == "test|open-brace|command-set|close-brace|"))
        {
          this->mm.clear();
          int iInstruction = this->program.size() - 1;
          this->mm.get();
          string sJumpPointers = this->mm.workspace();


      while (sJumpPointers.find(":") != string::npos)
	  {
            int iFirst = atoi(sJumpPointers.c_str()); 
            //cout << "jump pointers=" << sJumpPointers << endl;
 	    //cout << "iFirst=" << iFirst << endl;
            //cout << "iInstruction=" << iInstruction << endl;

            this->program.setJump(iFirst, iInstruction);
            sJumpPointers = sJumpPointers.substr(sJumpPointers.find(":") + 1);

          } //--while

          this->mm.clear();
          this->mm.add("command|");
          this->mm.push();
          bReduction = true;
        } //--if test, block

        this->mm.push();
        this->mm.push();
        this->mm.push();
        this->mm.push();

        if (bDebug)
          { cout << this->mm.printState(); }

       } //-- while a reduction

    } //-- for each letter

    tEndParsing = clock();
    this->parseDuration = (tEndParsing - tStartParsing);

    if (this->mm.stacksize() != 1)
    {
      this->mm.pop();

      if ((this->mm.workspace() == "quoted-text|") ||
          (this->mm.workspace() == "word|"))
      {
         this->mm.clear();
         this->mm.get();
         ssErrors << "incorrect syntax: ";
         ssErrors << "missing semicolon after '" << this->mm.workspace() << "' ?";
         ssErrors << " (line " << iLineNumber << ")" << "\n";
         this->mm.clear();
      }

      this->parseErrors.push_back(ssErrors.str());
      this->parseWarnings.push_back(ssWarnings.str());
      return false;
    }
    
    this->mm.clear();
    this->mm.pop();

    if ((this->mm.workspace() != "command|") &&
        (this->mm.workspace() != "command-set|"))
    {
      this->parseErrors.push_back(ssErrors.str());
      this->parseWarnings.push_back(ssWarnings.str());
      return false;
    }
    
    if (ssErrors.str().length() > 0)  
    {
      this->parseErrors.push_back(ssErrors.str());
      this->parseWarnings.push_back(ssWarnings.str());
      return false;
    }

    cout << "//-- script successfully parsed." << endl;
    this->mm.clear();
    //-------------------------------------        
    this->mm.get();
    this->mm.print();
       

    if (ssWarnings.str().length() > 0)
    {
      cout << "//--Warnings generated by parser: \n";
      cout << "/* \n" << ssWarnings.str() << "\n*/" << endl;
    }  

    if (bDebug)
     { cout << this->mm.printState(); }


    return true; 

  } //-- method: parse

 
