# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumpfalse block.end.11113
  clear
  jump parse
block.end.11113:
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
jump block.end.11475
  put
  add "*"
  push
  jump parse
block.end.11475:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.11593
  until "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.11593:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.11878
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
block.end.11878:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumpfalse block.end.12026
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.12026:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumpfalse block.end.12535
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.12220
    clear
    add "eof*"
    push
    jump parse
  block.end.12220:
  testis "=="
  jumpfalse block.end.12273
    clear
    add "tapetest*"
    push
    jump parse
  block.end.12273:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.12535:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.13492
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumpfalse block.end.12809
    clear
    jump start
  block.end.12809:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.13310
    until "*#"
    testends "*#"
    jumpfalse block.end.13107
      clear
      jump start
    block.end.13107:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  block.end.13310:
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
block.end.13492:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.13873
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
block.end.13873:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEOFKGPRUWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
testis "a"
jumpfalse block.end.14394
  clear
  add "add"
block.end.14394:
testis "k"
jumpfalse block.end.14424
  clear
  add "clip"
block.end.14424:
testis "K"
jumpfalse block.end.14454
  clear
  add "clop"
block.end.14454:
testis "D"
jumpfalse block.end.14487
  clear
  add "replace"
block.end.14487:
testis "d"
jumpfalse block.end.14518
  clear
  add "clear"
block.end.14518:
testis "t"
jumpfalse block.end.14549
  clear
  add "print"
block.end.14549:
testis "p"
jumpfalse block.end.14578
  clear
  add "pop"
block.end.14578:
testis "P"
jumpfalse block.end.14608
  clear
  add "push"
block.end.14608:
testis "u"
jumpfalse block.end.14641
  clear
  add "unstack"
block.end.14641:
testis "U"
jumpfalse block.end.14672
  clear
  add "stack"
block.end.14672:
testis "G"
jumpfalse block.end.14701
  clear
  add "put"
block.end.14701:
testis "g"
jumpfalse block.end.14730
  clear
  add "get"
block.end.14730:
testis "x"
jumpfalse block.end.14760
  clear
  add "swap"
block.end.14760:
testis ">"
jumpfalse block.end.14788
  clear
  add "++"
block.end.14788:
testis "<"
jumpfalse block.end.14816
  clear
  add "--"
block.end.14816:
testis "r"
jumpfalse block.end.14846
  clear
  add "read"
block.end.14846:
testis "R"
jumpfalse block.end.14877
  clear
  add "until"
block.end.14877:
testis "w"
jumpfalse block.end.14908
  clear
  add "while"
block.end.14908:
testis "W"
jumpfalse block.end.14942
  clear
  add "whilenot"
block.end.14942:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumpfalse block.end.15420
  clear
  add "count"
block.end.15420:
testis "+"
jumpfalse block.end.15448
  clear
  add "a+"
block.end.15448:
testis "-"
jumpfalse block.end.15476
  clear
  add "a-"
block.end.15476:
testis "0"
jumpfalse block.end.15506
  clear
  add "zero"
block.end.15506:
testis "c"
jumpfalse block.end.15534
  clear
  add "cc"
block.end.15534:
testis "l"
jumpfalse block.end.15562
  clear
  add "ll"
block.end.15562:
testis "^"
jumpfalse block.end.15594
  clear
  add "escape"
block.end.15594:
testis "v"
jumpfalse block.end.15628
  clear
  add "unescape"
block.end.15628:
testis "z"
jumpfalse block.end.15659
  clear
  add "delim"
block.end.15659:
testis "S"
jumpfalse block.end.15690
  clear
  add "state"
block.end.15690:
testis "q"
jumpfalse block.end.15720
  clear
  add "quit"
block.end.15720:
testis "Q"
jumpfalse block.end.15750
  clear
  add "bail"
block.end.15750:
testis "s"
jumpfalse block.end.15781
  clear
  add "write"
block.end.15781:
testis "o"
jumpfalse block.end.15810
  clear
  add "nop"
block.end.15810:
testis "rs"
jumpfalse block.end.15844
  clear
  add "restart"
block.end.15844:
testis "rp"
jumpfalse block.end.15878
  clear
  add "reparse"
block.end.15878:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.15989
  put
  clear
  add "eof*"
  push
  jump parse
block.end.15989:
testis "<==>"
jumpfalse block.end.16047
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.16047:
testis "add"
jumptrue 88
testis "clip"
jumptrue 86
testis "clop"
jumptrue 84
testis "replace"
jumptrue 82
testis "clear"
jumptrue 80
testis "print"
jumptrue 78
testis "pop"
jumptrue 76
testis "push"
jumptrue 74
testis "unstack"
jumptrue 72
testis "stack"
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
jump block.end.16500
  put
  clear
  add "word*"
  push
  jump parse
block.end.16500:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis "parse>"
jumpfalse block.end.16816
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
block.end.16816:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.17032
  put
  add "*"
  push
  jump parse
block.end.17032:
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
jump block.end.18892
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
block.end.18892:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.19081
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
block.end.19081:
testis ",*{*"
jumpfalse block.end.19249
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
block.end.19249:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.19436
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra semi-colon? \n"
  print
  clear
  quit
block.end.19436:
testis "!*!*"
jumpfalse block.end.19697
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: \n double negation '!!' is not implemented \n"
  add " and probably won't be, because what would be the point? \n"
  print
  clear
  quit
block.end.19697:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.20006
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced negation operator (!)? \n"
  add " The negation operator precedes tests, for example: \n"
  add "   !B'abc'{ ... } or !(eof),!'abc'{ ... } \n"
  print
  clear
  quit
block.end.20006:
testis ",*command*"
jumpfalse block.end.20176
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced comma? \n"
  print
  clear
  quit
block.end.20176:
testis "!*command*"
jumpfalse block.end.20375
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
block.end.20375:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.20578
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
block.end.20578:
testis "{*}*"
jumpfalse block.end.20709
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.20709:
testis "}*command*"
jumpfalse block.end.20856
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.20856:
# -------------
# 2 token end-of-stream errors
testeof 
jumpfalse block.end.21080
  testis "command*}*"
  jumpfalse block.end.21076
    push
    push
    add "error near line "
    ll
    add " of script: extra closing brace '}' ?. \n"
    print
    clear
    quit
  block.end.21076:
block.end.21080:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
# but '.' is also the AND concatenator, which seems ambiguous,
# but seems to work.
testis ".*word*"
jumpfalse block.end.21770
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.21448
    clear
    add "jump start"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21448:
  testis "reparse"
  jumpfalse block.end.21563
    clear
    add "jump parse"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21563:
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
block.end.21770:
#-----------------------------------------
# compiling comments so as to transfer them to the compiled 
# file. Improve this by just forming rules for
# command*comment* and comment*command* and comment*comment*
# implement these rules to conserve comments
testis "comment*command*"
jumpfalse block.end.22079
  nop
block.end.22079:
testis "command*comment*"
jumpfalse block.end.22116
  nop
block.end.22116:
testis "comment*comment*"
jumpfalse block.end.22153
  nop
block.end.22153:
testends "comment*"
jumpfalse block.end.22403
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.22323
    jump start
  block.end.22323:
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
block.end.22403:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumpfalse block.end.23020
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.22788
    jump start
  block.end.22788:
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
block.end.23020:
# -----------------------
# negated tokens.
# This is a new more elegant way to negate a whole set of 
# tests (tokens) where the negation logic is stored on the 
# stack, not in the current tape cell. We just add "not" to 
# the stack token.
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
#  This format is used to indicate a negative class test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
testis "!*quote*"
jumptrue 12
testis "!*class*"
jumptrue 10
testis "!*begintext*"
jumptrue 8
testis "!*endtext*"
jumptrue 6
testis "!*eof*"
jumptrue 4
testis "!*tapetest*"
jumptrue 2 
jump block.end.23947
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
block.end.23947:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.24219
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24219:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.24530
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24530:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.25209
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
  jump block.end.25079
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
  block.end.25079:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
block.end.25209:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.25533
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
block.end.25533:
#-------------------
# here we begin to parse "test*" and "ortestset*" and "andtestset*"
# 
#-------------------
# eg: B"abc" {} or E"xyz" {}
testis "begintext*{*"
jumptrue 12
testis "endtext*{*"
jumptrue 10
testis "quote*{*"
jumptrue 8
testis "class*{*"
jumptrue 6
testis "eof*{*"
jumptrue 4
testis "tapetest*{*"
jumptrue 2 
jump block.end.26556
  zero
  testbegins "begin"
  jumpfalse block.end.25849
    clear
    add "testbegins "
  block.end.25849:
  testbegins "end"
  jumpfalse block.end.25888
    clear
    add "testends "
  block.end.25888:
  testbegins "quote"
  jumpfalse block.end.25927
    clear
    add "testis "
  block.end.25927:
  testbegins "class"
  jumpfalse block.end.25969
    clear
    add "testclass "
  block.end.25969:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.26101
    clear
    put
    add "testeof "
  block.end.26101:
  testbegins "tapetest"
  jumpfalse block.end.26150
    clear
    put
    add "testtape "
  block.end.26150:
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
block.end.26556:
#-------------------
# negated tests
# eg: !B"xyz {} 
#     !E"xyz" {} 
#     !"abc" {}
#     ![a-z] {}
testis "notbegintext*{*"
jumptrue 12
testis "notendtext*{*"
jumptrue 10
testis "notquote*{*"
jumptrue 8
testis "notclass*{*"
jumptrue 6
testis "noteof*{*"
jumptrue 4
testis "nottapetest*{*"
jumptrue 2 
jump block.end.27525
  zero
  testbegins "notbegin"
  jumpfalse block.end.26855
    clear
    add "testbegins "
  block.end.26855:
  testbegins "notend"
  jumpfalse block.end.26897
    clear
    add "testends "
  block.end.26897:
  testbegins "notquote"
  jumpfalse block.end.26939
    clear
    add "testis "
  block.end.26939:
  testbegins "notclass"
  jumpfalse block.end.26984
    clear
    add "testclass "
  block.end.26984:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.27119
    clear
    put
    add "testeof "
  block.end.27119:
  testbegins "nottapetest"
  jumpfalse block.end.27171
    clear
    put
    add "testtape "
  block.end.27171:
  get
  add "\n"
  add "jumpfalse 2 \n"
  # this extra jump has utility when we parse ortestsets and
  # andtestsets.
  add "jump block.end."
  # the final jumpfalse + target will be added later
  # use the accumulator to store the incremented jump target
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
block.end.27525:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some 3 token errors!!!
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
jump block.end.27966
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
block.end.27966:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.28162
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.28162:
# rule 
#',' ortestset ::= ',' test '{'
# trigger a transmogrification from test to ortestset token
# and 
# '.' andtestset ::= '.' test '{'
testis ",*test*{*"
jumpfalse block.end.28399
  clear
  add ",*ortestset*{*"
  push
  push
  push
  jump parse
block.end.28399:
# trigger a transmogrification from "test" to "andtest" by
# looking backwards in the stack
testis ".*test*{*"
jumpfalse block.end.28636
  a-
  clear
  add ".*andtestset*{*"
  push
  push
  push
  jump parse
block.end.28636:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.28968
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
block.end.28968:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.29757
  clear
  get
  testis "replace"
  jumpfalse block.end.29308
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.29308:
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
  jump block.end.29569
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
  block.end.29569:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.29757:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.30265
  clear
  get
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.30115
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
  block.end.30115:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.30265:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.30926
  clear
  get
  testis "replace"
  jumpfalse block.end.30806
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
  block.end.30806:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
block.end.30926:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.31310
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
block.end.31310:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "begintext*,*ortestset*{*"
jumptrue 12
testis "endtext*,*ortestset*{*"
jumptrue 10
testis "quote*,*ortestset*{*"
jumptrue 8
testis "class*,*ortestset*{*"
jumptrue 6
testis "eof*,*ortestset*{*"
jumptrue 4
testis "tapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.32234
  testbegins "begin"
  jumpfalse block.end.31639
    clear
    add "testbegins "
  block.end.31639:
  testbegins "end"
  jumpfalse block.end.31679
    clear
    add "testends "
  block.end.31679:
  testbegins "quote"
  jumpfalse block.end.31719
    clear
    add "testis "
  block.end.31719:
  testbegins "class"
  jumpfalse block.end.31762
    clear
    add "testclass "
  block.end.31762:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.31897
    clear
    put
    add "testeof "
  block.end.31897:
  testbegins "tapetest"
  jumpfalse block.end.31947
    clear
    put
    add "testtape "
  block.end.31947:
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
block.end.32234:
# A collection of negated tests.
testis "notbegintext*,*ortestset*{*"
jumptrue 12
testis "notendtext*,*ortestset*{*"
jumptrue 10
testis "notquote*,*ortestset*{*"
jumptrue 8
testis "notclass*,*ortestset*{*"
jumptrue 6
testis "noteof*,*ortestset*{*"
jumptrue 4
testis "nottapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.33031
  testbegins "notbegin"
  jumpfalse block.end.32506
    clear
    add "testbegins "
  block.end.32506:
  testbegins "notend"
  jumpfalse block.end.32549
    clear
    add "testends "
  block.end.32549:
  testbegins "notquote"
  jumpfalse block.end.32592
    clear
    add "testis "
  block.end.32592:
  testbegins "notclass"
  jumpfalse block.end.32638
    clear
    add "testclass "
  block.end.32638:
  testbegins "noteof"
  jumpfalse block.end.32685
    clear
    put
    add "testeof "
  block.end.32685:
  testbegins "nottapetest"
  jumpfalse block.end.32738
    clear
    put
    add "testtape "
  block.end.32738:
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
block.end.33031:
# this works as long as we dont mix AND and OR concatenations 
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# it is possible to elide this block with the negated block
# for compactness but maybe readability is not as good.
testis "begintext*.*andtestset*{*"
jumptrue 12
testis "endtext*.*andtestset*{*"
jumptrue 10
testis "quote*.*andtestset*{*"
jumptrue 8
testis "class*.*andtestset*{*"
jumptrue 6
testis "eof*,*ortestset*{*"
jumptrue 4
testis "tapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.33959
  testbegins "begin"
  jumpfalse block.end.33573
    clear
    add "testbegins "
  block.end.33573:
  testbegins "end"
  jumpfalse block.end.33613
    clear
    add "testends "
  block.end.33613:
  testbegins "quote"
  jumpfalse block.end.33653
    clear
    add "testis "
  block.end.33653:
  testbegins "class"
  jumpfalse block.end.33696
    clear
    add "testclass "
  block.end.33696:
  testbegins "eof"
  jumpfalse block.end.33740
    clear
    put
    add "testeof "
  block.end.33740:
  testbegins "tapetest"
  jumpfalse block.end.33790
    clear
    put
    add "testtape "
  block.end.33790:
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
block.end.33959:
# eg
# negated tests concatenated with AND logic (.). The 
# negated tests can be chained with non negated tests.
# eg: B'http' . !E'.txt' { ... }
testis "notbegintext*.*andtestset*{*"
jumptrue 12
testis "notendtext*.*andtestset*{*"
jumptrue 10
testis "notquote*.*andtestset*{*"
jumptrue 8
testis "notclass*.*andtestset*{*"
jumptrue 6
testis "noteof*,*ortestset*{*"
jumptrue 4
testis "nottapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.34758
  testbegins "notbegin"
  jumpfalse block.end.34358
    clear
    add "testbegins "
  block.end.34358:
  testbegins "notend"
  jumpfalse block.end.34401
    clear
    add "testends "
  block.end.34401:
  testbegins "notquote"
  jumpfalse block.end.34444
    clear
    add "testis "
  block.end.34444:
  testbegins "notclass"
  jumpfalse block.end.34490
    clear
    add "testclass "
  block.end.34490:
  testbegins "noteof"
  jumpfalse block.end.34537
    clear
    put
    add "testeof "
  block.end.34537:
  testbegins "nottapetest"
  jumpfalse block.end.34590
    clear
    put
    add "testtape "
  block.end.34590:
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
block.end.34758:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.35829
  testbegins "test*{*"
  jumpfalse block.end.35379
    clear
    # get rid of unnecessary jump but only in "test" cases 
    get
    # for positive tests (eg [a-z] {...})
    replace "jumptrue 2 \njump" "jumpfalse"
    put
    # for negative tests (eg ![a-z] {...})
    replace "jumpfalse 2 \njump" "jumptrue"
    put
  block.end.35379:
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
block.end.35829:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.37552
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
  jump block.end.36565
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
  block.end.36565:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.37046
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
  block.end.37046:
  push
  push
  # state
  clear
  add "After compiling with 'compile.pss' (at EOF): \n "
  add "  parse error in input script, check syntax: \n "
  add "  To debug script try the -I switch with \n "
  add "   >> pp -If script -i 'some input' \n "
  add "  or to debug the compilation process try: \n "
  add "   >> pp -Ia asm.pp script' \n "
  print
  clear
  # clear sav.pp because script could not be compiled
  write
  # bail means exit with error
  bail
block.end.37552:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
