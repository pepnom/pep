#* 

   asm.pp
   This "assembler" script works with the pattern parsing machine
   at http://bumble.sf.net/books/gh/gh.c

   The proof is in the pudding!!
   As with many somewhat unnecessary software projects, this uses
   itself to parse and compile itself. This asm script demonstrates
   how the pp machine can parse and transform a context free language
   (in this case a pattern parsing script)

ASSEMBLER

  This script is written in an assembly language. 

  As with all assembly languages, only one instruction per line.
  blank lines are ok. Labels must end with : 
  
SCRIPT EXAMPLES

  here are few examples of the format that this pp script can parse
    
  * append a dot to all lower case ascii letters 
  >>  [a-z] { add "."; print; clear; }

  * the same as above, using abbreviated commands
  >>  [a-z] { a ".";t;d; }

  * append a dot to the letters a, d or f 
  >>  [adf] { add "."; print; clear; }

  * append a dot to all alpha-numeric letters 
  >>  [:alpha:] { add "."; print; clear; }

  * if the end of file/stream has been reached, print "no more!"
  <eof> { clear; add "no more!"; print; clear;  }

TRANSFORMATIONS

   This script implements a set of transformations (which we could call
   a "compilation") from a sed-like (the unix stream editor) syntax
   to a kind of "assembly language". It is an assembly language in the 
   sense that each line of the assembly file corresponds to one instruction
   on the machine.

   This script needs to transform  "pop ;" to "\npop \n" for example
   * below is a more complex transformation, with a multiline
     bracketed statement. The script is transformed into an "assembler"
     format which can be loaded with the function loadAssembledProgram()
     in the gh.c code.

   :"abc" { add "gg"; print; clear; } 
   --> becomes
     testis "abc"
     jumpfalse 4
     add "gg"
     print
     clear


HISTORY

    
  16 july 2019
    think I have fixed the bug. Took a while to get round to it.
    just stopped subtracting linenumber in instructionFromText() jump
    calculations.

    revisiting. There is still a bug in the gh.c code about how
    absolute jump addresses are calculated. But it is not a difficult
    bug, and I think I could fix it in an hour or so. But I 
    havent done it.

  3 sept 2018
    Started to code this, since the pp machine (gh.c) is sufficiently
    complete to make it possible. Need to actually start doing 
    stack parsing, and think about what syntax to use for tests
    eg startwith ."abc" endswith ,"abc" equals :"abc"
    As you can see by this file, multiline comments are ok. 

 The code should assemble a script
 this assembler implements a type of bnf grammar
 eg: arg { statements } --> statement
     statement statement --> statements
     keyword arg colon --> statement
 or: class { s1 } --> s1
     class { slist } --> s1
     qarg  { slist } --> s1
 etc

*# 

start:
  read

  testeof
  jumpfalse not.eof
    add "end of file!! \n"
    print
    clear
    pop
    add ":\n"
    get
    print
    clear 
    quit
not.eof:

newline:
  #-----------------------------
  # keep track of line numbers for error messages
  # but multiline comments stop this from working
  testis "\n"
  jumpfalse whitespace
  incc

whitespace:
  #--------------
  testclass [:space:] 
  jumpfalse openbrace
    clear
    jump 0 
 # commands are terminated with semi-colons
 openbrace:
  testis "{" 
  jumpfalse closebrace 
 # need to put this token on the stack 
    put
    add "*"
    push
    jump parse 
 closebrace:
  testis "}" 
  jumpfalse semicolon
 # need to put this token on the stack 
    put
    add "*"
    push
    jump parse 
 semicolon:
  testis ";" 
  jumpfalse quotetext 
 # need to put this token on the stack 
    put 
    add "*"
    push
    jump parse 
 quotetext:
  testis "\"" 
  jumpfalse comment
    until "\""
    put
    clear
    add "quote*"
    push 
    jump parse 
 # multiline and single line comments. 
 comment:
  testis "#" 
  jumpfalse nocomment
    clear
    read
    testis "\n" 
    jumpfalse multiline
    clear
    jump 0 
 #----------------------------
 # checking for multiline comments of the form "#* \n\n\n *#"
 # these are just ignored at the moment (deleted) 
 multiline:
    testis "*" 
    jumpfalse oneline 
    until "*#"
    clear
    jump 0 
 oneline:
    until "\n" 
 #  print
    clear 
    jump 0
 nocomment:
 #----------------------------------
 # parse command words (and abbreviations)

 testclass [:alpha:]
 jumptrue alpha 
# maybe handle other things here 
#
   clear
   jump parse 
alpha:
   while [:alpha:]
   #----------------------------------
   # KEYWORDS 
   # here we can test for all the keywords (command words) and their
   # abbreviated one letter versions (eg: clip k, clop K etc). Then
   # we can print an error message and abort if the word is not a 
   # legal keyword for the parse-edit language

   testis "add" 
   jumptrue keyword 
   testis "a" 
   jumpfalse 4
   clear
   add "add"
   jumptrue keyword 
   #------------ 
   testis "clip" 
   jumptrue keyword 
   testis "k" 
   jumpfalse 4
   clear
   add "clip"
   jumptrue keyword 
   #------------ 
   testis "clop" 
   jumptrue keyword 
   testis "K" 
   jumpfalse 4
   clear
   add "clop"
   jumptrue keyword 
   #------------ 
   testis "clear" 
   jumptrue keyword 
   testis "d" 
   jumpfalse 4
   clear
   add "clear"
   jumptrue keyword 
   #------------ 
   testis "print" 
   jumptrue keyword 
   testis "t" 
   jumpfalse 4
   clear
   add "print"
   jumptrue keyword 
   #------------ 
   testis "pop" 
   jumptrue keyword 
   testis "p" 
   jumpfalse 4
   clear
   add "pop"
   jumptrue keyword 
   #------------ 
   testis "push" 
   jumptrue keyword 
   testis "P" 
   jumpfalse 4
   clear
   add "push"
   jumptrue keyword 
   #------------ 
   testis "put" 
   jumptrue keyword 
   testis "G" 
   jumpfalse 4
   clear
   add "put"
   jumptrue keyword 
   #------------ 
   testis "get" 
   jumptrue keyword 
   testis "g" 
   jumpfalse 4
   clear
   add "get"
   jumptrue keyword 
   #------------ 
   testis "swap" 
   jumptrue keyword 
   testis "x" 
   jumpfalse 4
   clear
   add "swap"
   jumptrue keyword 
   #------------ 
   testis "++" 
   jumptrue keyword 
   testis ">" 
   jumpfalse 4
   clear
   add "++"
   jumptrue keyword 
   #------------ 
   testis "--" 
   jumptrue keyword 
   testis "<" 
   jumpfalse 4
   clear
   add "--"
   jumptrue keyword 
   #------------ 
   testis "swap" 
   jumptrue keyword 
   testis "x" 
   jumpfalse 4
   clear
   add "swap"
   jumptrue keyword 
   #------------ 
   testis "read" 
   jumptrue keyword 
   testis "r" 
   jumpfalse 4
   clear
   add "read"
   jumptrue keyword 
   #------------ 
   testis "until" 
   jumptrue keyword 
   testis "R" 
   jumpfalse 4
   clear
   add "until"
   jumptrue keyword 
   #------------ 
   testis "while" 
   jumptrue keyword 
   testis "w" 
   jumpfalse 4
   clear
   add "while"
   jumptrue keyword 
   #------------ 
   testis "whilenot" 
   jumptrue keyword 
   testis "W" 
   jumpfalse 4
   clear
   add "whilenot"
   jumptrue keyword 
   #------------ 
   testis "jump" 
   jumptrue keyword 
   testis "," 
   jumpfalse 4
   clear
   add "jump"
   jumptrue keyword 
   #------------ 
   testis "jumptrue" 
   jumptrue keyword 
   testis "j" 
   jumpfalse 4
   clear
   add "jumptrue"
   jumptrue keyword 
   #------------ 
   testis "jumpfalse" 
   jumptrue keyword 
   testis "J" 
   jumpfalse 4
   clear
   add "jumpfalse"
   jumptrue keyword 
   #------------ 
   testis "testis" 
   jumptrue keyword 
   testis "=" 
   jumpfalse 4
   clear
   add "testis"
   jumptrue keyword 
   #------------ 
   testis "testclass" 
   jumptrue keyword 
   testis "?" 
   jumpfalse 4
   clear
   add "testclass"
   jumptrue keyword 
   #------------ 
   testis "testbegins" 
   jumptrue keyword 
   testis "b" 
   jumpfalse 4
   clear
   add "testbegins"
   jumptrue keyword 
   #------------ 
   testis "testends" 
   jumptrue keyword 
   testis "B" 
   jumpfalse 4
   clear
   add "testends"
   jumptrue keyword 
   #------------ 
   testis "testeof" 
   jumptrue keyword 
   testis "E" 
   jumpfalse 4
   clear
   add "testeof"
   jumptrue keyword 
   #------------ 
   testis "testtape" 
   jumptrue keyword 
   testis "*" 
   jumpfalse 4
   clear
   add "testtape"
   jumptrue keyword 
   #------------ 
   testis "count" 
   jumptrue keyword 
   testis "n" 
   jumpfalse 4
   clear
   add "count"
   jumptrue keyword 
   #------------ 
   testis "a+" 
   jumptrue keyword 
   testis "+" 
   jumpfalse 4
   clear
   add "a+"
   jumptrue keyword 
   #------------ 
   testis "a-" 
   jumptrue keyword 
   testis "-" 
   jumpfalse 4
   clear
   add "a-"
   jumptrue keyword 
   #------------ 
   testis "zero" 
   jumptrue keyword 
   testis "0" 
   jumpfalse 4
   clear
   add "zero"
   jumptrue keyword 
   #------------ 
   testis "escape" 
   jumptrue keyword 
   testis "^" 
   jumpfalse 4
   clear
   add "escape"
   jumptrue keyword 
   #------------ 
   testis "unescape" 
   jumptrue keyword 
   testis "v" 
   jumpfalse 4
   clear
   add "unescape"
   jumptrue keyword 
   #------------ 
   testis "state" 
   jumptrue keyword 
   testis "S" 
   jumpfalse 4
   clear
   add "state"
   jumptrue keyword 
   #------------ 
   testis "quit" 
   jumptrue keyword 
   testis "e" 
   jumpfalse 4
   clear
   add "quit"
   jumptrue keyword 
   #------------ 
   testis "write" 
   jumptrue keyword 
   testis "s" 
   jumpfalse 4
   clear
   add "write"
   jumptrue keyword 
   #------------ 
   testis "nop" 
   jumptrue keyword 
   testis "o" 
   jumpfalse 4
   clear
   add "nop"
   jumptrue keyword 
   #------------ 

     add " <unknown command!>\n"
     print
     clear
     jump parse
keyword:
   put
   clear
   add "word*"
   push

jump 0

# ----------------------------------
# PARSING PHASE:
# the lexing phase finishes here, and below is the 
# parse/compile phase of the script. Here we pop tokens 
# off the stack and check for sequences of tokens eg word*semicolon*
# If we find a valid series of tokens, we "shift-reduce" or "resolve"
# The token series eg word*semicolon* --> command*
#
# At the same time, we manipulate (transform) the attributes on the 
# tape, as required. So Tape=|pop|;| becomes |\npop| where the 
# bars | indicate tape cells. (2 tapes cells are merged into 1).
#
# In this section we also have to manipulate the tape (to actually "compile"
# the script). Each time the stack is reduced, the tape must also be reduced
# 
parse:

#-------------------
# 4 tokens

# bnf: <command> ::= <quote> <open-brace> <commandset> <close-brace>
# bnf: <command> ::= <quote> <open-brace> <command> <close-brace>
   pop 
   pop 
   pop
   pop

quote.block:
   testis "quote*{*commandset*}*"
   jumptrue is.quote.block
   testis "quote*{*command*}*"
   jumptrue is.quote.block
   jump not.quote.block

is.quote.block:
   clear
   # ----------
   # compile to assembly

   add "testis "
   get
   add "\njumpfalse label."
   count
   add "\n"
   ++
   ++
   get 
   add "\nlabel."
   count
   --
   --
   add ":"
   put
   clear

   add "command*"
   push

   # It is necessary to jump back to the "parse:" label because other
   # bnf reduction rules may apply
   # For example:
   #  1. commandset := commandset command
   #  2. command := word quote semicolon
   # If rule 2 applies then we need to also check if rule 1 
   # applies. We could just put rule 1 after rule 2, but it
   # is not always possible to guarantee that that will work
   # in all cases.

   jump parse

not.quote.block:

# It seems redundant to push 4 times and then pop 3 times
# but it is necessary because the machine ignores a 
# push on an empty workspace, and also ignores a pop on
# an empty stack. This is tricky, but it seems to be working

   push
   push
   push
   push

   pop
   pop
   pop

   testis "word*quote*;*"
   jumpfalse not.quote.command 

# bnf: <command> ::= <keyword> <quoted-text> <semi-colon>
#--------------------------------------------
   clear
   get 
   testis "add"
   jumptrue good.quote.command
   testis "until"
   jumptrue good.quote.command
   testis "while"
   jumptrue good.quote.command
   testis "whilenot"
   jumptrue good.quote.command
   #------
   # error 
   add ": command does not take an argument \n" 
   print
   clear

   # print machine state an exit. 
   state
   quit

good.quote.command:
   clear
   add "command*"
   push
   #---------------------------
   # a command plus argument, eg add "this" 
   --
   get
   add " "
   ++
   get
   -- 
   put
   ++
   clear

not.quote.command:
   push
   push 
   push

   pop
   pop
   testis "word*;*"
   jumpfalse commandset 

# bnf: <command> ::= <keyword> <colon>
#--------------------------------------------
# handle "pop; push; clear; print; " etc
# put check for "add;" is an error, because add requires an argument
#

   clear
   #-----------------------
   # check if "add", "until" etc 
   get 
   testis "add"
   jumptrue bad.command
   testis "until"
   jumptrue bad.command
   testis "while"
   jumptrue bad.command
   testis "whilenot"
   jumptrue bad.command
   jump ok.command

bad.command:
   add ": command needs an argument \n" 
   print
   clear
   jump 0

ok.command:
   clear
   add "command*"
   #-------------
   # no need to format tape cells because current cell contains word
   push

   pop
   pop

# bnf: <commandset> ::= <command> <command>
commandset:
   testis "command*command*"
   jumpfalse commandset.command
   clear
   add "commandset*"
   push

   #---------------------------
   # format the tape attributes. Add the next command on a newline 
   --
   get
   add "\n"
   ++
   get
   -- 
   put
   ++
   clear
   #--------------------------
   jump 0
   
# bnf equivalent: <commandset> ::= <commandset> <command>
commandset.command:
   testis "commandset*command*"
   jumpfalse again 
   clear
   add "commandset*"
   push
   #---------------------------
   # format the tapecells. Add the next command on a newline 
   # -- and ++ (tape pointer commands) should be balance here 
   # because after formatting a cell the pointer should point
   # where it was before.
   --
   get
   add "\n"
   ++
   get
   -- 
   put
   ++
   clear
   #--------------------------
   jump 0
   


again:
   push 
   push
   jump 0

# not used at the moment
parsecompile:

continue:
# not keyword
 clear
 jump 0
# end of code
