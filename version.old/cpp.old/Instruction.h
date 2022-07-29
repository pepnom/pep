//string example
//http://www.yolinux.com/TUTORIALS/LinuxTutorialC++StringClass.html
/*
 *  
 *  Is a virtual tape 
 *
 *  @author http://bumble.sf.net
 */

// good examples
// http://www.josuttis.com/libbook/i18n/loc1.cpp.html
#if !defined (_INSTRUCTION_H)
#define _INSTRUCTION_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;
  
class Instruction
{

  private: 
     //--------------------------------------------
     string command;
     //--------------------------------------------
     vector<string> parameters;

  public: 
     //--------------------------------------------
     Instruction();
     //--------------------------------------------
     Instruction(string sCommand);
     //--------------------------------------------
     Instruction(string sCommand, string sParameter);
     //--------------------------------------------
     Instruction(string sCommand, string sFirstParameter, string sSecondParameter);
     //--------------------------------------------
     Instruction(string sCommand, vector<string> vParameters);
     //--------------------------------------------
     string toString();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     void setCommand(string sValue);
     //--------------------------------------------
     string getCommand();
     //--------------------------------------------
     void addParameter(string sValue);
     //--------------------------------------------
     string getParameter(int iParameter);
     //--------------------------------------------
};

#endif
