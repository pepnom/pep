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
#include "Interpret.h"

using namespace std;
  

  //--------------------------------------------
  /* a main method for testing */

  int main(int argc, char* argv[]) 
  {
    string sUsageMessage("");
    sUsageMessage.append("ms windows-- \n");
    sUsageMessage.append("usage: echo script | Interpret debugflag \n");
    sUsageMessage.append("usage: type scriptfile | Interpret debugflag \n");
    sUsageMessage.append("unix-- \n");
    sUsageMessage.append("usage: echo script | Interpret debugflag \n");
    sUsageMessage.append("usage: cat scriptfile | Interpret debugflag \n");
    ifstream in;
    string sMessage("");
    bool bDebug = true;

    if (argc == 1) 
    {
      bDebug = false;
    }
    else if (argc == 2)
    {
      if ((strcmp(argv[1], "-h") == 0) || (strcmp(argv[1], "-?") == 0))
      {
        cout << sUsageMessage;
	exit(0);
      }
      bDebug = true;
    } 
    else
    {
      bDebug = true;
    }
	  
    cout << "Interpret---------------";
    Interpret test;

    test.parse(cin);

    cout << test.toString() << endl;
    cout << "Interpret---------------";

 
  } //-- main()


