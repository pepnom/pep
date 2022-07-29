/*
 *  
 *  
 *
 *  @author http://bumble.sf.net
 */

#if !defined (_INTERPRET_H)
#define _INTERPRET_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Program.h"
//#include "Machine.h"

using namespace std;
  
class Parser
{

  private: 
     //--------------------------------------------
     Program program;
     //--------------------------------------------
     Machine mm;
     //--------------------------------------------
     vector<string> parseErrors;
     //--------------------------------------------
     vector<string> parseWarnings;
     //--------------------------------------------
     long parseDuration;
     //--------------------------------------------

  public: 
     //--------------------------------------------
     Parser();
     //--------------------------------------------
     string toString();
     //--------------------------------------------
     string showErrors();
     //--------------------------------------------
     string showWarnings();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     Program getProgram();
     //--------------------------------------------
     Machine getMachine();
     //--------------------------------------------
     bool parse(istream& inputstream);
     //--------------------------------------------
     bool parse(istream& inputstream, bool bDebug);
     //--------------------------------------------
     long parseTime();

};

#endif
