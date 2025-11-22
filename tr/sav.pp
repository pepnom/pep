# Assembled with the script 'compile.pss' 
# reserve 2 tapes cells
# mark "work"; ++; mark "head"; ++;
while [:space:]
clear
testeof 
jumpfalse block.end.8466
  # the usage topic of the help system. 
  add "usage"
  put
  clear
  add "nom.help*"
  push
  jump parse
block.end.8466:
# a document starting with / or // etc will be considered a help request
# a document starting with '/' would not be a valid nom script
while [/]
testis ""
jumptrue block.end.8876
  # get 2 help words and save with no space 
  clear
  while [:space:]
  clear
  whilenot [:space:]
  put
  clear
  while [:space:]
  clear
  whilenot [:space:]
  swap
  get
  put
  clear
  add "nom.help*"
  push
  jump parse
block.end.8876:
start:
# end of beginblock
read
# sort-of line-relative character numbers 
testclass [\n]
jumpfalse block.end.8975
  nochars
block.end.8975:
# ignore space except in quotes. but be careful about silent
# exit on read at eof
testclass [:space:]
jumpfalse block.end.9133
  clear
  testeof 
  jumpfalse block.end.9108
    jump parse
  block.end.9108:
  testeof 
  jumptrue block.end.9128
    jump start
  block.end.9128:
block.end.9133:
# literal tokens, for readability maybe 'dot*' and 'comma*'
testclass [<>}()!BE,.;]
jumpfalse block.end.9245
  put
  add "*"
  push
  jump parse
block.end.9245:
testclass [{]
jumpfalse block.end.9429
  # line and char number to help with missing close brace 
  # errors
  clear
  add "line:"
  ll
  add " char:"
  cc
  put
  clear
  add "{*"
  push
  jump parse
block.end.9429:
# parse (eof) etc as tokens? yes
# command names, need to do some tricks to parse ++ -- a+ etc
# here. This is because [:alpha:],[+-] etc is not a union set
# and while cannot do "while [:alpha:],[+-] etc
# subtle bug, [+-^0=] parses as a range!!! [a-z]
testclass [:alpha:]
jumptrue 4
testclass [-+^0=]
jumptrue 2 
jump block.end.14087
  # a much more succint abbreviation code
  testis "0"
  jumpfalse block.end.9794
    clear
    add "zero"
  block.end.9794:
  testis "^"
  jumpfalse block.end.9827
    clear
    add "escape"
  block.end.9827:
  # increment tape pointer ++ command
  testis "+"
  jumpfalse block.end.9890
    while [+]
  block.end.9890:
  # decrement tape pointer -- command
  testis "-"
  jumpfalse block.end.9953
    while [-]
  block.end.9953:
  # tape test (==)
  testis "="
  jumpfalse block.end.9997
    while [=]
  block.end.9997:
  # for better error messages dont read ahead for the 
  # above commands.
  testis "zero"
  jumptrue 9
  testis "escape"
  jumptrue 7
  testbegins "+"
  jumptrue 5
  testbegins "-"
  jumptrue 3
  testbegins "="
  jumpfalse 2 
  jump block.end.10149
    while [:alpha:]
  block.end.10149:
  # parse a+ or a- for the accumulator
  testis "a"
  jumpfalse block.end.10373
    # while [+-] is bug because compile.pss thinks its a range class
    # not a list class
    while [-+]
    testis "a+"
    jumptrue 4
    testis "a-"
    jumptrue 2 
    jump block.end.10335
      put
    block.end.10335:
    testis "a"
    jumpfalse block.end.10367
      clear
      add "add"
    block.end.10367:
  block.end.10373:
  # one letter command abbreviation expansions.
  # 'D' doesn't actually work in compile.pss !
  put
  clear
  add "#"
  get
  add "#"
  replace "#k#" "#clip#"
  replace "#K#" "#clop#"
  replace "#D#" "#replace#"
  replace "#d#" "#clear#"
  replace "#t#" "#print#"
  replace "#p#" "#pop#"
  replace "#P#" "#push#"
  replace "#u#" "#unstack#"
  replace "#U#" "#stack#"
  replace "#G#" "#put#"
  replace "#g#" "#get#"
  replace "#x#" "#swap#"
  replace "#m#" "#mark#"
  replace "#M#" "#go#"
  replace "#r#" "#read#"
  replace "#R#" "#until#"
  replace "#w#" "#while#"
  replace "#W#" "#whilenot#"
  replace "#n#" "#count#"
  replace "#c#" "#chars#"
  replace "#C#" "#nochars#"
  replace "#l#" "#lines#"
  replace "#L#" "#nolines#"
  replace "#v#" "#unescape#"
  replace "#z#" "#delim#"
  replace "#S#" "#state#"
  replace "#q#" "#quit#"
  replace "#s#" "#write#"
  replace "#o#" "#nop#"
  replace "#rs#" "#restart#"
  replace "#rp#" "#reparse#"
  # remove leading/trailing #
  clip
  clop
  put
  # dont want to use this syntax anymore because we already have
  # lines and 'l' or chars and 'c'
  testis "ll"
  jumptrue 4
  testis "cc"
  jumptrue 2 
  jump block.end.11805
    clear
    add "* The syntax \""
    get
    add "\" for lines or chars"
    add "  is no longer valid.\n"
    add "  use 'chars' or 'c' for a character count \n"
    add "  use 'lines' or 'l' for a line count \n"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.11805:
  testis "+"
  jumptrue 4
  testis "-"
  jumptrue 2 
  jump block.end.12091
    clear
    add "* This syntax \""
    get
    add "\" which were 1 letter abbreviations\n"
    add "  are no longer valid because.\n"
    add "  it is silly to have 1 letter abbrevs for 2 letter commands."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.12091:
  # writefile is also a command? yes.
  # commands parsed above
  testis "a+"
  jumptrue 86
  testis "a-"
  jumptrue 84
  testis "zero"
  jumptrue 82
  testis "++"
  jumptrue 80
  testis "--"
  jumptrue 78
  testis "add"
  jumptrue 76
  testis "clip"
  jumptrue 74
  testis "clop"
  jumptrue 72
  testis "replace"
  jumptrue 70
  testis "upper"
  jumptrue 68
  testis "lower"
  jumptrue 66
  testis "cap"
  jumptrue 64
  testis "clear"
  jumptrue 62
  testis "print"
  jumptrue 60
  testis "webstate"
  jumptrue 58
  testis "state"
  jumptrue 56
  testis "pop"
  jumptrue 54
  testis "push"
  jumptrue 52
  testis "unstack"
  jumptrue 50
  testis "stack"
  jumptrue 48
  testis "put"
  jumptrue 46
  testis "get"
  jumptrue 44
  testis "swap"
  jumptrue 42
  testis "mark"
  jumptrue 40
  testis "go"
  jumptrue 38
  testis "read"
  jumptrue 36
  testis "until"
  jumptrue 34
  testis "while"
  jumptrue 32
  testis "whilenot"
  jumptrue 30
  testis "count"
  jumptrue 28
  testis "zero"
  jumptrue 26
  testis "chars"
  jumptrue 24
  testis "lines"
  jumptrue 22
  testis "nochars"
  jumptrue 20
  testis "nolines"
  jumptrue 18
  testis "escape"
  jumptrue 16
  testis "unescape"
  jumptrue 14
  testis "echar"
  jumptrue 12
  testis "delim"
  jumptrue 10
  testis "quit"
  jumptrue 8
  testis "write"
  jumptrue 6
  testis "system"
  jumptrue 4
  testis "nop"
  jumptrue 2 
  jump block.end.12568
    clear
    add "command*"
    push
    jump parse
  block.end.12568:
  # words not commands == was parsed above
  testis "parse"
  jumptrue 12
  testis "reparse"
  jumptrue 10
  testis "restart"
  jumptrue 8
  testis "eof"
  jumptrue 6
  testis "EOF"
  jumptrue 4
  testis "=="
  jumptrue 2 
  jump block.end.12717
    put
    clear
    add "word*"
    push
    jump parse
  block.end.12717:
  testis "begin"
  jumpfalse block.end.12763
    put
    add "*"
    push
    jump parse
  block.end.12763:
  # lower case and check for command with error
  lower
  testis "add"
  jumptrue 94
  testis "clip"
  jumptrue 92
  testis "clop"
  jumptrue 90
  testis "replace"
  jumptrue 88
  testis "upper"
  jumptrue 86
  testis "lower"
  jumptrue 84
  testis "cap"
  jumptrue 82
  testis "clear"
  jumptrue 80
  testis "print"
  jumptrue 78
  testis "webstate"
  jumptrue 76
  testis "state"
  jumptrue 74
  testis "pop"
  jumptrue 72
  testis "push"
  jumptrue 70
  testis "unstack"
  jumptrue 68
  testis "stack"
  jumptrue 66
  testis "put"
  jumptrue 64
  testis "get"
  jumptrue 62
  testis "swap"
  jumptrue 60
  testis "mark"
  jumptrue 58
  testis "go"
  jumptrue 56
  testis "read"
  jumptrue 54
  testis "until"
  jumptrue 52
  testis "while"
  jumptrue 50
  testis "whilenot"
  jumptrue 48
  testis "count"
  jumptrue 46
  testis "zero"
  jumptrue 44
  testis "chars"
  jumptrue 42
  testis "lines"
  jumptrue 40
  testis "nochars"
  jumptrue 38
  testis "nolines"
  jumptrue 36
  testis "escape"
  jumptrue 34
  testis "unescape"
  jumptrue 32
  testis "echar"
  jumptrue 30
  testis "delim"
  jumptrue 28
  testis "quit"
  jumptrue 26
  testis "write"
  jumptrue 24
  testis "zero"
  jumptrue 22
  testis "++"
  jumptrue 20
  testis "--"
  jumptrue 18
  testis "a+"
  jumptrue 16
  testis "a-"
  jumptrue 14
  testis "system"
  jumptrue 12
  testis "nop"
  jumptrue 10
  testis "begin"
  jumptrue 8
  testis "parse"
  jumptrue 6
  testis "reparse"
  jumptrue 4
  testis "restart"
  jumptrue 2 
  jump block.end.13535
    ++
    put
    --
    clear
    add "* incorrect command \""
    get
    add "\"\n"
    add "- all nom commands and words are lower case \n"
    add "  (except for EOF and abbreviations) \n"
    add "- did you mean '"
    ++
    get
    --
    add "'?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.13535:
  clear
  add "* unknown word or command \""
  get
  add "\""
  add "\n"
  add "\n"
  add "    - Valid nom commands are: \n"
  add "\n"
  add "    add clip clop replace upper lower cap clear \n"
  add "    print state pop push unstack stack put get swap \n"
  add "    mark go read until while whilenot \n"
  add "    count zero chars lines nochars nolines \n"
  add "    escape unescape delim quit write (writefile ?) \n"
  add "    zero ++ -- a+ a- nop \n"
  add "    \n"
  add "    - Valid nom words are \n"
  add "\n"
  add "    parse reparse restart begin eof EOF == \n"
  add "\n"
  add "    see www.nomlang.org/doc/commands/ \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.14087:
# single line comments
# no need to rethink
testis "#"
jumpfalse block.end.14772
  testeof 
  jumpfalse block.end.14174
    clear
    jump parse
  block.end.14174:
  read
  # just delete empty comments
  testclass [#\n]
  jumpfalse block.end.14248
    clear
    jump parse
  block.end.14248:
  # multiline comments this needs to go within '#'
  testis "#*"
  jumpfalse block.end.14694
    # save the start line number for error messages
    clear
    add "line:"
    ll
    add " char:"
    cc
    put
    clear
    until "*#"
    testends "*#"
    jumptrue block.end.14620
      clear
      add "* unterminated multiline comment #*... \n  starting at "
      get
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.14620:
    clip
    clip
    put
    clear
    add "comment*"
    push
    jump parse
  block.end.14694:
  clear
  whilenot [\n]
  put
  clear
  add "comment*"
  push
  jump parse
block.end.14772:
# quoted text 
# I will double quote all text and escape $ and \\ 
# double quotes are for strings and single for chars in perl?
testis "\""
jumpfalse block.end.15738
  # save the start line number (for error messages) in case 
  # there is no terminating quote character.
  clear
  add "line:"
  ll
  add " char:"
  cc
  put
  clear
  until "\""
  testends "\""
  jumpfalse 4
  testeof 
  jumptrue 2 
  jump block.end.15274
    clear
    add "* unterminated quote (\") or incomplete command starting at "
    get
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.15274:
  # empty quotes are checked later.
  clip
  # this trick 
  unescape "\""
  #escape '\\'; 
  # I need to escape $ for variable names and @ for arrays in
  # perl double quoted strings. I think that is all. This is a thorny
  # issue because I want \n \t etc character substitution but not
  # the rest.
  escape "$"
  escape "@"
  escape "\""
  put
  clear
  add "\""
  get
  add "\""
  put
  clear
  add "quoted*"
  push
  jump parse
block.end.15738:
# single quotes
testis "'"
jumpfalse block.end.16400
  clear
  # save start line/char of "'" for error messages
  add "line:"
  ll
  add " char:"
  cc
  put
  clear
  until "'"
  testends "'"
  jumpfalse 4
  testeof 
  jumptrue 2 
  jump block.end.16062
    clear
    add "* unterminated quote (\') or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.16062:
  # empty quotes are checked later . must escape "\\" first 
  clip
  unescape "'"
  # not sure about escaping this. It is causing problems with 2nd gen
  unescape "\""
  # escape '\\'; 
  escape "$"
  escape "@"
  escape "\""
  put
  clear
  add "\""
  get
  add "\""
  put
  clear
  add "quoted*"
  push
  jump parse
block.end.16400:
# classes like [:space:] or [abc] or [a-z] 
# these are used in tests and also in while/whilenot
# The *until* command will read past 'escaped' end characters eg \]
# 
testis "["
jumpfalse block.end.23365
  clear
  # just leave brackets eg [:etc:]
  # save start line/char of '[' for error messages
  add "line:"
  ll
  add " char:"
  cc
  put
  clear
  until "]"
  testends "]"
  jumpfalse 4
  testeof 
  jumptrue 2 
  jump block.end.16928
    clear
    add "* unterminated class [...] or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.16928:
  clip
  put
  testbegins ":"
  jumpfalse 7
  testends ":"
  jumpfalse 5
  testis ":"
  jumptrue 3
  testis "::"
  jumpfalse 2 
  jump block.end.23073
    clip
    clop
    put
    # no nom class abbreviations, Unicode categories already have many
    # abbreviations, I will use those. I would like to accept any unicode
    # script/block/category but can't unless I want to code them.
    # these are ctype classes 
    testis "alnum"
    jumptrue 28
    testis "alpha"
    jumptrue 26
    testis "ascii"
    jumptrue 24
    testis "word"
    jumptrue 22
    testis "blank"
    jumptrue 20
    testis "cntrl"
    jumptrue 18
    testis "digit"
    jumptrue 16
    testis "graph"
    jumptrue 14
    testis "lower"
    jumptrue 12
    testis "print"
    jumptrue 10
    testis "punct"
    jumptrue 8
    testis "space"
    jumptrue 6
    testis "upper"
    jumptrue 4
    testis "xdigit"
    jumptrue 2 
    jump block.end.17665
      # these will all be handled by the Machine.matchClass() method
      # because it will all be changed by grapheme clusters and 
      # by using unicode perl modules ?
      clear
      add "[:"
      get
      add ":]"
      put
      clear
      add "class*"
      push
      jump parse
    block.end.17665:
    # unicode category names, the first is an abbreviation of the 
    # second. It would be good to allow all lower case etc.
    # allow writing spaces or dots instead of _  This is ok because 
    # unicode script names dont have spaces or dots in them.
    replace " " "_"
    replace "." "_"
    testis "L"
    jumptrue 152
    testis "Letter"
    jumptrue 150
    testis "Ll"
    jumptrue 148
    testis "Lowercase_Letter"
    jumptrue 146
    testis "Lu"
    jumptrue 144
    testis "Uppercase_Letter"
    jumptrue 142
    testis "Lt"
    jumptrue 140
    testis "Titlecase_Letter"
    jumptrue 138
    testis "L&"
    jumptrue 136
    testis "Cased_Letter"
    jumptrue 134
    testis "Lm"
    jumptrue 132
    testis "Modifier_Letter"
    jumptrue 130
    testis "Lo"
    jumptrue 128
    testis "Other_Letter"
    jumptrue 126
    testis "M"
    jumptrue 124
    testis "Mark"
    jumptrue 122
    testis "Mn"
    jumptrue 120
    testis "Non_Spacing_Mark"
    jumptrue 118
    testis "Mc"
    jumptrue 116
    testis "Spacing_Combining_Mark"
    jumptrue 114
    testis "Me"
    jumptrue 112
    testis "Enclosing_Mark"
    jumptrue 110
    testis "Z"
    jumptrue 108
    testis "Separator"
    jumptrue 106
    testis "Zs"
    jumptrue 104
    testis "Space_Separator"
    jumptrue 102
    testis "Zl"
    jumptrue 100
    testis "Line_Separator"
    jumptrue 98
    testis "Zp"
    jumptrue 96
    testis "Paragraph_Separator"
    jumptrue 94
    testis "S"
    jumptrue 92
    testis "Symbol"
    jumptrue 90
    testis "Sm"
    jumptrue 88
    testis "Math_Symbol"
    jumptrue 86
    testis "Sc"
    jumptrue 84
    testis "Currency_Symbol"
    jumptrue 82
    testis "Sk"
    jumptrue 80
    testis "Modifier_Symbol"
    jumptrue 78
    testis "So"
    jumptrue 76
    testis "Other_Symbol"
    jumptrue 74
    testis "N"
    jumptrue 72
    testis "Number"
    jumptrue 70
    testis "Nd"
    jumptrue 68
    testis "Decimal_Digit_Number"
    jumptrue 66
    testis "Nl"
    jumptrue 64
    testis "Letter_Number"
    jumptrue 62
    testis "No"
    jumptrue 60
    testis "Other_Number"
    jumptrue 58
    testis "P"
    jumptrue 56
    testis "Punctuation"
    jumptrue 54
    testis "Pd"
    jumptrue 52
    testis "Dash_Punctuation"
    jumptrue 50
    testis "Ps"
    jumptrue 48
    testis "Open_Punctuation"
    jumptrue 46
    testis "Pe"
    jumptrue 44
    testis "Close_Punctuation"
    jumptrue 42
    testis "Pi"
    jumptrue 40
    testis "Initial_Punctuation"
    jumptrue 38
    testis "Pf"
    jumptrue 36
    testis "Final_Punctuation"
    jumptrue 34
    testis "Pc"
    jumptrue 32
    testis "Connector_Punctuation"
    jumptrue 30
    testis "Po"
    jumptrue 28
    testis "Other_Punctuation"
    jumptrue 26
    testis "C"
    jumptrue 24
    testis "Other"
    jumptrue 22
    testis "Cc"
    jumptrue 20
    testis "Control"
    jumptrue 18
    testis "Cf"
    jumptrue 16
    testis "Format"
    jumptrue 14
    testis "Co"
    jumptrue 12
    testis "Private_Use"
    jumptrue 10
    testis "Cs"
    jumptrue 8
    testis "Surrogate"
    jumptrue 6
    testis "Cn"
    jumptrue 4
    testis "Unassigned"
    jumptrue 2 
    jump block.end.19155
      add ":\n"
      add "         This nom->perl translator does not currently support unicode character \n"
      add "         category names in nom classes. You could try the nom->dart\n"
      add "         translator if you really need them:\n"
      add "           nomlang.org/tr/nom.todart.pss \n"
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.19155:
    # unicode script names, 
    testis "Common"
    jumptrue 90
    testis "Arabic"
    jumptrue 88
    testis "Armenian"
    jumptrue 86
    testis "Bengali"
    jumptrue 84
    testis "Bopomofo"
    jumptrue 82
    testis "Braille"
    jumptrue 80
    testis "Buhid"
    jumptrue 78
    testis "Canadian_Aboriginal"
    jumptrue 76
    testis "Cherokee"
    jumptrue 74
    testis "Cyrillic"
    jumptrue 72
    testis "Devanagari"
    jumptrue 70
    testis "Ethiopic"
    jumptrue 68
    testis "Georgian"
    jumptrue 66
    testis "Greek"
    jumptrue 64
    testis "Gujarati"
    jumptrue 62
    testis "Gurmukhi"
    jumptrue 60
    testis "Han"
    jumptrue 58
    testis "Hangul"
    jumptrue 56
    testis "Hanunoo"
    jumptrue 54
    testis "Hebrew"
    jumptrue 52
    testis "Hiragana"
    jumptrue 50
    testis "Inherited"
    jumptrue 48
    testis "Kannada"
    jumptrue 46
    testis "Katakana"
    jumptrue 44
    testis "Khmer"
    jumptrue 42
    testis "Lao"
    jumptrue 40
    testis "Latin"
    jumptrue 38
    testis "Limbu"
    jumptrue 36
    testis "Malayalam"
    jumptrue 34
    testis "Mongolian"
    jumptrue 32
    testis "Myanmar"
    jumptrue 30
    testis "Ogham"
    jumptrue 28
    testis "Oriya"
    jumptrue 26
    testis "Runic"
    jumptrue 24
    testis "Sinhala"
    jumptrue 22
    testis "Syriac"
    jumptrue 20
    testis "Tagalog"
    jumptrue 18
    testis "Tagbanwa"
    jumptrue 16
    testis "TaiLe"
    jumptrue 14
    testis "Tamil"
    jumptrue 12
    testis "Telugu"
    jumptrue 10
    testis "Thaana"
    jumptrue 8
    testis "Thai"
    jumptrue 6
    testis "Tibetan"
    jumptrue 4
    testis "Yi"
    jumptrue 2 
    jump block.end.19994
      add ":\n"
      add "         This nom->perl translator does not currently support unicode script \n"
      add "         names in nom classes. You could try the nom->dart\n"
      add "         translator if you really need them:\n"
      add "           nomlang.org/tr/nom.todart.pss \n"
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.19994:
    # blocks
    # unicode block names. not supported 
    testis "InBasic_Latin"
    jumptrue 210
    testis "InLatin-1_Supplement"
    jumptrue 208
    testis "InLatin_Extended-A"
    jumptrue 206
    testis "InLatin_Extended-B"
    jumptrue 204
    testis "InIPA_Extensions"
    jumptrue 202
    testis "InSpacing_Modifier_Letters"
    jumptrue 200
    testis "InCombining_Diacritical_Marks"
    jumptrue 198
    testis "InGreek_and_Coptic"
    jumptrue 196
    testis "InCyrillic"
    jumptrue 194
    testis "InCyrillic_Supplementary"
    jumptrue 192
    testis "InArmenian"
    jumptrue 190
    testis "InHebrew"
    jumptrue 188
    testis "InArabic"
    jumptrue 186
    testis "InSyriac"
    jumptrue 184
    testis "InThaana"
    jumptrue 182
    testis "InDevanagari"
    jumptrue 180
    testis "InBengali"
    jumptrue 178
    testis "InGurmukhi"
    jumptrue 176
    testis "InGujarati"
    jumptrue 174
    testis "InOriya"
    jumptrue 172
    testis "InTamil"
    jumptrue 170
    testis "InTelugu"
    jumptrue 168
    testis "InKannada"
    jumptrue 166
    testis "InMalayalam"
    jumptrue 164
    testis "InSinhala"
    jumptrue 162
    testis "InThai"
    jumptrue 160
    testis "InLao"
    jumptrue 158
    testis "InTibetan"
    jumptrue 156
    testis "InMyanmar"
    jumptrue 154
    testis "InGeorgian"
    jumptrue 152
    testis "InHangul_Jamo"
    jumptrue 150
    testis "InEthiopic"
    jumptrue 148
    testis "InCherokee"
    jumptrue 146
    testis "InUnified_Canadian_Aboriginal_Syllabics"
    jumptrue 144
    testis "InOgham"
    jumptrue 142
    testis "InRunic"
    jumptrue 140
    testis "InTagalog"
    jumptrue 138
    testis "InHanunoo"
    jumptrue 136
    testis "InBuhid"
    jumptrue 134
    testis "InTagbanwa"
    jumptrue 132
    testis "InKhmer"
    jumptrue 130
    testis "InMongolian"
    jumptrue 128
    testis "InLimbu"
    jumptrue 126
    testis "InTai_Le"
    jumptrue 124
    testis "InKhmer_Symbols"
    jumptrue 122
    testis "InPhonetic_Extensions"
    jumptrue 120
    testis "InLatin_Extended_Additional"
    jumptrue 118
    testis "InGreek_Extended"
    jumptrue 116
    testis "InGeneral_Punctuation"
    jumptrue 114
    testis "InSuperscripts_and_Subscripts"
    jumptrue 112
    testis "InCurrency_Symbols"
    jumptrue 110
    testis "InCombining_Diacritical_Marks_for_Symbols"
    jumptrue 108
    testis "InLetterlike_Symbols"
    jumptrue 106
    testis "InNumber_Forms"
    jumptrue 104
    testis "InArrows"
    jumptrue 102
    testis "InMathematical_Operators"
    jumptrue 100
    testis "InMiscellaneous_Technical"
    jumptrue 98
    testis "InControl_Pictures"
    jumptrue 96
    testis "InOptical_Character_Recognition"
    jumptrue 94
    testis "InEnclosed_Alphanumerics"
    jumptrue 92
    testis "InBox_Drawing"
    jumptrue 90
    testis "InBlock_Elements"
    jumptrue 88
    testis "InGeometric_Shapes"
    jumptrue 86
    testis "InMiscellaneous_Symbols"
    jumptrue 84
    testis "InDingbats"
    jumptrue 82
    testis "InMiscellaneous_Mathematical_Symbols-A"
    jumptrue 80
    testis "InSupplemental_Arrows-A"
    jumptrue 78
    testis "InBraille_Patterns"
    jumptrue 76
    testis "InSupplemental_Arrows-B"
    jumptrue 74
    testis "InMiscellaneous_Mathematical_Symbols-B"
    jumptrue 72
    testis "InSupplemental_Mathematical_Operators"
    jumptrue 70
    testis "InMiscellaneous_Symbols_and_Arrows"
    jumptrue 68
    testis "InCJK_Radicals_Supplement"
    jumptrue 66
    testis "InKangxi_Radicals"
    jumptrue 64
    testis "InIdeographic_Description_Characters"
    jumptrue 62
    testis "InCJK_Symbols_and_Punctuation"
    jumptrue 60
    testis "InHiragana"
    jumptrue 58
    testis "InKatakana"
    jumptrue 56
    testis "InBopomofo"
    jumptrue 54
    testis "InHangul_Compatibility_Jamo"
    jumptrue 52
    testis "InKanbun"
    jumptrue 50
    testis "InBopomofo_Extended"
    jumptrue 48
    testis "InKatakana_Phonetic_Extensions"
    jumptrue 46
    testis "InEnclosed_CJK_Letters_and_Months"
    jumptrue 44
    testis "InCJK_Compatibility"
    jumptrue 42
    testis "InCJK_Unified_Ideographs_Extension_A"
    jumptrue 40
    testis "InYijing_Hexagram_Symbols"
    jumptrue 38
    testis "InCJK_Unified_Ideographs"
    jumptrue 36
    testis "InYi_Syllables"
    jumptrue 34
    testis "InYi_Radicals"
    jumptrue 32
    testis "InHangul_Syllables"
    jumptrue 30
    testis "InHigh_Surrogates"
    jumptrue 28
    testis "InHigh_Private_Use_Surrogates"
    jumptrue 26
    testis "InLow_Surrogates"
    jumptrue 24
    testis "InPrivate_Use_Area"
    jumptrue 22
    testis "InCJK_Compatibility_Ideographs"
    jumptrue 20
    testis "InAlphabetic_Presentation_Forms"
    jumptrue 18
    testis "InArabic_Presentation_Forms-A"
    jumptrue 16
    testis "InVariation_Selectors"
    jumptrue 14
    testis "InCombining_Half_Marks"
    jumptrue 12
    testis "InCJK_Compatibility_Forms"
    jumptrue 10
    testis "InSmall_Form_Variants"
    jumptrue 8
    testis "InArabic_Presentation_Forms-B"
    jumptrue 6
    testis "InHalfwidth_and_Fullwidth_Forms"
    jumptrue 4
    testis "InSpecials"
    jumptrue 2 
    jump block.end.22745
      add ":\n"
      add "           This nom->perl translator does not currently support unicode block \n"
      add "           names in nom class patterns. "
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.22745:
    clear
    add "* Incorrect nom character class\n"
    add " \n"
    add "      Character classes are used in tests and the nom while \n"
    add "      and whilenot commands\n"
    add "        eg: [:space:] { while [:space:]; clear; } \n"
    add "        or: [:alnum:] { while [:alnum:]; clear; } \n"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.23073:
  # not using regexes for matching classes in this translator
  # ] should already be escaped in the nom class
  # this is a normal escape so as not to break the '...'
  escape "\""
  unescape "]"
  put
  clear
  add "["
  get
  add "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.23365:
testis ""
jumptrue block.end.23579
  put
  clear
  add "* strange character found '"
  get
  add "'\n\n"
  add "  see www.nomlang.org/doc/syntax for nom syntax documentation \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.23579:
parse:
# watch the parse-stack resolve.  
# add "--> line "; lines; add " char "; chars; add ": "; print; clear; 
# unstack; print; stack; add "\n"; print; clear;
# ----------------
# the error and help system
pop

#  error and help tokens which allow implementing a help system
#  that can be triggered by an empty document or by help keywords
# 
testis "nom.error*"
jumpfalse block.end.24546
  clear
  add "--nom.toperl.pss-- (translate nom script to perl)\n"
  add "near line:"
  ll
  add " char:"
  cc
  add "\n"
  get
  add "\n try: /help for more information"
  add "\n run /eg/nom.syntax.reference.pss for more detailed \n"
  add " syntax checking. See www.nomlang.org/doc for comprehensive \n"
  add " pep and nom documentation. \n"
  # indent the error message 
  replace "\n" "\n  "
  add "\n"
  print
  clear
  pop
  testis "help*"
  jumpfalse block.end.24445
    push
    jump parse
  block.end.24445:
  # the help* token also quits but if there is no help token
  # then just stop here.
  quit
block.end.24546:
# this error is when the error should have been trapped earlier
testis "nom.untrapped.error*"
jumpfalse block.end.24871
  clear
  add "! Nom untrapped error! :"
  add " near line:"
  ll
  add " char:"
  cc
  add "\n"
  get
  add "\n run /eg/nom.syntax.reference.pss for more detailed \n"
  add " syntax checking. \n"
  print
  quit
block.end.24871:

#  Using a help* token to allow the script to document itself.
#  The swap commands below are used to save the help text in the tape
#  cell so that several or all help topics can be printed at once.
# 
testis "nom.help*"
jumpfalse block.end.37425
  clear
  swap
  # how to use this script
  testis "usage"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.25369
    swap
    add "\n"
    add "   USAGE\n"
    add "     pep -f nom.toperl.pss machine.txt \n"
    add "     pep -f nom.toperl.pss -i ' '\n"
    add "\n"
    add "     A nom script to format a pep machine description into an \n"
    add "     html diagram.\n"
    add "     "
    swap
  block.end.25369:
  # help about the help-system
  testis "words"
  jumptrue 6
  testis "usage"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.27672
    swap
    add "\n"
    add "   HELP KEYWORDS\n"
    add "\n"
    add "     All documents/input which begin with '/' are considered to be help \n"
    add "     requests. See below for the list of valid help keywords.\n"
    add "\n"
    add "     pep -f nom.toperl.pss -i /<helpword> \n"
    add "       see some help for that topic or category\n"
    add "\n"
    add "     pep -f nom.toperl.pss -i /words\n"
    add "       see what help topics and categories are available for this script.\n"
    add "\n"
    add "     pep -f nom.toperl.pss -i /help\n"
    add "       see the entire help.\n"
    add "\n"
    add "     pep -f nom.toperl.pss -i /toperl | bash\n"
    add "       translate this script to perl \n"
    add "       \n"
    add "   ### General Help \n"
    add "     - /usage: show a usage message for this script \n"
    add "     - /words: show what help commands are available\n"
    add "     - /faq: show an FAQ about this script.\n"
    add "     - /nom: show information about the nom script language\n"
    add "     - /flaws: known limitations with how this script works \n"
    add "   ### About the input format \n"
    add "     - /format: show summary information about the input pep machine \n"
    add "         text format.\n"
    add "   ### About testing this translation script\n"
    add "     - /check <script> check the given nom script for syntax errors\n"
    add "        and give helpful error message. todo\n"
    add "     - /eg: an example script for testing\n"
    add "     - /eg.lines: prints a set of example one-line nom scripts for testing \n"
    add "     - /eg.bad.lines: a set of nom one liners with syntax errors\n"
    add "     - /test.line: tests one random one-line document.\n"
    add "     - /test.line.open: translates to html and opens in a browser. \n"
    add "     - /test.bad.line: tests one random one-line invalid input.\n"
    add "     - /test: test the nom to perl translation script \n"
    add "        and open result in a browser. \n"
    add "     - /to<lang>: translate this script to some other language\n"
    add "         using the nom translation scripts at www.nomlang.org/tr/ \n"
    add "          ( rust|dart|perl|lua|go|java|javascript|ruby|python|tcl|c) \n"
    add "          (eg: /toperl /tolua etc). Or latex/pdf/html \n"
    add "\n"
    add "     The 'test' and 'to' words need to be piped to bash to actually \n"
    add "     execute.\n"
    add "\n"
    add "     Also see the /test.line help word for testing translated scripts\n"
    add "\n"
    add "     There are also help 'categories' which display several help\n"
    add "     topics at once such as:\n"
    add "\n"
    add "     - /usage: script usage and helpwords\n"
    add "     - /syntax: all information about valid nom syntax\n"
    add "     - /help: show all available help topics.\n"
    add "\n"
    add "     "
    swap
  block.end.27672:
  # the faq 
  testis "FAQ"
  jumptrue 6
  testis "faq"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.29800
    swap
    add "\n"
    add "   FAQ\n"
    add "     (Not) frequently asked questions about /eg/nom.toperl.pss\n"
    add "   \n"
    add "     Q: What is the purpose of this script?\n"
    add "     A: To translate a nom script (see www.nomlang.org ) into a stand-alone\n"
    add "        perl script.\n"
    add "\n"
    add "     Q: What else can it do?\n"
    add "     A: Quite alot actually. It can, or will, test itself, translate itself,\n"
    add "        interpret itself (after it has translated itself) and document itself.\n"
    add "\n"
    add "     Q: That sounds very confusing. Why would a translation script want to \n"
    add "        translate itself?\n"
    add "     A: It means that the script will translate a nom script into perl, or \n"
    add "        translate itself into perl, and once it has done that it can also\n"
    add "        interpret any nom script using its interpret() method and the eval()\n"
    add "        perl function. Basically it runs the parse() method to create a new \n"
    add "        parse() method, then renames the new parse() method to runScript() and\n"
    add "        then adds that new method to the existing pep machine class with \n"
    add "        the eval() function, and then calls that new method.\n"
    add "\n"
    add "     Q: Thats even more confusing. So what is the point?\n"
    add "     A: It creates a new interpreter for nom language in perl.\n"
    add "\n"
    add "     Q: I still dont get it. Does this script have any bugs it in?\n"
    add "     A: Possibly ... probably ... \n"
    add "\n"
    add "     Q: Isn't perl an obsolete language now?\n"
    add "     A: Maybe, but this translation script can be used as a model for the \n"
    add "        translation of nom into any scripting language that can execute \n"
    add "        a string as code.\n"
    add "\n"
    add "     Q: Can I use a nom script on a web-server from within my own perl code?\n"
    add "     A: Yes, because all the parsing and translating code is within a \n"
    add "        parse() method in the generated perl code, so you could import the \n"
    add "        package into your own script and then call the parse() method.\n"
    add "\n"
    add "     Q: But the only language anyone uses in Javascript. Can I translate a \n"
    add "        nom script to java script?\n"
    add "     A: Yes, using the /eg/translate.js.pss script but this translation script\n"
    add "        I wrote a few years ago and its not as good as the nom.to<lang>.pss \n"
    add "        scripts.\n"
    add "\n"
    add "     "
    swap
  block.end.29800:
  # more information about the nom language 
  testis "nom"
  jumptrue 6
  testis "about"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.30220
    swap
    add "\n"
    add "       This script is written in the 'nom' language which is a \n"
    add "       manifestation of the pep{nom} parsing system.\n"
    add "\n"
    add "       Nom is a scripting language for parsing/translating context-free and \n"
    add "       (some) context-sensitive patterns. Please see www.nomlang.org for\n"
    add "       (much) more information.\n"
    add "     "
    swap
  block.end.30220:
  testis "eg"
  jumpfalse block.end.30412
    swap
    add "\n"
    add "      while [:space:]; clear;\n"
    add "      whilenot [:space:]; add \"\n\"; print;\n"
    add "      clear;\n"
    add "      (eof) { zero; quit; }\n"
    add "     "
    replace "\n      " "\n"
    swap
  block.end.30412:
  # This help word is standard so that a script like 
  # /eg/nom.to.pss can call it and test any script, or the script can
  # test itself.
  testis "eg.lines"
  jumpfalse block.end.30878
    swap
    add "\n"
    add "       # the simplest  \n"
    add "       read; print; clear;\n"
    add "       # every word on a separate line\n"
    add "       while [:space:]; clear; whilenot [:space:]; add \"\\n\"; print;\n"
    add "       # simple test and block\n"
    add "       read; \"x\" { print; } print; clear;\n"
    add "     "
    replace "\n       " "\n"
    swap
  block.end.30878:
  # one line nom scripts with syntax errors. These can be used to test
  # the usefulness of the error messages. But detailed syntax error 
  # checking is probably better done in a separate script such as 
  # /eg/nom.syntax.reference.pss
  testis "eg.bad.lines"
  jumpfalse block.end.31348
    swap
    add "\n"
    add "       # missing semi-colon \n"
    add "       read print;\n"
    add "       # missing close brace\n"
    add "       'x' { print;\n"
    add "       # bad case of command\n"
    add "       read; Print; clear;\n"
    add "       #  \n"
    add "     "
    swap
  block.end.31348:
  testis "test.line"
  jumpfalse block.end.31822
    swap
    add "\n"
    add "       # TESTING SOME RANDOM (one-line) NOM SCRIPT\n"
    add "       doc=$(pep -f nom.toperl.pss -i /eg.lines | \\\n"
    add "         sed '/^ *#/d;/^ *$/d;/^</d;' | shuf -n 1) \n"
    add "       echo \"# input: $doc\"\n"
    add "       pep -f nom.toperl.pss -i \"$doc\" \n"
    add "       echo \"# input: $doc\"\n"
    add "       # ------------------------\n"
    add "       # RUN THIS WITH:\n"
    add "       # pep -f nom.toperl.pss -i /test.line  | bash\n"
    add "       "
    replace "\n     " "\n"
    system
    print
    quit
  block.end.31822:
  # translates a one-line script to perl but only shows the parse
  # method.
  testis "test.line.showparse"
  jumpfalse block.end.32144
    swap
    add "\n"
    add "       # TESTING SOME RANDOM (one-line) NOM SCRIPT\n"
    add "       pep -f nom.toperl.pss -i /test.line | sed -n '/sub parse {/,/# sub parse/p;' \n"
    add "       "
    # print; quit;
    system
    print
    quit
  block.end.32144:
  # tests one one-line invalid input with this script
  testis "test.bad.line"
  jumpfalse block.end.32647
    swap
    add "\n"
    add "       # TESTING SOME RANDOM (one-line) INPUT\n"
    add "       doc=$(pep -f nom.toperl.pss -i /eg.bad.lines | \\\n"
    add "         sed '/^ *#/d;/^ *$/d;' | shuf -n 1) \n"
    add "       echo \"test-line: $doc\"\n"
    add "       pep -f nom.toperl.pss -i \"$doc\" \n"
    add "       # ------------------------\n"
    add "       # RUN THIS WITH:\n"
    add "       # pep -f nom.toperl.pss -i /test.bad.line | sed 's/^</#</' | bash\n"
    add "       "
    replace "\n     " "\n"
    swap
  block.end.32647:
  # tests 
  testis "test"
  jumpfalse block.end.32957
    swap
    add "\n"
    add "       # TESTING INPUT from /eg \n"
    add "       # echo \"<em>input: $doc</em>\"\n"
    add "       pep -f nom.toperl.pss -i /eg\n"
    add "       # ------------------------\n"
    add "       # RUN THIS WITH:\n"
    add "       # pep -f nom.toperl.pss -i /test | bash\n"
    add "       "
    replace "\n     " "\n"
    swap
  block.end.32957:
  # using /eg/nom.to.pss script which does translation but translating
  # a translation script into another language doesn't seem very 
  # practically useful.
  testbegins "to"
  jumpfalse block.end.33805
    clop
    clop
    put
    clear
    add "\n"
    add "      translator=${PEPNOM}/eg/nom.to.pss\n"
    add "      if [ -f $translator ]; then\n"
    add "        echo -e \"[ok] Found translator script: $translator\"\n"
    add "      else\n"
    add "        echo -e \"\n"
    add "         [error] did not find translator: \\${PEPNOM}/eg/nom.to.pss\n"
    add "         (maybe) set the $PEPNOM environment var\n"
    add "         (or)    download the translator from www.nomlang.org/eg/ \n"
    add "         \";\n"
    add "        exit 1;\n"
    add "      fi\n"
    add "      pep -f $translator -i \"translate nom.toperl.pss to "
    get
    add "\" | bash\n"
    add "      # RUN THIS WITH:  \n"
    add "      #   pep -f nom.toperl.pss -i /to"
    get
    add " sed \"s/^</#</\" | bash\n"
    add "      "
    replace "\n    " "\n"
    print
    quit
  block.end.33805:
  testbegins "flaw"
  jumptrue 6
  testbegins "fault"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.34235
    swap
    add "\n"
    add "    NOM TO PERL TRANSLATION SCRIPT FLAWS (Sept 2025): \n"
    add "      \n"
    add "      - I haven't tested this much.\n"
    add "      - The /eg/palindrome.pss script doesn't translate properly. Possibly\n"
    add "        because of variable interpolation in perl print() commands.\n"
    add "      - The /eg/maths.tolatex.pss script does not translate. Probably \n"
    add "        newline and quote translation issues.\n"
    add "\n"
    add "     "
    swap
  block.end.34235:
   
  #     What follows is a very incomplete syntax reference. And I think that 
  #     it would be much better to put this into /eg/nom.syntax.reference.pss
  #     or even into /compile.pss Otherwise I will have to cut and paste this 
  #     into every translation script which seems silly.
  #   
  # a short list of commands and abbreviations 
  testis "commands.shortlist"
  jumptrue 8
  testis "commands"
  jumptrue 6
  testis "syntax"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.35112
    swap
    add "\n"
    add "     # 'D' doesn't actually work in compile.pss !\n"
    add "     nom abbreviations and commands: \n"
    add "\n"
    add "       zero k clip K clop D replace d clear t print p pop P push u unstack U\n"
    add "       stack G put g get x swap m mark M go r read R until w while W whilenot n\n"
    add "       count c zero chars C nochars l lines L nolines v escape unescape z delim\n"
    add "       S state q quit s write X system o nop .rs .restart .rp .reparse (no\n"
    add "       abbreviations) a+ a- ++ --\n"
    add "         "
    swap
  block.end.35112:
  # specific help for the add command. But  
  testis "command.add"
  jumptrue 8
  testis "commands"
  jumptrue 6
  testis "syntax"
  jumptrue 4
  testis "help"
  jumptrue 2 
  jump block.end.35518
    swap
    add "\n"
    add "     add command:\n"
    add "       add text to end of the workspace buffer\n"
    add "       see: nomlang.org/doc/commands/nom.add.html\n"
    add "     eg:\n"
    add "       add ':tag:';     # correct\n"
    add "       add [:space:];   # incorrect, cannot have class parameter \n"
    add "       add;             # incorrect, missing parameter\n"
    add "         "
  block.end.35518:
  #  
  testis "semicolon"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.35876
    swap
    add "\n"
    add "      semicolon:\n"
    add "        All statements (commands) must end with a semi-colon \n"
    add "        except .reparse and .restart (even the last command in\n"
    add "        the block)\n"
    add "      eg:\n"
    add "        clear; .reparse       # correct\n"
    add "        clear add '.';        # incorrect, clear needs ; \n"
    add "        "
    swap
  block.end.35876:
  # 'brackets' is topic, 'punctuation' is a category, 'all' is everthing 
  testis "brackets"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.36274
    swap
    add "\n"
    add "     brackets () \n"
    add "       are used for tests like (eof) (EOF) (==) \n"
    add "       currently (2025) brackets are not used for logical grouping in \n"
    add "       tests.\n"
    add "     examples:\n"
    add "        (==)                  # correct\n"
    add "        (==,'abc' { nop; }    # incorrect: unbalanced "
  block.end.36274:
  testis "negation"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.36770
    swap
    add "\n"
    add "     negation operator ! \n"
    add "       is used for negating class and equals tests and with the \n"
    add "       B and E modifiers. It should precede the test and the \n"
    add "       B and E modifiers.\n"
    add "\n"
    add "     examples:\n"
    add "        !(eof) { add '.'; }   # correct, not at end-of-file\n"
    add "        ![:space:] { clear; } # correct \n"
    add "        'abc'! { clear; }     # incorrect: ! must precede test.\n"
    add "        B!'abc' { clear; }    # incorrect: ! must precede 'B'  "
    swap
  block.end.36770:
  # 
  testis "modifiers"
  jumptrue 6
  testis "tests"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.37117
    swap
    add "\n"
    add "     begins-with 'B' and ends-with 'E' modifiers:\n"
    add "       are used with quoted text tests and cannot be used with \n"
    add "       class tests.\n"
    add "     eg: \n"
    add "       B'abc' { clear; }        # correct \n"
    add "       E\"abc\" { clear; }      # correct \n"
    add "       B[:alpha:] { clear; }  # incorrect  "
    swap
  block.end.37117:
  swap
  testis ""
  jumpfalse block.end.37393
    add "Help topic '/"
    get
    add "' not known\n"
    add "Type: pep -f nom.toperl.pss -i /words \n"
    add "      to see valid help keywords \n"
    add "  or: pep -f nom.toperl.pss -i /help \n"
    add "      to see entire help text. \n"
  block.end.37393:
  add "\n\n"
  print
  quit
block.end.37425:
# end of the error and help system.
# -------------------
#----------------
# 2 parse token errors

#  possible tokens: 
#  literal* BE!<>{}(),.;
#  quoted* class* word* command* test*
#  ortest* andtest* statement* statementset* 
#  
# none of these literal tokens can start a sequence because
# they should have already reduced to a subpattern (token)
pop
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.38009
  clear
  clear
  add "modifiers"
  put
  clear
  add "nom.help*"
  push
  add "  B or E modifier before class test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38009:
# general token sequence errors
# literal token error sequences.
testbegins "}*"
jumptrue 8
testbegins ";*"
jumptrue 6
testbegins ">*"
jumptrue 4
testbegins ")*"
jumptrue 2 
jump block.end.38220
  clear
  add "* misplaced } or ; or > or ) character?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38220:
testbegins "B*"
jumptrue 4
testbegins "E*"
jumptrue 2 
jump block.end.38505
  testends "!*"
  jumpfalse block.end.38501
    clear
    add "negation"
    put
    clear
    add "nom.help*"
    push
    add "* The negation operator (!) must precede the  \n"
    add "  begins-with (B) or ends-with (E) modifiers \n"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.38501:
block.end.38505:
testbegins "B*"
jumpfalse 5
testis "B*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.38712
  clear
  add "* misplaced begin-test modifier 'B' ?"
  add "  eg: B'##' { d; add 'heading*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38712:
testbegins "E*"
jumpfalse 5
testis "E*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.38915
  clear
  add "* misplaced end-test modifier 'E' ?"
  add "  eg: E'.' { d; add 'phrase*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38915:
# empty quote after B or E
testbegins "E*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.39211
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.39178
    clear
    add "modifiers"
    put
    clear
    add "nom.help*"
    push
    add "  Empty quote after 'E' modifier "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.39178:
  clear
  add "E*quoted*"
block.end.39211:
testbegins "B*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.39478
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.39445
    clear
    add "modifiers"
    put
    clear
    add "nom.help*"
    push
    add "  Empty quote after 'B' modifier "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.39445:
  clear
  add "B*quoted*"
block.end.39478:
testbegins "!*"
jumpfalse 17
testis "!*"
jumptrue 15
testends "(*"
jumptrue 13
testends "<*"
jumptrue 11
testends "B*"
jumptrue 9
testends "E*"
jumptrue 7
testends "quoted*"
jumptrue 5
testends "class*"
jumptrue 3
testends "test*"
jumpfalse 2 
jump block.end.39839
  clear
  add "* misplaced negation operator (!) ?"
  add "  e.g. \n"
  add "   !B'$#@' { clear; }   # correct \n"
  add "   !\"xyz\" { clear; }   # correct \n"
  add "   \"abc\"! { clear; }   # incorrect \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.39839:
# comma sequence errors, 2 tokens
# error eg: ,,
testbegins ",*"
jumpfalse 17
testends "(*"
jumptrue 15
testends "<*"
jumptrue 13
testends "!*"
jumptrue 11
testends "B*"
jumptrue 9
testends "E*"
jumptrue 7
testends "quoted*"
jumptrue 5
testends "class*"
jumptrue 3
testends "test*"
jumpfalse 2 
jump block.end.40065
  clear
  add "* misplaced comma ?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.40065:
# error eg: . {
testbegins ".*"
jumpfalse 19
testends "(*"
jumptrue 17
testends "<*"
jumptrue 15
testends "!*"
jumptrue 13
testends "B*"
jumptrue 11
testends "E*"
jumptrue 9
testends "quoted*"
jumptrue 7
testends "class*"
jumptrue 5
testends "test*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.40263
  clear
  add "* misplaced dot?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.40263:
# error eg: {}
testbegins "{*"
jumpfalse 3
testends "}*"
jumptrue 2 
jump block.end.40386
  clear
  add "* empty block {} "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.40386:
# error eg: { ,
testbegins "{*"
jumpfalse 3
testis "{*"
jumpfalse 2 
jump block.end.40594
  testends ">*"
  jumptrue 12
  testends ",*"
  jumptrue 10
  testends ")*"
  jumptrue 8
  testends "{*"
  jumptrue 6
  testends "}*"
  jumptrue 4
  testends ";*"
  jumptrue 2 
  jump block.end.40590
    clear
    add "* misplaced character '"
    ++
    get
    --
    add "' ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.40590:
block.end.40594:
# try to diagnose missing close brace errors at end of script
# eg ortest*{*statement*
# we probably need a line/char number in the tape cell
testeof 
jumpfalse block.end.41050
  testis "{*statement*"
  jumptrue 4
  testis "{*statementset*"
  jumptrue 2 
  jump block.end.41046
    clear
    add "* missing close brace (}) ?\n"
    add "  At "
    get
    add " there is an opening brace ({) which does \n"
    add "  not seem to be matched with a closing brace "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.41046:
block.end.41050:
# missing dot
# error eg: clear; reparse 
testbegins ".*"
jumptrue 5
testends "word*"
jumpfalse 3
testis "word*"
jumpfalse 2 
jump block.end.41324
  push
  push
  --
  get
  ++
  testis "reparse"
  jumptrue 4
  testis "restart"
  jumptrue 2 
  jump block.end.41299
    clear
    add "* missing dot before reparse/restart ? "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.41299:
  clear
  pop
  pop
block.end.41324:
# error eg: ( add
# currently brackets are only used for tests
testbegins "(*"
jumpfalse 5
testis "(*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.41517
  clear
  add "* strange syntax after '(' "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.41517:
testis "<*;*"
jumpfalse block.end.41723
  clear
  add "* '<' used to be an abbreviation for '--' \n"
  add "* but no-longer (mar 2025) since it clashes with <eof> etc "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.41723:
# error eg: < add
# currently angle brackets are only used for tests ( <eof> <==> ) 
testbegins "<*"
jumpfalse 5
testis "<*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.41929
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.41929:
testis ">*;*"
jumpfalse block.end.42137
  clear
  add "* '>' used to be an abbreviation for '++' \n"
  add "  but no-longer (mar 2025) since it clashes with <eof> etc \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42137:
# error eg: begin add
testbegins "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.42353
  clear
  add "* begin is always followed by a brace.\n"
  add "   eg: begin { delim '/'; }\n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42353:
# error eg: clear; begin { clear; }
testends "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testbegins "comment*"
jumpfalse 2 
jump block.end.42543
  clear
  add "* only comments can precede a begin block."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42543:
testis "command*}*"
jumpfalse block.end.42867
  clear
  add "* missing semicolon? "
  add "\n"
  add "     In nom all commands except .reparse and .restart \n"
  add "     must be terminated with a semicolon, even the last \n"
  add "     command in a block {...} \n"
  add "\n"
  add "     see www.nomlang.org/doc/syntax/ for details \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42867:
# error eg: clear {
testbegins "command*"
jumpfalse 9
testis "command*"
jumptrue 7
testends ";*"
jumptrue 5
testends "quoted*"
jumptrue 3
testends "class*"
jumpfalse 2 
jump block.end.43041
  clear
  add "* bad command syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.43041:
# specific analysis of the token sequences permitted above
testis "command*class*"
jumpfalse block.end.43416
  clear
  get
  testis "while"
  jumptrue 3
  testis "whilenot"
  jumpfalse 2 
  jump block.end.43379
    clear
    add "* command '"
    get
    add "' does not take class argument.\n"
    add "  see www.nomlang/doc/commands/nom."
    get
    add ".html "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.43379:
  clear
  add "command*class*"
block.end.43416:
testis "command*quoted*"
jumpfalse block.end.44837
  clear
  get
  testis "add"
  jumptrue 17
  testis "replace"
  jumptrue 15
  testis "mark"
  jumptrue 13
  testis "go"
  jumptrue 11
  testis "until"
  jumptrue 9
  testis "delim"
  jumptrue 7
  testis "escape"
  jumptrue 5
  testis "unescape"
  jumptrue 3
  testis "echar"
  jumpfalse 2 
  jump block.end.43790
    clear
    add "* command '"
    get
    add "' does not take quoted argument.\n\n"
    add "  see www.nomlang/doc/commands/nom."
    get
    add ".html "
    add "  for details."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.43790:
  # for the delimiter and the escape char only allow one 'character'
  # (ie unicode code-point) not a unicode grapheme cluster, which
  # could be several 'characters'. This is because it is unnecessary and
  # I doubt that any language is going to use a grapheme cluster as
  # an escape character.
  testis "delim"
  jumptrue 4
  testis "echar"
  jumptrue 2 
  jump block.end.44322
    clear
    ++
    get
    --
    clip
    clop
    clip
    testis ""
    jumptrue block.end.44316
      clear
      add "* multiple char argument to 'delim' or 'echar'. "
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.44316:
  block.end.44322:
  # check that not empty argument.
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.44799
    clear
    add "* empty quoted text ('' or \"\") is an error here.\n\n"
    add "  - The 2nd argument to 'replace' can be an empty quote\n"
    add "    eg: replace 'abc' ''; # replace 'abc' with nothing \n"
    add "  - Also, empty quotes can be used in tests \n"
    add "    eg: '' { add 'xyz'; } !'' { clear; } \n"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.44799:
  clear
  add "command*quoted*"
block.end.44837:
testis "command*;*"
jumpfalse block.end.45173
  clear
  get
  testis "add"
  jumptrue 16
  testis "replace"
  jumptrue 14
  testis "while"
  jumptrue 12
  testis "whilenot"
  jumptrue 10
  testis "delim"
  jumptrue 8
  testis "escape"
  jumptrue 6
  testis "unescape"
  jumptrue 4
  testis "echar"
  jumptrue 2 
  jump block.end.45140
    clear
    add "* command '"
    get
    add "' requires argument."
    add "- eg: add 'abc'; while [:alnum:]; escape ']'; "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.45140:
  clear
  add "command*;*"
block.end.45173:
# end-of-script 2 token command errors.
testeof 
jumpfalse block.end.45577
  testends "command*"
  jumpfalse block.end.45385
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.45385:
  testis "command*quoted*"
  jumptrue 4
  testis "command*class*"
  jumptrue 2 
  jump block.end.45573
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.45573:
block.end.45577:
# error eg: "xx" }
testbegins "quoted*"
jumpfalse 13
testis "quoted*"
jumptrue 11
testends "{*"
jumptrue 9
testends "quoted*"
jumptrue 7
testends ";*"
jumptrue 5
testends ",*"
jumptrue 3
testends ".*"
jumpfalse 2 
jump block.end.45804
  clear
  add " dubious syntax (eg: missing semicolon ';') after quoted text."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.45804:
# error eg: [:space:] }
testbegins "class*"
jumpfalse 11
testis "class*"
jumptrue 9
testends "{*"
jumptrue 7
testends ";*"
jumptrue 5
testends ",*"
jumptrue 3
testends ".*"
jumpfalse 2 
jump block.end.46057
  clear
  add "semicolon"
  put
  clear
  add "nom.help*"
  push
  clear
  add "* missing semi-colon after class? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46057:
# A word is not a command. reparse and restart have already reduced.
# error eg: eof (
testbegins "word*"
jumpfalse 7
testis "word*"
jumptrue 5
testends ")*"
jumptrue 3
testends ">*"
jumpfalse 2 
jump block.end.46281
  clear
  add "* bad syntax after word."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46281:
# error eg: E"abc";
testbegins "test*"
jumpfalse 9
testis "test*"
jumptrue 7
testends ",*"
jumptrue 5
testends ".*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.46437
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46437:
# error "xx","yy"."zz"
testbegins "ortest*"
jumpfalse 5
testis "ortest*"
jumptrue 3
testends ".*"
jumptrue 2 
jump block.end.46597
  clear
  add "* AND '.' operator in OR test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46597:
# error eg: "aa" "abc";
testis "ortest*quoted*"
jumptrue 4
testis "ortest*test*"
jumptrue 2 
jump block.end.46756
  clear
  add "* missing comma in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46756:
# error eg: "aa",E"abc";
testbegins "ortest*"
jumpfalse 7
testis "ortest*"
jumptrue 5
testends ",*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.46917
  clear
  add "* bad OR test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46917:
# error "xx"."yy","zz"
testbegins "andtest*"
jumpfalse 5
testis "andtest*"
jumptrue 3
testends ",*"
jumptrue 2 
jump block.end.47079
  clear
  add "* OR ',' operator in AND test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47079:
# error eg: "aa".E"abc";
testis "andtest*quoted*"
jumptrue 4
testis "andtest*test*"
jumptrue 2 
jump block.end.47239
  clear
  add "* missing dot in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47239:
# error eg: "aa".E"abc";
testbegins "andtest*"
jumpfalse 7
testis "andtest*"
jumptrue 5
testends ".*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.47403
  clear
  add "* bad AND test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47403:
# end-of-script 2 token test errors.
testeof 
jumpfalse block.end.47653
  testends "test*"
  jumptrue 12
  testbegins "test*"
  jumptrue 10
  testends "ortest*"
  jumptrue 8
  testbegins "ortest*"
  jumptrue 6
  testends "andtest*"
  jumptrue 4
  testbegins "andtest*"
  jumptrue 2 
  jump block.end.47649
    clear
    add "* test with no block {} at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.47649:
block.end.47653:
# error eg: add 'x'; { 
testbegins "statement*"
jumpfalse 3
testis "statement*"
jumpfalse 2 
jump block.end.47841
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.47837
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.47837:
block.end.47841:
# error eg: clear;add 'x'; { 
testbegins "statementset*"
jumpfalse 3
testis "statementset*"
jumpfalse 2 
jump block.end.48041
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.48037
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.48037:
block.end.48041:
# specific command errors
# until, mark, go etc have no-parameter versions
testis "command*;*"
jumpfalse block.end.48386
  clear
  get
  testis "add"
  jumptrue 16
  testis "replace"
  jumptrue 14
  testis "while"
  jumptrue 12
  testis "whilenot"
  jumptrue 10
  testis "delim"
  jumptrue 8
  testis "escape"
  jumptrue 6
  testis "unescape"
  jumptrue 4
  testis "echar"
  jumptrue 2 
  jump block.end.48353
    clear
    add "* command '"
    get
    add "' requires argument"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.48353:
  clear
  add "command*;*"
block.end.48386:
#----------------
# 3 parse token errors, 
pop
# missing semicolon errors?
# error eg: [:space:] { whilenot [:space:] }
testbegins "command*class*"
jumpfalse 5
testis "command*class*"
jumptrue 3
testends ";*"
jumpfalse 2 
jump block.end.48744
  clear
  add "semicolon"
  put
  clear
  add "nom.help*"
  push
  clear
  add "* missing semi-colon after statement? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.48744:
# missing semicolon errors
# error eg: [:space:] { until "</em>" }
testbegins "command*quoted*"
jumpfalse 7
testis "command*quoted*"
jumptrue 5
testends ";*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.48987
  clear
  add "* missing semi-colon after statement? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.48987:
# error eg: "cd" "ef" {
testbegins "quoted*quoted*"
jumpfalse 3
testends ";*"
jumpfalse 2 
jump block.end.49147
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49147:
# error eg: , "cd" "ef"
testends "quoted*quoted*"
jumpfalse 3
testbegins "command*"
jumpfalse 2 
jump block.end.49313
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49313:
testis "command*quoted*quoted*"
jumpfalse block.end.49644
  clear
  get
  testis "replace"
  jumptrue block.end.49599
    clear
    add "* command '"
    get
    add "' does not take 2 quoted arguments.\n"
    add "- The only nom command with 2 quoted arguments is 'replace'."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.49599:
  clear
  add "command*quoted*quoted*"
block.end.49644:
# error eg: clear "x"; already checked above.
# "command*quoted*;*" {}
# error eg: add [:space:] already checked above in 2 tokens
# "command*class*;*" {}
#----------------
# 4 parse token errors
pop
testis "command*quoted*quoted*;*"
jumpfalse block.end.50299
  clear
  get
  testis "replace"
  jumptrue block.end.50056
    clear
    add "* command '"
    get
    add "' does not take 2 arguments."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.50056:
  # check that not 1st argument is empty
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.50252
    clear
    add "* empty quoted text '' is an error here."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.50252:
  clear
  add "command*quoted*quoted*;*"
block.end.50299:
push
push
push
push
# end of errors
# ----------------
# ----------------
# 2 grammar parse tokens 
pop
pop
# permit comments anywhere in script
testbegins "comment*"
jumpfalse 3
testis "comment*"
jumpfalse 2 
jump block.end.50631
  # A translator would try to conserve the comment.
  replace "comment*" ""
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.50631:
testends "comment*"
jumpfalse 3
testis "comment*"
jumpfalse 2 
jump block.end.50706
  replace "comment*" ""
  push
  jump parse
block.end.50706:
#------------ 
# The .restart command jumps to the first instruction after the
# begin block (if there is a begin block), or the first instruction
# of the script.
testis ".*word*"
jumpfalse block.end.51824
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.51025
    clear
    add "next SCRIPT;"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.51025:
  testis "reparse"
  jumpfalse block.end.51721
    clear
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    count
    # if the count is not 0/1 then something is wrong. Probably
    # > 1 parse> label which should have already been trapped.
    testis "0"
    jumptrue 3
    testis "1"
    jumpfalse 2 
    jump block.end.51489
      clear
      add "* multiple parse label error?"
      put
      clear
      add "nom.untrapped.error*"
      push
      jump parse
    block.end.51489:
    testis "0"
    jumpfalse block.end.51527
      clear
      add "last LEX;"
    block.end.51527:
    testis "1"
    jumpfalse block.end.51567
      clear
      add "next PARSE;"
    block.end.51567:
    # for languages that have goto we can use the following
    # add "goto parse;";
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.51721:
  clear
  add "* invalid statement ."
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.51824:
testis "word*>*"
jumpfalse block.end.52236
  clear
  get
  testis "parse"
  jumpfalse block.end.52206
    clear
    count
    testis "0"
    jumptrue block.end.52051
      clear
      add "script error:\n"
      add "  extra parse> label at line "
      ll
      add ".\n"
      print
      quit
    block.end.52051:
    clear
    add "--> parse>"
    put
    clear
    add "parselabel*"
    push
    # use accumulator to indicate after parse> label
    a+
    jump parse
  block.end.52206:
  clear
  add "word*>*"
block.end.52236:
#-----------------------------------------
# format: E"text" {...} or E'text' {...}
# the ends-with test. The \Q...\E construct quotes all 'meta'
# pattern characters so they will be matched literally. I wonder 
# if this is slower than the substr approach
testis "E*quoted*"
jumpfalse block.end.52797
  # remove quotes around text and unescape escaped chars 
  clear
  ++
  add "(length("
  get
  add ") <= length($self->{work})) && "
  add "(substr($self->{work}, -length("
  get
  add ")) eq "
  get
  add ")"
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.52797:

#    This is perl code to do an 'ends with' test using substr which
#    may be faster than a regex.
#    # If the suffix is longer than the string, it can't be a suffix.
#    return 0 if length($suffix) > $length($string);
#    return substr($string, -$length($suffix)) eq $suffix;
#  
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#  The begins-with test. I use a substring equals approach in perl
#  for speed and to avoid regular expression meta-quoted issues.
#  I dont think it is necessary to bracket this expression?
testis "B*quoted*"
jumpfalse block.end.53523
  clear
  add "substr($self->{work}, 0, length("
  ++
  get
  add ")) eq "
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.53523:
#---------------------------------
# Compiling comments so as to transfer them to the output code
# but comments in some places are an error.
testis "comment*statement*"
jumptrue 6
testis "statement*comment*"
jumptrue 4
testis "statementset*comment*"
jumptrue 2 
jump block.end.53833
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "command*"
  push
  jump parse
block.end.53833:
testis "comment*comment*"
jumpfalse block.end.53946
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "comment*"
  push
  jump parse
block.end.53946:
# -----------------------
# negated tokens.
#  This format is used to indicate a negative test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
testis "!*test*"
jumpfalse block.end.54288
  clear
  add "!("
  ++
  get
  --
  add ")"
  put
  clear
  add "test*"
  push
  jump parse
block.end.54288:
# transform quotes and classses to tests, this greatly reduces the number
# of rules required for other reductions
testis ",*quoted*"
jumptrue 6
testis ".*quoted*"
jumptrue 4
testis "!*quoted*"
jumptrue 2 
jump block.end.54544
  push
  clear
  add "$self->{work} eq "
  get
  put
  clear
  add "test*"
  push
  jump parse
block.end.54544:
# transform quotes to tests
testis "quoted*,*"
jumptrue 6
testis "quoted*.*"
jumptrue 4
testis "quoted*{*"
jumptrue 2 
jump block.end.54739
  replace "quoted*" "test*"
  push
  push
  --
  --
  add "$self->{work} eq "
  get
  put
  ++
  ++
  clear
  jump parse
block.end.54739:
# transform classes to tests, all characters in the workspace need
# to match the (unicode) class, category or unicode script name for the 
# class test to return true. Empty workspace never matches.
testis ",*class*"
jumptrue 6
testis ".*class*"
jumptrue 4
testis "!*class*"
jumptrue 2 
jump block.end.55111
  push
  clear
  add "$self->matchClass($self->{work}, \""
  get
  add "\")"
  put
  clear
  add "test*"
  push
  jump parse
block.end.55111:
# transform classes to tests
testis "class*,*"
jumptrue 6
testis "class*.*"
jumptrue 4
testis "class*{*"
jumptrue 2 
jump block.end.55340
  replace "class*" "test*"
  push
  push
  --
  --
  add "$self->matchClass($self->{work}, \""
  get
  add "\")"
  put
  ++
  ++
  clear
  jump parse
block.end.55340:
#--------------------------------------------
# ebnf: command := command ';' ;
# formats: "pop; push; clear; print; " etc
testis "command*;*"
jumpfalse block.end.60030
  clear
  get
  # error trap here .
  testis "go"
  jumptrue 67
  testis "mark"
  jumptrue 65
  testis "until"
  jumptrue 63
  testis "clip"
  jumptrue 61
  testis "clop"
  jumptrue 59
  testis "clear"
  jumptrue 57
  testis "upper"
  jumptrue 55
  testis "lower"
  jumptrue 53
  testis "cap"
  jumptrue 51
  testis "print"
  jumptrue 49
  testis "pop"
  jumptrue 47
  testis "push"
  jumptrue 45
  testis "unstack"
  jumptrue 43
  testis "stack"
  jumptrue 41
  testis "webstate"
  jumptrue 39
  testis "state"
  jumptrue 37
  testis "put"
  jumptrue 35
  testis "get"
  jumptrue 33
  testis "swap"
  jumptrue 31
  testis "++"
  jumptrue 29
  testis "--"
  jumptrue 27
  testis "read"
  jumptrue 25
  testis "count"
  jumptrue 23
  testis "a+"
  jumptrue 21
  testis "a-"
  jumptrue 19
  testis "zero"
  jumptrue 17
  testis "chars"
  jumptrue 15
  testis "lines"
  jumptrue 13
  testis "nochars"
  jumptrue 11
  testis "nolines"
  jumptrue 9
  testis "quit"
  jumptrue 7
  testis "write"
  jumptrue 5
  testis "system"
  jumptrue 3
  testis "nop"
  jumpfalse 2 
  jump block.end.55961
    clear
    add "  incorrect command syntax?"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.55961:
  # go; not implemented in pars/compile.pss yet (feb 2025)
  testis "go"
  jumpfalse block.end.56133
    clear
    add "$self->goToMark($self->{tape}[$self->{cell}]);  # go (tape) "
  block.end.56133:
  testis "mark"
  jumpfalse block.end.56276
    clear
    add "$mark = $self->{tape}[$self->{cell}];\n"
    add "$self->addMark($mark);  # mark (tape) "
  block.end.56276:
  # the new until; command with no argument
  testis "until"
  jumpfalse block.end.56485
    clear
    add "$text = $self->{tape}[$self->{cell}];\n"
    add "$self->readUntil($text); "
    add "# until (tape)"
  block.end.56485:
  testis "clip"
  jumpfalse block.end.56619
    # use chop for code points not grapheme clusters
    clear
    add "$self->{work} =~ s/\\X$//; # clip"
  block.end.56619:
  testis "clop"
  jumpfalse block.end.56798
    # use Unicode:GCString; is one option for perl grapheme clusters
    # but \\X should work.
    clear
    add "$self->{work} =~ s/^\\X//; # clop"
  block.end.56798:
  testis "clear"
  jumpfalse block.end.56872
    clear
    add "$self->{work} = '';  # clear "
  block.end.56872:
  testis "upper"
  jumpfalse block.end.56989
    # grapheme clusters?
    clear
    add "$self->{work} = uc($self->{work});  # upper"
  block.end.56989:
  testis "lower"
  jumpfalse block.end.57077
    clear
    add "$self->{work} = lc($self->{work});  # lower"
  block.end.57077:
  testis "cap"
  jumpfalse block.end.57344
    clear
    # capitalize every word not just the first.
    # other translators and pep just capitalise the first letter
    # but thats silly. This command "cap" is not really required.
    add "$self->capitalise(); # cap "
  block.end.57344:
  testis "print"
  jumpfalse block.end.57463
    clear
    # write to stdout/file/string
    add "$self->writeText(); # print  "
  block.end.57463:
  testis "pop"
  jumpfalse block.end.57511
    clear
    add "$self->popToken();"
  block.end.57511:
  testis "push"
  jumpfalse block.end.57561
    clear
    add "$self->pushToken();"
  block.end.57561:
  testis "unstack"
  jumpfalse block.end.57643
    clear
    add "while ($self->popToken()) { next; }   # unstack "
  block.end.57643:
  testis "stack"
  jumpfalse block.end.57722
    clear
    add "while ($self->pushToken()) { next; }   # stack "
  block.end.57722:
  testis "state"
  jumpfalse block.end.57786
    clear
    add "$self->printState();    # state "
  block.end.57786:
  testis "webstate"
  jumpfalse block.end.57860
    clear
    add "$self->printHtmlState();    # webstate "
  block.end.57860:
  testis "put"
  jumpfalse block.end.57969
    clear
    add "${$self->{tape}}[$self->{cell}] = $self->{work};   # put "
  block.end.57969:
  testis "get"
  jumpfalse block.end.58146
    clear
    add "$self->{work} .= $self->{tape}[$self->{cell}];  # get"
    # add "$self->{work} .= ${$self->{tape}}[$self->{cell}];  # get";
  block.end.58146:
  testis "swap"
  jumpfalse block.end.58315
    clear
    add "($self->{tape}[$self->{cell}], $self->{work}) = "
    add "($self->{work}, $self->{tape}[$self->{cell}]);  # swap"
  block.end.58315:
  # need a method because we may need to increase the tape size.
  testis "++"
  jumpfalse block.end.58439
    clear
    add "$self->increment();   # ++ "
  block.end.58439:
  testis "--"
  jumpfalse block.end.58533
    clear
    add "if ($self->{cell} > 0) { $self->{cell} -= 1; } # --"
  block.end.58533:
  testis "read"
  jumpfalse block.end.58816
    clear
    # it is better to break out of the nom script loop than exit() or 
    # return because we may need to close open files or flush written
    # file content.
    add "if ($self->{eof}) { last SCRIPT; } $self->readChar(); # read "
  block.end.58816:
  testis "count"
  jumpfalse block.end.58917
    clear
    add "$self->{work} .= $self->{accumulator}; # count "
  block.end.58917:
  testis "a+"
  jumpfalse block.end.58978
    clear
    add "$self->{accumulator} += 1; # a+ "
  block.end.58978:
  testis "a-"
  jumpfalse block.end.59039
    clear
    add "$self->{accumulator} -= 1; # a- "
  block.end.59039:
  testis "zero"
  jumpfalse block.end.59103
    clear
    add "$self->{accumulator} = 0; # zero "
  block.end.59103:
  testis "chars"
  jumpfalse block.end.59194
    clear
    add "$self->{work} .= $self->{charsRead}; # chars "
  block.end.59194:
  testis "lines"
  jumpfalse block.end.59285
    clear
    add "$self->{work} .= $self->{linesRead}; # lines "
  block.end.59285:
  testis "nochars"
  jumpfalse block.end.59353
    clear
    add "$self->{charsRead} = 0; # nochars "
  block.end.59353:
  testis "nolines"
  jumpfalse block.end.59421
    clear
    add "$self->{linesRead} = 0; # nolines "
  block.end.59421:
  # use a labelled loop to quit script.
  # better to break than return because can close open files etc.
  testis "quit"
  jumpfalse block.end.59584
    clear
    add "last SCRIPT; # quit "
  block.end.59584:
  testis "write"
  jumpfalse block.end.59721
    clear
    add "open my $fh, '>:utf8', 'sav.pp';\n"
    add "print $fh $self->{work}; close $fh; # write"
  block.end.59721:
  testis "system"
  jumpfalse block.end.59866
    clear
    add "# system\n"
    add "$result = `$self->{work}`;\n"
    add "$self->{work} = $result;"
  block.end.59866:
  # just eliminate since it does nothing.
  testis "nop"
  jumpfalse block.end.59969
    clear
    add "# removed nop: does nothing "
  block.end.59969:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.60030:
testis "statementset*statement*"
jumptrue 4
testis "statement*statement*"
jumptrue 2 
jump block.end.60179
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "statementset*"
  push
  jump parse
block.end.60179:
# ----------------
# 3 grammar parse tokens 
pop
testis "(*word*)*"
jumptrue 4
testis "<*word*>*"
jumptrue 2 
jump block.end.60606
  clear
  ++
  get
  --
  testis "eof"
  jumptrue 3
  testis "=="
  jumpfalse 2 
  jump block.end.60421
    clear
    add "* invalid test <> or () ."
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.60421:
  testis "eof"
  jumpfalse block.end.60473
    clear
    add "$self->{eof}"
  block.end.60473:
  testis "=="
  jumpfalse block.end.60557
    clear
    add "$self->{tape}[$self->{cell}] eq $self->{work}"
  block.end.60557:
  put
  clear
  add "test*"
  push
  jump parse
block.end.60606:
#--------------------------------------------
# quoted text is already double quoted eg "abc" 
# eg: add "text";
testis "command*quoted*;*"
jumpfalse block.end.62853
  clear
  get
  # error trap here 
  testis "mark"
  jumptrue 15
  testis "go"
  jumptrue 13
  testis "delim"
  jumptrue 11
  testis "add"
  jumptrue 9
  testis "until"
  jumptrue 7
  testis "escape"
  jumptrue 5
  testis "unescape"
  jumptrue 3
  testis "echar"
  jumpfalse 2 
  jump block.end.61077
    clear
    add "  superfluous argument or other error?\n"
    add "  (error should have been trapped in error block: check)"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.61077:
  testis "mark"
  jumpfalse block.end.61164
    clear
    add "$self->addMark("
    ++
    get
    --
    add "); # mark "
  block.end.61164:
  testis "go"
  jumpfalse block.end.61247
    clear
    add "$self->goToMark("
    ++
    get
    --
    add "); # go "
  block.end.61247:
  testis "delim"
  jumpfalse block.end.61627
    # perl has a char type?, but it is for 'code points' not 
    # grapheme clusters (diacritics etc). So technically the 'delim'
    # char could be a string of several chars but in practice this 
    # is not necessary.
    # have already verified one char in error block 
    clear
    add "$self->{delimiter} = "
    ++
    get
    --
    add "; # delim "
  block.end.61627:
  testis "add"
  jumpfalse block.end.62102
    clear
    add "$self->{work} .= "
    ++
    get
    --
    # handle multiline text
    # it is possible to just use multiline strings in some languages
    # but they will be indented by the translator, so they will have 
    # handle multiline text check this! \\n or \n
    # more indentation than the script writer intended...
    # this is more readable than just adding 
    replace "\n" "\";\n$self->{work} .= \"\\n"
    add "; # add "
  block.end.62102:
  # read until workspace ends with text
  testis "until"
  jumpfalse block.end.62296
    clear
    add "$self->readUntil("
    ++
    get
    --
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
  block.end.62296:
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.62607
    # only use the first char or grapheme cluster of escape argument?
    # cant use single quotes because they are not interpolated
    # an chars like $ and @ are escaped in perl
    clear
    add "$self->"
    get
    add "Char"
    add "("
    ++
    get
    --
    add ");"
  block.end.62607:
  # can only be a unicode codepoint not grapheme cluster because 
  # I say so.
  testis "echar"
  jumpfalse block.end.62797
    # 
    clear
    add "$self->{escape} = "
    ++
    get
    --
    add "; # echar "
  block.end.62797:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.62853:
# eg: while [:alpha:]; or whilenot [a-z];
testis "command*class*;*"
jumpfalse block.end.63611
  clear
  get
  # 
  testis "while"
  jumpfalse block.end.63209
    clear
    add "# while \n"
    add "while ($self->matchClass($self->{peep}, \""
    ++
    get
    --
    add "\")) {\n"
    add "  if ($self->{eof}) { last; } $self->readChar();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.63209:
  testis "whilenot"
  jumpfalse block.end.63483
    clear
    add "# whilenot   \n"
    add "while (!$self->matchClass($self->{peep}, \""
    ++
    get
    --
    add "\")) {\n"
    add "  if ($self->{eof}) { last; } $self->readChar();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.63483:
  clear
  add "*** unchecked error in rule: statement = command class ;"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.63611:
# brackets around tests will be ignored.
testis "(*test*)*"
jumpfalse block.end.63743
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.63743:
# brackets will allow mixing AND and OR logic 
testis "(*ortest*)*"
jumptrue 4
testis "(*andtest*)*"
jumptrue 2 
jump block.end.63898
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.63898:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "test*,*test*"
jumptrue 4
testis "ortest*,*test*"
jumptrue 2 
jump block.end.64370
  # OR logic concatenation 
  # put brackets around tests even though operator 
  # precedence should take care of it
  testis "test*,*test*"
  jumpfalse block.end.64234
    clear
    add "("
    get
    add ")"
  block.end.64234:
  testis "ortest*,*test*"
  jumpfalse block.end.64271
    clear
    get
  block.end.64271:
  add " || ("
  ++
  ++
  get
  --
  --
  add ")"
  put
  clear
  add "ortest*"
  push
  jump parse
block.end.64370:
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# negated tests can be chained with non negated tests.
# eg: B'http'.!E'.txt' { ... }
testis "test*.*test*"
jumptrue 4
testis "andtest*.*test*"
jumptrue 2 
jump block.end.64880
  # AND logic concatenation 
  # add brackets 
  testis "test*.*test*"
  jumpfalse block.end.64742
    clear
    add "("
    get
    add ")"
  block.end.64742:
  testis "andtest*.*test*"
  jumpfalse block.end.64780
    clear
    get
  block.end.64780:
  add " && ("
  ++
  ++
  get
  --
  --
  add ")"
  put
  clear
  add "andtest*"
  push
  jump parse
block.end.64880:
# dont need to reparse 
testis "{*statement*}*"
jumpfalse block.end.64958
  replace "ment*" "mentset*"
block.end.64958:
# ----------------
# 4 grammar parse tokens 
pop
# see below
# "command*quoted*quoted*;*" { clear; add "statement*"; push; .reparse }
# eg:  replace "and" "AND" ; 
testis "command*quoted*quoted*;*"
jumpfalse block.end.65627
  clear
  get
  testis "replace"
  jumpfalse block.end.65500
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    # multiline replace? no. 
    clear
    add "$self->replace("
    ++
    get
    add ", "
    ++
    get
    add ");  # replace "
    --
    --
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.65500:
  # error trap
  clear
  add "  incorrect command syntax?"
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.65627:
# reducing blocks
testis "test*{*statementset*}*"
jumptrue 6
testis "ortest*{*statementset*}*"
jumptrue 4
testis "andtest*{*statementset*}*"
jumptrue 2 
jump block.end.65991
  clear
  # indent the translated code for readability
  ++
  ++
  add "\n"
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "if ("
  get
  add ") {"
  ++
  ++
  get
  add "\n}"
  --
  --
  put
  clear
  add "statement*"
  push
  jump parse
block.end.65991:
testis "begin*{*statementset*}*"
jumpfalse block.end.66228
  clear
  ++
  ++
  get
  replace "next SCRIPT;" "goto SCRIPT;"
  replace "last LEX;" "$jumptoparse = true; goto SCRIPT;"
  --
  --
  put
  clear
  add "beginblock*"
  push
  jump parse
block.end.66228:
# end of input stream errors
testeof 
jumpfalse block.end.66426
  testis "test*"
  jumptrue 8
  testis "ortest*"
  jumptrue 6
  testis "andtest*"
  jumptrue 4
  testis "begin*"
  jumptrue 2 
  jump block.end.66422
    clear
    add "* Incomplete script."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.66422:
block.end.66426:
# cannot be reduced to one push;
push
push
push
push
pop
pop
pop
testeof 
jumpfalse block.end.67705
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  # perl has labelled loops?
  testis "statementset*parselabel*statementset*"
  jumpfalse block.end.67701
    clear
    # indent both code blocks
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    ++
    ++
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    --
    --
    # add a block so that .reparse works before the parse> label.
    add "SCRIPT:\n"
    add "while (true) {\n"
    add "  LEX: { \n"
    # This is all so that .reparse will work in the beginblock
    # adapt from lua.
    add "    if ($jumptoparse == true) {\n"
    add "      $jumptoparse = false;\n"
    add "      last LEX;\n"
    add "    }\n"
    get
    add "\n  } # lex block \n"
    add "  # parse> label\n"
    add "  PARSE: \n"
    add "    while (true) { \n"
    ++
    ++
    get
    --
    --
    add "\n     last PARSE;  # run-once parse loop "
    add "\n   } # parse block "
    add "\n} # nom script loop "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.67701:
block.end.67705:
push
push
push
# this cannot be reduced to 'push;'
pop
pop
testeof 
jumpfalse block.end.69153
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*parselabel*"
  jumpfalse block.end.68568
    clear
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    add "SCRIPT:\n"
    add "while (true) {\n"
    add "  LEX: { \n"
    add "    if ($jumptoparse == true) {\n"
    add "      $jumptoparse = false;\n"
    add "      last LEX;\n"
    add "    }\n"
    get
    add "  } # lex block \n"
    # parse label with no statement after.
    add "  # parse> label\n"
    add "  PARSE: "
    add "\n} # nom script loop "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.68568:
  testis "parselabel*statementset*"
  jumpfalse block.end.69026
    clear
    add "    "
    ++
    get
    --
    replace "\n" "\n    "
    put
    clear
    add "SCRIPT:\n"
    add "while (true) {\n"
    add "  # parse> label\n"
    add "  PARSE: \n"
    add "    while (true) { \n"
    get
    add "\n     last PARSE;  # run-once parse loop "
    add "\n   } # parse block "
    add "\n} # nom script loop "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.69026:
  testis "beginblock*script*"
  jumpfalse block.end.69149
    clear
    get
    add "\n"
    ++
    get
    --
    put
    clear
    add "script*"
    push
    jump parse
  block.end.69149:
block.end.69153:
# cannot reduce to push
push
push
pop
testeof 
jumpfalse block.end.69755
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*"
  jumpfalse block.end.69655
    clear
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    add "SCRIPT:\n"
    add "while (true) {\n"
    get
    add "\n} # nom script loop "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.69655:
  testis "beginblock*"
  jumptrue 6
  testis "comment*"
  jumptrue 4
  testis "parselabel*"
  jumptrue 2 
  jump block.end.69751
    clear
    add "script*"
    push
    jump parse
  block.end.69751:
block.end.69755:
push
push
push
push
testeof 
jumpfalse block.end.101417
  pop
  pop
  testis ""
  jumpfalse block.end.69872
    add "# empty nom script\n"
    print
    quit
  block.end.69872:
  testis "script*"
  jumptrue block.end.70162
    push
    push
    unstack
    put
    clear
    add "* script syntax problem: the error was not caught by the \n"
    add "  syntax checker, and should have been.\n"
    add "  The parse stack was: "
    get
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.70162:
  clear
  add "#!/usr/bin/perl \n"
  print
  clear
  # indent the compiled code
  add "\n"
  get
  replace "\n" "\n      "
  put
  clear
  # create the virtual machine object code and save it
  # on the tape.
  add "\n"
  add "\n"
  add " use strict;\n"
  add " use warnings;\n"
  add " use utf8;\n"
  add " # for unicode character properties.\n"
  add " # use Unicode::UCD qw(charprop);\n"
  add " # use IO::File;\n"
  add " #use IO::BufReader;\n"
  add " #use IO::BufWriter;\n"
  add " use Getopt::Long;\n"
  add " use List::Util;  # for all function\n"
  add " use Carp; # For croak and confess\n"
  add "\n"
  add " package Machine; \n"
  add "   use constant { true => 1, false => 0 };\n"
  add "\n"
  add "   sub new {\n"
  add "     # my ($class) = @_;\n"
  add "     my $class = shift;  # \n"
  add "     binmode STDOUT, \":encoding(UTF-8)\";\n"
  add "\n"
  add "     my $self = {\n"
  add "       accumulator   => 0,       # counter for anything\n"
  add "       peep          => \"\",      # next char in input stream\n"
  add "       charsRead     => 0,       # No. of chars read so far init:0\n"
  add "       linesRead     => 1,       # No. of lines read so far init:1\n"
  add "       inputBuffer   => [],      # reversed array of input chars/graphemes\n"
  add "       outputBuffer  => \"\",      # where string output will go\n"
  add "       inputType    => \"unset\",  # reading from stdin/string/file etc\n"
  add "       sinkType      => \"stdout\",# \n"
  add "       work          => \"\",      # text accumulator\n"
  add "       stack         => [],      # parse token stack\n"
  add "       tapeLength    => 100,     # tape initial length\n"
  add "       tape          => [ map { \"\" } 1..100 ], # array of token attributes\n"
  add "       marks         => [ map { \"\" } 1..100 ], # tape marks\n"
  add "       cell          => 0,       # pointer to current cell\n"
  add "       input         => *STDIN,  # text input stream\n"
  add "       output        => *STDOUT, #\n"
  add "       eof           => false,    # end of stream reached? (boolean)\n"
  add "       escape        => \"\\\\\",   # char used to \"escape\" others: default \"\\\"\n"
  add "       delimiter     => \"*\",      # push/pop delimiter (default is \"*\")\n"
  add "     };\n"
  add "     bless $self, $class;\n"
  add "     return $self;\n"
  add "   }\n"
  add "   # reset the machine registers to nothing. This is particularly used\n"
  add "   # by the interpret() method once the script has been \"compiled\" and \n"
  add "   # loaded into the current machine (with eval()) and then needs to be \n"
  add "   # run with a fresh pep machine.\n"
  add "   sub resetMachine {\n"
  add "     my $self = shift;   # a reference to the pep machine\n"
  add "     $self->{accumulator} = 0;\n"
  add "     $self->{peep} = \"\";\n"
  add "     $self->{charsRead} = 0;\n"
  add "     $self->{linesRead} = 1;\n"
  add "     $self->{inputBuffer} = [];\n"
  add "     $self->{outputBuffer} = \"\";\n"
  add "     $self->{inputType} = \"unset\";\n"
  add "     $self->{sinkType} = \"stdout\";\n"
  add "     $self->{work} = \"\";\n"
  add "     $self->{stack} = [];\n"
  add "     $self->{tapeLength} = 100;\n"
  add "     $self->{tape} = [ map { \"\" } 1..100 ];\n"
  add "     $self->{marks} = [ map { \"\" } 1..100 ];\n"
  add "     $self->{cell} = 0;\n"
  add "     $self->{input} = *STDIN;\n"
  add "     $self->{output} = *STDOUT;\n"
  add "     $self->{eof} = false;\n"
  add "     $self->{escape} = \"\\\\\";\n"
  add "     $self->{delimiter} = \"*\";\n"
  add "   }\n"
  add "\n"
  add "   sub fillInputStringBuffer {\n"
  add "     my ($self, $text) = @_;\n"
  add "     my $revtext = reverse $text;\n"
  add "     # push onto the array\n"
  add "     push @{$self->{inputBuffer}}, split //, $revtext;\n"
  add "   }\n"
  add "\n"
  add "   sub fillInputBuffer {\n"
  add "     my $self = shift;\n"
  add "     my $text = shift;\n"
  add "     # grapheme clusters regex is \\X in perl\n"
  add "     # the grapheme cluster splitter is making an extra empty char \n"
  add "     # in the array\n"
  add "\n"
  add "     # not working?\n"
  add "     # my @charArray = reverse split(/(\\X)/, $text);\n"
  add "\n"
  add "     #my @graphemes = $text =~ m/\\X/g;\n"
  add "     #my @charArray = reverse(@graphemes);\n"
  add "     my @charArray = reverse split(//, $text);\n"
  add "     push (@{$self->{inputBuffer}}, @charArray);\n"
  add "     # display the input buffer array\n"
  add "     # print \"[\",join(\", \", @{$self->{inputBuffer}}),\"]\";\n"
  add "   }\n"
  add "\n"
  add "   # read one character from the input stream and\n"
  add "   #   update the machine. This reads though an inputBuffer/inputChars\n"
  add "   #   so as to handle unicode grapheme clusters (which can be more\n"
  add "   #   than one \"character\").\n"
  add "   # \n"
  add "   sub readChar {\n"
  add "     my $self = shift;\n"
  add "\n"
  add "     #  this exit code should never be called in a translated script\n"
  add "     #  because the Machine:parse() method will return just before\n"
  add "     #  a read() on self.eof But I should keep this here in case\n"
  add "     #  the machine methods are used outside of a parse() method?\n"
  add "     if ($self->{eof}) {\n"
  add "       # need to return from parse method (i.e break loop) when reading on eof.\n"
  add "       exit 0; # print(\"eof exit\")\n"
  add "     }\n"
  add "\n"
  add "     my $result = 0; my $line = \"\";\n"
  add "     $self->{charsRead} += 1;\n"
  add "     # increment lines\n"
  add "     if ($self->{peep} eq \"\\n\") { $self->{linesRead} += 1; }\n"
  add "     $self->{work} .= $self->{peep};\n"
  add "\n"
  add "     # fix: it would be better not to have an if else here\n"
  add "     # stdin.all/string/file all read the whole input stream\n"
  add "     #    at once into a buffer.\n"
  add "     my $inputType = $self->{inputType};\n"
  add "     if ($inputType eq \"stdin\" || $inputType eq \"string\" || \n"
  add "         $inputType eq \"file\") {\n"
  add "       if (!@{$self->{inputBuffer}}) {\n"
  add "         $self->{eof} = true;\n"
  add "         $self->{peep} = \"\";\n"
  add "       } else {\n"
  add "         $self->{peep} = \"\";\n"
  add "         # the inputBuffer is a reversed array. pop() returns the last element\n"
  add "         my $char = pop @{$self->{inputBuffer}};\n"
  add "         $self->{peep} .= $char if defined $char;\n"
  add "       }\n"
  add "       return;\n"
  add "     } elsif ($inputType eq \"stdinstream\") {\n"
  add "       # read from stdin one line at a time. \n"
  add "       # \n"
  add "     } elsif ($inputType eq \"filestream\") {\n"
  add "       # if (scalar(@{$self->{inputBuffer}}) == 0) {\n"
  add "       if (!@{$self->{inputBuffer}}) {\n"
  add "         my $bytes = $self->{input}->getline(\\$line);\n"
  add "         if ($bytes > 0) {\n"
  add "           $self->fillInputBuffer($line);\n"
  add "         } else {\n"
  add "           $self->{eof} = true;\n"
  add "           $self->{peep} = \"\";\n"
  add "         }\n"
  add "       }\n"
  add "       if (scalar(@{$self->{inputBuffer}}) > 0) {\n"
  add "         $self->{peep} = \"\";\n"
  add "         my $char = pop @{$self->{inputBuffer}};\n"
  add "         $self->{peep} .= $char if defined $char;\n"
  add "       }\n"
  add "       return;\n"
  add "     } else {\n"
  add "       print STDERR \"Machine.inputType error \", $inputType, \" while trying to read input\\n\";\n"
  add "       exit 1;\n"
  add "     }\n"
  add "   } # read\n"
  add "\n"
  add "   # function Machine:write(output)\n"
  add "   sub writeText {\n"
  add "     my $self = shift;\n"
  add "     my $outputType = $self->{sinkType};\n"
  add "     if ($outputType eq \"stdout\") {\n"
  add "       print $self->{work};\n"
  add "     } elsif ($outputType eq \"file\") {\n"
  add "       print {$self->{output}} $self->{work} or die \"Error writing to file: $!\";\n"
  add "     } elsif ($outputType eq \"string\") {\n"
  add "       $self->{outputBuffer} .= $self->{work};\n"
  add "     } else {\n"
  add "       print STDERR \"Machine.sinkType error for type \", $outputType, \"\\n\";\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   # increment tape pointer by one\n"
  add "   sub increment {\n"
  add "     my ($self) = @_;\n"
  add "     $self->{cell}++;\n"
  add "     if ($self->{cell} >= $self->{tapeLength}) {\n"
  add "       for (my $ii = 1; $ii <= 50; $ii++) {\n"
  add "         push @{$self->{tape}}, \"\";\n"
  add "         push @{$self->{marks}}, \"\";\n"
  add "       }\n"
  add "       $self->{tapeLength} += 50;\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   # Machine.decrement() is usually compiled inline\n"
  add "\n"
  add "   # remove escape char, the char should be a string because it could be\n"
  add "   # a unicode grapheme cluster (diacritics etc) \n"
  add "   sub unescapeChar {\n"
  add "     my ($self, $c) = @_;\n"
  add "     # dont unescape chars that are not escaped!\n"
  add "     my $countEscapes = 0;\n"
  add "     my $s = \"\";\n"
  add "     # let nextChar = ;\n"
  add "     return if length($self->{work}) == 0;\n"
  add "\n"
  add "     for my $nextChar (split //, $self->{work}) {\n"
  add "       if (($nextChar eq $c) && ($c ne $self->{escape}) && \n"
  add "           ($countEscapes % 2 == 1)) {\n"
  add "         # assuming that the escape char is only one char?\n"
  add "         # remove last escape char\n"
  add "         substr($s, -1) = \"\";\n"
  add "       }\n"
  add "       if ($nextChar eq $self->{escape}) {\n"
  add "         $countEscapes++;\n"
  add "       } else {\n"
  add "         if (($c eq $self->{escape}) && ($countEscapes > 0) && \n"
  add "             ($countEscapes % 2 == 0)) {\n"
  add "           substr($s, -1) = \"\";\n"
  add "         } \n"
  add "         $countEscapes = 0;\n"
  add "       }\n"
  add "       $s .= $nextChar;\n"
  add "     }\n"
  add "     $self->{work} = $s;\n"
  add "   }\n"
  add "\n"
  add "   #  add escape character, dont escape chars that are already escaped!\n"
  add "   #  It is important to get this code right especially for 2nd \n"
  add "   #  generation tests and also because some languages will crash or \n"
  add "   #  refuse to compile if there is an \"unrecognised escape sequence\"\n"
  add "   #    modify this for grapheme clusters.\n"
  add "   #   \n"
  add "   # This can be tested with something like the following\n"
  add "   # >> pep.pls \"whilenot [:space:];escape\'x\';t;d;(eof){quit;}\' \'ab\\xc\'\n"
  add "   # >> pep.pls \'until \":\";escape\"\\\";t;d;(eof){quit;}\' \'ab\\c\'\n"
  add "   # If there are an even number of escape chars (in this case, backslashes)\n"
  add "   # then the target character should not be escaped, *unless* the \n"
  add "   # target character IS the escape character. Confusing no? But important.\n"
  add "   # Notice that I have to use a while/whilenot/until read to test this\n"
  add "   # properly...\n"
  add "   # \n"
  add "   # This code should be copied to all the other translators\n"
  add "\n"
  add "   # fix: just modify the rust code based on the code in \n"
  add "   # object/machine.interp.c \n"
  add "   sub escapeChar {\n"
  add "     my $self = shift;\n"
  add "     my $c = shift;  # the character to escape\n"
  add "     my $countEscapes = 0;\n"
  add "     return if length($self->{work}) == 0;\n"
  add "\n"
  add "     my @chars = split(//, $self->{work});\n"
  add "     $self->{work} = \"\";\n"
  add "     for (my $ii = 0; $ii < @chars; $ii++) {\n"
  add "       # escape the character c but only if it is not the pep\n"
  add "       # machine escape character (by default a backslash \\)\n"
  add "       if (($chars[$ii] eq $c) && ($c ne $self->{escape}) && \n"
  add "           ($countEscapes % 2 == 0)) {\n"
  add "         $self->{work} .= $self->{escape};\n"
  add "       }\n"
  add "\n"
  add "       if ($chars[$ii] eq $self->{escape}) {\n"
  add "         $countEscapes += 1;\n"
  add "       }\n"
  add "       else {\n"
  add "         if (($c eq $self->{escape}) && ($countEscapes > 0) && \n"
  add "            ($countEscapes %2 == 1)) { \n"
  add "           $self->{work} .= $self->{escape};\n"
  add "         } \n"
  add "         $countEscapes = 0; \n"
  add "       } \n"
  add "       $self->{work} .= $chars[$ii];\n"
  add "     } \n"
  add "   } \n"
  add "\n"
  add "   # a helper to see how many trailing escape chars, this is used\n"
  add "   # only by the until command to see if it should keep reading or \n"
  add "   # not.\n"
  add "   sub countEscaped {\n"
  add "     my ($self, $suffix) = @_;\n"
  add "     my $s = $self->{work};\n"
  add "     my $count = 0;\n"
  add "     if (substr($s, -length($suffix)) eq $suffix) {\n"
  add "       $s = substr($s, 0, length($s) - length($suffix));\n"
  add "     }\n"
  add "     while (substr($s, -length($self->{escape})) eq $self->{escape}) {\n"
  add "       $count++;\n"
  add "       $s = substr($s, 0, length($s) - length($self->{escape}));\n"
  add "     }\n"
  add "     return $count;\n"
  add "   }\n"
  add "\n"
  add "   #  reads the input stream until the work end with text. It is\n"
  add "   #    better to call this readUntil instead of until because some\n"
  add "   #       languages dont like keywords as methods. Same for read()\n"
  add "   #       should be readChar() \n"
  add "   sub readUntil {\n"
  add "     my ($self, $suffix) = @_;\n"
  add "     # read at least one character\n"
  add "     return if $self->{eof};\n"
  add "     $self->readChar();\n"
  add "     while (true) {\n"
  add "       return if $self->{eof};\n"
  add "       if (substr($self->{work}, -length($suffix)) eq $suffix) {\n"
  add "         return if $self->countEscaped($suffix) % 2 == 0;\n"
  add "       }\n"
  add "       $self->readChar();\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   # pop the first token from the stack into the workspace\n"
  add "   sub popToken {\n"
  add "     my $self = shift;   # a reference to the pep machine\n"
  add "     if (!@{$self->{stack}}) { return false; }\n"
  add "     $self->{work} = pop(@{$self->{stack}}) . $self->{work};\n"
  add "     if ($self->{cell} > 0) { $self->{cell} -= 1; }\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   # push the first token from the workspace to the stack\n"
  add "   sub pushToken {\n"
  add "     my $self = shift;   # a reference to the pep machine\n"
  add "     # dont increment the tape pointer on an empty push\n"
  add "     if (length($self->{work}) == 0) { return false; }\n"
  add "\n"
  add "     # I iterate the workspace buffer chars so that this method\n"
  add "     # can be easily adapted for grapheme clusters\n"
  add "     my $token = \"\";\n"
  add "     my $remainder = \"\";\n"
  add "     my @chars = split(//, $self->{work});\n"
  add "\n"
  add "     # maybe for grapheme clusters\n"
  add "     # my @chars = split(/\\X/, $self->{work});\n"
  add "     for (my $ii = 0; $ii < scalar(@chars); $ii++) {\n"
  add "       my $c = $chars[$ii];\n"
  add "       $token .= $c;\n"
  add "       if ($c eq $self->{delimiter}) {\n"
  add "         push @{$self->{stack}}, $token;\n"
  add "         $remainder = join \"\", @chars[$ii+1 .. $#chars];\n"
  add "         $self->{work} = \"\";\n"
  add "         $self->{work} .= $remainder;\n"
  add "         $self->increment();\n"
  add "         return true;\n"
  add "       }\n"
  add "     }\n"
  add "     # push the whole workspace if there is no token delimiter\n"
  add "     push @{$self->{stack}}, $token;\n"
  add "     $self->{work} = \"\";\n"
  add "     $self->increment();\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   # save the workspace to file \"sav.pp\"\n"
  add "   # we can put this inline?\n"
  add "   sub writeToFile {\n"
  add "     my ($self) = @_;\n"
  add "     my $filename = \"sav.pp\";\n"
  add "     open my $fh, \">:utf8\", $filename or \n"
  add "       die \"Could not open file [$filename] for writing: $!\";\n"
  add "     print $fh $self->{work};\n"
  add "     close $fh;\n"
  add "   }\n"
  add "\n"
  add "   sub goToMark {\n"
  add "     my ($self, $mark) = @_;\n"
  add "     for (my $ii = 0; $ii < @{$self->{marks}}; $ii++) {\n"
  add "       # print(\"ii:\", $ii, \" mark:\", $thismark,\"\\n\");\n"
  add "       if ($self->{marks}[$ii] eq $mark) {\n"
  add "         $self->{cell} = $ii;\n"
  add "         return;\n"
  add "       }\n"
  add "     }\n"
  add "     print \"badmark \'$mark\'!\\n\";\n"
  add "     exit 1;\n"
  add "   }\n"
  add "\n"
  add "   # # remove existing marks with the same name and add new mark \n"
  add "   sub addMark {\n"
  add "     my ($self, $newMark) = @_;\n"
  add "     # remove existing marks with the same name.\n"
  add "     for my $mark (@{$self->{marks}}) {\n"
  add "       if ($mark eq $newMark) {\n"
  add "         $mark = \"\";\n"
  add "       }\n"
  add "     }\n"
  add "     $self->{marks}[$self->{cell}] = $newMark;\n"
  add "   }\n"
  add "\n"
  add "   # # check if the workspace matches given list class eg [hjk]\n"
  add "   #    or a range class eg [a-p]. The class string will be \"[a-p]\" ie\n"
  add "   #    with brackets [:alpha:] may have already been made into something else by the\n"
  add "   #    compiler.\n"
  add "   #    fix: for grapheme clusters and more complete classes\n"
  add "   #   \n"
  add "   sub matchClass {\n"
  add "     my ($self, $text, $class) = @_;\n"
  add "     # empty text should never match a class.\n"
  add "     return false if length($text) == 0;\n"
  add "\n"
  add "     # a character type class like [:alpha:]\n"
  add "     # print(\"class: $class\");\n"
  add "         \n"
  add "     if ($class =~ /^\\[:(.+):\\]$/ && $class ne \"[:]\" && $class ne \"[::]\") {\n"
  add "       my $charType = $1;\n"
  add "       my @chars = split //, $text;\n"
  add "       if ($charType eq \"alnum\") { return $text =~ /^\\w+$/; }\n"
  add "       if ($charType eq \"alpha\") { return $text =~ /^[[:alpha:]]+$/; }\n"
  add "       if ($charType eq \"ascii\") { return $text =~ /^[[:ascii:]]+$/; }\n"
  add "       if ($charType eq \"word\") { return $text =~ /^[\\w_]+$/; }\n"
  add "       if ($charType eq \"blank\") { return $text =~ /^[\\s\\t]+$/; }\n"
  add "       if ($charType eq \"control\") { return $text =~ /^[[:cntrl:]]+$/; }\n"
  add "       if ($charType eq \"cntrl\") { return $text =~ /^[[:cntrl:]]+$/; }\n"
  add "       if ($charType eq \"digit\") { return $text =~ /^\\d+$/;}\n"
  add "       if ($charType eq \"graph\") { return $text =~ /^[[:graph:]]+$/; }\n"
  add "       if ($charType eq \"lower\") { return $text =~ /^[[:lower:]]+$/; }\n"
  add "       if ($charType eq \"upper\") { return $text =~ /^[[:upper:]]+$/; }\n"
  add "       if ($charType eq \"print\") { return $text =~ /^[[:print:]]+$/; \n"
  add "         # and not eq \" \"\n"
  add "       }\n"
  add "       if ($charType eq \"punct\") { return $text =~ /^[[:punct:]]+$/; }\n"
  add "       if ($charType eq \"space\") { return $text =~ /^\\s+$/; }\n"
  add "       if ($charType eq \"xdigit\") { return $text =~ /^[0-9a-fA-F]+$/; }\n"
  add "       print STDERR \"unrecognised char class in translated nom script\\n\";\n"
  add "       print STDERR \"$charType\\n\";\n"
  add "       exit 1;\n"
  add "       return false;\n"
  add "     }\n"
  add "\n"
  add "     # get a vector of chars except the first and last which are [ and ]\n"
  add "     my @charList = split //, substr($class, 1, length($class)-2);\n"
  add "     # is a range class like [a-z]\n"
  add "     if (scalar(@charList) == 3 && $charList[1] eq \"-\") {\n"
  add "       my ($start, undef, $end) = @charList;\n"
  add "       my @chars = split(//, $text);\n"
  add "       #print(\"chars: @chars\");\n"
  add "       #return all { $_ ge $start && $_ le $end } @chars;\n"
  add "       # modify split for grapheme clusters?\n"
  add "       for my $char (split //, $text) {\n"
  add "         if ($char lt $start || $char gt $end) { return false; }\n"
  add "       }\n"
  add "       return true;\n"
  add "     }\n"
  add "\n"
  add "     # list class like: [xyzabc]\n"
  add "     # check if all characters in text are in the class list\n"
  add "     # my @textChars = split //, $text;\n"
  add "\n"
  add "     # Create a hash for faster lookup?\n"
  add "     my %charHash = map { $_ => 1 } @charList; \n"
  add "     for my $char (split //, $text) {\n"
  add "       return false unless exists $charHash{$char};\n"
  add "     }\n"
  add "     return true;\n"
  add "\n"
  add "     #return all { grep { $_ eq $textChars[$_] } @charList } 0 .. $#textChars;\n"
  add "     #return false;\n"
  add "     # also must handle eg [:alpha:] This can be done with char methods\n"
  add "   }\n"
  add "\n"
  add "   # # a plain text string replace function on the workspace \n"
  add "   sub replace {\n"
  add "     my ($self, $old, $new) = @_;\n"
  add "     return if length($old) == 0;\n"
  add "     return if $old eq $new;\n"
  add "     $old = quotemeta($old);\n"
  add "     $self->{work} =~ s/$old/$new/g;\n"
  add "   }\n"
  add "\n"
  add "   #  make the workspace capital case \n"
  add "   sub capitalise {\n"
  add "     my ($self) = @_;\n"
  add "     my $result = \"\";\n"
  add "     my $capitalize_next = 1;\n"
  add "     for my $c (split //, $self->{work}) {\n"
  add "       if ($c =~ /[[:alpha:]]/) {\n"
  add "         if ($capitalize_next) {\n"
  add "           $result .= uc $c;\n"
  add "           $capitalize_next = false;\n"
  add "         } else {\n"
  add "           $result .= lc $c;\n"
  add "         }\n"
  add "       } else {\n"
  add "         $result .= $c;\n"
  add "         if ($c eq \"\\n\" || $c eq \" \" || $c eq \".\" || $c eq \"?\" || $c eq \"!\") {\n"
  add "           $capitalize_next = true;\n"
  add "         }\n"
  add "       }\n"
  add "     }\n"
  add "     $self->{work} = $result;\n"
  add "   }\n"
  add "\n"
  add "   #  print the internal state of the pep/nom parsing machine. This\n"
  add "   #    is handy for debugging \n"
  add "   sub printState {\n"
  add "     my $self = shift;\n"
  add "     print \n"
  add "       \"\\n--------- Machine State ------------- \\n\",\n"
  add "       \"(input buffer:\", join(\",\", @{$self->{inputBuffer}}), \")\\n\",\n"
  add "       \"Stack[\", join(\",\", @{$self->{stack}}), \"]\", \n"
  add "       \" Work[\", $self->{work}, \"]\",\n"
  add "       \" Peep[\", $self->{peep}, \"]\\n\",\n"
  add "       \"Acc:\", $self->{accumulator},\n"
  add "       \" EOF:\", $self->{eof} eq true? \"true\":\"false\", \n"
  add "       \" Esc:\", $self->{escape},\n"
  add "       \" Delim:\", $self->{delimiter}, \n"
  add "       \" Chars:\", $self->{charsRead}, \" \";\n"
  add "     print \"Lines:\", $self->{linesRead}, \"\\n\";\n"
  add "     print \"-------------- Tape ----------------- \\n\";\n"
  add "     print \"Tape Size: \", $self->{tapeLength}, \"\\n\";\n"
  add "     my $start = 0;\n"
  add "     if ($self->{cell} > 3) {\n"
  add "       $start = $self->{cell} - 4;\n"
  add "     }\n"
  add "     my $end = $self->{cell} + 4;\n"
  add "     for (my $ii = $start; $ii <= $end; $ii++) {\n"
  add "       print \"    $ii \";\n"
  add "       if ($ii == $self->{cell}) { print \"> [\"; }\n"
  add "       else { print \"  [\"; }\n"
  add "       if (defined $self->{tape}[$ii]) {\n"
  add "         print $self->{tape}[$ii], \"] \";\n"
  add "         if (defined $self->{marks}[$ii] && ($self->{marks}[$ii] ne \"\")) {\n"
  add "           print \"(m:\", $self->{marks}[$ii], \")\";\n"
  add "         }\n"
  add "         print \"\\n\";\n"
  add "       } else {\n"
  add "         print \"]\\n\";\n"
  add "       }\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   # print the internal state of the pep/nom parsing machine as an\n"
  add "   # html table. But use the script /eg/machine.tohtml.pss instead which\n"
  add "   # is better.\n"
  add "   sub printHtmlState {\n"
  add "     my $self = shift;\n"
  add "     print \n"
  add "       \"\\n<table><thead> Machine State </thead> \\n\",\n"
  add "       \"<tr><td>Stack</td><td>Workspace</td><td>Peep</td></tr>\\n\",\n"
  add "       \"<tr><td>\", join(\",\", @{$self->{stack}}), \"</td>\\n\", \n"
  add "       \"    <td>\", $self->{work}, \"</td>\\n\",\n"
  add "       \"    <td>\", $self->{peep}, \"</td></tr>\\n\",\n"
  add "       \"<tr><td>Acc</td><td>EOF</td><td>Esc</td>\\n\",\n"
  add "       \"    <td>Delim</td><td>Chars</td><td>Lines</td></tr>\\n\",\n"
  add "       \"<tr><td>\", $self->{accumulator}, \"</td>\\n\",\n"
  add "       \"    <td>\", $self->{eof} eq true? \"true\":\"false\", \"</td>\\n\",\n"
  add "       \"    <td>\", $self->{escape}, \"</td>\\n\",\n"
  add "       \"    <td>\", $self->{delimiter}, \"</td>\\n\",\n"
  add "       \"    <td>\", $self->{charsRead}, \"</td>\\n\";\n"
  add "     print \"<td>\", $self->{linesRead}, \"</td></tr>\\n\";\n"
  add "     print \"<tr><td> Tape \\n\";\n"
  add "     print \"Tape Size: \", $self->{tapeLength}, \"\\n\";\n"
  add "     my $start = 0;\n"
  add "     if ($self->{cell} > 3) {\n"
  add "       $start = $self->{cell} - 4;\n"
  add "     }\n"
  add "     my $end = $self->{cell} + 4;\n"
  add "     for (my $ii = $start; $ii <= $end; $ii++) {\n"
  add "       print \"    $ii \";\n"
  add "       if ($ii == $self->{cell}) { print \"> [\"; }\n"
  add "       else { print \"  [\"; }\n"
  add "       if (defined $self->{tape}[$ii]) {\n"
  add "         print $self->{tape}[$ii], \"] \";\n"
  add "         if (defined $self->{marks}[$ii] && ($self->{marks}[$ii] ne \"\")) {\n"
  add "           print \"(m:\", $self->{marks}[$ii], \")\";\n"
  add "         }\n"
  add "         print \"\\n\";\n"
  add "       } else {\n"
  add "         print \"]\\n\";\n"
  add "       }\n"
  add "     }\n"
  add "     print \"</table>\\n\";\n"
  add "   }\n"
  add "\n"
  add "   # # makes the machine read from a string also needs to prime\n"
  add "   #    the \"peep\" value. \n"
  add "   sub setStringInput {\n"
  add "     my ($self, $text) = @_;\n"
  add "     $self->{inputType} = \"string\";\n"
  add "     $self->{inputBuffer} = [];\n"
  add "     $self->fillInputBuffer($text);\n"
  add "     # prime the \"peep\" with the 1st char\n"
  add "     $self->{peep} = \"\"; $self->readChar(); $self->{charsRead} = 0;\n"
  add "   }\n"
  add "\n"
  add "   # # makes the machine write to a string \n"
  add "   sub setStringOutput {\n"
  add "     my ($self) = @_;\n"
  add "     $self->{sinkType} = \"string\";\n"
  add "   }\n"
  add "\n"
  add "   # # parse/translate from a string and return the translated\n"
  add "   #    string \n"
  add "   sub parseString {\n"
  add "     my ($self, $input) = @_;\n"
  add "     $self->setStringInput($input);\n"
  add "     $self->{sinkType} = \"string\";\n"
  add "     $self->parse();\n"
  add "     return $self->{outputBuffer};\n"
  add "   }\n"
  add "\n"
  add "   # # makes the machine read from a file stream line by line,\n"
  add "   #    not from stdin \n"
  add "   sub setFileStreamInput {\n"
  add "     my ($self, $filename) = @_;\n"
  add "     unless (checkTextFile($filename)) { exit 1; }\n"
  add "     open my $fh, \"<:utf8\", $filename or \n"
  add "       die \"Cannot open file [$filename] for reading: $!\";\n"
  add "     $self->{input} = IO::BufReader->new($fh);\n"
  add "     $self->{inputType} = \"filestream\";\n"
  add "     # prime the peep, the read() method should refill the\n"
  add "     # inputChars or inputBuffer if it is empty.\n"
  add "     $self->{peep} = \"\"; $self->readChar(); $self->{charsRead} = 0;\n"
  add "   }\n"
  add "\n"
  add "   # # makes the machine read from a file line buffer array\n"
  add "   #    but this also needs to prime the \"peep\" value \n"
  add "   sub setFileInput {\n"
  add "     my ($self, $filename) = @_;\n"
  add "     open my $fh, \"<:utf8\", $filename or \n"
  add "       die \"Could not open file [$filename] for reading: $!\";\n"
  add "     my $text = do { local $/ = undef; <$fh> };\n"
  add "     close $fh;\n"
  add "     # there is an extra newline being added, I dont know where.\n"
  add "     if ($text =~ s/\\n$//) {}\n"
  add "     $self->{inputType} = \"file\";\n"
  add "     $self->{inputBuffer} = [];\n"
  add "     $self->fillInputBuffer($text);\n"
  add "     # prime the \"peep\" with the 1st char\n"
  add "     $self->{peep} = \"\"; $self->readChar(); $self->{charsRead} = 0;\n"
  add "   }\n"
  add "\n"
  add "   # # makes the machine write to a file not to stdout (the default) \n"
  add "   sub setFileOutput {\n"
  add "     my ($self, $filename) = @_;\n"
  add "     unless (checkTextFile($filename)) { exit 1; }\n"
  add "     open my $fh, \">:utf8\", $filename or \n"
  add "       die \"Cannot create file [$filename] for writing: $!\";\n"
  add "     $self->{output} = $fh;\n"
  add "     $self->{sinkType} = \"file\";\n"
  add "   }\n"
  add "\n"
  add "   # parse from a file and put result in file\n"
  add "   sub parseFile {\n"
  add "     my ($self, $inputFile, $outputFile) = @_;\n"
  add "     $self->setFileInput($inputFile);\n"
  add "     $self->setFileOutput($outputFile);\n"
  add "     $self->parse();\n"
  add "   }\n"
  add "\n"
  add "   # # parse from any stream, fix handle \n"
  add "   # #\n"
  add "   # sub parseStream {\n"
  add "   #   my ($self, $reader) = @_;\n"
  add "   #   # $self->{input} = $reader; # Needs proper handling of reader type\n"
  add "   #   $self->parse();\n"
  add "   # }\n"
  add "   # \n"
  add "\n"
  add "   # this is the default parsing mode. If no other is selected\n"
  add "   #   it will be activated when parse() is first called. I activate it when\n"
  add "   #   parse is 1st called because otherwise it will block if no stdin\n"
  add "   #   is availabel. It also sets stdout as output \n"
  add "   sub setStandardInput {\n"
  add "     my $self = shift;\n"
  add "     $self->{inputType} = \"stdin\";\n"
  add "     $self->{sinkType} = \"stdout\";\n"
  add "     # for printing wide characters\n"
  add "     binmode STDOUT, \":encoding(UTF-8)\";\n"
  add "     # binmode STDERR, \":encoding(UTF-8)\";\n"
  add "\n"
  add "     # $self->{input} = \*STDIN;\n"
  add "     # $self->{output} = \*STDOUT;\n"
  add "\n"
  add "     # read the whole of stdin into the inputBuffer\n"
  add "     $self->{inputBuffer} = [];\n"
  add "     my $buffer = \"\";\n"
  add "     while (<STDIN>) { \n"
  add "       $buffer .= $_;\n"
  add "     }\n"
  add "     \n"
  add "     # print(\"buffer: [$buffer]\\n\");\n"
  add "     $self->fillInputBuffer($buffer);\n"
  add "     # $self->printState();\n"
  add "     # prime the \"peep\" with the 1st char, but this doesnt count as\n"
  add "     # a character read.\n"
  add "     $self->{peep} = \"\"; $self->readChar(); $self->{charsRead} = 0;\n"
  add "   }\n"
  add "\n"
  add "   # This function performs all sorts of magic and shenanigans. \n"
  add "   # Creates a new method runScript() - a clone of the parse() method\n"
  add "   # and evaluates it, thus acting as an interpreter of a scriptfile given to an\n"
  add "   # -E switch. This method only works when the nom to perl translator has \n"
  add "   # been run on itself (the translator translating the translator). \n"
  add "   #   >> pep -f nom.toperl.pss nom.toperl.pss > interp.perl.pl\n"
  add "   #   >> echo \"read; print; print; clear; \" > test.pss\n"
  add "   #   >> chmod a+x interp.perl.pl\n"
  add "   #   >> echo buzz | ./interp.perl.pl -f test.pss\n"
  add "   #   >> (output should be \"bbuuzz\")\n"
  add "   # Only those who have achieved\n"
  add "   # true enlightenment will understand this method.\n"
  add "   sub interpret {\n"
  add "     my $self = shift;          # the pep parse machine \n"
  add "     my $filename = shift;\n"
  add "\n"
  add "     # print \"# $filename\";\n"
  add "     if ((!defined $filename) || ($filename eq \"\")) { return; }\n"
  add "     # set string output and file input\n"
  add "     $self->setFileInput($filename);\n"
  add "     $self->setStringOutput($filename);\n"
  add "     $self->parse($filename);\n"
  add "     my $method = $self->{outputBuffer}; \n"
  add "\n"
  add "     # remove everything except the parse method and rename\n"
  add "     # the method so that it doesnt clash with the existing parse\n"
  add "     # method. Although it would probably override the existing parse()\n"
  add "     # method ...?\n"
  add "\n"
  add "     $method =~ s/^.*sub parse \\{/sub runScript \\{/s;\n"
  add "     $method =~ s/sub printHelp \\{.*$//s;\n"
  add "     # to debug\n"
  add "     # print $method; \n"
  add "\n"
  add "     # add this new runScript() method to the current class via evaluation\n"
  add "     eval($method);\n"
  add "     # print \"after eval\";\n"
  add "     # $self->{inputType} = \"unset\";\n"
  add "     $self->resetMachine();\n"
  add "     # execute the new method, thus interpreting the script-file \n"
  add "     # that was provide. This method did not exist when the script was \n"
  add "     # first loaded, but apparently that doesnt matter. \n"
  add "     $self->runScript();\n"
  add "   }\n"
  add "\n"
  add "   # parse and translate the input stdin/file/string \n"
  add "   sub parse {\n"
  add "     my $self = shift;\n"
  add "     # some temporary variables\n"
  add "     my $text = \"\"; my $mark = \"\";\n"
  add "     my $jumptoparse = false;\n"
  add "     # capture the output of the system command.\n"
  add "     my $result = \"\";\n"
  add "     if ($self->{inputType} eq \"unset\") {\n"
  add "       $self->setStandardInput();\n"
  add "     }\n"
  add "    \n"
  add "     # -----------\n"
  add "     # translated nom code inserted below\n"
  add "     # -----------\n"
  add "     "
  # get the compiled code from the tape
  get
  add "\n"
  add "\n"
  add "     # close open files here? yes. use break, not return\n"
  add "     my $outputType = $self->{sinkType};\n"
  add "     if ($outputType eq \"file\") {\n"
  add "       $self->{output}->flush() or die \"Error flushing output file: $!\";\n"
  add "     } elsif ($outputType eq \"stdout\") {\n"
  add "       # STDOUT is typically flushed automatically\n"
  add "     } elsif ($outputType eq \"string\") {\n"
  add "       # Output is in the buffer\n"
  add "     } else {\n"
  add "       print STDERR \"unsupported output type: \", $outputType, \"\\n\";\n"
  add "     }\n"
  add "   } # sub parse\n"
  add "\n"
  add "\n"
  add " sub printHelp {\n"
  add "   print <<EOF;\n"
  add "\n"
  add "   Nom script translated to perl by www.nomlang.org/tr/ script \n"
  add "   usage:\n"
  add "         echo \"..sometext..\" | ./script\n"
  add "         cat somefile.txt | ./script\n"
  add "         ./script -f <file>\n"
  add "         ./script -i <text>\n"
  add "   options:\n"
  add "     --file -f <file>\n"
  add "       run the script with <file> as input (not stdin)\n"
  add "     --input -i <text>\n"
  add "       run the script with <text> as input\n"
  add "     --filetest -F <filename>\n"
  add "       test the translated script with file input and output\n"
  add "     --filestream -S <filename>\n"
  add "       test the translated script with file-stream input\n"
  add "     --inputtest -I <text>\n"
  add "       test the translated script with string input and output\n"
  add "     --ifile -e <filename> \n"
  add "       make the translated-translator act as an interpreter (interprets\n"
  add "       the nom script in the given file. Only works with the translated\n"
  add "       translator - eg: \n"
  add "         pep -f nom.toperl.pss nom.toperl.pss > nomtoperl.pl\n"
  add "         chmod +x nomtoperl.pl\n"
  add "         eg: echo \"hannah\" | ./nomtoperl.pl -E ../eg/palindrome.pss\n"
  add "     --iscript -d \"<inline script>\"\n"
  add "         Interpret the given nom script with input from <stdin>\n"
  add "         when the nom.toperl.pss script has translated itself - see \n"
  add "         above.\n"
  add "         eg: echo -n hello | ./pepnom.pl -d \"read; add \'.\'; print; clear;\"\n"
  add "     --help -h\n"
  add "       show this help\n"
  add "\n"
  add "EOF\n"
  add "\n"
  add " }\n"
  add "\n"
  add " # display a message about a missing argument to the translated\n"
  add " #    script \n"
  add " sub missingArgument {\n"
  add "   print \"Missing argument.\\n\";\n"
  add "   printHelp();\n"
  add "   exit 1;\n"
  add " }\n"
  add "\n"
  add " # display a message if an command line option is repeated\n"
  add " sub duplicateSwitch {\n"
  add "   print \"Duplicate switch found.\\n\";\n"
  add "   printHelp();\n"
  add "   exit 1;\n"
  add " }\n"
  add "\n"
  add " sub checkTextFile {\n"
  add "   my ($filepath) = @_;\n"
  add "   eval {\n"
  add "     open my $fh, \"<:utf8\", $filepath;\n"
  add "     close $fh;\n"
  add "     return true;\n"
  add "   };\n"
  add "   if ($@) {\n"
  add "     if ($@ =~ /No such file or directory/) {\n"
  add "       print \"File [$filepath] not found.\\n\";\n"
  add "     } elsif ($@ =~ /Permission denied/) {\n"
  add "       print \"Permission denied to read file [$filepath]\\n\";\n"
  add "     } else {\n"
  add "       print \"Error opening file $filepath: $@\";\n"
  add "     }\n"
  add "     return false;\n"
  add "   }\n"
  add "   return true;\n"
  add " }\n"
  add "\n"
  add "# shows where the package ends.\n"
  add "1;\n"
  add "\n"
  add "package main;\n"
  add "\n"
  add "  my $mm = Machine->new();\n"
  add "  my $input = \"\";\n"
  add "  my $filename = \"\";\n"
  add "\n"
  add "  GetOptions (\n"
  add "    \"file|f=s\"      => \$filename,\n"
  add "    \"input|i=s\"     => \$input,\n"
  add "    \"filetest|F=s\"  => sub {\n"
  add "      my ($opt_name, $value) = @_;\n"
  add "      if ($value) {\n"
  add "        if ($filename ne \"\") { $mm->duplicateSwitch(); }\n"
  add "        if (!$mm->checkTextFile($value)) { $mm->printHelp(); exit 1; }\n"
  add "        $mm->parseFile($value, \"out.txt\");\n"
  add "        my $output = do {\n"
  add "          local $/ = undef;\n"
  add "          open my $fh, \"<:utf8\", \"out.txt\" or die \"Could not open out.txt: $!\";\n"
  add "          <$fh>;\n"
  add "        };\n"
  add "        print $output;\n"
  add "        exit($mm->{accumulator});\n"
  add "      } else {\n"
  add "        $mm->missingArgument();\n"
  add "      }\n"
  add "    },\n"
  add "    \"filestream|S=s\" => sub {\n"
  add "      my ($opt_name, $value) = @_;\n"
  add "      if ($value) {\n"
  add "        if ($filename ne \"\") { $mm->duplicateSwitch(); }\n"
  add "        if (!$mm->checkTextFile($value)) { $mm->printHelp(); exit 1; }\n"
  add "        $mm->setFileStreamInput($value);\n"
  add "      } else {\n"
  add "        $mm->missingArgument();\n"
  add "      }\n"
  add "    },\n"
  add "    \"inputtest|I=s\" => sub {\n"
  add "      my ($opt_name, $value) = @_;\n"
  add "      if ($value) {\n"
  add "        if ($input ne \"\") { $mm->duplicateSwitch(); }\n"
  add "        my $text = $mm->parseString($value);\n"
  add "        print $text;\n"
  add "        exit($mm->{accumulator});\n"
  add "      } else {\n"
  add "        $mm->missingArgument();\n"
  add "      }\n"
  add "    },\n"
  add "    \"ifile|e=s\"  => sub {\n"
  add "      my ($opt_name, $ifile) = @_;\n"
  add "      if ($ifile) {\n"
  add "        if ($filename ne \"\") { $mm->duplicateSwitch(); }\n"
  add "        if (!$mm->checkTextFile($ifile)) { $mm->printHelp(); exit 1; }\n"
  add "        $mm->interpret($ifile);\n"
  add "        exit($mm->{accumulator});\n"
  add "      } else {\n"
  add "        $mm->missingArgument();\n"
  add "      }\n"
  add "    },\n"
  add "    \"iscript|d=s\"  => sub {\n"
  add "      my ($opt_name, $script) = @_;\n"
  add "      if ($script) {\n"
  add "        if ($filename ne \"\") { $mm->duplicateSwitch(); }\n"
  add "        if (!$mm->checkTextFile($script)) { $mm->printHelp(); exit 1; }\n"
  add "        open my $fh, \">:utf8\", \"temp.txt\" or die \"Could not open temp.txt: $!\";\n"
  add "        print $fh $script; close $fh; \n"
  add "        $mm->interpret(\"temp.txt\");\n"
  add "        exit($mm->{accumulator});\n"
  add "      } else {\n"
  add "        $mm->missingArgument();\n"
  add "      }\n"
  add "    },\n"
  add "    \"help|h\"        => sub { $mm->printHelp(); exit 0; },\n"
  add "  ) or die \"Error in command line arguments\\n\";\n"
  add "\n"
  add "  if ($input ne \"\" && $filename ne \"\") {\n"
  add "    print <<EOF;\n"
  add "\n"
  add "    Either use the --file/--filetest options or the --input/--inputtest\n"
  add "    options, not both\n"
  add "\n"
  add "EOF\n"
  add "    printHelp();\n"
  add "    exit 0;\n"
  add "  }\n"
  add "\n"
  add "  $mm->parse();\n"
  add "  # accumulator as exit code \n"
  add "  exit($mm->{accumulator});\n"
  add "  # shows where the package ends.\n"
  add "  #1;\n"
  add "\n"
  add "  \n"
  # accumulator zero for success.
  zero
  print
  quit
block.end.101417:
# end of block
jump start 
