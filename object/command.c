/*

  This object represent one machine command (eg "add", "clip", "delete")
  but without the commands parameters.

*/

#include <stdio.h>
#include <string.h>
#include "colours.h"
#include "command.h"

struct MachineCommand info[] = { 
  { ADD, "add", 'a', 1,
     "adds a given text to the workspace buffer", 
     "appends text to the workspace buffer.", 
     "'tree' { put; clear; add 'noun*'; push; }" },
  { CLIP, "clip", 'k', 0,
     "removes one character from the end of the workspace", 
     "One character is removed from the end of the workspace \n"
     "register. The peek register and all other registers are unchanged. \n"
     "This instruction is useful for obtaining the value of a token when \n"
     "the end delimiter of the token is not wanted. ", 
     "'\"' { clear; until '\"'; clip; print; } clear; \n "
     " prints all text within quotes but first removing the \n"
     " the quotes. The above example could also have been \n"
     " done with whilenot '\"' and without the clip but in cases \n"
     " where the end delimiter is more than one character, until \n"
     " seems to be required." },
  { CLOP, "clop", 'K', 0,
     "removes one character from the beginning of the workspace", 
     "One character is deleted from the beginning of the workspace \n"
     "register. All other registers are unchanged. ", 
     "d; add 'abc'; clop; print; \n"
     "prints 'bc' many times. " },
  { CLEAR, "clear", 'd', 0,
     "clears the workspace", 
     "This instruction deletes the contents of the workspace \n"
     "register. All other registers are unchanged. The parsing machine \n "
     "is designed so that all text manipulation should take place in \n"
     "the workspace register (which is like a text 'accumulator' or an \n"
     "AX/EAX register in the x86 architecture. The clear instruction is \n"
     "one of a set of pp instructions which modifies the workspace. \n" , 
     "clear;" },
  { REPLACE, "replace", 'D', 2,
     "replace one string with another in the workspace", 
     "This command is useful for simple stream editing, such  \n" 
     "indented a code text file (replace '\\n' '\\n  ';) or adding the \n"
     "bash comment symbol # at the beginning of each line \n"
     "(replace '\\n' '\\n#';). It can also be used to delete text from \n"
     "the input stream (eg: replace 'gone' '';). The replace machine \n"
     "instruction does not support regular expressions or other patters \n"
     "it only replaces simple text. This is a limitation, but also a \n"
     "deliberate design choice.\n",
     "replace 'big' 'small'; replace '\\n' ''; D '\\t' '  '; " },
  { UPPERC, "upper", 'u', 0,
     "converts all characters to uppercase in the workspace", 
     "converts all characters to uppercase in the workspace", 
     "r;upper;print;d;  \n"
     "   convert the input to uppercase." },
  { LOWERC, "lower", 'U', 0,
     "converts all characters to lowercase in the workspace", 
     "converts all characters to lowercase in the workspace", 
     "r;lower;print;d;  \n"
     "   convert the input to all lowercase." },
  { CAPITALC, "cap", 'A', 0,
     "First char in workspace uppercase, the rest lowercase", 
     "First char in workspace uppercase, the rest lowercase", 
     "r;cap;print;d;  \n"
     "   ...." },
  { PRINT, "print", 't', 0,
     "prints the workspace to stdout", 
     "prints the content of the workspace register to standard-out. \n"
     "Unlike the sed stream editor, the pattern parser has no implicit \n"
     "print instruction compiled by default. ", 
     "t;t;t;d;  \n"
     "   print every character in the input stream 3 times" },
  { POP, "pop", 'p', 0,
    "pops from the stack to the start of the workspace", 
    "Pop scans the content of the stack starting from its end  \n"
    "and skipping the '*' delimiter character if it is the \n"
    "last char on the stack \n"
    "and scanning backwards until it encounters \n"
    "another * delimiter character \n"
    "(or whatever is the stack token delimiter). It then adjusts the \n "
    "workspace register pointer so that it points either to the next '*' \n"
    "on the stack, or else to the beginning of the stack. Pop also \n"
    "decrements the tape pointer by one (or does nothing if the \n"
    "tape pointer == 0). If the stack is empty when 'pop' is executed \n"
    "then the state of the machine is unchanged (including the tape \n"
    "pointer)",
    "pop; \n"
    "if the stack == 'adj*noun*' before pop is executed and \n"
    " the workspace == 'verb*fullstop*' then, after the pop \n"
    " the stack will be 'adj*' and the workspace will be \n"
    " noun*verb*fullstop* and the tapepointer will be one less \n"
    },
  { PUSH, "push", 'P', 0,
    "push (*) delimited token from start of the workspace to the stack", 
    "Push appends a delimited token from the beginning of the \n"
    "workspace register to the end of the stack register. If there is \n"
    "no text in the workspace then no action is taken and the machine \n"
    "state is unchanged. The amount \n"
    "of text appended is determined by the placement of the token \n"
    "delimiter character (usually *). Push also increments the current \n"
    "tape cell by one, but only if the workspace is not empty. \n", 
    "push; \n"
    "  If the workspace was adj*noun*verb* before the push, then after \n"
    "  the push it will be 'noun*verb*'. If the stack was sentence* \n"
    "  before the push, then it will be 'sentence*adj*' after the push. \n"
    "  It should be noted that the 'stack' is really just a character \n"
    "  buffer which can be manipulated in stack-like ways with push and pop" },
  { POPALL, "unstack", 'U', 0,
    "pops entire stack onto the beginning of the workspace", "", 
    "unstack;" },
  { PUSHALL, "stack", 'u', 0,
    "pushes entire workspace onto the stack", "", 
    "stack;" },
  { PUT, "put", 'G', 0,
    "puts the workspace into the current tape cell", 
    "copies the content of the machine workspace register \n"
    "into the tape cell currently indicated by the tape pointer. \n"
    "The previous contents of this tape cell are overwritten. \n"
    "The contents of the workspace register are unchanged by this \n"
    "instruction.", 
    "put;" },
  { GET, "get", 'g', 0,
    "Appends current tape cell to the workspace", 
    "This appends the contents of the current tape cell to the workspace \n"
    "register. The contents of the tape cell are unchanged by this \n"
    "instruction.", 
    "put; get; print; clear; \n"
    "  prints every character in the input stream twice.\n"
    "  [note that there is an implicit 'read' at the beginning \n"
    "   of every script, and an implicit 'jump 0' looping instruction \n"
    "   at the end of every script. This is because the pattern parsing \n"
    "   machine is designed to operate on streams, one character at a \n"
    "   time]. " },
  { SWAP, "swap", 'x', 0,
    "swaps the current tape cell and the workspace", 
    "The contents of the workspace register and the current \n"
    "tape cell are swapped.", 
    "swap; print; clear; \n"
    "   prints each pair of characters in the input stream in \n"
    "   reverse order. That is, if the input stream is 'abcdef' \n"
    "   then the script will print 'badcfe'" },
  { INCREMENT, "++", '>', 0,
    "increments the current tape cell by one", 
    "When a push operation on the stack is performed, auto ++", 
    "++;" },
  { DECREMENT, "--", '<', 0,
    "decrements the current tape cell by one", 
    "The tape cell pointer is decreased by 1. If the tape cell pointer \n"
    "is already zero, then this instruction does nothing. This instruction \n"
    "is useful to access the values/ attributes of parsing tokens on the \n"
    "stack, but the script writer needs to realign the tape pointer, so \n"
    "that subsequent pushes and pops will work correctly. In general, this \n"
    "means that ++ instructions should be matched by -- instructions and \n"
    "vice-versa. ",
    "get; --; get; ++; \n" 
    "  gets last 2 attributes from the tape \n"
    "  ... \n" },
  { MARK, "mark", 'm', 1,
    "marks the current tape cell with the given text", 
    "", "" },
  { MARKTAPE, "marktape", '1', 0,
    "marks the current tape cell with the text of the current tape cell", 
    "", "" },
  { GO, "go", 'M', 1,
    "sets the tape cell pointer to the marked cell", 
    "", "" },
  { GOTAPE, "gotape", '&', 0,
    "sets the current tape cell to the marked cell in the current tapecell", 
    "", "" },
  { READ, "read", 'r', 0,
    "read a character from the input stream", 
    "The character in the peep register is appended to the end of the \n"
    "workspace register, and then the next character from the input stream \n"
    "is placed in the peep register. If the peep register already holds \n"
    "the end-of-file token, then the program will normally exit. \n\n"
    "All scripts have an implicit 'read' instruction at the very beginning \n"
    "of the program. (The internal compiler places a 'read' instruction \n"
    "at position 0). This is because the pattern parser is designed to \n"
    "cycle through input streams one character at a time. A program which \n"
    "is hand-assembled in the interpreter or a text file does not need to \n"
    "include the initial 'read' instruction, but the program may not be \n"
    "very useful without it." , 
    "t;r;d; \n"
    "  deletes every second character from the input stream \n"
    "  This script would be compiled to 'assembly' as: \n"
    "     read \n"
    "     print \n"
    "     read \n"
    "     clear \n"
    "     jump 0 \n" },
  { UNTIL, "until", 'R', 1, 
    "reads the input stream until the workspace ends with given text", 
    "While the workspace buffer does not end with the given \n"
    "text, the input stream is read through the peep register and \n"
    "appended to the workspace. However, the 'until' command \n"
    "takes note of the character in the escape register and ignores \n"
    "text ending with characters escaped with that character. \n\n"
    "This instruction is useful for parsing tokens which have a \n"
    "multiple-character end delimiter, such as, html comments which \n"
    "end with -->. Or c comments ending in */ ", 
    "'/' { r; '*' {until '*/'; d; }} t;d;  \n"
    "  deletes c style comments from the input stream \n"
    "  Note that unlike 'sed', \n"
    "  in pep there is no implicit 'print' instruction] "}, 
  { UNTILTAPE, "untiltape", 'T', 0, 
    "reads the input stream until the workspace ends with tape-cell text", 
    "The input stream is read until the work-space end with\n"
    "the text in the current tape-cell, ignoring 'escaped' text or \n"
    "characters (according to the current escape character). ",
    "begin { a '*/'; put; d; } '/' { r; '*' {until; d; }} t;d;  \n"
    "  (sort of) deletes c style comments from the input stream \n"},
  { WHILE, "while", 'w', 1,
    "reads io while peek is something", 
    "While continues to read the input stream while \n"
    "the character in the 'peek' register is in a particular \n"
    "character class (eg, alphanumeric, integer, whitespace etc) \n"
    "character range (eg p-z) or a character list (eg: 678abc^&*). \n\n"
    "This instruction is useful for parsing tokens which are defined \n"
    "by a set of legal characters, for example c identifiers \n",
    "while :alnum:; w a-f; while abxy; w \"" },
  { WHILENOT, "whilenot", 'W', 1,
    "reads io while peek is not something", 
    "The whilenot machine instruction is the complementary \n"
    "instruction to the while instruction. It reads the input stream \n"
    "while the character in the peek register is not a specified \n"
    "character class, character range or character list. \n"
    "", 
    "W :punct: \n"
    "  keep reading the input stream and append to the workspace \n"
    "  register as long as the peek register is not a punctuation \n"
    "  character. " },
  { JUMP, "jump", 'b', 1,
    "unconditional jump to absolute instruction number", 
    "Transfer program control to the given instruction number. \n"
    "This command is automatically compiled into a program as the last \n"
    "instruction in the form JUMP 0. This is because, pp, like sed has \n"
    "an implicit character reading loop. The command is not designed to \n"
    "be used in a script, but can be used in an assembler code text file. ",
    "jump 0; " },
  { JUMPTRUE, "jumptrue", 'j', 1,
    "jump to relative instruction +/-N if flag is set to true ", 
    "Jumps if the flag is set to true. This flag is set by \n"
    "instructions such as testis, testbegins etc. The parameter to \n"
    "the instruction is a relative offset of the next \n"
    "instruction to be executed by the machine. \n"
    "This is designed only to be used in assembler code text files. \n"
    "",
    "jumptrue 10  \n"
    "  jumps forward 10 instructions if the flag register is set to true " },
  { JUMPFALSE, "jumpfalse", 'J', 1,
    "jump to relative instruction +/-N if flag is set to false ", 
    "If the flag register is set to false, transfer program control \n"
    "to the specified instruction at offset. If the flag register is true \n"
    "the state of the machine is unchanged and the next instruction in the \n"
    "program will be executed. \n\n"
    "This instruction is used in conjuction with the 'test' instructions \n"
    "to implement condition behaviour. In particular, it allows certain \n"
    "instructions to be skipped if certain conditions in the workspace \n"
    "register are met. This is a relative jump", 
    "J -10 \n"
    "  jumps back 10 instructions if the flag register is set to false" },
  { TESTIS, "testis", '=', 1,
    "Test if the workspace equals the given text", 
    "If the workspace buffer is exactly the same as the text \n"
    "then set the machine flag to true.  \n",
    " \"abc\" { pop; } \n "
    "  pop one item off the machine stack if the workspace \n"
    "  is currently equal to 'abc'." },
  { TESTCLASS, "testclass", '?', 1,
    "test if all characters in the workspace are in given class/list/range", 
    "[note: on reflection, this instruction could be amalgamated \n"
    "with the testis instruction. The only difference is the datatype \n"
    "of the parameter- range a-z, list abcd, class :alnum:, text blah etc] \n"
    "This command allows \n"
    "character class tests eg [:space:] tests if \n"
    "the workspace consists entirely of space characters \n"
    "[:digit:] tests that the workspace only contains numeric digits \n"
    "Also range tests, eg: '[a-z]' workspace only has characters "
    "Also list tests, eg: '[abxy]' workspace must contain only the "
    "listed characters ",
    "[:alnum:] { add 'X' } \n "
    "  adds X to the workspace if the workspace consists only of \n"
    "  alphanumeric characters." },
  { TESTBEGINS, "testbegins", 'b', 1,
    "tests if the workspace begins with the given text", 
    "If the workspace buffer ends with the specified text "
    "then the flag register is set to false, otherwise it is "
    "set to true. This command is used in conjuction with the "
    "jump instructions to control program flow.", 
    ".\"abc\" { clear; } \n"
    "  deletes the content of the workspace if it begins with \n"
    "  'abc' " },
  { TESTENDS, "testends", 'B', 1,
    "tests if the workspace ends with the given text", 
    "Check if the workspace register ends with the given text \n"
    "and set the machine flag register to true if so, and to false \n"
    "otherwise. ", 
    ",\"abc\" { clear; } \n"
    "  deletes the content of the workspace if it ends with \n"
    "  'abc' " },
  { TESTEOF, "testeof", 'E', 0,
    "tests if the peep register contains the end of file character", 
    "long desc...", 
    "EOF { print 'end of file'; } \n"
    "   prints 'end of file' when the end of the input stream has \n"
    "   been reached." },
  { TESTTAPE, "testtape", '*', 0,
    "tests if the workspace is the same as the content of the current cell", 
    "If the current cell (the cell pointed to by the tape pointer) \n"
    "of the machine tape structure is exactly equal \n"
    "to the content of the workspace register, then the flag register is \n"
    "set to true, otherwise the flag is set to false.", 
    "** { print 'equal'; } \n"
    "  print the word equal to standard-out if the tape cell is \n"
    "  the same as the workspace." },
  { COUNT, "count", 'n', 0,
    "appends the value of the accumulator to the workspace", 
    "The (long?) integer accumulator is appended as text to the \n"
    "workspace buffer with no preceding space. ", 
    "add 'chars read'; count; " },
  { INCC, "a+", '+', 0,
    "increments the machine accumulator by one", 
    "increments the integer accumulator in the parsing machine \n"
    "Hopefully this accumulator will be useful in implementing address \n"
    "calculation when 'assembling' programs. This type of calculation \n"
    "is required when converting if and loop blocks in highish level \n"
    "languages to forward jumps in assembler type languages. \n"
    "Since the pattern parsing machine is designed to transform, translate \n"
    "compile and assemble, this is an important function.", 
    "a+ ; EOF { add 'total chars = '; count; print; } \n"
    "  for every character read from the input stream, increment \n"
    "  the machine accumulator. At the end of the input stream, \n"
    "  display the total number of characters in the stream/ file. " },
  { DECC, "a-", '-', 0,
    "decrements the accumulator by one", 
    "Decrements the integer accumulator in the parsing machine. \n"
    "incc and decc could be used, for example to ensure that opening \n "
    "and closing braces in some programming language are 'balanced'. ",
    "a-; \n"
    "  decrement the accumulator by one." },
  { ZERO, "zero", '0', 0,
    "sets the numerical accumulator to zero", 
    "resets the machine accumulator back to zero. ", 
    "incc; print; 0; print; " },
  { CHARS, "cc", 'c', 0,
    "Appends number of characters read to end of workspace buffer", 
    "Appends number of characters read to end of workspace buffer", 
    "add 'chars read='; cc; print; clear; " },
  { LINES, "ll", 'l', 0,
    "Appends number of lines read to end of workspace buffer", 
    "Appends number of lines read to end of workspace buffer", 
    "add 'lines read='; ll; print; clear; " },
  { NOCHARS, "nochars", 'C', 0,
    "Sets the character counter to zero", 
    "Sets the character counter to zero", 
    "nochars; " },
  { NOLINES, "nolines", 'L', 0,
    "Sets the line counter to zero", 
    "Sets the line counter to zero", 
    "nolines; " },
  { ESCAPE, "escape", '^', 1,
    "prefixes the given character with the escape character ", 
    "This command replaces a character with itself preceded by \n"
    "the machines escape char (default is \\). This is important in \n"
    "many parsing situations because it allows, for example, a double \n"
    "quote character to be included within double quotes.",
    "esc ';'; \n"
    "   replace all occurrences of the semi-colon in the workspace \n"
    "   with \\; or the machine escape character."},
  { UNESCAPE, "unescape", 'v', 1,
    "converts chars to unescaped equivalent", 
    "removes the escape char (default: \\) prefix from the given character\n" 
    "checking that the character really is escaped by counting the number\n"
    "of escape characters before it. ", 
    "unescape '\"';" },
  { ECHAR, "echar", 'z', 1,
    "changes the escape character to the given character ", 
    " ", 
    "delim '/';" },
  { DELIM, "delim", 'z', 1,
    "changes the stack token delimited to the given character ", 
    " ", 
    "delim '/';" },
  { STATE, "state", 'S', 0,
    "prints the current state of the machine.", 
    "state prints to stdout the values of the registers of "
    "the parsing machine, such as the workspace, the stack, the peep "
    "the tape and the numerical accumulator",
    "state; " },
  { QUIT, "quit", 'q', 0,
    "immediately exits the script", 
    "This command ceases all commands and exits the parsing machine \n"
    "process.", 
    "quit; " },
  { BAIL, "bail", 'Q', 0,
    "immediately exits the script with a non zero error code", 
    "This command performs the same as the 'quit' command, but \n"
    "tells the machine interpreter to generate a non-zero error code \n"
    "on exit.", 
    "bail; " },
  { WRITE, "write", 's', 0,
    "writes the workspace to default file 'sav.pp'", 
    "The contents of the workspace are saved to the file 'sav.pp'  \n"
    "This is also used to convert a script to assembler and then run it", 
    "write; " },
  { WRITEFILE, "writefile", 'f', 1,
    "writes the workspace to a file", 
    "The contents of the workspace are saved to the file  \n"
    "and (any) existing contents of the file are overwritten. ", 
    "write 'filename'; #* or *# f 'filename';" },

  { WRITEFILEAPPEND, "appendfile", 'F', 1,
    "appends the workspace to a given file", 
    "The contents of the workspace are appended to the file,  \n"
    "but the contents of the file are not overwritten. ", 
    "writeappend 'file'; #* or *# F 'filename';" },
  { SYSTEM, "system", 'X', 0,
    "execute workspace as system command and read results to workspace", 
    "...", 
    "system;" },
  { NOP, "nop", 'o', 0,
    "no operation",
    "this command performs no operation. The program ip is incremented \n"
    "by 1 and the state of the machine is otherwise unchanged. \n"
    "I am not actually convinced \n"
    "that it is necessary, but since most real machines have a nop \n"
    "I will kowtow to the tyranny of consensus.",
    "nop; \n"
    "  the state of the machine is unchanged except that the \n"
    "  instruction pointer is incremented by 1." },
  { UNDEFINED, "undefined", 'e', 0,
    "undefined command",
    "The undefined command is used as a 'bookend' programmatically "
    "and to catch all invalid commands. When a program is cleared "
    "all instruction commands are set to undefined.",
    "n/a" }
};

// given the abbreviated command, this returns the command
// number (in the array and enumeration)
enum Command abbrevToCommand(char c) {
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    if (info[ii].abbreviation == c) return ii;
  }
  return UNDEFINED;
} 

// what type of command is it, a jump, test, stack, etc
enum CommandType commandType(enum Command com) {
  if (strncmp(info[com].name, "jump", 4) == 0)
    return JUMPS;
  if (strncmp(info[com].name, "test", 4) == 0) 
    return TESTS;
  if (strcmp(info[com].name, "push") == 0) 
    return STACK;
  if (strcmp(info[com].name, "pop") == 0) 
    return STACK;
  if (strcmp(info[com].name, "get") == 0) 
    return TAPE;
  if (strcmp(info[com].name, "put") == 0) 
    return TAPE;
  if (strcmp(info[com].name, "a+") == 0) 
    return ACCUMULATOR;
  if (strcmp(info[com].name, "a-") == 0) 
    return ACCUMULATOR;
  if (strcmp(info[com].name, "zero") == 0) 
    return ACCUMULATOR;
  if (strcmp(info[com].name, "cc") == 0) 
    return ACCUMULATOR;
  if (strcmp(info[com].name, "ll") == 0) 
    return ACCUMULATOR;
  if (strcmp(info[com].name, "until") == 0) 
    return WORK;
  if (strcmp(info[com].name, "while") == 0) 
    return WORK;
  if (strcmp(info[com].name, "whilenot") == 0) 
    return WORK;
  if (strcmp(info[com].name, "read") == 0) 
    return WORK;

  return OTHER;
}

// given a short or long machine command name, return the 
// enum command value
enum Command textToCommand(const char * text) {
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    if ((strlen(text) == 1) && (info[ii].abbreviation == text[0]))
      return ii;
    else if (strcmp(text, info[ii].name) == 0) 
      return ii;
  }
  return UNDEFINED;
} 

// info functions: 
void fprintCommandNames(FILE * file) {
  printf("Valid machine commands are [name (abbrev)]:\n ");
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    printf("%s ", info[ii].name);
  }
  printf("\n");
} 

// display help for all commands, one per line 
void machineCommandHelp() {
  printf("%s[All machine instructions]%s:\n", YELLOW, NORMAL);
  int ii;
  char key;
  for (ii = 0; ii < UNDEFINED; ii++) {
    printf(" %s%c%s - %s: %s%s%s \n", 
      WHITE, info[ii].abbreviation, BLUE, info[ii].name, GREEN,
      info[ii].shortDesc, NORMAL);
    if ( (ii+1) % 14 == 0 ) {
      pagePrompt();
      key = getc(stdin);
      if (key == 'q') { return; }
    }
  }
  printf("\n");
} 


// searches info array for machine commands matching a search term
void searchCommandHelp(char * text) {
  int ii; 
  int jj = 0;
  printf("%s[Searching machine commands]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < UNDEFINED; ii++) {
    if ((strstr(info[ii].shortDesc, text) != NULL) ||
        (strstr(info[ii].longDesc, text) != NULL) ||
        (strstr(info[ii].name, text) != NULL)) {
      jj++; 

      printf(" %s%c%s - %s: %s \n", 
        GREEN, info[ii].abbreviation, NORMAL, info[ii].name,
        info[ii].shortDesc );

      if ( (jj+1) % 14 == 0 ) {
        pagePrompt();
        getc(stdin);
      }
    } // if search term found
  } // for

  if (jj == 0) {
    printf("No results found for '%s'\n", text); 
  }
}

void showCommandNames() {
  printf("%s Valid machine commands are [name (abbrev)]: \n%s", BLUE, NORMAL);
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    printf(" %s %s(%s%c%s)%s", 
      info[ii].name, GREY, YELLOW, info[ii].abbreviation, GREY, NORMAL);
    if ( (ii+1) % 4 == 0 ) { printf ("\n"); }
  }
  printf("\n");
} 

// display each machine command and a one line description 
// of what it does using bash colours
void fprintCommandSummary(FILE * file) {
  printf("All Machine Commands:\n");
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    printf("%s\n %s", info[ii].name, info[ii].shortDesc);
  }
  printf("\n");
} 

// display each machine command and a one line description 
// of what it does using bash colours and paging a few lines at 
// a time
void showCommandSummary() {
  printf("%sA Summary of All Machine Commands:\n%s ",BLUE,NORMAL);
  printf("%sFormat: name (abbreviation) title\n%s ",CYAN,NORMAL);
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    printf("%s%s (%c)%s\n  %s\n%s", 
      BLUE, info[ii].name, info[ii].abbreviation,
      GREEN, info[ii].shortDesc, NORMAL);
    if ( (ii+1) % 10 == 0 ) {
      printf("any key to continue...");
      getc(stdin);
    }
  }
  printf("\n");
} 


// print all information about a given command 
void printCommandInfo(enum Command command) {
  printf(
    "command name: %s\n"
    "abbreviation: %c\n"
    "number of arguments: %d\n"
    "short description: %s\n"
    "long description: %s\n"
    "example: %s\n",
    info[command].name, info[command].abbreviation,
    info[command].args, info[command].shortDesc, info[command].longDesc,
    info[command].example
    );
} 

/* try to print all machine commands and descriptions in a format
   suitable for output in various formats. So the output may be
   a type of 'asciidoc' or 'markdown' */
void machineCommandAsciiDoc(FILE * out) {
  // using 'asciidoc' description list
  printf("commands of the parsing virtual machine:\n ");
  int ii;
  struct MachineCommand com;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    com = info[ii]; 
    fprintf(out, "%s::\n%s\n%s\n", 
      com.name, com.shortDesc, com.longDesc);
  }
  printf("\n");
} 

void printCommandNamesAndDescriptions() {
  printf("Valid commands are:\n ");
  int ii;
  for (ii = ADD; ii < UNDEFINED; ii++) {
    printf("%s;\n  %s\n", info[ii].name, info[ii].shortDesc);
  }
  printf("\n");
} 

//----------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

