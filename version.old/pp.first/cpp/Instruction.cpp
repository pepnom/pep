/*
 *  
 *  This class is an instruction for a virtual machine.
 *  More documentation can  be found at http://bumble.sf.net/machine/
 *  @author http://bumble.sf.net
 */


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
    int falseJump;
    this->falseJump = -1;
    this->trueJump = -1;
    this->negation = false;    
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand) 
  {
    string command;
    this->command = sCommand;
    vector<string> parameters;
    int falseJump;
    this->falseJump = -1;
     this->trueJump = -1;
    this->negation = false;   
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, string sParameter) 
  {
    string command;
    vector<string> parameters;
    int falseJump;
    this->falseJump = -1;
    this->trueJump = -1;
    this->negation = false;
    this->command = sCommand;
    this->parameters.push_back(sParameter);
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, string sFirstParameter, string sSecondParameter) 
  {
    string command;
    vector<string> parameters;
    int falseJump;
    this->falseJump = -1;
    this->trueJump = -1;
    this->negation = false;
    this->command = sCommand;
    this->parameters.push_back(sFirstParameter);
    this->parameters.push_back(sSecondParameter);
  }

  //--------------------------------------------
  Instruction::Instruction(string sCommand, vector<string> vParameters) 
  {
    string command;
    vector<string> parameters;
    int falseJump;
    this->falseJump = -1;
    this->trueJump = -1;
    this->negation = false;
    this->parameters = vParameters;
    this->command = sCommand;
  }

  //--------------------------------------------
  string Instruction::toString()
  {
    stringstream ssReturn;
    ssReturn << this->command << "(";
    ssReturn << "negation=" << this->negation << ",";
    if (this->trueJump != -1)
     { ssReturn << "trueJump=" << this->trueJump << ","; }
    if (this->falseJump != -1)
     { ssReturn << "trueJump=" << this->falseJump << ","; }

    for (int ii = 0; ii < this->parameters.size(); ii++)
    {
      ssReturn << "\"" << this->parameters[ii] << "\"";
      if (ii < (this->parameters.size() - 1))      
       { ssReturn <<","; }
    }
    ssReturn << ")";        
    return ssReturn.str();
  } //-- method:

  //--------------------------------------------
  /* attempts to print the instruction as it would
     look in the script */
  string Instruction::print()
  {
    stringstream ssReturn;
    if (this->command == "test")
    {
      if (this->negation) { ssReturn << "!"; }
      ssReturn << "/" << this->parameters.at(0) << "/"; 
    }
    else if (this->command == "begin-test")
    {
      if (this->negation) { ssReturn << "!"; }
      ssReturn << "<" << this->parameters.at(0) << ">"; 
    }
    else
    {  
      ssReturn << this->command << " ";

      for (int ii = 0; ii < this->parameters.size(); ii++)
      {
        ssReturn << "\"" << this->parameters[ii] << "\"";
        if (ii < (this->parameters.size() - 1))      
         { ssReturn <<","; }
      }
    } //-- if,else 
    return ssReturn.str();

  } //-- method: print

  //--------------------------------------------
  int Instruction::size()
  {
    return this->parameters.size();
  }

  //--------------------------------------------
  void Instruction::toggleNegation()
  {
    this->negation = !this->negation;
  }
  //--------------------------------------------
  bool Instruction::isNegated()
  {
    return this->negation;
  }
  
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
  int Instruction::getTrueJump()
  {
    return this->trueJump;
  }

  //--------------------------------------------
  void Instruction::setTrueJump(int iJump)
  {
    this->trueJump = iJump;
  }
  
  //--------------------------------------------
  int Instruction::getFalseJump()
  {
    return this->falseJump;
  }

  //--------------------------------------------
  void Instruction::setFalseJump(int iJump)
  {
    this->falseJump = iJump;
  }
  
  //--------------------------------------------
  void Instruction::swapJumps()
  {
    int iFalseJump = this->falseJump;
    this->falseJump = this->trueJump;
    this->trueJump = iFalseJump;
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


