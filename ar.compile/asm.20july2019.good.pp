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
  Or, will be able to.

  * append a dot to all lower case ascii letters 
  >>  [a-z] { add "."; print; clear; }

  * the same as above, using abbreviated commands
  >>  [a-z] { a ".";t;d; }

  * append a dot to the letters a, d or f 
  >>  [adf] { add "."; print; clear; }

  * append a dot to all alpha-numeric letters 
  >>  [:alpha:] { add "."; print; clear; }

  * print a message if work space is a letter and end reached (nested tests) 
  >>  [a-z] { <eof> { add "last letter"; print;  }}

  * if the end of file/stream has been reached, print "no more!"
  >> <eof> { clear; add "no more!"; print; clear;  }

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
    add "end of script!! \n"
    print
    clear
    #---------------------
    # check if the script correctly parsed (there should only
    # be one token on the stack, namely "commandset*"
    pop
    pop
    testis "commandset*"
    jumptrue ok
    testis "command*"
    jumptrue ok
      push
      push
      state
      clear
      add "Bad syntax in script! "
      print
      quit
ok:
    clear
    add "start:\n"
    get
    # an extra space because of a bug in compile()
    add "\njump start \n"
    # print just for debuging
    print
    # save the compiled script to 'sav.pp'
    write
    clear 
    quit
not.eof:

newline:
  #-----------------------------
  # was using the accumulator to make unique labels. but
  testis "\n"
  jumpfalse whitespace
  a+ 

 #--------------
 whitespace:
  testclass [:space:] 
  jumpfalse openbrace
    clear
    jump 0 
 #---------------
 openbrace:
  testis "{" 
  jumpfalse closebrace 
    put
    add "*"
    push
    jump parse 
 #---------------
 closebrace:
  testis "}" 
  jumpfalse semicolon
    put
    add "*"
    push
    jump parse 
 #---------------
 # format: ; 
 # we just put the character itself on the stack as a token
 # in the form ;*  (char delimiter)
 semicolon:
  testis ";" 
  jumpfalse quotetext 
    put 
    add "*"
    push
    jump parse 
 #---------------
 # format: "text"
 quotetext:
  testis "\"" 
  jumpfalse singlequotetext 
    until "\""
    put
    clear
    add "quote*"
    push 
    jump parse 
 #---------------
 # format: 'text', this will be changed to "text"
 singlequotetext:
  testis "'" 
  jumpfalse class
    clear 
    add "\""
    until "'"
    clip
    add "\""
    put
    clear
    add "quote*"
    push 
    jump parse 
 #---------------
 # formats: [:space:] [a-z] [abcd] [:alpha:] etc 
 class:
  testis "[" 
  jumpfalse statetest 
    until "]"
    put
    clear
    add "class*"
    push 
    jump parse 
 #---------------
 # formats: (eof) etc 
 statetest:
  testis "(" 
  jumpfalse comment
    clear
    until ")"
    clip
    put
    clear
    add "state*"
    push 
    jump parse 
 #---------------
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

 # legal characters for keywords (commands)
 testclass [abcdefghijklmnopqrstuvwxyzKGPRWS+-<>0^]
 jumptrue alpha 
# maybe handle other things here 
#
   clear
   jump parse 
alpha:
   #while [:alpha:]
   # my testclass implementation cannot handle complex lists
   # eg [a-z+-] this is why I have to write out the whole alphabet
   while [abcdefghijklmnopqrstuvwxyzKGPRWS+-<>0^]
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
   testis "cc" 
   jumptrue keyword 
   testis "c" 
   jumpfalse 4
   clear
   add "cc"
   jumptrue keyword 
   #------------ 
   testis "ll" 
   jumptrue keyword 
   testis "l" 
   jumpfalse 4
   clear
   add "ll"
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
   testis "q" 
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

     add " <unknown command!> on line "
     ll 
     add " of source file "
     print
     clear
     quit

keyword:
   put
   clear
   add "word*"
   push
   jump parse
   

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

#-------------------------------------
# 2 tokens
#-------------------------------------
   pop
   pop


error.word.word:
   testis "word*word*"
   jumptrue error.two.tokens 
   testis "quote*word*"
   jumptrue error.two.tokens 
   testis "class*word*"
   jumptrue error.two.tokens 
   testis "word*}*"
   jumptrue error.two.tokens 
   testis "quote*}*"
   jumptrue error.two.tokens 
   testis "class*}*"
   jumptrue error.two.tokens 
   jump word.colon 

error.two.tokens:
   push 
   push
   add "error near line " 
   ll
   add " of script (missing semicolon?) \n"
   print
   clear
   quit
    
#--------------------------------------------
# bnf: <command> ::= <keyword> <colon>
# formats: "pop; push; clear; print; " etc
word.colon:

   testis "word*;*"
   jumpfalse commandset.command

   clear
   #-----------------------
   # check if "add", "until" etc 
   get 
   testis "add"
   jumptrue missing.parameter
   testis "until"
   jumptrue missing.parameter
   testis "while"
   jumptrue missing.parameter
   testis "whilenot"
   jumptrue missing.parameter
   testis "escape"
   jumptrue missing.parameter
   testis "unescape"
   jumptrue missing.parameter
   jump ok.command
missing.parameter:
   add ": command needs an argument, on line: " 
   ll
   print
   clear
   quit
ok.command:
   clear
   add "command*"
   #-------------
   # no need to format tape cells because current cell contains word
   push
   jump parse

#-----------------------------------------
# bnf: commandset <= command command
# 
commandset.command:
   testis "command*command*"
   jumptrue yes.commandset.command
   testis "commandset*command*"
   jumptrue yes.commandset.command
   jump three.tokens

yes.commandset.command:
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
   jump parse
   
#-------------------
# 3 tokens
#-------------------
three.tokens:

   pop
#--------------------------------------------
# bnf: command <= keyword quoted-text semi-colon
# format: add "text";

   testis "word*quote*;*"
   jumpfalse word.class.colon

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
   testis "escape"
   jumptrue good.quote.command
   testis "unescape"
   jumptrue good.quote.command
   #------
   # error 
   add ": command does not take an argument \n" 
   print
   clear
   # error: print machine state and exit. 
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
   jump parse

#----------------------------------
# parsing format: "while [:alpha:] ;" 
word.class.colon:
   testis "word*class*;*"
   jumpfalse four.tokens

   clear
   get 
   testis "while"
   jumptrue good.class.command
   testis "whilenot"
   jumptrue good.class.command
   #------
   # error 
   add ": command cannot have a class argument \n" 
   add "line "
   ll  
   add ": error in script \n"
   print
   clear
   quit

good.class.command:
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
   jump parse


   jump 4.tokens

# -------------------------------
# 4 tokens
# -------------------------------
four.tokens:

   pop
#-------------------------------------
# bnf: command <= quote open-brace commandset close-brace
# bnf: command <= quote open-brace command close-brace
# format:  "text" { add ":"; print; clear; }
# format:  "text" { print; }

quote.block:
   testis "quote*{*commandset*}*"
   jumptrue is.quote.block
   testis "quote*{*command*}*"
   jumptrue is.quote.block
   jump class.block

is.quote.block:
   clear
   # ----------
   # compile to assembly
   add "testis "
   get
   add "\njumpfalse not.text."
   cc
   add "\n"
   ++
   ++
   get 
   add "\nnot.text."
   cc
   --
   --
   add ":"
   put
   clear

   add "command*"
   push
   # always reparse/compile
   jump parse

#-------------------------------------
# format:  [:alpha:] { add ":"; print; clear; }
# format:  [a-z] { print; }

class.block:
   testis "class*{*commandset*}*"
   jumptrue is.class.block
   testis "class*{*command*}*"
   jumptrue is.class.block
   jump eof.block 

is.class.block:
   clear
   # ----------
   # compile to assembly
   add "testclass "
   get
   add "\njumpfalse not.in.class."
   cc
   add "\n"
   ++
   ++
   get 
   add "\nnot.in.class."
   cc
   --
   --
   add ":"
   put
   clear

   add "command*"
   push
   jump parse
#-------------------------------------
# format:  [:alpha:] { add ":"; print; clear; }
# format:  [a-z] { print; }

eof.block:
   testis "state*{*commandset*}*"
   jumptrue is.state.block
   testis "state*{*command*}*"
   jumptrue is.state.block
   jump again

is.state.block:
   clear
   # ----------
   # compile to assembly
   add "testeof "
   add "\njumpfalse not.eof."
   cc
   add "\n"
   ++
   ++
   get 
   add "\nnot.eof."
   cc
   --
   --
   add ":"
   put
   clear

   add "command*"
   push
   jump parse

again:
   push 
   push
   push
   push

   jump 0

#--- end of parse/compile assembler script
