/*
    The curent file provides an implementation of an interpreted 
    language which is similar to the sed stream editor language but
    which has been redesigned to make it more appropriate for
    parsing context free grammars and transforming input streams
    in accordance with the rules of those grammars (also referred to
    as generative grammars in the linguistic context). 

    From a non-technical point of view this program provides a 
    way to transform one type of text pattern into another type.
    These patterns are often referred to as "formats". The curent
    language has been designed to allow the transformation of text 
    formats which obey certain rules. An example of a "format" is
    html, or xml, or postscript, or texinfo or latex dvi, or unix
    man pages or unix groff pages etc. 

    More information about this system can be found at 
    http://bumble.sf.net/machine .The original version of the current
    file should be locateable at http://bumble.sf.net/machine/Parser.main.cpp
    It should be noted that the naming scheme followed for the cpp
    class files is not very explanatory. For example the current file 
    is called Parser.main.cpp but it does more than simply parse and 
    would probably be better named as Interpreter etc. The file which
    is called Interpret.cpp does not really interpret...

    The language which this program interpret looks like
    /text/
    {
      clear; pop;
      add "word";
      print;
    }

    the above script does not do anything meaningful

    this file requires a number of other classes such as
     Machine, Parser, Instruction, Program, Tape, ...

 *  @author http://bumble.sf.net
 */


#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Parser.h"

using namespace std;
  

  //--------------------------------------------
  /* */

  int main(int argc, char* argv[]) 
  {
    string sUsageMessage("");
    sUsageMessage.append("usage: echo input | Parser script-file debug-flag\n");
    sUsageMessage.append("usage: cat input-file | Parser script-file debug-flag\n");
    sUsageMessage.append("implements a script language for parsing.");
    sUsageMessage.append("\n");
    sUsageMessage.append("if the debug flag is set (any value) then the program");
    sUsageMessage.append("\n");
    sUsageMessage.append("outputs a trace of the program and the state of the ");
    sUsageMessage.append("\n");
    sUsageMessage.append("virtual machine.");
    sUsageMessage.append("\n");
    ifstream in;
    bool bDebug = false;

    if (argc < 2) 
    {
       cout << sUsageMessage;
       exit(-1);
    }
    else if (argc == 3)
    {
      bDebug = true;
    }

    in.open(argv[1]);
    if (!in.is_open())
    {
        cout << "couldnt open file " << argv[1] << endl;
	exit(-1);
    }
	  

    Parser parser;
    bool bResult = parser.parse(in);
    if (bResult)
    {
      Program program = parser.getProgram();
      //cout << parser.toString();
      cout << program.listing();      
      program.run(cin, bDebug);
    }
    else
    {
      cout << "There was a problem parsing the script" << endl;
      cout << parser.showErrors();
      cout << parser.showWarnings();
    }


 
  } //-- main()


