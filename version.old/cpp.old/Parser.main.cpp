/*
 *  
 *   
 *
 *  @author http://bumble.sf.net
 */


#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Parser.h"

using namespace std;
  

  //--------------------------------------------
  /* a main method for testing */

  int main(int argc, char* argv[]) 
  {
    string sUsageMessage("");
    sUsageMessage.append("usage: echo input | Parser script-file compile-flag\n");
    sUsageMessage.append("usage: cat input-file | Parser script-file compile-flag\n");
    sUsageMessage.append("  \n");
    ifstream in;
    bool bCompile = false;

    if (argc < 2) 
    {
       cout << sUsageMessage;
       exit(-1);
    }
    else if (argc == 3)
    {
      bCompile = true;
    }

    in.open(argv[1]);
    if (!in.is_open())
    {
        cout << "couldnt open file " << argv[1] << endl;
	exit(-1);
    }
	  
    cout << "Parser---------------";

    Parser parser;
    bool bResult = parser.parse(in);
    if (bResult)
    {
      if (bCompile)
      {
      }

      Program program = parser.getProgram();
      
      //program.run(cin);
    }
    else
    {
      parser.showErrors();
      parser.showWarnings();
    }

    cout << "Parser---------------";

 
  } //-- main()


