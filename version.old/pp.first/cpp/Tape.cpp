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
#include "Tape.h"

using namespace std;
  

  //--------------------------------------------
  Tape::Tape() 
  {
    vector<string> array;
    pointer = 0;
  }


  //--------------------------------------------
  string Tape::toString()
  {
    string sReturn("");
    stringstream ssReturn;
    string currentItem("");
    
    ssReturn << "Pointer==" << this->pointer << endl;
    for (int ii = 0; ii < array.size(); ii++)
    {
      currentItem = this->array[ii];
      ssReturn << ii << ":" << currentItem << endl;
    }
    
    sReturn = ssReturn.str();
    return sReturn;
  } //-- method:

  //--------------------------------------------
  string Tape::print()
  {
    string sReturn("");
    stringstream ssReturn;
    string currentItem("");
    
    ssReturn << "Pointer==" << this->pointer << endl;

    for (int ii = 0; ii < array.size(); ii++)
    {
      currentItem = this->array[ii];
      ssReturn << ii << ":" << currentItem << endl;
      //cout << ii << ":" << currentItem << endl;
    }
    
    return ssReturn.str();
    //cout << ssReturn.str();
  } //-- method:



  //--------------------------------------------
  void Tape::put(string sNewElement)
  {
    if (this->pointer == this->array.size())
    {
      this->array.push_back(sNewElement);
      return;
    }

    this->array[this->pointer] = sNewElement;
  } //-- method:

  
  //--------------------------------------------
  string Tape::get()
  {
    if (this->pointer == this->array.size())
     { return ""; }
    return this->array[this->pointer];
  } //-- method:

  //--------------------------------------------
  void Tape::incrementPointer()
  {
    if (this->pointer == this->array.size())
    {
      this->array.push_back("");
    }

    this->pointer++;
  } //-- method:

  //--------------------------------------------
  /*  */
  void Tape::decrementPointer()
  {
    if (this->pointer == 0)
     { return; }

    this->pointer--;
  } //-- method:


  //--------------------------------------------
  /* a main method for testing */
/*
  int main()
  {
    
    stringstream ssUsageMessage;
    ssUsageMessage << "test usage: java Tape ";

    string sMessage("");


    //String sText = args[0];
    //char cChar = args[1].charAt(0);


    Tape testTape;

    cout << "put 'diffle'               " << endl;
    testTape.put("diffle");
    cout << testTape.toString() << endl;

    cout << "put 'buff'               " << endl;
    testTape.put("buff");
    cout << testTape.toString() << endl;

    cout << ".incrementPointer()       " << endl;
    testTape.incrementPointer();
    cout << testTape.toString() << endl;

    cout << "put 'diffle'               " << endl;
    testTape.put("diffle");
    testTape.print();
    cout << testTape.toString() << endl;



  } //-- main()

*/
