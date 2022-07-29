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
#include "Instruction.h"

using namespace std;
  
class Interpret
{

  private: 
     //--------------------------------------------
     Program program;
     //--------------------------------------------
     string parseErrors;
     //--------------------------------------------

  public: 
     //--------------------------------------------
     Interpret();
     //--------------------------------------------
     string toString();
     //--------------------------------------------
     string print();
     //--------------------------------------------
     void parse();
     //--------------------------------------------
     void execute();
};

#endif
