/*
 *  
 *  
 *
 *  @author http://bumble.sf.net
 */

#if !defined (_PROGRAM_H)
#define _PROGRAM_H_


#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Machine.h"
#include "Instruction.h"

using namespace std;
  
class Program
{

  private: 
     //--------------------------------------------
     vector<Instruction> instructionSet;
     //--------------------------------------------
     Machine cpu;
     //--------------------------------------------
     int instructionPointer;
     //--------------------------------------------
     string errors; 
     //--------------------------------------------

  public: 
     //--------------------------------------------
     Program();
     //--------------------------------------------
     string toString();
     //--------------------------------------------
     string showErrors();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     string listing();
     //--------------------------------------------
     string showMachine();
     //--------------------------------------------
     string showNext();
     //--------------------------------------------
     void execute(istream& inputstream);
     //--------------------------------------------
     void reset();
     //--------------------------------------------
     int length();
     //--------------------------------------------
     int size();
     //--------------------------------------------
     int pointer();
     //--------------------------------------------
     void executeInstruction(int iInstruction);
     //--------------------------------------------
     void addInstruction(string sCommand);
     //--------------------------------------------
     void addInstruction(string sCommand, string sParameter);
     //--------------------------------------------
     void addInstruction(string sCommand, string sFirstParameter, string sSecondParameter);
     //--------------------------------------------
     void addInstruction(string sCommand, vector<string> vParameters);
     //--------------------------------------------
     void run(istream& inputstream);
};

#endif
