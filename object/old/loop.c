// loop.c

// This code is not currently used: everything is in gh.c
//
// this is a interpreter or testing loop for the machine
// and code in gh.c
// see gh.c for more information

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// put an ifdef guard here!!
#include "gh.h"

/* 
Notes:
 valid commands for the interpreter loop as opposed to 
 the machine. The structures in the loopInfo[]
 array should be in the same order for easy access
 Information about machine instructions are contained in
 the info[] in the gh.c file

 the function pointers in the loopInfo array wont be 
 used
*/

enum LoopCommand { 
  // display test loop commands
  HELP=0, 
  // machine commands
  MCOMMANDNAMES, 
  // quit the interpreter loop
  EXIT, 
  // not a recognised command, used as a bookend
  INVALID
};


void help() {
  // display some help for the test loop
}

void quit() {
  // exit the test loop
  printf("%sGoodbye!%s\n", MAGENTA, NORMAL);
  exit(0);
}

// contain information about the test loop commands
struct {
  enum LoopCommand c;
  char * name;
  char * name2;
  char * shortDesc;
  char * longDesc;
  char * example;
  void (*fn)();
} loopInfo[] = { 
  { HELP, "help", "h",
     "Displays some help for the test loop", 
     "displays help", 
     "<eg>", help },
  { MCOMMANDNAMES, "mc", "commandnames",
     "Displays the virtual machine commands", 
     "Shows a short list of all legal commands", 
     "<eg>", quit },
  { EXIT, "exit", "x",
     "Exit from the test loop", 
     "<long desc>", 
     "<eg>", quit },
  { INVALID, "invalid", "e",
    "invalid command",
    "this command does not exist in the test loop",
    "n/a", help }
};

// displays valid commands with bash colours and paging
void showHelp() {
  //printf("%s Valid commands are:\n %s", BLUE, NORMAL);
  printf("Valid interpreter commands are:\n");
  int ii;
  for (ii = HELP; ii < INVALID; ii++) {
    printf("%s%s or %s%s\n", 
      GREEN, loopInfo[ii].name, loopInfo[ii].name2, WHITE);
    printf("  %s%s\n ", loopInfo[ii].shortDesc, WHITE);
    if (((ii+1) % 10) == 0) {
      printf("Press any key to continue...");
      getc(stdin);
    }
  }
  printf("\n");
} 

// given some text return the corresponding command
enum LoopCommand loopCommandFromText(char * text) {
  int ii = HELP;
  while (ii < INVALID) {
    if (strcmp(text, loopInfo[ii].name) == 0)
      return ii;
    else if (strcmp(text, loopInfo[ii].name2) == 0)
      return ii;
    ii++;
  }
  return INVALID;
}

// this typedef simplifies the syntax of returning a 
// function pointer from a function
//typedef void (*commandFn)(struct Machine *, struct Instruction *);
// given the command type return the function which actually 
// carries out that function on the machine.
//commandFn commandToFunction(enum Command cc) {
//}

int main(int argc, char *argv[]) {
  //struct Machine m; struct Instruction i;
  //info[1].fn(&m, &i);
  //fprintCommandNames(stdout); 
  //showCommandNames(); 
  //showCommandSummary(); 
  //printCommandNamesAndDescriptions();
  //printCommandInfo(PUSH); 
  //struct Tape t;

  // open the first command line argument as an inputstream
  // for machine 'reads'
  if (argc > 1) {
    FILE *fp;
    char ch;
    if ((fp = fopen (argv[1], "r")) == NULL) {
      printf ("Cannot open input file.\n");
      exit(1);
    }

    // need to check feof or ferror
    while ((ch = fgetc (fp)) != EOF)
    { printf ("%c", ch); }
    fclose (fp);
  }

  char command[128];
  char param[128];
  char line[128];
  enum LoopCommand cc = INVALID;
  while (1) {
    printf(">%s", GREEN);
    scanf("%127[^\n]%*c", line);
    printf("%s", NORMAL);
    //printf(">%s\n", line);
     
    if (sscanf(line, "%127s", command) == 1) {
      cc = loopCommandFromText(command); 
      //printf("command:%s (%d)\n", command, cc);
      if (cc == HELP) {
        showHelp();
      }
      else if (cc == MCOMMANDNAMES) {
        printf("<machine commands>\n");
      }
      else if (cc == INVALID) {
        printf("%sNot a recognised command!%s\n", RED, NORMAL);
        printf("%sType h for help%s\n", GREEN, NORMAL);
      }
      else if (cc == EXIT) {
        quit();
      }
    }

    //if (sscanf(line, "%127s '%127[^']'", command,param) == 2) 
    //    printf("com:%s param:%s\n", command, param);
    //if (strcmp(line, "quit") == 0) exit(1);
  }
  //newTape(&t); printTape(&t);
  return(0);
}
