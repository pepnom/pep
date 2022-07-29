
 /**
 *  
 *  Is a virtual machine for parsing. It has some ideas
 *  drawn from the sed tool.
 *
 *  @author http://bumble.sf.net
 */
// good examples
// http://www.josuttis.com/libbook/i18n/loc1.cpp.html

#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <ctype.h>
#include "Tape.h" 

using namespace std;
 
  
class Machine 
{
  private:
   //--------------------------------------------
   vector<string> tokenstack;
   //--------------------------------------------
   Tape tape;
   //--------------------------------------------
   /* where the stack and tape are used */
   string workarea;
   //--------------------------------------------
   /* where input stream accumulates */
   string influx;
   //--------------------------------------------
   /* the next char of the input stream */
   char peep;
   //--------------------------------------------
   string lastOperation;

  public: 
   //--------------------------------------------
   Machine();
   //--------------------------------------------
   string getWorkspace();
   //--------------------------------------------
   string workspace();
   //--------------------------------------------
   string accumulator();
   //--------------------------------------------
   char peep();
   //--------------------------------------------
   bool peek();
   //--------------------------------------------
   /* reads while the peep is */
   void Machine::readWhile(istream& inputstream, string sWhile);
   //--------------------------------------------
   /* reads while the peep is not */
   void Machine::readWhileNot(istream& inputstream, string sWhileNot);
   //--------------------------------------------
   /* reads the next character from the input stream */
   void readNext(istream& inputstream);
   //--------------------------------------------
   /* reads until accumulator ends with string */
   void readUntil(istream& inputstream, string sTerminator);
   //--------------------------------------------
   void readUntil(istream& inputstream, string sTerminator, string sNotTerminator);
   //--------------------------------------------
   /* si el espai d'accumulacio termina amb */
   bool endsWith(string sFinal);
   //--------------------------------------------
   /** this method may not be necessary, can check with pops */
   int stacksize();
   //--------------------------------------------
   bool matches(string sTest);
   //--------------------------------------------
   /* determines if the workspace is a space character */
   bool isSpace();
   //--------------------------------------------
   /* determines if the workspace is a digit character */
   bool isDigit();
   //--------------------------------------------
   /* determines if the workspace is a letter character */
   bool isLetter();
   //--------------------------------------------
   bool isUnicode();
   //--------------------------------------------
   /* to allow simple pattern testing for literal values */
   bool workspaceInRange(char cStart, char cEnd);
   //--------------------------------------------
   /* to allow simple pattern testing for literal values */
   bool matches(char cStart, char cEnd);
   //--------------------------------------------
   /** decrements the pointer to the tape by one */
   void decrementTape();
   //--------------------------------------------
   /** increments the pointer to the tape by one */
   void incrementTape();
   //--------------------------------------------
   /** puts the workspace into the current item of the tape.
   *  The workspace is not changed  */
   void put();
   //--------------------------------------------
   /** gets the current item of the tape and adds it to
   *  the end of the workspace */
   void get();
   //--------------------------------------------
   /** inserts the last item of the stack at the front of the workspace,
   * adding a bar character "|" to separate the token. If the
   * stack is empty, there is no change to the machine.
   */
   void pop();
   //--------------------------------------------
   string replaceText(string sOriginal, string sReplace, string sReplacement);
   //--------------------------------------------
   /** pushes the contents of the workspace onto the stack.
   *  The first token on the workspace is deleted.
   */ 
   void push();
   //--------------------------------------------
   /* shifts the accumulator into the workspace */ 
   void shift();
   //--------------------------------------------
   /** prints the workspace to standard out */
   void print();
   //--------------------------------------------
   /** adds a piece of text to the end of the workspace */
   void add(string sText);
   //--------------------------------------------
   /** clears the workspace */
   void clear();
   //--------------------------------------------
   /**  anyade una nueva linea al espacio */
   void newline();
   //--------------------------------------------
   /** indents each line of the workspace, which may
   *  be useful for print code fragments */
   void indent();
   //--------------------------------------------
   string toString();
   //--------------------------------------------
   string Machine::printStack();
   //--------------------------------------------
   /** returns a description of the current state of the machine, displays the 
   *  contents of the stack, tape and the workspace.
   */ 
   string printState();


};  //-- class definition







  //--------------------------------------------
  Machine::Machine()
  {
    stack<string> tokenstack;
    Tape tape;
    char peep = ' ';
    string influx("");
    string workarea("");
    string lastOperation("NEW MACHINE");
  }


  //--------------------------------------------
  string Machine::getWorkspace()
  {
    return this->workarea;
  } //-- 

  //--------------------------------------------
  string Machine::workspace()
  {
    return this->workarea;
  } //-- 

  //--------------------------------------------
  string Machine::accumulator()
  {
    return this->influx;
  } //-- 

  //--------------------------------------------
  char Machine::peek()
  {
    return this->peep;
  } //-- 

  //--------------------------------------------
  bool Machine::peek(string sTest)
  {
      if ((sTest == "[:digit:]") && (!isdigit(this->peep)))
      {
        return true;
      } 

      if ((sTest == "[:letter:]") && (!isalpha(this->peep)))
      {
        return true;
      } 

      if ((sTest == "[:space:]") && (!isspace(this->peep)))
      {
        return true;
      } 

	  
    return false;
  } //-- 

//--------------------------------------------
  /* reads one char from the input stream and update the machine */
  void Machine::readNext(istream& inputstream)
  {
    this->influx += this->peep;	  
    inputstream.get(this->peep);
    this->lastOperation.clear();
    this->lastOperation.append("read next");
    
  }  

  //--------------------------------------------
  /* reads while the peep is */
  void Machine::readWhile(istream& inputstream, string sWhile)
  {	  
    while(!inputstream.eof())
    {
      if ((sWhile == "[:digit:]") && (!isdigit(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      if ((sWhile == "[:letter:]") && (!isalpha(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      if ((sWhile == "[:space:]") && (!isspace(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      this->influx += this->peep;	  
      inputstream.get(this->peep);
    }

    this->lastOperation.clear();
    this->lastOperation.append("read while");
    
  }  //-- method: readWhile

  //--------------------------------------------
  /* reads while the peep is not */
  void Machine::readWhileNot(istream& inputstream, string sWhileNot)
  {	  
    while(!inputstream.eof())
    {
      if ((sWhileNot.length() == 1) && (this->peep == sWhileNot.at(0)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      if ((sWhileNot == "[:digit:]") && (isdigit(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      if ((sWhileNot == "[:letter:]") && (isalpha(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      if ((sWhileNot == "[:space:]") && (isspace(this->peep)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read while");
        return;
      } 

      this->influx += this->peep;	  
      inputstream.get(this->peep);
    }

    this->lastOperation.clear();
    this->lastOperation.append("read while");
    
  }  //-- method: readWhileNot

//--------------------------------------------
  /* reads until the accumulator end with the string */
  void Machine::readUntil(istream& inputstream, string sTerminator)
  {	  
    while(!inputstream.eof())
    {	    	    
      this->influx += this->peep;	  
      inputstream.get(this->peep);
      if (this->endsWith(sTerminator))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read until");
        return;
      } 
    }

    this->lastOperation.clear();
    this->lastOperation.append("read until");
    
  }  

  //--------------------------------------------
  /* reads until the accumulator end with the string */
  void Machine::readUntil(istream& inputstream, string sTerminator, string sNotTerminator)
  {	  

    while(!inputstream.eof())
    {	    	    
      this->influx += this->peep;	  
      inputstream.get(this->peep);
      if (this->endsWith(sTerminator) && (!this->endsWith(sNotTerminator)))
      {
        this->lastOperation.clear();
        this->lastOperation.append("read until but not");
        return;
      } 
    }
    this->lastOperation.clear();
    this->lastOperation.append("read until but not");
    
  }  

  //--------------------------------------------
  bool Machine::endsWith(string sFinal)
  {	  

    if (this->influx.substr(this->influx.length() - sFinal.length()) == sFinal)
    {
      return true;
    }

    return false;
  }   

  //--------------------------------------------
  /** this method may not be necessary, can check with pops */
  int Machine::stacksize()
  {
    return this->tokenstack.size();
  }  

  //--------------------------------------------
  bool Machine::matches(string sTest)
  {
    if (this->workarea == sTest)
      { return true; }

    return false;
  }  

  //--------------------------------------------
  /* determines if the workspace is a space character */
  bool Machine::isSpace()
  {
    if (this->workarea.length() != 1)
    {
      return false;
    }	    
    
    if (isspace(this->workarea.at(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* determines if the workspace is a digit character */
  bool Machine::isDigit()
  {
    if (this->workarea.length() != 1)
    {
      return false;
    }	    

    if (isdigit(this->workarea.at(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /* determines if the workspace is a letter character */
  bool Machine::isLetter()
  {
    if (this->workarea.length() != 1)
    {
      return false;
    }	    

    if (isalpha(this->workarea.at(0)))
      { return true; }

    return false;
  } //-- 

  //--------------------------------------------
  /*
  bool Machine::isUnicode()
  {
    if (this->workarea.length() != 1)
    {
      return false;
    }	    

    if (Character.isDefined(this->workarea.at(0)))
      { return true; }

    return false;
  } //-- 
  */

  //--------------------------------------------
  /* to allow simple pattern testing for literal values */
  bool Machine::workspaceInRange(char cStart, char cEnd)
  {
    if (this->workarea.length() > 1)
     { return false;}

    char cCharacter = this->workarea.at(0);

    if (cCharacter < cStart)
     { return false; }

    if (cCharacter > cEnd)
     { return false; }

    return true;
  }

  //--------------------------------------------
  /* to allow simple pattern testing for literal values */
  bool Machine::matches(char cStart, char cEnd)
  {
    if (this->workarea.length() > 1)
     { return false;}

    char cCharacter = this->workarea.at(0);

    if (cCharacter < cStart)
     { return false; }

    if (cCharacter > cEnd)
     { return false; }

    return true;
  }


  //--

  //--------------------------------------------
  /** decrements the pointer to the tape by one */
  void Machine::decrementTape()
  {
    this->tape.decrementPointer();
    this->lastOperation.clear();
    this->lastOperation.append("decrement-tape");
  } //-- 

  //--------------------------------------------
  /** increments the pointer to the tape by one */
  void Machine::incrementTape()
  {
    this->tape.incrementPointer();
    this->lastOperation.clear();
    this->lastOperation.append("increment-tape");
  } //-- 


  //--------------------------------------------
  /** puts the workspace into the current item of the tape.
   *  The workspace is not changed  */
  void Machine::put()
  {
    this->tape.put(this->workarea);
    this->lastOperation.clear();
    this->lastOperation.append("put");
  } //-- 

  //--------------------------------------------
  /** gets the current item of the tape and adds it to
   *  the end of the workspace */
  void Machine::get()
  {
    this->workarea.append(this->tape.get());
    this->lastOperation.clear();
    this->lastOperation.append("get");
  } //-- 

  //--------------------------------------------
  /** inserts the last item of the stack at the front of the workspace,
   * adding a bar character "|" to separate the token. If the
   * stack is empty, there is no change to the machine.
   */
  void Machine::pop()
  {
    if (this->tokenstack.empty())
    {
      this->lastOperation.clear();
      this->lastOperation.append("pop [stack empty]");
      return;
    }

    string sSymbol(this->tokenstack.at(this->tokenstack.size() - 1));
    this->tokenstack.pop_back();


    string sText(this->replaceText(sSymbol, "|", "&bar;"));
    this->workarea.insert(0, sText + "|");
    this->tape.decrementPointer();
    this->lastOperation.clear();
    this->lastOperation.append("pop");
  } //-- 

  string Machine::replaceText(string sOriginal, string sReplace, string sReplacement)
  {
    string::size_type iFirst = sOriginal.find(sReplace, 0 );

    if (iFirst == string::npos)
    {
      return sOriginal;
    }
	sOriginal.replace(iFirst, sReplace.length(), sReplacement);  
    return sOriginal;
  } //-- 

  //--------------------------------------------
  /** pushes the contents of the workspace onto the stack.
   *  The first token on the workspace is deleted.
   */ 
  void Machine::push()
  {

    if (this->workarea.length() < 1)
    {
      this->lastOperation.clear();
      this->lastOperation.append("push [workspace empty]");
      return;
    }

    this->lastOperation.clear();
    this->lastOperation.append("push");

    string::size_type iFirstBar = this->workarea.find("|", 0 );

    if (iFirstBar == string::npos)
    {
      string sText(this->replaceText(this->workarea, "&bar;", "|"));
      this->tokenstack.push_back(sText);
      this->tape.incrementPointer();
      this->workarea.clear();
      return;
    }

    string sFirstToken(this->workarea.substr(0, iFirstBar));
    string sText(this->replaceText(sFirstToken, "&bar;", "|"));
    this->tokenstack.push_back(sText);
    this->workarea = this->workarea.substr(iFirstBar + 1);
    this->tape.incrementPointer();
    return;
  } //-- method: push

  //--------------------------------------------
  /**  */
  void Machine::shift()
  {
    this->workarea.append(this->influx);
    this->influx.clear();   
    this->lastOperation.clear();
    this->lastOperation.append("shift");
  } 

  //--------------------------------------------
  /** prints the workspace to standard out */
  void Machine::print()
  {
    cout << this->workarea;    
    this->lastOperation.clear();
    this->lastOperation.append("print");
  } 

  //--------------------------------------------
  /** adds a piece of text to the end of the workspace */
  void Machine::add(string sText)
  {
    this->workarea.append(sText);
    this->lastOperation.clear();
    this->lastOperation.append("add");

  } 

  //--------------------------------------------
  /** clears the workspace */
  void Machine::clear()
  {
    this->workarea.clear();
    this->lastOperation.clear();
    this->lastOperation.append("clear");
  } 

  //--------------------------------------------
  /**  anyade una nueva linea al espacio */
  void Machine::newline()
  {
    this->workarea.append("\n");
    this->lastOperation.clear();
    this->lastOperation.append("newline");
  } 

  //--------------------------------------------
  /** indents each line of the workspace, which may
   *  be useful for print code fragments */
  void Machine::indent()
  {
    string sText(this->workarea);
    this->workarea.clear();
    char cCurrent;

    this->workarea.append("  ");
    for (int ii = 0; ii < sText.length(); ii++)
    {
      cCurrent = sText[ii];
      this->workarea += cCurrent;
      if (cCurrent == '\n')
       { this->workarea.append("  "); }

    } //-- for
    this->lastOperation.clear();
    this->lastOperation.append("indent");

  } //-- method: indent 

  //--------------------------------------------
  /**  */
  string Machine::toString()
  {
    return "";
  } //-- method:

  //--------------------------------------------
  /** returns a description of the current state of the machine, displays the 
   *  contents of the tokenstack, tape and the workspace.
   */ 
  string Machine::printState()
  {
    string sMessage("");
    sMessage.append("\n");
    sMessage.append("last operation:" + this->lastOperation);
    sMessage.append("\n");
    sMessage.append("PEEP:[");
    sMessage += this->peep;
    sMessage.append("]");
    sMessage.append("\n");
    sMessage.append("ACCUMULATOR:[");
    sMessage.append(this->influx);
    sMessage.append("]");
    sMessage.append("\n");
    sMessage.append("WORKSPACE:[");
    sMessage.append(this->workarea);
    sMessage.append("]");
    sMessage.append("\n");

    sMessage.append("STACK    :");
    sMessage.append(this->printStack());
    sMessage.append("\n");
    sMessage.append("TAPE     :");
    sMessage.append("\n");
    sMessage.append(this->tape.print());

    sMessage.append("\n");
    return sMessage;
  } //-- method:

  //--------------------------------------------
  /* shows the contents of the stack in a concise form */ 
  string Machine::printStack()
  {
    string sCurrentItem("");

    string sMessage("[");
    for (int ii = 0; ii < this->tokenstack.size(); ii++)
    {
      sMessage.append(this->tokenstack.at(ii)); 
      sMessage.append(", ");
    }
    
    sMessage.append("]");
    return sMessage;
  } //-- method:


  //--------------------------------------------
  /** provides a command loop to test the machine operations and view the machine */
  int main(int argc, char* argv[]) 
  {
    
    string sUsageMessage("");
    sUsageMessage.append("test usage: java Machine inputfile");
    sUsageMessage.append("\n");
    ifstream in;
    string sMessage("");

    if (argc == 1) {
       cout << sUsageMessage;
       exit(-1);
       // no argument => count lines of standard input
       //in = std::cin;
    }
    else
    {
      in.open(argv[1]);      
    } //-- if
 
     Machine testMachine;

     //Machine testMachine(std::cin);

     string sCommand("");
     char *ccCommand;
     string sUserMessage("");

     sUserMessage.append("Commands;");
     sUserMessage.append("\n");
     sUserMessage.append(" a - add to the workspace");
     sUserMessage.append("\n");
     sUserMessage.append(" c - clear the work space [clear, cl]");
     sUserMessage.append("\n");
     sUserMessage.append(" pr - print the contents of the workspace [print]");
     sUserMessage.append("\n");
     sUserMessage.append(" i - indents the work space [indent]");
     sUserMessage.append("\n");
     sUserMessage.append(" n - add newline to the work space [newline, nl]");
     sUserMessage.append("\n");
     sUserMessage.append(" p - push the workspace onto the stack [push]");
     sUserMessage.append("\n");
     sUserMessage.append(" s - shift the accumulator to the workspace [shift]");
     sUserMessage.append("\n");
     sUserMessage.append(" r - read the next character from the stream [read]");
     sUserMessage.append("\n");
     sUserMessage.append(" l - read until accumulator ends with text");
     sUserMessage.append("\n");
     sUserMessage.append(" e - check if accumulator ends with text");
     sUserMessage.append("\n");
     sUserMessage.append(" w - read while peep is- [:digit:], [:space:], [:letter:]");
     sUserMessage.append("\n");
     sUserMessage.append(" x - read while peep is not- character or [:digit:], [:space:], [:letter:]");
     sUserMessage.append("\n");
     sUserMessage.append(" o - pop the stack into the workspace [pop]");
     sUserMessage.append("\n");
     sUserMessage.append(" u - put the workspace on the tape [put]");
     sUserMessage.append("\n");
     sUserMessage.append(" g - get the tape item into the workspace ");
     sUserMessage.append("\n");
     sUserMessage.append(" - - decrement the tape pointer");
     sUserMessage.append("\n");
     sUserMessage.append(" + - increment the tape pointer");
     sUserMessage.append("\n");
     sUserMessage.append(" h - help, show this message [?]");
     sUserMessage.append("\n");
     sUserMessage.append(" q - quit");
     sUserMessage.append("\n");
     cout << sUserMessage;

     //----------------------------------
     //-- the command loop
     //--
     sCommand = " ";
     while (!(sCommand == "q"))
     {
       cout << "command[" << sCommand << "]";

       //--------------------------------
       if (sCommand.at(0) == 'a')
       {
         testMachine.add(sCommand.substr(1));               
       }

       //--------------------------------
       if ((sCommand == "c") || (sCommand == "clear"))
       {
         testMachine.clear();
       }

       //--------------------------------
       if ((sCommand == "pr") || (sCommand == "print"))
       {
         testMachine.print();
       }

       //--------------------------------
       if ((sCommand == "n") || (sCommand == "newline"))
       {
         testMachine.newline();
       }

       //--------------------------------
       // 
       if ((sCommand == "i") || (sCommand == "indent"))
       {
         testMachine.indent();
       }

       //--------------------------------
       if ((sCommand == "p") || (sCommand == "push"))
       {
         testMachine.push();               
       }

       //--------------------------------
       if ((sCommand == "s") || (sCommand == "shift"))
       {
         testMachine.shift();               
       }

       //--------------------------------
       if ((sCommand == "r") || (sCommand == "read"))
       {
         testMachine.readNext(in);               
       }

       //--------------------------------
       if (sCommand.at(0) == 'l')
       {
         testMachine.readUntil(in, sCommand.substr(1));               
       }

       //--------------------------------
       if (sCommand.at(0) == 'e')
       {
	 if (testMachine.endsWith(sCommand.substr(1)))
	  { cout << "true"; }
         else
	  { cout << "false"; }
       }

       //--------------------------------
       if (sCommand.at(0) == 'w')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "This command requires an argument: \n" 
	        << "eg 'w[:digit:]' reads stream while the peep contains a digit";
	 }
	 else
	 {
           testMachine.readWhile(in, sCommand.substr(1));               
	 }
       }

       //--------------------------------
       if (sCommand.at(0) == 'x')
       {
	 if (sCommand.length() == 1)
	 {
	   cout << "This command requires an argument: \n" 
	        << "eg 'x%' reads stream until the peep has a % character";
	 }
	 else
	 {
	   testMachine.readWhileNot(in, sCommand.substr(1)); 
	 }
       }

       //--------------------------------
       // 
       if ((sCommand == "o") || (sCommand == "pop"))
       {
         testMachine.pop();               
       }

       //--------------------------------
       // 
       if ((sCommand == "u") || (sCommand == "put"))
       {
         testMachine.put();
       }

       //--------------------------------
       // 
       if ((sCommand == "g") || (sCommand == "get"))
       {
         testMachine.get();
       }

       //--------------------------------
       // 
       if (sCommand == "-")
       {
         testMachine.decrementTape();               
       }

       //--------------------------------
       // 
       if (sCommand == "+")
       {
         testMachine.incrementTape();               
       }

       //--------------------------------
       // 
       if ((sCommand == "?") || (sCommand == "h"))
       {
         cout << sUserMessage;               
       }


       cout << testMachine.printState();
       cout << ">";
       //cin.getline(ccCommand);
       sCommand.clear();
       //sCommand.append(ccCommand);
       getline(cin, sCommand);
     } //-- while


    cout << testMachine.printState();
    

  } //-- main()
  



