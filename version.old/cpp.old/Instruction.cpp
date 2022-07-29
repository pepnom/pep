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

#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include "Instruction.h"

using namespace std;
  

  //--------------------------------------------
  Instruction::Instruction() 
  {
    string command;
    vector<string> parameters;
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand) 
  {
    string command;
    this->command = sCommand;
    vector<string> parameters;
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, string sParameter) 
  {
    string command;
    vector<string> parameters;

    this->command = sCommand;
    this->parameters.push_back(sParameter);
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, string sFirstParameter, string sSecondParameter) 
  {
    string command;
    vector<string> parameters;

    this->command = sCommand;
    this->parameters.push_back(sFirstParameter);
    this->parameters.push_back(sSecondParameter);
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, vector<string> vParameters) 
  {
    string command;
    vector<string> parameters;
    this->parameters = vParameters;
    this->command = sCommand;
  }

  //--------------------------------------------
  string Instruction::toString()
  {
    string sReturn("");
    sReturn.append(this->command + "(");        
    for (int ii = 0; ii < this->parameters.size(); ii++)
    {
      sReturn.append(this->parameters[ii]);
      if (ii < (this->parameters.size() - 1))      
       { sReturn.append(","); }
    }
    sReturn.append(")");        
    return sReturn;
  } //-- method:

  //--------------------------------------------
  string Instruction::print()
  {
    string sReturn("");
    sReturn.append(this->command + "(");        
    for (int ii = 0; ii < this->parameters.size(); ii++)
    {
      sReturn.append(this->parameters[ii]);
      if (ii < (this->parameters.size() - 1))      
       { sReturn.append(","); }
    }
    sReturn.append(")");        
    return sReturn;
  } //-- method:


  //--------------------------------------------
  void Instruction::setCommand(string sValue)
  {
    this->command = sValue;
  }
  //--------------------------------------------
  string Instruction::getCommand()
  {
    return this->command;
  }

  //--------------------------------------------
  void Instruction::addParameter(string sValue)
  {
    this->parameters.push_back(sValue);
  }

  //--------------------------------------------
  string Instruction::getParameter(int iParameter)
  {
    if ((iParameter >= this->parameters.size()) ||
        (this->parameters.size() == 0))
    { 
      return "";
    }

    return this->parameters[iParameter];
  }
  //--------------------------------------------


