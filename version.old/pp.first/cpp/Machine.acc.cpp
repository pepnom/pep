
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
#include "Machine.h" 

using namespace std;
 




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

  



