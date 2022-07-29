
 /**
 *  
 *  This class represents a virtual machine with certain
 *  buffers and certain commands or instructions which can
 *  be the machine is capable of executing. In some ways the 
 *  machine was originally inspired by the virtual machine 
 *  which is encapsulated in the sed stream editing language.
 *  Like sed, there is a "pattern space" (although in the current
 *  machine it is called a "workspace". Also, like sed nearly all
    the instructions which the machine can execute directly affect
    the workspace, in other words the workspace is a kind of 
    cpu register. however the machine contains a number of features
    not to be found in the sed machine, and these features were
    added in order to make the machine suitble or more suitable 
    for the parsing of language grammars (generative grammars in
    the terminology of linguists, or backus-naur grammars in the 
    terminology of computer science.

    A more complete documentation of the machine and its capabilities
    can be found at http://bumble.sf.net/machine/doc

    The original version of this file should be at 
    http://bumble.sourceforge.net/machine/Machine.h

 *  @author http://bumble.sf.net
 */
#if !defined (_MACHINE_H)
#define _MACHINE_H_

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
   /* the next char of the input stream */
   char peep;
   //--------------------------------------------
   string lastOperation;
   //--------------------------------------------
   bool stackChanged;

  public: 
   //--------------------------------------------
   Machine();
   //--------------------------------------------
   string getWorkspace();
   //--------------------------------------------
   string workspace();
   //--------------------------------------------
   void peek();
   //--------------------------------------------
   bool stackFlag();
   //--------------------------------------------
   void setFlag();
   //--------------------------------------------
   void resetFlag();
   //--------------------------------------------
   bool peek(string sTest);
   //--------------------------------------------
   /* reads while the peep buffer is a certain character */
   void readWhile(istream& inputstream, string sWhile);
   //--------------------------------------------
   /* reads while the peep buffer is -not- a certain character */
   void readWhileNot(istream& inputstream, string sWhileNot);
   //--------------------------------------------
   /* reads the next character from the input stream */
   void readNext(istream& inputstream);
   //--------------------------------------------
   /* reads until the workspace buffer ends in the given string */
   void readUntil(istream& inputstream, string sTerminator);
   //--------------------------------------------
   /* reads until the workspace ends in the string and -not- in the second */
   void readUntil(istream& inputstream, string sTerminator, string sNotTerminator);
   //--------------------------------------------
   /* determines if the workspace ends with the given string */
   bool endsWith(string sFinal);
   //--------------------------------------------
   /* determines if the workspace begin with the given string */
   bool beginsWith(string sBegin);
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
   void replace(string sReplace, string sReplacement);
   //--------------------------------------------
   /** pushes the contents of the workspace onto the stack.
   *  The first token on the workspace is deleted.
   */ 
   void push();
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
   /**   */
   void clip();
   //--------------------------------------------
   string toString();
   //--------------------------------------------
   string printStack();
   //--------------------------------------------
   /** returns a description of the current state of the machine, displays the 
   *  contents of the stack, tape and the workspace.
   */ 
   string printState();


};  //-- class definition

#endif
