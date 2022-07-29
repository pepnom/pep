#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#include "library.c";

/* -------------------------------------------*/

int main(int argc, char** argv)
{

  char sText[200];
  char sTemp[20];
  FILE * fp;
  FILE * scriptstream;
  FILE * inputstream = stdin;
  char sScriptFileName[200];
  char sScriptString[500];
  int bDebug = FALSE;
  int bCompileOnly = FALSE;
  int bShowFinalState = FALSE;
  int bShowExecutionTime = FALSE;
  int bShowLegalCommands = FALSE;
  int iExecuteResult = TRUE;
  enum debugModes debugMode;
  debugMode = NONE;


  clock_t tBeginExecute;
  clock_t tEndExecute;

  Machine machine;
  Program program;
	
  strcpy(sScriptFileName, "");
  strcpy(sScriptString, "");

  char sShortHelpMessage[] = " \n\
  chomski, a parsing script language \n\
  Usage: cat inputfile | chomski -f scriptfile \n\
  type chomski -h  for more help \n\
  ";

  char sHelpMessage[] = "\n\
  Chomski, a parsing script language \n\
  Usage: cat inputfile | chomski -f scriptfile \n\
  Options: \n\
    -h         print this help message \n\
    -c         compile only, do not run the script \n\
    -a         interactive script analysis  \n\
    -d         print full script trace  \n\
    -D         print tape trace  \n\
    -e         run script and print final machine state  \n\
    -r         print a trace of stack reductions \n\
    -t         show compilation and execution times  \n\
    -l         show legal script commands and classes and exit \n\
    -f file    use specified script file \n\
    -s 'text'  use the 'text' as a script \n\
  Examples: \n\
  -Unix \n\
    echo 'xyz abc' | ./chomski -s 'newline;print;clear;'  \n\
    cat textfile | ./chomski -f script.file \n\
  -MS Windows \n\
    echo 'xyz abc' | chomski -s 'newline;print;clear;'  \n\
    type textfile | chomski -f script.file \n\
 \n\
  See http://bumble.sourceforge.net  \n\
         ";
   
   if (argc == 1)
   {
     printf(sHelpMessage);
     exit(1);
   }

   int ii;

   for (ii = 1; ii < argc; ii++)
   {

     if (argv[ii][0] == '-') 
     {
       switch (argv[ii][1])
       {
         case 'h':
          printf(sHelpMessage);
          exit(1);
          break;
         case 'c':
           bCompileOnly = TRUE;
           break;
         case 'D':
           debugMode = FULLTRACE;
           break;
         case 'd':
           debugMode = TAPETRACE;
           break;
         case 'a':
           debugMode = ANALYSE;
           break;
         case 'e':
           bShowFinalState = TRUE;
           break;
         case 'f':
           ii++;
	   if ((ii == argc) || (argv[ii][0] == '-'))
           {
             fprintf(stderr, "no script file specified after '-f' option \n"); 
             fprintf(stderr, "type 'chomski -h' for more help"); 
             exit(1);
           }

           strcpy(sScriptFileName, argv[ii]);
           break;
         case 'l':
           bShowLegalCommands = TRUE;
           break;
         case 'r':
           debugMode = STACKTRACE;
           break;
         case 's':
           ii++;
	   if ((ii == argc) || (argv[ii][0] == '-'))
           {
             fprintf(stderr, "no script specified after '-s' option"); 
             fprintf(stderr, "type 'chomski -h' for more help"); 
             exit(1);
           }

           strcpy(sScriptString, argv[ii]);
           break;
         case 't':
           bShowExecutionTime = TRUE;
           break;
         default:
           fprintf(stderr, "Unknown switch %s\n", argv[ii]);
           fprintf(stderr, "type 'chomski -h' for more help"); 
           exit(1);
       } //--switch
     } //--if
   } //--for

   if (bShowLegalCommands)
   {
     fnPrintCommands();
     fnPrintClasses();
     exit(0);  
   }


   if ((strlen(sScriptFileName) != 0) && (strlen(sScriptString) != 0)) 
   {
     fprintf(stderr, "only one of the options '-s' and '-f' is permitted \n"); 
     fprintf(stderr, "type 'chomski -h' for more help"); 
     exit(1);
   }

   if ((strlen(sScriptFileName) == 0) && (strlen(sScriptString) == 0)) 
   {
     fprintf(stderr, "no script specified, use either '-s' or '-f' to specify a script \n"); 
     fprintf(stderr, "type 'chomski -h' for more help"); 
     exit(1);
   }


   if (strlen(sScriptFileName) != 0)
   {
     scriptstream = fopen(sScriptFileName, "r");
     if (scriptstream == NULL)
     {
       printf("could not open script file '%s' ", sScriptFileName);
       exit(1);
     } 
   }

   if (strlen(sScriptString) != 0)
   {
     scriptstream = fopen("123junk.txt", "w+");
     if (scriptstream == NULL)
     {
       printf("could not open a script stream '%s' ", sScriptFileName);
       exit(1);
     } 
     fputs(sScriptString, scriptstream);
     rewind(scriptstream);
     
   }


   fnInitializeMachine(&machine);
   fnInitializeProgram(&program);
   fnCompile(&program, scriptstream);

   if (bCompileOnly)
   {
     fnPrintProgram(&program);
     exit(0);  
   }

   if (bDebug)
   {
     //fnPrintProgram(&program);
     fnPrintMachine(&machine);
   }
   
   tBeginExecute = clock();

   //-- prime  the peep with the first char
   //char cFirstCharacter = getc(inputstream);
   //sprintf(sTemp, "%c", cFirstCharacter);
   //appendToWorkspace(&machine, sTemp);
   machine.peep = getc(inputstream);
     
   char cCommand[80];
   char buffer[80];
   char * p;

   switch (debugMode)
   {
 
     case FULLTRACE:
    
     while (iExecuteResult != FALSE)
     {
       iExecuteResult = fnExecuteInstruction(&program, &machine, inputstream);

       printf("\n------------------\n");
       printf("next: [%d] ", program.instructionPointer);
       fnPrintInstruction(program.instructionSet[program.instructionPointer]);
       printf("\n");
       
       fnPrintMachine(&machine);
     } 
     break;
     //------------------------------------
     case TAPETRACE:
    
       while (iExecuteResult != FALSE)
       {
         iExecuteResult = fnExecuteInstruction(&program, &machine, inputstream);
         if (machine.lastoperation == JUMP)
         {
           printf("\n------------------\n");
         
           fnPrintStackTape(&machine);
         }
       } //-- while
       break;

     //------------------------------------
     case STACKTRACE:
    
       while (iExecuteResult != FALSE)
       {
         iExecuteResult = fnExecuteInstruction(&program, &machine, inputstream);
         if (machine.lastoperation == PUSH)
         {
           printf("\n------------------\n");
           printf("[%d] %s", program.instructionPointer, machine.stack);
         }
       } //-- while
       break;

     default: 
       while (iExecuteResult != FALSE)
       {
         iExecuteResult = fnExecuteInstruction(&program, &machine, inputstream);
       }
       break;

   } //-- switch

   /* compute the execution time */
   tEndExecute = clock();
   int iExecutionTime =
     (int) (((tEndExecute - tBeginExecute) * 1000)/ CLOCKS_PER_SEC);
   program.executionTime = iExecutionTime;

   if (bShowFinalState)
   {
     // fnPrintProgram(&program);
     fnPrintMachineState(&machine);
   }

   if (bShowExecutionTime)
   {
     printf("\n(compilation time: %d milliseconds)\n", program.compileTime);
     printf("(execution time  : %d milliseconds)", program.executionTime);
   }

   fnDestroyMachine(&machine);
   fclose(scriptstream);

} //-- main
