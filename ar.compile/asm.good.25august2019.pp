
# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumpfalse not.in.class.7037
  clear
  jump parse
not.in.class.7037:
#---------------
# We can ellide all these single character tests, because
# the stack token is just the character itself with a *
testis "{"
jumpfalse 2 
jumptrue 17
testis "}"
jumpfalse 2 
jumptrue 14
testis ";"
jumpfalse 2 
jumptrue 11
testis ","
jumpfalse 2 
jumptrue 8
testis "!"
jumpfalse 2 
jumptrue 5
testis "B"
jumptrue 3 
testis "E"

jumpfalse not.quoteset.text.7258
  put
  add "*"
  push
  jump parse
not.quoteset.text.7258:
#---------------
# format: "text"
testis "\""
jumpfalse not.text.7376
  until "\""
  put
  clear
  add "quote*"
  push
  jump parse
not.text.7376:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse not.text.7661
  clear
  until "'"
  clip
  escape "\""
  put
  clear
  add "\""
  get
  add "\""
  put
  clear
  add "quote*"
  push
  jump parse
not.text.7661:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumpfalse not.text.7809
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
not.text.7809:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumpfalse not.text.8002
  clear
  until ")"
  clip
  put
  clear
  add "state*"
  push
  jump parse
not.text.8002:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse not.text.8959
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumpfalse not.text.8276
    clear
    jump 0
  not.text.8276:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse not.text.8777
    until "*#"
    testends "*#"
    jumpfalse not.ends.8574
      clear
      jump 0
    not.ends.8574:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  not.text.8777:
  # single line comments. some will get lost.
  put
  clear
  add "#"
  get
  until "\n"
  clip
  put
  clear
  add "comment*"
  push
  #clear; .restart 
  clear
  jump parse
not.text.8959:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^.]
jumptrue is.in.class.9340
  put
  clear
  add "!! Misplaced character '"
  get
  add "' in script near line "
  ll
  add " (character "
  cc
  add ") \n"
  print
  clear
  bail
is.in.class.9340:
#while [:alpha:]
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^.]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
testis "a"
jumpfalse not.text.9879
  clear
  add "add"
not.text.9879:
testis "k"
jumpfalse not.text.9909
  clear
  add "clip"
not.text.9909:
testis "K"
jumpfalse not.text.9939
  clear
  add "clop"
not.text.9939:
testis "D"
jumpfalse not.text.9972
  clear
  add "replace"
not.text.9972:
testis "d"
jumpfalse not.text.10003
  clear
  add "clear"
not.text.10003:
testis "t"
jumpfalse not.text.10034
  clear
  add "print"
not.text.10034:
testis "p"
jumpfalse not.text.10063
  clear
  add "pop"
not.text.10063:
testis "P"
jumpfalse not.text.10093
  clear
  add "push"
not.text.10093:
testis "G"
jumpfalse not.text.10122
  clear
  add "put"
not.text.10122:
testis "g"
jumpfalse not.text.10151
  clear
  add "get"
not.text.10151:
testis "x"
jumpfalse not.text.10181
  clear
  add "swap"
not.text.10181:
testis ">"
jumpfalse not.text.10209
  clear
  add "++"
not.text.10209:
testis "<"
jumpfalse not.text.10237
  clear
  add "--"
not.text.10237:
testis "r"
jumpfalse not.text.10267
  clear
  add "read"
not.text.10267:
testis "R"
jumpfalse not.text.10298
  clear
  add "until"
not.text.10298:
testis "w"
jumpfalse not.text.10329
  clear
  add "while"
not.text.10329:
testis "W"
jumpfalse not.text.10363
  clear
  add "whilenot"
not.text.10363:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumpfalse not.text.10841
  clear
  add "count"
not.text.10841:
testis "+"
jumpfalse not.text.10869
  clear
  add "a+"
not.text.10869:
testis "-"
jumpfalse not.text.10897
  clear
  add "a-"
not.text.10897:
testis "0"
jumpfalse not.text.10927
  clear
  add "zero"
not.text.10927:
testis "c"
jumpfalse not.text.10955
  clear
  add "cc"
not.text.10955:
testis "l"
jumpfalse not.text.10983
  clear
  add "ll"
not.text.10983:
testis "^"
jumpfalse not.text.11015
  clear
  add "escape"
not.text.11015:
testis "v"
jumpfalse not.text.11049
  clear
  add "unescape"
not.text.11049:
testis "S"
jumpfalse not.text.11080
  clear
  add "state"
not.text.11080:
testis "q"
jumpfalse not.text.11110
  clear
  add "quit"
not.text.11110:
testis "Q"
jumpfalse not.text.11140
  clear
  add "bail"
not.text.11140:
testis "s"
jumpfalse not.text.11171
  clear
  add "write"
not.text.11171:
testis "o"
jumpfalse not.text.11200
  clear
  add "nop"
not.text.11200:
testis "add"
jumpfalse 2 
jumptrue 113
testis "clip"
jumpfalse 2 
jumptrue 110
testis "clop"
jumpfalse 2 
jumptrue 107
testis "replace"
jumpfalse 2 
jumptrue 104
testis "clear"
jumpfalse 2 
jumptrue 101
testis "print"
jumpfalse 2 
jumptrue 98
testis "pop"
jumpfalse 2 
jumptrue 95
testis "push"
jumpfalse 2 
jumptrue 92
testis "put"
jumpfalse 2 
jumptrue 89
testis "get"
jumpfalse 2 
jumptrue 86
testis "swap"
jumpfalse 2 
jumptrue 83
testis "++"
jumpfalse 2 
jumptrue 80
testis "--"
jumpfalse 2 
jumptrue 77
testis "read"
jumpfalse 2 
jumptrue 74
testis "until"
jumpfalse 2 
jumptrue 71
testis "while"
jumpfalse 2 
jumptrue 68
testis "whilenot"
jumpfalse 2 
jumptrue 65
testis "jump"
jumpfalse 2 
jumptrue 62
testis "jumptrue"
jumpfalse 2 
jumptrue 59
testis "jumpfalse"
jumpfalse 2 
jumptrue 56
testis "testis"
jumpfalse 2 
jumptrue 53
testis "testclass"
jumpfalse 2 
jumptrue 50
testis "testbegins"
jumpfalse 2 
jumptrue 47
testis "testends"
jumpfalse 2 
jumptrue 44
testis "testeof"
jumpfalse 2 
jumptrue 41
testis "testtape"
jumpfalse 2 
jumptrue 38
testis "count"
jumpfalse 2 
jumptrue 35
testis "a+"
jumpfalse 2 
jumptrue 32
testis "a-"
jumpfalse 2 
jumptrue 29
testis "zero"
jumpfalse 2 
jumptrue 26
testis "cc"
jumpfalse 2 
jumptrue 23
testis "ll"
jumpfalse 2 
jumptrue 20
testis "escape"
jumpfalse 2 
jumptrue 17
testis "unescape"
jumpfalse 2 
jumptrue 14
testis "state"
jumpfalse 2 
jumptrue 11
testis "quit"
jumpfalse 2 
jumptrue 8
testis "bail"
jumpfalse 2 
jumptrue 5
testis "write"
jumptrue 3 
testis "nop"

jumpfalse not.quoteset.text.11607
  put
  clear
  add "word*"
  push
  jump parse
not.quoteset.text.11607:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
testis ".restart"
jumpfalse not.text.11846
  clear
  add "jump 0"
  put
  clear
  add "command*"
  push
  jump parse
not.text.11846:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis ".reparse"
jumpfalse not.text.12164
  clear
  add "jump parse"
  put
  clear
  add "command*"
  push
  jump parse
not.text.12164:
testis "parse>"
jumpfalse not.text.12264
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
not.text.12264:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse not.text.12480
  put
  add "*"
  push
  jump parse
not.text.12480:
add " << unknown command on line "
ll
add " (char "
cc
add ")"
add " of source file. \n"
print
clear
quit
# ----------------------------------
# PARSING PHASE:
# the lexing phase finishes here, and below is the 
# parse/compile phase of the script. Here we pop tokens 
# off the stack and check for sequences of tokens eg word*semicolon*
# If we find a valid series of tokens, we "shift-reduce" or "resolve"
# the token series eg word*semicolon* --> command*
# At the same time, we manipulate (transform) the attributes on the 
# tape, as required. So Tape=|pop|;| becomes |\npop| where the 
# bars | indicate tape cells. (2 tapes cells are merged into 1).
# Each time the stack is reduced, the tape must also be reduced
# 
parse:
#-------------------------------------
# 2 tokens
#-------------------------------------
pop
pop
# All of the below are currently errors, but may not
# be in the future if we expand the syntax of the parse
# language. Also consider:
#    begintext* endtext* quoteset* notclass*, !* ,* ;* B* E*
# It is nice to trap the errors here because we can emit some
# hopefully not-very-cryptic error messages with a line number.
# Otherwise the script writer has to debug with
#   pp -a asm.pp scriptfile -I
testis "word*word*"
jumpfalse 2 
jumptrue 74
testis "word*}*"
jumpfalse 2 
jumptrue 71
testis "word*begintext*"
jumpfalse 2 
jumptrue 68
testis "word*endtext*"
jumpfalse 2 
jumptrue 65
testis "word*!*"
jumpfalse 2 
jumptrue 62
testis "word*,*"
jumpfalse 2 
jumptrue 59
testis "quote*word*"
jumpfalse 2 
jumptrue 56
testis "quote*class*"
jumpfalse 2 
jumptrue 53
testis "quote*state*"
jumpfalse 2 
jumptrue 50
testis "quote*}*"
jumpfalse 2 
jumptrue 47
testis "quote*begintext*"
jumpfalse 2 
jumptrue 44
testis "quote*endtext*"
jumpfalse 2 
jumptrue 41
testis "class*word*"
jumpfalse 2 
jumptrue 38
testis "class*quote*"
jumpfalse 2 
jumptrue 35
testis "class*class*"
jumpfalse 2 
jumptrue 32
testis "class*state*"
jumpfalse 2 
jumptrue 29
testis "class*}*"
jumpfalse 2 
jumptrue 26
testis "class*begintext*"
jumpfalse 2 
jumptrue 23
testis "class*endtext*"
jumpfalse 2 
jumptrue 20
testis "class*!*"
jumpfalse 2 
jumptrue 17
testis "class*,*"
jumpfalse 2 
jumptrue 14
testis "notclass*word*"
jumpfalse 2 
jumptrue 11
testis "notclass*quote*"
jumpfalse 2 
jumptrue 8
testis "notclass*class*"
jumpfalse 2 
jumptrue 5
testis "notclass*state*"
jumptrue 3 
testis "notclass*}*"

jumpfalse not.quoteset.text.14353
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (missing semicolon?) \n"
  print
  clear
  quit
not.quoteset.text.14353:
testis "{*;*"
jumpfalse 2 
jumptrue 5
testis ";*;*"
jumptrue 3 
testis "}*;*"

jumpfalse not.quoteset.text.14542
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced semi-colon? ; \n"
  print
  clear
  quit
not.quoteset.text.14542:
testis ",*{*"
jumpfalse not.text.14710
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra comma in list? \n"
  print
  clear
  quit
not.text.14710:
testis "!*{*"
jumpfalse not.text.14890
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced negation operator (!)? \n"
  print
  clear
  quit
not.text.14890:
testis "!*command*"
jumpfalse not.text.15094
  push
  push
  add "error near line "
  ll
  add " (at char "
  cc
  add ") \n"
  add " The negation operator (!) is not valid in this context. \n"
  print
  clear
  quit
not.text.15094:
testis "!*begintext*"
jumptrue 3 
testis "!*endtext*"

jumpfalse not.quoteset.text.15385
  push
  push
  add "error near line "
  ll
  add " (at char "
  cc
  add ") \n"
  add " The negation operator (!) has not been implemented  \n"
  add " for 'begin-tests' and 'end-tests' (but maybe in the future) \n"
  print
  clear
  quit
not.quoteset.text.15385:
testis ";*{*"
jumpfalse 2 
jumptrue 5
testis "command*{*"
jumptrue 3 
testis "commandset*{*"

jumpfalse not.quoteset.text.15588
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: no test for brace block? \n"
  print
  clear
  quit
not.quoteset.text.15588:
testis "{*}*"
jumpfalse not.text.15719
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
not.text.15719:
#-----------------------------------------
# trying to parse comments so as not to lose them
# tricky .... 
testends "comment*"
jumpfalse not.ends.16083
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse not.text.16003
    jump 0
  not.text.16003:
  clear
  --
  get
  ++
  add "\n"
  get
  --
  put
  ++
  clear
  jump parse
not.ends.16083:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumpfalse not.begins.16700
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse not.text.16468
    jump 0
  not.text.16468:
  # some tricky juggling of the unknown token
  # get rid of comment* token but conserve other one.
  ++
  put
  pop
  clear
  ++
  get
  push
  clear
  --
  --
  --
  get
  ++
  add "\n"
  get
  --
  put
  ++
  clear
  jump parse
not.begins.16700:
#-----------------------------------------
# format: ![:alpha:] or ![a-z] or ![abcd]  
#  This format is used to indicate a negative class test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
testis "!*class*"
jumpfalse not.text.17027
  clear
  add "notclass*"
  push
  get
  --
  put
  ++
  clear
  jump parse
not.text.17027:
#-----------------------------------------
# format: !"text" 
#  This format is used to indicate a negative workspace text test
#  eg: !"" { add "not empty!!"; } print; clear;
testis "!*quote*"
jumpfalse not.text.17311
  clear
  add "notquote*"
  push
  get
  --
  put
  ++
  clear
  jump parse
not.text.17311:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse not.text.17583
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
not.text.17583:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse not.text.17894
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
not.text.17894:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse not.text.18493
  clear
  # check if command requires parameter
  get
  testis "add"
  jumpfalse 2 
  jumptrue 17
  testis "until"
  jumpfalse 2 
  jumptrue 14
  testis "while"
  jumpfalse 2 
  jumptrue 11
  testis "whilenot"
  jumpfalse 2 
  jumptrue 8
  testis "escape"
  jumpfalse 2 
  jumptrue 5
  testis "unescape"
  jumptrue 3 
  testis "replace"
  
  jumpfalse not.quoteset.text.18363
    add " < command needs an argument, on line: "
    ll
    print
    clear
    quit
  not.quoteset.text.18363:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
not.text.18493:
#-----------------------------------------
# ebnf: commandset := command, command ;
testis "command*command*"
jumptrue 3 
testis "commandset*command*"

jumpfalse not.quoteset.text.18819
  clear
  add "commandset*"
  push
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
not.quoteset.text.18819:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------------------
# ebnf: quoteset := quote , "," , quote ;
#      quoteset := quoteset, "," quote ;
# This allows multiple "testis" tests for one block which is 
# very useful. But this is a little tricky to compile because we
# dont know the jump target yet. But it is solvable
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse not.text.20790
  clear
  get
  testis "replace"
  jumpfalse not.text.20332
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  not.text.20332:
  testis "add"
  jumpfalse 2 
  jumptrue 14
  testis "until"
  jumpfalse 2 
  jumptrue 11
  testis "while"
  jumpfalse 2 
  jumptrue 8
  testis "whilenot"
  jumpfalse 2 
  jumptrue 5
  testis "escape"
  jumptrue 3 
  testis "unescape"
  
  jumpfalse not.quoteset.text.20594
    clear
    add "command*"
    push
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
  not.quoteset.text.20594:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
not.text.20790:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z]
testis "word*class*;*"
jumpfalse not.text.21297
  clear
  get
  testis "while"
  jumptrue 3 
  testis "whilenot"
  
  jumpfalse not.quoteset.text.21147
    clear
    add "command*"
    push
    # a command plus argument, eg while [a-z] 
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
  not.quoteset.text.21147:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
not.text.21297:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse not.text.21958
  clear
  get
  testis "replace"
  jumpfalse not.text.21838
    clear
    add "command*"
    push
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    --
    get
    add " "
    ++
    get
    add " "
    ++
    get
    --
    --
    put
    ++
    clear
    jump parse
  not.text.21838:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
not.text.21958:
#-------------------------------------
# format: begin { #* commands *# }
# implementing begin blocks which are only executed once (they
# will be put before the "start:" label. They must come before
# all other commands.
testis "begin*{*commandset*}*"
jumptrue 3 
testis "begin*{*command*}*"

jumpfalse not.quoteset.text.22344
  clear
  ++
  ++
  get
  --
  --
  put
  clear
  add "beginblock*"
  push
  jump parse
not.quoteset.text.22344:
# A new approach to quotesets, hopefully to eliminate the rabbit
# hops
# an interesting "look-ahead" technique for compiling quotesets
# uses the accumulator to keep track of the jumptrue target
# This eliminates the need for "rabbit-hops" for the jumptrue code.
testis "quote*,*quote*{*"
jumpfalse not.text.23067
  zero
  clear
  add "testis "
  get
  add "\n"
  add "jumptrue 3 \n"
  ++
  ++
  add "testis "
  get
  add "\n"
  # dont add jumpfalse here
  # add "jumpfalse ";
  # the final jumpfalse target will be added when
  # "quoteset*{*commandset*}*" is parsed
  --
  --
  put
  a+
  a+
  a+
  a+
  a+
  clear
  add "quoteset*{*"
  push
  push
  jump parse
not.text.23067:
testis "quote*,*quoteset*{*"
jumpfalse not.text.23314
  clear
  add "testis "
  get
  add "\n"
  add "jumpfalse 2 \n"
  add "jumptrue "
  count
  add "\n"
  ++
  ++
  get
  --
  --
  put
  clear
  add "quoteset*{*"
  push
  push
  a+
  a+
  a+
  jump parse
not.text.23314:
#-------------------------------------
testis "quote*{*commandset*}*"
jumptrue 3 
testis "quote*{*command*}*"

jumpfalse not.quoteset.text.23976
  clear
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
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
not.quoteset.text.23976:
#-------------------------------------
# ebnf: 
#   command := quoteset , "{" , commandset , "}" ;
#   command := quoteset , "{" , command , "}" ;
# examples: 
#   "text","more","and" { add ":"; print; clear; }
#   "text","more","and" { print; }
testis "quoteset*{*commandset*}*"
jumptrue 3 
testis "quoteset*{*command*}*"

jumpfalse not.quoteset.text.24718
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  # quotesets compile differently to quote blocks
  clear
  get
  add "\njumpfalse not.quoteset.text."
  cc
  add "\n"
  ++
  ++
  get
  add "\nnot.quoteset.text."
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
not.quoteset.text.24718:
#-------------------------------------
# ebnf: 
#   command := begintext , "{" , commandset , "}" ;
#   command := begintext , "{" , command , "}" ;
# examples: 
#   B"text" { add ":"; print; clear; }
#   B"text" { print; }
testis "begintext*{*commandset*}*"
jumptrue 3 
testis "begintext*{*command*}*"

jumpfalse not.quoteset.text.25345
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "testbegins "
  get
  add "\njumpfalse not.begins."
  cc
  add "\n"
  ++
  ++
  get
  add "\nnot.begins."
  cc
  --
  --
  add ":"
  put
  clear
  add "command*"
  push
  jump parse
not.quoteset.text.25345:
#-------------------------------------
# bnf: command <- endtext { commandset } 
# bnf: command <- endtext { command } 
# format:  ,"text" { add ":"; print; clear; }
# format:  ,"text" { print; }
testis "endtext*{*commandset*}*"
jumptrue 3 
testis "endtext*{*command*}*"

jumpfalse not.quoteset.text.25947
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "testends "
  get
  add "\njumpfalse not.ends."
  cc
  add "\n"
  ++
  ++
  get
  add "\nnot.ends."
  cc
  --
  --
  add ":"
  put
  clear
  add "command*"
  push
  jump parse
not.quoteset.text.25947:
#-------------------------------------
# formats: [:alpha:] { add ":"; print; clear; }
#          [a-z] { print; }
#   this syntax pattern executes a brace-block of commands if
#   the single letter in the workspace is in a particular
#   character class, list or range.
testis "class*{*commandset*}*"
jumptrue 3 
testis "class*{*command*}*"

jumpfalse not.quoteset.text.26631
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
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
not.quoteset.text.26631:
#-------------------------------------
# formats:  ![:alpha:] { add ":"; print; clear; }
#           ![a-z] { print; }
#   this syntax pattern executes a brace-block of commands if
#   all the letters in the workspace are not in a particular
#   character class, list or range.
testis "notclass*{*commandset*}*"
jumptrue 3 
testis "notclass*{*command*}*"

jumpfalse not.quoteset.text.27293
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "testclass "
  get
  add "\njumptrue is.in.class."
  cc
  add "\n"
  ++
  ++
  get
  add "\nis.in.class."
  cc
  --
  --
  add ":"
  put
  clear
  add "command*"
  push
  jump parse
not.quoteset.text.27293:
#-------------------------------------
# formats:  !"text" { #*commands*# }
#   this syntax pattern executes a brace-block of commands if
#   the  letter in the workspace is not in a particular
#   character class, list or range.
testis "notquote*{*commandset*}*"
jumptrue 3 
testis "notquote*{*command*}*"

jumpfalse not.quoteset.text.27894
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "testis "
  get
  add "\njumptrue is.text."
  cc
  add "\n"
  ++
  ++
  get
  add "\nis.text."
  cc
  --
  --
  add ":"
  put
  clear
  add "command*"
  push
  jump parse
not.quoteset.text.27894:
#-------------------------------------
# format:  (eof) { add ":"; print; clear; }
# format:  (==)  { print; }
testis "state*{*commandset*}*"
jumptrue 3 
testis "state*{*command*}*"

jumpfalse not.quoteset.text.28967
  clear
  # indent for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  get
  testis "eof"
  jumpfalse not.text.28418
    clear
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
  not.text.28418:
  # ----------
  # compile to tape= test 
  testis "=="
  jumpfalse not.text.28707
    clear
    add "testtape "
    add "\njumpfalse not.testtape."
    cc
    add "\n"
    ++
    ++
    get
    add "\nnot.testtape."
    cc
    --
    --
    add ":"
    put
    clear
    add "command*"
    push
    jump parse
  not.text.28707:
  add ": unknown state test near line "
  ll
  add " of script.\n"
  add " State tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
not.quoteset.text.28967:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse not.eof.30550
  print
  clear
  #---------------------
  # check if the script correctly parsed (there should only
  # be one token on the stack, namely "commandset*" or "command*"
  pop
  pop
  testis "commandset*"
  jumptrue 3 
  testis "command*"
  
  jumpfalse not.quoteset.text.29704
    push
    --
    add "# Assembled with the script 'compile.pss' \n"
    add "start:\n"
    get
    # an extra space because of a bug in compile()
    add "\njump start \n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    # print
    # save the compiled script to 'sav.pp'
    write
    clear
    quit
  not.quoteset.text.29704:
  testis "beginblock*commandset*"
  jumptrue 3 
  testis "beginblock*command*"
  
  jumpfalse not.quoteset.text.30185
    clear
    add "# Assembled with the script 'compile.pss' \n"
    get
    add "\n"
    ++
    add "start:\n"
    get
    # an extra space because of a bug in compile()
    add "\njump start \n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    # print
    # also save the compiled script to 'sav.pp'
    write
    clear
    quit
  not.quoteset.text.30185:
  push
  push
  # state
  clear
  add "After compiling with 'compile.pss' (at EOF): \n "
  add "  parse error in input script, check syntax or try \n "
  add "  'pp -Ia asm.pp script' to debug compilation \n "
  print
  clear
  # clear sav.pp because script could not be compiled
  write
  # bail means exit with error
  bail
not.eof.30550:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
