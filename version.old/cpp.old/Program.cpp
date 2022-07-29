
/**
 *  
 *  generates a program to execute a script
 *
 *  @author http://bumble.sf.net
 */
 
#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
#include <string>
#include <sstream>
#include <stdlib.h>
#include <ctype.h>
//#include "Interpret.h" 
//#include "Machine.h" 
#include "Program.h" 

using namespace std;
  
  //--------------------------------------------
  /** this program uses the Machine class to parse a script and 
   *  
   */ 
  Program::Program()
  {
    Machine cpu;
    string errors;
    vector<Instruction> instructionSet;
    instructionPointer = 0;
  }

  //--------------------------------------------
  string Program::toString()
  {
    string sReturn("");
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "--program--" << endl << endl;
    ssReturn << "instruction pointer:" << this->instructionPointer << endl;
    if (this->instructionSet.size() == 0)
    {
      ssReturn << "(no instructions)" << endl;
    }
    else
    {
     for (int ii = 0; ii < this->instructionSet.size(); ii++)
     {
       currentItem = this->instructionSet[ii];
       ssReturn << ii << ":" << currentItem.toString() << endl;
     }
    } //-- if, else

    ssReturn << "--cpu--\n" << this->cpu.toString() << endl << endl;
    ssReturn << "--errors--\n" << this->errors << endl;
    sReturn = ssReturn.str();
    return sReturn;

  } //-- method: toString


  //--------------------------------------------
  string Program::showErrors()
  {
    return this->errors;
  } //-- method:

  //--------------------------------------------
  int Program::length()
  {
    return this->instructionSet.size();
  }

  //--------------------------------------------
  int Program::size()
  {
    return this->instructionSet.size();
  }

  //--------------------------------------------
  int Program::pointer()
  {
    return this->instructionPointer;
  }

  //--------------------------------------------
  string Program::print()
  {
    return "";
  } //-- method:

  //--------------------------------------------
  string Program::listing()
  {
    stringstream ssReturn;
    Instruction currentItem;
    
    ssReturn << "instruction pointer:" << this->instructionPointer << endl;
    if (this->instructionSet.size() == 0)
    {
      ssReturn << "(no instructions)" << endl;
      return ssReturn.str();
    }

    for (int ii = 0; ii < this->instructionSet.size(); ii++)
    {
      currentItem = this->instructionSet[ii];
      ssReturn << ii << ":" << currentItem.toString() << endl;
    }
    
    return ssReturn.str();
  } //-- method:

//--------------------------------------------
  string Program::showMachine()
  {
    return this->cpu.toString();
  } //-- method:

  //--------------------------------------------
  string Program::showNext()
  {
    stringstream ssReturn;

    if ((this->instructionPointer >= this->instructionSet.size()) ||
        (this->instructionSet.size() == 0))
    {
      this->errors.append("attempt to access instruction out of range (");
      //this->errors += this->instructionPointer;
      this->errors.append(")");

      return "";
    }
    ssReturn << this->instructionPointer << ":" << 
                this->instructionSet.at(this->instructionPointer).toString();
    return ssReturn.str();

  } //-- method:

  //--------------------------------------------
  void Program::addInstruction(string ssCommand)
  {
    Instruction newInstruction(ssCommand);
    //newInstruction.setCommand(ssCommand);
    //cout << "new instruction:" << newInstruction.toString() << endl;
    this->instructionSet.push_back(newInstruction);
  } //-- method:

  //--------------------------------------------
  void Program::addInstruction(string sCommand, string sParameter)
  {
    Instruction newInstruction(sCommand, sParameter);
    this->instructionSet.push_back(newInstruction);
  } //-- method:

  //--------------------------------------------
  /* adds an instruction to the program */
  void Program::addInstruction(string sCommand, string sFirstParameter, string sSecondParameter)
  {
    Instruction newInstruction(sCommand, sFirstParameter, sSecondParameter);
    this->instructionSet.push_back(newInstruction);
  } //-- method:

  //--------------------------------------------
  void Program::addInstruction(string sCommand, vector<string> vParameters)
  {
    Instruction newInstruction(sCommand, vParameters);
    this->instructionSet.push_back(newInstruction);
  } //-- method:

  //--------------------------------------------
  void Program::run(istream& inputstream)
  {
    while (!inputstream.eof())
    {
      if (this->pointer() >= this->length())
      { this->reset(); }

      this->execute(inputstream); 
    }
  }

  //--------------------------------------------
  /* resets the instructionPointer to zero */
  void Program::reset()
  {
    this->instructionPointer = 0;
  }

  //--------------------------------------------
  void Program::execute(istream& inputstream)
  {
    string sCommand("");
    string sParameterA("");
    string sParameterB("");

    if ((this->instructionPointer >= this->instructionSet.size()) ||
        (this->instructionSet.size() == 0))
    {
      this->errors.append("attempt to access instruction out of range (");
      //this->errors += this->instructionPointer;
      this->errors.append(")\n");
      return;
    } 

      int iInstruction = this->instructionPointer;
      sCommand = this->instructionSet[iInstruction].getCommand();
      sParameterA = this->instructionSet[iInstruction].getParameter(0);
      sParameterB = this->instructionSet[iInstruction].getParameter(1);

      if (sCommand == "add") 
      {
        this->cpu.add(sParameterA); 
        this->instructionPointer++;
      } 
      else if (sCommand == "crash") 
      {
        exit(-1);
        this->instructionPointer++;
      }
      else if (sCommand == "flag") 
      {
        this->cpu.setFlag(); 
        this->instructionPointer++;
      }
      else if (sCommand == "print") 
      {
        this->cpu.print(); 
        this->instructionPointer++;
      }
      else if (sCommand == "clear") 
      {
        this->cpu.clear(); 
        this->instructionPointer++;
      }
      else if (sCommand == "read") 
      {
        this->cpu.readNext(inputstream); 
        this->instructionPointer++;
      }
      else if (sCommand == "push") 
      {
        this->cpu.push(); 
        this->instructionPointer++;
      }
      else if (sCommand == "pop") 
      {
        this->cpu.pop(); 
        this->instructionPointer++;
      }
      else if (sCommand == "put") 
      {
        this->cpu.put(); 
        this->instructionPointer++;
      }
      else if (sCommand == "get") 
      {
        this->cpu.get(); 
        this->instructionPointer++;
      }
      else if (sCommand == "++") 
      {
        this->cpu.incrementTape(); 
        this->instructionPointer++;
      }
      else if (sCommand == "--") 
      {
        this->cpu.decrementTape(); 
        this->instructionPointer++;
      }
      else if (sCommand == "newline") 
      {
        this->cpu.newline(); 
        this->instructionPointer++;
      }
      else if (sCommand == "indent") 
      {
        this->cpu.indent(); 
        this->instructionPointer++;
      }
      else if (sCommand == "clip") 
      {
        this->cpu.clip(); 
        this->instructionPointer++;
      }
      else if (sCommand == "state") 
      {
        cout << this->cpu.printState(); 
        this->instructionPointer++;
      }
      else if (sCommand == "while") 
      { 
        this->cpu.readWhile(inputstream, sParameterA); 
        this->instructionPointer++;
      }
      else if (sCommand == "whilenot") 
      { 
        this->cpu.readWhileNot(inputstream, sParameterA); 
        this->instructionPointer++;
      }
      else if (sCommand == "until") 
      { 
        this->cpu.readUntil(inputstream, sParameterA); 
        this->instructionPointer++;
      }
      else if (sCommand == "if") 
      { 
        if (this->cpu.workspace() == sParameterA)
        {
         this->instructionPointer = atoi(sParameterB.c_str()); 
        } 
        else
        {
          this->instructionPointer++; 
        }
      } 
      else
      {
        this->errors.append("unrecognized instruction at ");
        this->errors += this->instructionPointer;
        this->errors.append("(" + this->instructionSet[this->instructionPointer].toString() + ")");
        this->instructionPointer++;
      } //-- if
      
  } //-- method: execute

 
