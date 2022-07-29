# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumptrue 2 
jump block.end.10606
  clear
  jump parse
block.end.10606:
#---------------
# We can ellide all these single character tests, because
# the stack token is just the character itself with a *
# Braces {} are used for blocks, ',' and '.' for concatenating
# tests with OR or AND logic. 'B' and 'E' for begin and end
# tests. 
testis "{"
jumptrue 16
testis "}"
jumptrue 14
testis ";"
jumptrue 12
testis ","
jumptrue 10
testis "."
jumptrue 8
testis "!"
jumptrue 6
testis "B"
jumptrue 4
testis "E"
jumptrue 2 
jump block.end.10968
  put
  add "*"
  push
  jump parse
block.end.10968:
#---------------
# format: "text"
testis "\""
jumptrue 2 
jump block.end.11086
  until "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.11086:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumptrue 2 
jump block.end.11371
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
block.end.11371:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumptrue 2 
jump block.end.11519
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.11519:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumptrue 2 
jump block.end.11712
  clear
  until ")"
  clip
  put
  clear
  add "state*"
  push
  jump parse
block.end.11712:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumptrue 2 
jump block.end.12669
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumptrue 2 
  jump block.end.11986
    clear
    jump start
  block.end.11986:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumptrue 2 
  jump block.end.12487
    until "*#"
    testends "*#"
    jumptrue 2 
    jump block.end.12284
      clear
      jump start
    block.end.12284:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  block.end.12487:
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
block.end.12669:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^]
jumpfalse 2 
jump block.end.13049
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
block.end.13049:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
testis "a"
jumptrue 2 
jump block.end.13567
  clear
  add "add"
block.end.13567:
testis "k"
jumptrue 2 
jump block.end.13597
  clear
  add "clip"
block.end.13597:
testis "K"
jumptrue 2 
jump block.end.13627
  clear
  add "clop"
block.end.13627:
testis "D"
jumptrue 2 
jump block.end.13660
  clear
  add "replace"
block.end.13660:
testis "d"
jumptrue 2 
jump block.end.13691
  clear
  add "clear"
block.end.13691:
testis "t"
jumptrue 2 
jump block.end.13722
  clear
  add "print"
block.end.13722:
testis "p"
jumptrue 2 
jump block.end.13751
  clear
  add "pop"
block.end.13751:
testis "P"
jumptrue 2 
jump block.end.13781
  clear
  add "push"
block.end.13781:
testis "G"
jumptrue 2 
jump block.end.13810
  clear
  add "put"
block.end.13810:
testis "g"
jumptrue 2 
jump block.end.13839
  clear
  add "get"
block.end.13839:
testis "x"
jumptrue 2 
jump block.end.13869
  clear
  add "swap"
block.end.13869:
testis ">"
jumptrue 2 
jump block.end.13897
  clear
  add "++"
block.end.13897:
testis "<"
jumptrue 2 
jump block.end.13925
  clear
  add "--"
block.end.13925:
testis "r"
jumptrue 2 
jump block.end.13955
  clear
  add "read"
block.end.13955:
testis "R"
jumptrue 2 
jump block.end.13986
  clear
  add "until"
block.end.13986:
testis "w"
jumptrue 2 
jump block.end.14017
  clear
  add "while"
block.end.14017:
testis "W"
jumptrue 2 
jump block.end.14051
  clear
  add "whilenot"
block.end.14051:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumptrue 2 
jump block.end.14529
  clear
  add "count"
block.end.14529:
testis "+"
jumptrue 2 
jump block.end.14557
  clear
  add "a+"
block.end.14557:
testis "-"
jumptrue 2 
jump block.end.14585
  clear
  add "a-"
block.end.14585:
testis "0"
jumptrue 2 
jump block.end.14615
  clear
  add "zero"
block.end.14615:
testis "c"
jumptrue 2 
jump block.end.14643
  clear
  add "cc"
block.end.14643:
testis "l"
jumptrue 2 
jump block.end.14671
  clear
  add "ll"
block.end.14671:
testis "^"
jumptrue 2 
jump block.end.14703
  clear
  add "escape"
block.end.14703:
testis "v"
jumptrue 2 
jump block.end.14737
  clear
  add "unescape"
block.end.14737:
testis "z"
jumptrue 2 
jump block.end.14768
  clear
  add "delim"
block.end.14768:
testis "S"
jumptrue 2 
jump block.end.14799
  clear
  add "state"
block.end.14799:
testis "q"
jumptrue 2 
jump block.end.14829
  clear
  add "quit"
block.end.14829:
testis "Q"
jumptrue 2 
jump block.end.14859
  clear
  add "bail"
block.end.14859:
testis "s"
jumptrue 2 
jump block.end.14890
  clear
  add "write"
block.end.14890:
testis "o"
jumptrue 2 
jump block.end.14919
  clear
  add "nop"
block.end.14919:
testis "rs"
jumptrue 2 
jump block.end.14953
  clear
  add "restart"
block.end.14953:
testis "rp"
jumptrue 2 
jump block.end.14987
  clear
  add "reparse"
block.end.14987:
testis "add"
jumptrue 84
testis "clip"
jumptrue 82
testis "clop"
jumptrue 80
testis "replace"
jumptrue 78
testis "clear"
jumptrue 76
testis "print"
jumptrue 74
testis "pop"
jumptrue 72
testis "push"
jumptrue 70
testis "put"
jumptrue 68
testis "get"
jumptrue 66
testis "swap"
jumptrue 64
testis "++"
jumptrue 62
testis "--"
jumptrue 60
testis "read"
jumptrue 58
testis "until"
jumptrue 56
testis "while"
jumptrue 54
testis "whilenot"
jumptrue 52
testis "jump"
jumptrue 50
testis "jumptrue"
jumptrue 48
testis "jumpfalse"
jumptrue 46
testis "testis"
jumptrue 44
testis "testclass"
jumptrue 42
testis "testbegins"
jumptrue 40
testis "testends"
jumptrue 38
testis "testeof"
jumptrue 36
testis "testtape"
jumptrue 34
testis "count"
jumptrue 32
testis "a+"
jumptrue 30
testis "a-"
jumptrue 28
testis "zero"
jumptrue 26
testis "cc"
jumptrue 24
testis "ll"
jumptrue 22
testis "escape"
jumptrue 20
testis "unescape"
jumptrue 18
testis "delim"
jumptrue 16
testis "state"
jumptrue 14
testis "quit"
jumptrue 12
testis "bail"
jumptrue 10
testis "write"
jumptrue 8
testis "nop"
jumptrue 6
testis "reparse"
jumptrue 4
testis "restart"
jumptrue 2 
jump block.end.15422
  put
  clear
  add "word*"
  push
  jump parse
block.end.15422:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis "parse>"
jumptrue 2 
jump block.end.16107
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
block.end.16107:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumptrue 2 
jump block.end.16323
  put
  add "*"
  push
  jump parse
block.end.16323:
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
jumptrue 50
testis "word*}*"
jumptrue 48
testis "word*begintext*"
jumptrue 46
testis "word*endtext*"
jumptrue 44
testis "word*!*"
jumptrue 42
testis "word*,*"
jumptrue 40
testis "quote*word*"
jumptrue 38
testis "quote*class*"
jumptrue 36
testis "quote*state*"
jumptrue 34
testis "quote*}*"
jumptrue 32
testis "quote*begintext*"
jumptrue 30
testis "quote*endtext*"
jumptrue 28
testis "class*word*"
jumptrue 26
testis "class*quote*"
jumptrue 24
testis "class*class*"
jumptrue 22
testis "class*state*"
jumptrue 20
testis "class*}*"
jumptrue 18
testis "class*begintext*"
jumptrue 16
testis "class*endtext*"
jumptrue 14
testis "class*!*"
jumptrue 12
testis "notclass*word*"
jumptrue 10
testis "notclass*quote*"
jumptrue 8
testis "notclass*class*"
jumptrue 6
testis "notclass*state*"
jumptrue 4
testis "notclass*}*"
jumptrue 2 
jump block.end.18184
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
block.end.18184:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.18373
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
block.end.18373:
testis ",*{*"
jumptrue 2 
jump block.end.18541
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
block.end.18541:
testis "!*{*"
jumptrue 2 
jump block.end.18721
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
block.end.18721:
testis "!*command*"
jumptrue 2 
jump block.end.18920
  push
  push
  add "error near line "
  ll
  add " (at char "
  cc
  add ") \n"
  add " The negation operator (!) cannot precede a command \n"
  print
  clear
  quit
block.end.18920:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.19123
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
block.end.19123:
testis "{*}*"
jumptrue 2 
jump block.end.19254
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.19254:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
testis ".*word*"
jumptrue 2 
jump block.end.19856
  clear
  ++
  get
  --
  testis "restart"
  jumptrue 2 
  jump block.end.19534
    clear
    add "jump start"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.19534:
  testis "reparse"
  jumptrue 2 
  jump block.end.19649
    clear
    add "jump parse"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.19649:
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script:  \n"
  add " misplaced dot '.' (use for AND logic or in .reparse/.restart \n"
  print
  clear
  quit
block.end.19856:
#-----------------------------------------
# compiling comments so as to transfer them to the compiled 
# file. Improve this by just forming rules for
# command*comment* and comment*command* and comment*comment*
# implement these rules to conserve comments
testis "comment*command*"
jumptrue 2 
jump block.end.20165
  nop
block.end.20165:
testis "command*comment*"
jumptrue 2 
jump block.end.20202
  nop
block.end.20202:
testis "comment*comment*"
jumptrue 2 
jump block.end.20239
  nop
block.end.20239:
testends "comment*"
jumptrue 2 
jump block.end.20489
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumptrue 2 
  jump block.end.20409
    jump start
  block.end.20409:
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
block.end.20489:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumptrue 2 
jump block.end.21106
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumptrue 2 
  jump block.end.20874
    jump start
  block.end.20874:
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
block.end.21106:
# -----------------------
# negated tokens.
# This is a new more elegant way to negate a whole set of 
# tests (tokens) where the negation logic is stored on the 
# stack, not in the current tape cell.
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
#  This format is used to indicate a negative class test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
testis "!*quote*"
jumptrue 8
testis "!*class*"
jumptrue 6
testis "!*begintext*"
jumptrue 4
testis "!*endtext*"
jumptrue 2 
jump block.end.21964
  push
  ++
  put
  --
  clear
  pop
  clear
  add "not"
  # extract the saved token name from the tape
  ++
  ++
  get
  --
  --
  # now we have a token "notquote*" / "notclass*" / "notbegintext*
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.21964:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumptrue 2 
jump block.end.22236
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.22236:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumptrue 2 
jump block.end.22547
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.22547:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumptrue 2 
jump block.end.23226
  clear
  # check if command requires parameter
  get
  testis "add"
  jumptrue 16
  testis "until"
  jumptrue 14
  testis "while"
  jumptrue 12
  testis "whilenot"
  jumptrue 10
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "delim"
  jumptrue 4
  testis "replace"
  jumptrue 2 
  jump block.end.23096
    put
    clear
    add "'"
    get
    add "'"
    add " << command needs an argument, on line "
    ll
    add " of script.\n"
    print
    clear
    quit
  block.end.23096:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
block.end.23226:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.23552
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
block.end.23552:
#-------------------
# here we begin to parse "test*" and "ortestset*" and "andtestset*"
# 
#-------------------
# eg: B"abc" {} or E"xyz" {}
testis "begintext*{*"
jumptrue 8
testis "endtext*{*"
jumptrue 6
testis "quote*{*"
jumptrue 4
testis "class*{*"
jumptrue 2 
jump block.end.24286
  zero
  testbegins "begin"
  jumptrue 2 
  jump block.end.23842
    clear
    add "testbegins "
  block.end.23842:
  testbegins "end"
  jumptrue 2 
  jump block.end.23881
    clear
    add "testends "
  block.end.23881:
  testbegins "quote"
  jumptrue 2 
  jump block.end.23920
    clear
    add "testis "
  block.end.23920:
  testbegins "class"
  jumptrue 2 
  jump block.end.23962
    clear
    add "testclass "
  block.end.23962:
  get
  add "\n"
  add "jumptrue 2 \n"
  add "jump block.end."
  # the final jumpfalse + target will be added when
  # "test*{*commandset*}*" is parsed, or when
  # "ortestset*{*commandset*}*"
  # "andtestset*{*commandset*}*"
  put
  a+
  a+
  a+
  a+
  clear
  add "test*{*"
  push
  push
  jump parse
block.end.24286:
#-------------------
# negated tests
# eg: !B"xyz {} 
#     !E"xyz" {} 
#     !"abc" {}
testis "notbegintext*{*"
jumptrue 8
testis "notendtext*{*"
jumptrue 6
testis "notquote*{*"
jumptrue 4
testis "notclass*{*"
jumptrue 2 
jump block.end.24906
  zero
  testbegins "notbegin"
  jumptrue 2 
  jump block.end.24535
    clear
    add "testbegins "
  block.end.24535:
  testbegins "notend"
  jumptrue 2 
  jump block.end.24577
    clear
    add "testends "
  block.end.24577:
  testbegins "notquote"
  jumptrue 2 
  jump block.end.24619
    clear
    add "testis "
  block.end.24619:
  testbegins "notclass"
  jumptrue 2 
  jump block.end.24664
    clear
    add "testclass "
  block.end.24664:
  # clear; add "testbegins "; 
  get
  add "\n"
  add "jumpfalse 2 \n"
  add "jump block.end."
  # the final jumpfalse + target will be added later
  put
  a+
  a+
  a+
  a+
  clear
  add "test*{*"
  push
  push
  jump parse
block.end.24906:
#-------------------
# 3 tokens
#-------------------
pop
# rule 
#',' ortestset ::= ',' test '{'
# trigger a transmogrification from test to ortestset token
# and 
# '.' andtestset ::= '.' test '{'
testis ",*test*{*"
jumptrue 2 
jump block.end.25211
  clear
  add ",*ortestset*{*"
  push
  push
  push
  jump parse
block.end.25211:
# trigger a transmogrification from "test" to "andtest" by
# looking backwards in the stack
testis ".*test*{*"
jumptrue 2 
jump block.end.25448
  a-
  clear
  add ".*andtestset*{*"
  push
  push
  push
  jump parse
block.end.25448:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.25780
  push
  push
  push
  add " error: mixing AND (.) and OR (,) concatenation in \n"
  add " in script near line "
  ll
  add " (character "
  cc
  add ") \n"
  print
  clear
  quit
block.end.25780:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumptrue 2 
jump block.end.26569
  clear
  get
  testis "replace"
  jumptrue 2 
  jump block.end.26120
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.26120:
  testis "add"
  jumptrue 14
  testis "until"
  jumptrue 12
  testis "while"
  jumptrue 10
  testis "whilenot"
  jumptrue 8
  testis "escape"
  jumptrue 6
  testis "unescape"
  jumptrue 4
  testis "delim"
  jumptrue 2 
  jump block.end.26381
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
  block.end.26381:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.26569:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z]
testis "word*class*;*"
jumptrue 2 
jump block.end.27076
  clear
  get
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.26926
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
  block.end.26926:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.27076:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumptrue 2 
jump block.end.27737
  clear
  get
  testis "replace"
  jumptrue 2 
  jump block.end.27617
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
  block.end.27617:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
block.end.27737:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
testis "begin*{*commandset*}*"
jumptrue 4
testis "begin*{*command*}*"
jumptrue 2 
jump block.end.28119
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
block.end.28119:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "begintext*,*ortestset*{*"
jumptrue 8
testis "endtext*,*ortestset*{*"
jumptrue 6
testis "quote*,*ortestset*{*"
jumptrue 4
testis "class*,*ortestset*{*"
jumptrue 2 
jump block.end.28803
  testbegins "begin"
  jumptrue 2 
  jump block.end.28393
    clear
    add "testbegins "
  block.end.28393:
  testbegins "end"
  jumptrue 2 
  jump block.end.28433
    clear
    add "testends "
  block.end.28433:
  testbegins "quote"
  jumptrue 2 
  jump block.end.28473
    clear
    add "testis "
  block.end.28473:
  testbegins "class"
  jumptrue 2 
  jump block.end.28516
    clear
    add "testclass "
  block.end.28516:
  get
  add "\n"
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
  # this works as long as we dont mix AND and OR concatenations 
  # add "test*{*";
  # need to change to this
  add "ortestset*{*"
  push
  push
  a+
  a+
  jump parse
block.end.28803:
# A collection of negated tests.
testis "notbegintext*,*ortestset*{*"
jumptrue 8
testis "notendtext*,*ortestset*{*"
jumptrue 6
testis "notquote*,*ortestset*{*"
jumptrue 4
testis "notclass*,*ortestset*{*"
jumptrue 2 
jump block.end.29439
  testbegins "notbegin"
  jumptrue 2 
  jump block.end.29014
    clear
    add "testbegins "
  block.end.29014:
  testbegins "notend"
  jumptrue 2 
  jump block.end.29057
    clear
    add "testends "
  block.end.29057:
  testbegins "notquote"
  jumptrue 2 
  jump block.end.29100
    clear
    add "testis "
  block.end.29100:
  testbegins "notclass"
  jumptrue 2 
  jump block.end.29146
    clear
    add "testclass "
  block.end.29146:
  get
  add "\n"
  add "jumpfalse "
  count
  add "\n"
  ++
  ++
  get
  --
  --
  put
  clear
  # this works as long as we dont mix AND and OR concatenations 
  add "ortestset*{*"
  # need to change to this
  # add "ortestset*{*";
  push
  push
  a+
  a+
  jump parse
block.end.29439:
# this works as long as we dont mix AND and OR concatenations 
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# it is possible to elide this block with the negated block
# for compactness but maybe readability is not as good.
testis "begintext*.*andtestset*{*"
jumptrue 8
testis "endtext*.*andtestset*{*"
jumptrue 6
testis "quote*.*andtestset*{*"
jumptrue 4
testis "class*.*andtestset*{*"
jumptrue 2 
jump block.end.30218
  testbegins "begin"
  jumptrue 2 
  jump block.end.29926
    clear
    add "testbegins "
  block.end.29926:
  testbegins "end"
  jumptrue 2 
  jump block.end.29966
    clear
    add "testends "
  block.end.29966:
  testbegins "quote"
  jumptrue 2 
  jump block.end.30006
    clear
    add "testis "
  block.end.30006:
  testbegins "class"
  jumptrue 2 
  jump block.end.30049
    clear
    add "testclass "
  block.end.30049:
  get
  add "\n"
  add "jumpfalse "
  count
  add "\n"
  ++
  ++
  get
  --
  --
  put
  clear
  add "andtestset*{*"
  push
  push
  a+
  a+
  jump parse
block.end.30218:
# eg
# negated tests concatenated with AND logic (.). The 
# negated tests can be chained with non negated tests.
# eg: B'http' . !E'.txt' { ... }
testis "notbegintext*.*andtestset*{*"
jumptrue 8
testis "notendtext*.*andtestset*{*"
jumptrue 6
testis "notquote*.*andtestset*{*"
jumptrue 4
testis "notclass*.*andtestset*{*"
jumptrue 2 
jump block.end.30856
  testbegins "notbegin"
  jumptrue 2 
  jump block.end.30556
    clear
    add "testbegins "
  block.end.30556:
  testbegins "notend"
  jumptrue 2 
  jump block.end.30599
    clear
    add "testends "
  block.end.30599:
  testbegins "notquote"
  jumptrue 2 
  jump block.end.30642
    clear
    add "testis "
  block.end.30642:
  testbegins "notclass"
  jumptrue 2 
  jump block.end.30688
    clear
    add "testclass "
  block.end.30688:
  get
  add "\n"
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
  add "andtestset*{*"
  push
  push
  a+
  a+
  jump parse
block.end.30856:
#-------------------------------------
testis "test*{*commandset*}*"
jumptrue 12
testis "test*{*command*}*"
jumptrue 10
testis "andtestset*{*commandset*}*"
jumptrue 8
testis "andtestset*{*command*}*"
jumptrue 6
testis "ortestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*command*}*"
jumptrue 2 
jump block.end.31568
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
  get
  # the final jump (to the closing brace) has already been
  # coded in the "test*{*" rule or the other rules.
  # we just need to add the label number with "cc"
  cc
  add "\n"
  ++
  ++
  get
  add "\nblock.end."
  cc
  add ":"
  --
  --
  put
  clear
  add "command*"
  push
  # always reparse/compile
  jump parse
block.end.31568:
#-------------------------------------
# format:  (eof) { add ":"; print; clear; }
# format:  (==)  { print; }
# rewrite to separate into 2 separate test tokens
#  "testeof*" and "testtape*"
testis "state*{*commandset*}*"
jumptrue 4
testis "state*{*command*}*"
jumptrue 2 
jump block.end.32723
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
  jumptrue 2 
  jump block.end.32174
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
  block.end.32174:
  # ----------
  # compile to tape= test 
  testis "=="
  jumptrue 2 
  jump block.end.32463
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
  block.end.32463:
  add ": unknown state test near line "
  ll
  add " of script.\n"
  add " State tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.32723:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse not.eof.34306
  print
  clear
  #---------------------
  # check if the script correctly parsed (there should only
  # be one token on the stack, namely "commandset*" or "command*"
  pop
  pop
  testis "commandset*"
  jumptrue 4
  testis "command*"
  jumptrue 2 
  jump block.end.33460
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
  block.end.33460:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.33941
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
  block.end.33941:
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
not.eof.34306:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
