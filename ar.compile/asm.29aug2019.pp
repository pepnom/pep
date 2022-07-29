# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumpfalse block.end.10673
  clear
  jump parse
block.end.10673:
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
jump block.end.11035
  put
  add "*"
  push
  jump parse
block.end.11035:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.11153
  until "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.11153:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.11438
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
block.end.11438:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumpfalse block.end.11586
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.11586:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumpfalse block.end.11779
  clear
  until ")"
  clip
  put
  clear
  add "state*"
  push
  jump parse
block.end.11779:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.12736
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumpfalse block.end.12053
    clear
    jump start
  block.end.12053:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.12554
    until "*#"
    testends "*#"
    jumpfalse block.end.12351
      clear
      jump start
    block.end.12351:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  block.end.12554:
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
block.end.12736:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^]
jumptrue block.end.13116
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
block.end.13116:
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
jumpfalse block.end.13634
  clear
  add "add"
block.end.13634:
testis "k"
jumpfalse block.end.13664
  clear
  add "clip"
block.end.13664:
testis "K"
jumpfalse block.end.13694
  clear
  add "clop"
block.end.13694:
testis "D"
jumpfalse block.end.13727
  clear
  add "replace"
block.end.13727:
testis "d"
jumpfalse block.end.13758
  clear
  add "clear"
block.end.13758:
testis "t"
jumpfalse block.end.13789
  clear
  add "print"
block.end.13789:
testis "p"
jumpfalse block.end.13818
  clear
  add "pop"
block.end.13818:
testis "P"
jumpfalse block.end.13848
  clear
  add "push"
block.end.13848:
testis "G"
jumpfalse block.end.13877
  clear
  add "put"
block.end.13877:
testis "g"
jumpfalse block.end.13906
  clear
  add "get"
block.end.13906:
testis "x"
jumpfalse block.end.13936
  clear
  add "swap"
block.end.13936:
testis ">"
jumpfalse block.end.13964
  clear
  add "++"
block.end.13964:
testis "<"
jumpfalse block.end.13992
  clear
  add "--"
block.end.13992:
testis "r"
jumpfalse block.end.14022
  clear
  add "read"
block.end.14022:
testis "R"
jumpfalse block.end.14053
  clear
  add "until"
block.end.14053:
testis "w"
jumpfalse block.end.14084
  clear
  add "while"
block.end.14084:
testis "W"
jumpfalse block.end.14118
  clear
  add "whilenot"
block.end.14118:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumpfalse block.end.14596
  clear
  add "count"
block.end.14596:
testis "+"
jumpfalse block.end.14624
  clear
  add "a+"
block.end.14624:
testis "-"
jumpfalse block.end.14652
  clear
  add "a-"
block.end.14652:
testis "0"
jumpfalse block.end.14682
  clear
  add "zero"
block.end.14682:
testis "c"
jumpfalse block.end.14710
  clear
  add "cc"
block.end.14710:
testis "l"
jumpfalse block.end.14738
  clear
  add "ll"
block.end.14738:
testis "^"
jumpfalse block.end.14770
  clear
  add "escape"
block.end.14770:
testis "v"
jumpfalse block.end.14804
  clear
  add "unescape"
block.end.14804:
testis "z"
jumpfalse block.end.14835
  clear
  add "delim"
block.end.14835:
testis "S"
jumpfalse block.end.14866
  clear
  add "state"
block.end.14866:
testis "q"
jumpfalse block.end.14896
  clear
  add "quit"
block.end.14896:
testis "Q"
jumpfalse block.end.14926
  clear
  add "bail"
block.end.14926:
testis "s"
jumpfalse block.end.14957
  clear
  add "write"
block.end.14957:
testis "o"
jumpfalse block.end.14986
  clear
  add "nop"
block.end.14986:
testis "rs"
jumpfalse block.end.15020
  clear
  add "restart"
block.end.15020:
testis "rp"
jumpfalse block.end.15054
  clear
  add "reparse"
block.end.15054:
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
jump block.end.15489
  put
  clear
  add "word*"
  push
  jump parse
block.end.15489:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis "parse>"
jumpfalse block.end.16174
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
block.end.16174:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.16390
  put
  add "*"
  push
  jump parse
block.end.16390:
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
jump block.end.18251
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
block.end.18251:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.18440
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
block.end.18440:
testis ",*{*"
jumpfalse block.end.18608
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
block.end.18608:
testis "!*{*"
jumpfalse block.end.18788
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
block.end.18788:
testis "!*command*"
jumpfalse block.end.18987
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
block.end.18987:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.19190
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
block.end.19190:
testis "{*}*"
jumpfalse block.end.19321
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.19321:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
testis ".*word*"
jumpfalse block.end.19923
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.19601
    clear
    add "jump start"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.19601:
  testis "reparse"
  jumpfalse block.end.19716
    clear
    add "jump parse"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.19716:
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
block.end.19923:
#-----------------------------------------
# compiling comments so as to transfer them to the compiled 
# file. Improve this by just forming rules for
# command*comment* and comment*command* and comment*comment*
# implement these rules to conserve comments
testis "comment*command*"
jumpfalse block.end.20232
  nop
block.end.20232:
testis "command*comment*"
jumpfalse block.end.20269
  nop
block.end.20269:
testis "comment*comment*"
jumpfalse block.end.20306
  nop
block.end.20306:
testends "comment*"
jumpfalse block.end.20556
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.20476
    jump start
  block.end.20476:
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
block.end.20556:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumpfalse block.end.21173
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.20941
    jump start
  block.end.20941:
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
block.end.21173:
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
jump block.end.22031
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
block.end.22031:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.22303
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.22303:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.22614
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.22614:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.23293
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
  jump block.end.23163
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
  block.end.23163:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
block.end.23293:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.23619
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
block.end.23619:
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
jump block.end.24435
  zero
  testbegins "begin"
  jumpfalse block.end.23909
    clear
    add "testbegins "
  block.end.23909:
  testbegins "end"
  jumpfalse block.end.23948
    clear
    add "testends "
  block.end.23948:
  testbegins "quote"
  jumpfalse block.end.23987
    clear
    add "testis "
  block.end.23987:
  testbegins "class"
  jumpfalse block.end.24029
    clear
    add "testclass "
  block.end.24029:
  get
  add "\n"
  add "jumptrue 2 \n"
  # this extra jump has utility when we parse ortestsets and
  # andtestsets.
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
block.end.24435:
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
jump block.end.25137
  zero
  testbegins "notbegin"
  jumpfalse block.end.24684
    clear
    add "testbegins "
  block.end.24684:
  testbegins "notend"
  jumpfalse block.end.24726
    clear
    add "testends "
  block.end.24726:
  testbegins "notquote"
  jumpfalse block.end.24768
    clear
    add "testis "
  block.end.24768:
  testbegins "notclass"
  jumpfalse block.end.24813
    clear
    add "testclass "
  block.end.24813:
  # clear; add "testbegins "; 
  get
  add "\n"
  add "jumpfalse 2 \n"
  # this extra jump has utility when we parse ortestsets and
  # andtestsets.
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
block.end.25137:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some errors!!!
# there are many other of these errors but I am not going
# to write them all.
testis "{*quote*;*"
jumptrue 8
testis "{*begintext*;*"
jumptrue 6
testis "{*endtext*;*"
jumptrue 4
testis "{*class*;*"
jumptrue 2 
jump block.end.25573
  push
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (misplaced semicolon?) \n"
  print
  clear
  quit
block.end.25573:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.25769
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.25769:
# rule 
#',' ortestset ::= ',' test '{'
# trigger a transmogrification from test to ortestset token
# and 
# '.' andtestset ::= '.' test '{'
testis ",*test*{*"
jumpfalse block.end.26006
  clear
  add ",*ortestset*{*"
  push
  push
  push
  jump parse
block.end.26006:
# trigger a transmogrification from "test" to "andtest" by
# looking backwards in the stack
testis ".*test*{*"
jumpfalse block.end.26243
  a-
  clear
  add ".*andtestset*{*"
  push
  push
  push
  jump parse
block.end.26243:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.26575
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
block.end.26575:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.27364
  clear
  get
  testis "replace"
  jumpfalse block.end.26915
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.26915:
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
  jump block.end.27176
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
  block.end.27176:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.27364:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z]
testis "word*class*;*"
jumpfalse block.end.27871
  clear
  get
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.27721
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
  block.end.27721:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.27871:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.28532
  clear
  get
  testis "replace"
  jumpfalse block.end.28412
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
  block.end.28412:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
block.end.28532:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.28916
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
block.end.28916:
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
jump block.end.29600
  testbegins "begin"
  jumpfalse block.end.29190
    clear
    add "testbegins "
  block.end.29190:
  testbegins "end"
  jumpfalse block.end.29230
    clear
    add "testends "
  block.end.29230:
  testbegins "quote"
  jumpfalse block.end.29270
    clear
    add "testis "
  block.end.29270:
  testbegins "class"
  jumpfalse block.end.29313
    clear
    add "testclass "
  block.end.29313:
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
block.end.29600:
# A collection of negated tests.
testis "notbegintext*,*ortestset*{*"
jumptrue 8
testis "notendtext*,*ortestset*{*"
jumptrue 6
testis "notquote*,*ortestset*{*"
jumptrue 4
testis "notclass*,*ortestset*{*"
jumptrue 2 
jump block.end.30236
  testbegins "notbegin"
  jumpfalse block.end.29811
    clear
    add "testbegins "
  block.end.29811:
  testbegins "notend"
  jumpfalse block.end.29854
    clear
    add "testends "
  block.end.29854:
  testbegins "notquote"
  jumpfalse block.end.29897
    clear
    add "testis "
  block.end.29897:
  testbegins "notclass"
  jumpfalse block.end.29943
    clear
    add "testclass "
  block.end.29943:
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
block.end.30236:
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
jump block.end.31015
  testbegins "begin"
  jumpfalse block.end.30723
    clear
    add "testbegins "
  block.end.30723:
  testbegins "end"
  jumpfalse block.end.30763
    clear
    add "testends "
  block.end.30763:
  testbegins "quote"
  jumpfalse block.end.30803
    clear
    add "testis "
  block.end.30803:
  testbegins "class"
  jumpfalse block.end.30846
    clear
    add "testclass "
  block.end.30846:
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
block.end.31015:
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
jump block.end.31653
  testbegins "notbegin"
  jumpfalse block.end.31353
    clear
    add "testbegins "
  block.end.31353:
  testbegins "notend"
  jumpfalse block.end.31396
    clear
    add "testends "
  block.end.31396:
  testbegins "notquote"
  jumpfalse block.end.31439
    clear
    add "testis "
  block.end.31439:
  testbegins "notclass"
  jumpfalse block.end.31485
    clear
    add "testclass "
  block.end.31485:
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
block.end.31653:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.32724
  testbegins "test*{*"
  jumpfalse block.end.32274
    clear
    # get rid of unnecessary jump but only in "test" cases 
    get
    # for positive tests (eg [a-z] {...})
    replace "jumptrue 2 \njump" "jumpfalse"
    put
    # for negative tests (eg ![a-z] {...})
    replace "jumpfalse 2 \njump" "jumptrue"
    put
  block.end.32274:
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
block.end.32724:
#-------------------------------------
# format:  (eof) { add ":"; print; clear; }
# format:  (==)  { print; }
# rewrite to separate into 2 separate test tokens
#  "testeof*" and "testtape*"
testis "state*{*commandset*}*"
jumptrue 4
testis "state*{*command*}*"
jumptrue 2 
jump block.end.33879
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
  jumpfalse block.end.33330
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
  block.end.33330:
  # ----------
  # compile to tape= test 
  testis "=="
  jumpfalse block.end.33619
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
  block.end.33619:
  add ": unknown state test near line "
  ll
  add " of script.\n"
  add " State tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.33879:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse not.eof.35462
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
  jump block.end.34616
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
  block.end.34616:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.35097
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
  block.end.35097:
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
not.eof.35462:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
