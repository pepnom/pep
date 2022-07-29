# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumpfalse block.end.10973
  clear
  jump parse
block.end.10973:
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
jump block.end.11335
  put
  add "*"
  push
  jump parse
block.end.11335:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.11453
  until "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.11453:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.11738
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
block.end.11738:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumpfalse block.end.11886
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.11886:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumpfalse block.end.12395
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.12080
    clear
    add "eof*"
    push
    jump parse
  block.end.12080:
  testis "=="
  jumpfalse block.end.12133
    clear
    add "tapetest*"
    push
    jump parse
  block.end.12133:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.12395:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.13352
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumpfalse block.end.12669
    clear
    jump start
  block.end.12669:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.13170
    until "*#"
    testends "*#"
    jumpfalse block.end.12967
      clear
      jump start
    block.end.12967:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  block.end.13170:
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
block.end.13352:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^]
jumptrue block.end.13732
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
block.end.13732:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEOFKGPRWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
testis "a"
jumpfalse block.end.14252
  clear
  add "add"
block.end.14252:
testis "k"
jumpfalse block.end.14282
  clear
  add "clip"
block.end.14282:
testis "K"
jumpfalse block.end.14312
  clear
  add "clop"
block.end.14312:
testis "D"
jumpfalse block.end.14345
  clear
  add "replace"
block.end.14345:
testis "d"
jumpfalse block.end.14376
  clear
  add "clear"
block.end.14376:
testis "t"
jumpfalse block.end.14407
  clear
  add "print"
block.end.14407:
testis "p"
jumpfalse block.end.14436
  clear
  add "pop"
block.end.14436:
testis "P"
jumpfalse block.end.14466
  clear
  add "push"
block.end.14466:
testis "G"
jumpfalse block.end.14495
  clear
  add "put"
block.end.14495:
testis "g"
jumpfalse block.end.14524
  clear
  add "get"
block.end.14524:
testis "x"
jumpfalse block.end.14554
  clear
  add "swap"
block.end.14554:
testis ">"
jumpfalse block.end.14582
  clear
  add "++"
block.end.14582:
testis "<"
jumpfalse block.end.14610
  clear
  add "--"
block.end.14610:
testis "r"
jumpfalse block.end.14640
  clear
  add "read"
block.end.14640:
testis "R"
jumpfalse block.end.14671
  clear
  add "until"
block.end.14671:
testis "w"
jumpfalse block.end.14702
  clear
  add "while"
block.end.14702:
testis "W"
jumpfalse block.end.14736
  clear
  add "whilenot"
block.end.14736:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumpfalse block.end.15214
  clear
  add "count"
block.end.15214:
testis "+"
jumpfalse block.end.15242
  clear
  add "a+"
block.end.15242:
testis "-"
jumpfalse block.end.15270
  clear
  add "a-"
block.end.15270:
testis "0"
jumpfalse block.end.15300
  clear
  add "zero"
block.end.15300:
testis "c"
jumpfalse block.end.15328
  clear
  add "cc"
block.end.15328:
testis "l"
jumpfalse block.end.15356
  clear
  add "ll"
block.end.15356:
testis "^"
jumpfalse block.end.15388
  clear
  add "escape"
block.end.15388:
testis "v"
jumpfalse block.end.15422
  clear
  add "unescape"
block.end.15422:
testis "z"
jumpfalse block.end.15453
  clear
  add "delim"
block.end.15453:
testis "S"
jumpfalse block.end.15484
  clear
  add "state"
block.end.15484:
testis "q"
jumpfalse block.end.15514
  clear
  add "quit"
block.end.15514:
testis "Q"
jumpfalse block.end.15544
  clear
  add "bail"
block.end.15544:
testis "s"
jumpfalse block.end.15575
  clear
  add "write"
block.end.15575:
testis "o"
jumpfalse block.end.15604
  clear
  add "nop"
block.end.15604:
testis "rs"
jumpfalse block.end.15638
  clear
  add "restart"
block.end.15638:
testis "rp"
jumpfalse block.end.15672
  clear
  add "reparse"
block.end.15672:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.15783
  put
  clear
  add "eof*"
  push
  jump parse
block.end.15783:
testis "<==>"
jumpfalse block.end.15841
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.15841:
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
jump block.end.16276
  put
  clear
  add "word*"
  push
  jump parse
block.end.16276:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis "parse>"
jumpfalse block.end.16961
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
block.end.16961:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.17177
  put
  add "*"
  push
  jump parse
block.end.17177:
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
jump block.end.19037
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
block.end.19037:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.19226
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
block.end.19226:
testis ",*{*"
jumpfalse block.end.19394
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
block.end.19394:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.19581
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
block.end.19581:
testis "!*!*"
jumpfalse block.end.19842
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
block.end.19842:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.20151
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
block.end.20151:
testis ",*command*"
jumpfalse block.end.20321
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
block.end.20321:
testis "!*command*"
jumpfalse block.end.20520
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
block.end.20520:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.20723
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
block.end.20723:
testis "{*}*"
jumpfalse block.end.20854
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.20854:
testis "}*command*"
jumpfalse block.end.21001
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.21001:
# -------------
# 2 token end-of-stream errors
testeof 
jumpfalse block.end.21225
  testis "command*}*"
  jumpfalse block.end.21219
    push
    push
    add "error near line "
    ll
    add " of script: extra closing brace '}' ?. \n"
    print
    clear
    quit
  block.end.21219:
block.end.21225:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
# but '.' is also the AND concatenator, which seems ambiguous,
# but seems to work.
testis ".*word*"
jumpfalse block.end.21915
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.21593
    clear
    add "jump start"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21593:
  testis "reparse"
  jumpfalse block.end.21708
    clear
    add "jump parse"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21708:
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
block.end.21915:
#-----------------------------------------
# compiling comments so as to transfer them to the compiled 
# file. Improve this by just forming rules for
# command*comment* and comment*command* and comment*comment*
# implement these rules to conserve comments
testis "comment*command*"
jumpfalse block.end.22224
  nop
block.end.22224:
testis "command*comment*"
jumpfalse block.end.22261
  nop
block.end.22261:
testis "comment*comment*"
jumpfalse block.end.22298
  nop
block.end.22298:
testends "comment*"
jumpfalse block.end.22548
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.22468
    jump start
  block.end.22468:
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
block.end.22548:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumpfalse block.end.23165
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.22933
    jump start
  block.end.22933:
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
block.end.23165:
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
jump block.end.24092
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
block.end.24092:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.24364
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24364:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.24675
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24675:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.25354
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
  jump block.end.25224
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
  block.end.25224:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
block.end.25354:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.25678
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
block.end.25678:
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
jump block.end.26701
  zero
  testbegins "begin"
  jumpfalse block.end.25994
    clear
    add "testbegins "
  block.end.25994:
  testbegins "end"
  jumpfalse block.end.26033
    clear
    add "testends "
  block.end.26033:
  testbegins "quote"
  jumpfalse block.end.26072
    clear
    add "testis "
  block.end.26072:
  testbegins "class"
  jumpfalse block.end.26114
    clear
    add "testclass "
  block.end.26114:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.26246
    clear
    put
    add "testeof "
  block.end.26246:
  testbegins "tapetest"
  jumpfalse block.end.26295
    clear
    put
    add "testtape "
  block.end.26295:
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
block.end.26701:
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
jump block.end.27607
  zero
  testbegins "notbegin"
  jumpfalse block.end.27000
    clear
    add "testbegins "
  block.end.27000:
  testbegins "notend"
  jumpfalse block.end.27042
    clear
    add "testends "
  block.end.27042:
  testbegins "notquote"
  jumpfalse block.end.27084
    clear
    add "testis "
  block.end.27084:
  testbegins "notclass"
  jumpfalse block.end.27129
    clear
    add "testclass "
  block.end.27129:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.27264
    clear
    put
    add "testeof "
  block.end.27264:
  testbegins "nottapetest"
  jumpfalse block.end.27316
    clear
    put
    add "testtape "
  block.end.27316:
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
block.end.27607:
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
jump block.end.28043
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
block.end.28043:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.28239
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.28239:
# rule 
#',' ortestset ::= ',' test '{'
# trigger a transmogrification from test to ortestset token
# and 
# '.' andtestset ::= '.' test '{'
testis ",*test*{*"
jumpfalse block.end.28476
  clear
  add ",*ortestset*{*"
  push
  push
  push
  jump parse
block.end.28476:
# trigger a transmogrification from "test" to "andtest" by
# looking backwards in the stack
testis ".*test*{*"
jumpfalse block.end.28713
  a-
  clear
  add ".*andtestset*{*"
  push
  push
  push
  jump parse
block.end.28713:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.29045
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
block.end.29045:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.29834
  clear
  get
  testis "replace"
  jumpfalse block.end.29385
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.29385:
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
  jump block.end.29646
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
  block.end.29646:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.29834:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z]
testis "word*class*;*"
jumpfalse block.end.30340
  clear
  get
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.30190
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
  block.end.30190:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.30340:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.31001
  clear
  get
  testis "replace"
  jumpfalse block.end.30881
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
  block.end.30881:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
block.end.31001:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.31385
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
block.end.31385:
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
jump block.end.32309
  testbegins "begin"
  jumpfalse block.end.31714
    clear
    add "testbegins "
  block.end.31714:
  testbegins "end"
  jumpfalse block.end.31754
    clear
    add "testends "
  block.end.31754:
  testbegins "quote"
  jumpfalse block.end.31794
    clear
    add "testis "
  block.end.31794:
  testbegins "class"
  jumpfalse block.end.31837
    clear
    add "testclass "
  block.end.31837:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.31972
    clear
    put
    add "testeof "
  block.end.31972:
  testbegins "tapetest"
  jumpfalse block.end.32022
    clear
    put
    add "testtape "
  block.end.32022:
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
block.end.32309:
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
jump block.end.33106
  testbegins "notbegin"
  jumpfalse block.end.32581
    clear
    add "testbegins "
  block.end.32581:
  testbegins "notend"
  jumpfalse block.end.32624
    clear
    add "testends "
  block.end.32624:
  testbegins "notquote"
  jumpfalse block.end.32667
    clear
    add "testis "
  block.end.32667:
  testbegins "notclass"
  jumpfalse block.end.32713
    clear
    add "testclass "
  block.end.32713:
  testbegins "noteof"
  jumpfalse block.end.32760
    clear
    put
    add "testeof "
  block.end.32760:
  testbegins "nottapetest"
  jumpfalse block.end.32813
    clear
    put
    add "testtape "
  block.end.32813:
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
block.end.33106:
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
jump block.end.34034
  testbegins "begin"
  jumpfalse block.end.33648
    clear
    add "testbegins "
  block.end.33648:
  testbegins "end"
  jumpfalse block.end.33688
    clear
    add "testends "
  block.end.33688:
  testbegins "quote"
  jumpfalse block.end.33728
    clear
    add "testis "
  block.end.33728:
  testbegins "class"
  jumpfalse block.end.33771
    clear
    add "testclass "
  block.end.33771:
  testbegins "eof"
  jumpfalse block.end.33815
    clear
    put
    add "testeof "
  block.end.33815:
  testbegins "tapetest"
  jumpfalse block.end.33865
    clear
    put
    add "testtape "
  block.end.33865:
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
block.end.34034:
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
jump block.end.34833
  testbegins "notbegin"
  jumpfalse block.end.34433
    clear
    add "testbegins "
  block.end.34433:
  testbegins "notend"
  jumpfalse block.end.34476
    clear
    add "testends "
  block.end.34476:
  testbegins "notquote"
  jumpfalse block.end.34519
    clear
    add "testis "
  block.end.34519:
  testbegins "notclass"
  jumpfalse block.end.34565
    clear
    add "testclass "
  block.end.34565:
  testbegins "noteof"
  jumpfalse block.end.34612
    clear
    put
    add "testeof "
  block.end.34612:
  testbegins "nottapetest"
  jumpfalse block.end.34665
    clear
    put
    add "testtape "
  block.end.34665:
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
block.end.34833:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.35904
  testbegins "test*{*"
  jumpfalse block.end.35454
    clear
    # get rid of unnecessary jump but only in "test" cases 
    get
    # for positive tests (eg [a-z] {...})
    replace "jumptrue 2 \njump" "jumpfalse"
    put
    # for negative tests (eg ![a-z] {...})
    replace "jumpfalse 2 \njump" "jumptrue"
    put
  block.end.35454:
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
block.end.35904:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.37627
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
  jump block.end.36640
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
  block.end.36640:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.37121
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
  block.end.37121:
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
block.end.37627:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
