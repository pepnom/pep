#ifndef COMMANDH 
#define COMMANDH

// valid commands on the machine. The structures in the info[]
// array should be in the same order for easy access
enum Command { 
  // workspace commands
  ADD=0, CLIP, CLOP, CLEAR, REPLACE, 
  UPPERC, LOWERC, CAPITALC, PRINT, 
  // stack commands
  POP, PUSH, POPALL, PUSHALL,
  // tape commands 
  PUT, GET, SWAP, INCREMENT, DECREMENT, MARK, GO, 
  // read commands
  READ, UNTIL, WHILE, WHILENOT, 
  // jumps
  JUMP, JUMPTRUE, JUMPFALSE,
  // tests
  TESTIS, TESTCLASS, TESTBEGINS, TESTENDS, TESTEOF, TESTTAPE,
  // accumulator commands
  COUNT, INCC, DECC, ZERO,
  // append character counter and newline counter
  CHARS, LINES, NOCHARS, NOLINES,
  // escape commands 
  ESCAPE, UNESCAPE, DELIM,
  // system commands
  STATE, QUIT, BAIL,
  // write workspace to file
  WRITE,
  NOP, 
  // not a recognised command
  UNDEFINED
};

// contains help information about all machine commands
struct MachineCommand {
  enum Command c;
  char * name;
  char abbreviation;
  int args;     // how many parameters for this command
  char * shortDesc;
  char * longDesc;
  char * example;
};

extern struct MachineCommand info[];

// given the abbreviated command, this returns the command
// number (in the array and enumeration)
enum Command abbrevToCommand(char c);

enum CommandType {JUMPS=0, TESTS, STACK, WORK, TAPE, ACCUMULATOR, OTHER};
// what type of command is it, a jump, test, stack, etc
enum CommandType commandType(enum Command com);

// given a short or long machine command name, return the 
// enum command value
enum Command textToCommand(const char * text);

// info functions: 
void fprintCommandNames(FILE * file);

void machineCommandHelp();

void searchCommandHelp(char * text);

void showCommandNames();

void fprintCommandSummary(FILE * file);

void showCommandSummary();

void printCommandInfo(enum Command command);

void machineCommandAsciiDoc(FILE * out);

void printCommandNamesAndDescriptions();

#endif

