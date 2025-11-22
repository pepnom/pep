# Assembled with the script 'compile.pss' 
start:

#
#ABOUT 
#
#  Translate nom to the lua language. This uses the 
#  new script organisation from /tr/nom.todart.pss
#
#NOTES
#
#  need to use goto instead of labelled loops.
#
#  See /tr/nom.todart.pss for info about this new translation
#  script organisation.
#
#  https://www.regular-expressions.info/unicode.html#category
#    important unicode regexp info for different languages. The 
#    unicode script names and properties which are included here 
#    were copied from this website.
#
#  When reading with until we stop at the end text, but not if 
#  it is escaped with the machine escape char (usually '\\' ?). 
#
#  This will read one line at a time into a buffer
#
#  Details to check. Quoting. escaping special sequences. Will "\n"
#  work in strings?
#
#UNICODE CATEGORIES
#
#  Does lua support these categories?, here is a list.
#
#  If the translator supports unicode and grapheme clusters (and
#  dart seems to, through the 'characters' api), then it seems preferable 
#  to convert [:alnum:] [:alpha:] classes to the unicode categories 
#  below. 
#
#  So [:alpha:] would probably become \p{L} or \p{Letter}
#  So [:space:] might become \p{Z} or \p{Separator}
#
#  Apparently \P{L} (capital P) is the inverse set, ie any non-letter.
#  But \p{L} does not match grapheme clusters, see below for that.
#
#   * match any unicode character or grapheme cluster
#   >> \P{M}\p{M}*+ is the equivalent of \X
#   \X is the simplest way if the language supports it.
#
#    \p{L} or \p{Letter}: 
#       any kind of letter from any language.
#    \p{Ll} or \p{Lowercase_Letter}: 
#       a lowercase letter that has an uppercase variant.
#    \p{Lu} or \p{Uppercase_Letter}: 
#       an uppercase letter that has a lowercase variant.
#    \p{Lt} or \p{Titlecase_Letter}: a letter that appears at the start of a word when only the first letter of the word is capitalized.
#    \p{L&} or \p{Cased_Letter}: a letter that exists in lowercase and uppercase variants (combination of Ll, Lu and Lt).
#    \p{Lm} or \p{Modifier_Letter}: a special character that is used like a letter.
#    \p{Lo} or \p{Other_Letter}: a letter or ideograph that does not have lowercase and uppercase variants.
#    \p{M} or \p{Mark}: a character intended to be combined with another character (e.g. accents, umlauts, enclosing boxes, etc.).
#    \p{Mn} or \p{Non_Spacing_Mark}: a character intended to be combined with another character without taking up extra space (e.g. accents, umlauts, etc.).
#    \p{Mc} or \p{Spacing_Combining_Mark}: a character intended to be combined with another character that takes up extra space (vowel signs in many Eastern languages).
#    \p{Me} or \p{Enclosing_Mark}: a character that encloses the character it is combined with (circle, square, keycap, etc.).
#    \p{Z} or \p{Separator}: any kind of whitespace or invisible separator.
#    \p{Zs} or \p{Space_Separator}: a whitespace character that is invisible, but does take up space.
#    \p{Zl} or \p{Line_Separator}: line separator character U+2028.
#    \p{Zp} or \p{Paragraph_Separator}: paragraph separator character U+2029.
#    \p{S} or \p{Symbol}: math symbols, currency signs, dingbats, box-drawing characters, etc.
#    \p{Sm} or \p{Math_Symbol}: any mathematical symbol.
#    \p{Sc} or \p{Currency_Symbol}: any currency sign.
#    \p{Sk} or \p{Modifier_Symbol}: a combining character (mark) as a full character on its own.
#    \p{So} or \p{Other_Symbol}: various symbols that are not math symbols, currency signs, or combining characters.
#    \p{N} or \p{Number}: any kind of numeric character in any script.
#    \p{Nd} or \p{Decimal_Digit_Number}: a digit zero through nine in any script except ideographic scripts.
#    \p{Nl} or \p{Letter_Number}: a number that looks like a letter, such as a Roman numeral.
#    \p{No} or \p{Other_Number}: a superscript or subscript digit, or a number that is not a digit 0–9 (excluding numbers from ideographic scripts).
#    \p{P} or \p{Punctuation}: any kind of punctuation character.
#    \p{Pd} or \p{Dash_Punctuation}: any kind of hyphen or dash.
#    \p{Ps} or \p{Open_Punctuation}: any kind of opening bracket.
#    \p{Pe} or \p{Close_Punctuation}: any kind of closing bracket.
#    \p{Pi} or \p{Initial_Punctuation}: any kind of opening quote.
#    \p{Pf} or \p{Final_Punctuation}: any kind of closing quote.
#    \p{Pc} or \p{Connector_Punctuation}: a punctuation character such as an underscore that connects words.
#    \p{Po} or \p{Other_Punctuation}: any kind of punctuation character that is not a dash, bracket, quote or connector.
#    \p{C} or \p{Other}: invisible control characters and unused code points.
#    \p{Cc} or \p{Control}: an ASCII or Latin-1 control character: 0x00–0x1F and 0x7F–0x9F.
#    \p{Cf} or \p{Format}: invisible formatting indicator.
#    \p{Co} or \p{Private_Use}: any code point reserved for private use.
#    \p{Cs} or \p{Surrogate}: one half of a surrogate pair in UTF-16 encoding.
#    \p{Cn} or \p{Unassigned}: any code point to which no character has been assigned.
#
#UNICODE SCRIPT NAMES
#
#  Information from regular-expressions.info/unicode.html#script
#  A surprising useful website.
#
#  The JGsoft engine, Perl, PCRE, PHP, Ruby 1.9, Delphi can match Unicode scripts. 
#
#  * unicode script names
#  -----
#   \p{Common} \p{Arabic} \p{Armenian} \p{Bengali} \p{Bopomofo}
#   \p{Braille} \p{Buhid} \p{Canadian_Aboriginal} \p{Cherokee}
#   \p{Cyrillic} \p{Devanagari} \p{Ethiopic} \p{Georgian} \p{Greek}
#   \p{Gujarati} \p{Gurmukhi} \p{Han} \p{Hangul} \p{Hanunoo}
#   \p{Hebrew} \p{Hiragana} \p{Inherited} \p{Kannada} \p{Katakana}
#   \p{Khmer} \p{Lao} \p{Latin} \p{Limbu} \p{Malayalam} \p{Mongolian}
#   \p{Myanmar} \p{Ogham} \p{Oriya} \p{Runic} \p{Sinhala} \p{Syriac}
#   \p{Tagalog} \p{Tagbanwa} \p{TaiLe} \p{Tamil} \p{Telugu} \p{Thaana}
#   \p{Thai} \p{Tibetan} \p{Yi} 
#  ,,,,
#
#UNICODE BLOCKS
#
#  I would like for nom to support all these categories, scripts and 
#  blocks if the target translation language supports them. But in 
#  some cases it may be better for the translator to create 'ascii' 
#  regular expressions for the sake of speed.
#
#  It may be possible to omit underscores?
#
#  * a list of unicode block names
#  --------
#   \p{InBasic_Latin}: U+0000–U+007F
#   \p{InLatin-1_Supplement}: U+0080–U+00FF
#   \p{InLatin_Extended-A}: U+0100–U+017F
#   \p{InLatin_Extended-B}: U+0180–U+024F
#   \p{InIPA_Extensions}: U+0250–U+02AF
#   \p{InSpacing_Modifier_Letters}: U+02B0–U+02FF
#   \p{InCombining_Diacritical_Marks}: U+0300–U+036F
#   \p{InGreek_and_Coptic}: U+0370–U+03FF
#   \p{InCyrillic}: U+0400–U+04FF
#   \p{InCyrillic_Supplementary}: U+0500–U+052F
#   \p{InArmenian}: U+0530–U+058F
#   \p{InHebrew}: U+0590–U+05FF
#   \p{InArabic}: U+0600–U+06FF
#   \p{InSyriac}: U+0700–U+074F
#   \p{InThaana}: U+0780–U+07BF
#   \p{InDevanagari}: U+0900–U+097F
#   \p{InBengali}: U+0980–U+09FF
#   \p{InGurmukhi}: U+0A00–U+0A7F
#   \p{InGujarati}: U+0A80–U+0AFF
#   \p{InOriya}: U+0B00–U+0B7F
#   \p{InTamil}: U+0B80–U+0BFF
#   \p{InTelugu}: U+0C00–U+0C7F
#   \p{InKannada}: U+0C80–U+0CFF
#   \p{InMalayalam}: U+0D00–U+0D7F
#   \p{InSinhala}: U+0D80–U+0DFF
#   \p{InThai}: U+0E00–U+0E7F
#   \p{InLao}: U+0E80–U+0EFF
#   \p{InTibetan}: U+0F00–U+0FFF
#   \p{InMyanmar}: U+1000–U+109F
#   \p{InGeorgian}: U+10A0–U+10FF
#   \p{InHangul_Jamo}: U+1100–U+11FF
#   \p{InEthiopic}: U+1200–U+137F
#   \p{InCherokee}: U+13A0–U+13FF
#   \p{InUnified_Canadian_Aboriginal_Syllabics}: U+1400–U+167F
#   \p{InOgham}: U+1680–U+169F
#   \p{InRunic}: U+16A0–U+16FF
#   \p{InTagalog}: U+1700–U+171F
#   \p{InHanunoo}: U+1720–U+173F
#   \p{InBuhid}: U+1740–U+175F
#   \p{InTagbanwa}: U+1760–U+177F
#   \p{InKhmer}: U+1780–U+17FF
#   \p{InMongolian}: U+1800–U+18AF
#   \p{InLimbu}: U+1900–U+194F
#   \p{InTai_Le}: U+1950–U+197F
#   \p{InKhmer_Symbols}: U+19E0–U+19FF
#   \p{InPhonetic_Extensions}: U+1D00–U+1D7F
#   \p{InLatin_Extended_Additional}: U+1E00–U+1EFF
#   \p{InGreek_Extended}: U+1F00–U+1FFF
#   \p{InGeneral_Punctuation}: U+2000–U+206F
#   \p{InSuperscripts_and_Subscripts}: U+2070–U+209F
#   \p{InCurrency_Symbols}: U+20A0–U+20CF
#   \p{InCombining_Diacritical_Marks_for_Symbols}: U+20D0–U+20FF
#   \p{InLetterlike_Symbols}: U+2100–U+214F
#   \p{InNumber_Forms}: U+2150–U+218F
#   \p{InArrows}: U+2190–U+21FF
#   \p{InMathematical_Operators}: U+2200–U+22FF
#   \p{InMiscellaneous_Technical}: U+2300–U+23FF
#   \p{InControl_Pictures}: U+2400–U+243F
#   \p{InOptical_Character_Recognition}: U+2440–U+245F
#   \p{InEnclosed_Alphanumerics}: U+2460–U+24FF
#   \p{InBox_Drawing}: U+2500–U+257F
#   \p{InBlock_Elements}: U+2580–U+259F
#   \p{InGeometric_Shapes}: U+25A0–U+25FF
#   \p{InMiscellaneous_Symbols}: U+2600–U+26FF
#   \p{InDingbats}: U+2700–U+27BF
#   \p{InMiscellaneous_Mathematical_Symbols-A}: U+27C0–U+27EF
#   \p{InSupplemental_Arrows-A}: U+27F0–U+27FF
#   \p{InBraille_Patterns}: U+2800–U+28FF
#   \p{InSupplemental_Arrows-B}: U+2900–U+297F
#   \p{InMiscellaneous_Mathematical_Symbols-B}: U+2980–U+29FF
#   \p{InSupplemental_Mathematical_Operators}: U+2A00–U+2AFF
#   \p{InMiscellaneous_Symbols_and_Arrows}: U+2B00–U+2BFF
#   \p{InCJK_Radicals_Supplement}: U+2E80–U+2EFF
#   \p{InKangxi_Radicals}: U+2F00–U+2FDF
#   \p{InIdeographic_Description_Characters}: U+2FF0–U+2FFF
#   \p{InCJK_Symbols_and_Punctuation}: U+3000–U+303F
#   \p{InHiragana}: U+3040–U+309F
#   \p{InKatakana}: U+30A0–U+30FF
#   \p{InBopomofo}: U+3100–U+312F
#   \p{InHangul_Compatibility_Jamo}: U+3130–U+318F
#   \p{InKanbun}: U+3190–U+319F
#   \p{InBopomofo_Extended}: U+31A0–U+31BF
#   \p{InKatakana_Phonetic_Extensions}: U+31F0–U+31FF
#   \p{InEnclosed_CJK_Letters_and_Months}: U+3200–U+32FF
#   \p{InCJK_Compatibility}: U+3300–U+33FF
#   \p{InCJK_Unified_Ideographs_Extension_A}: U+3400–U+4DBF
#   \p{InYijing_Hexagram_Symbols}: U+4DC0–U+4DFF
#   \p{InCJK_Unified_Ideographs}: U+4E00–U+9FFF
#   \p{InYi_Syllables}: U+A000–U+A48F
#   \p{InYi_Radicals}: U+A490–U+A4CF
#   \p{InHangul_Syllables}: U+AC00–U+D7AF
#   \p{InHigh_Surrogates}: U+D800–U+DB7F
#   \p{InHigh_Private_Use_Surrogates}: U+DB80–U+DBFF
#   \p{InLow_Surrogates}: U+DC00–U+DFFF
#   \p{InPrivate_Use_Area}: U+E000–U+F8FF
#   \p{InCJK_Compatibility_Ideographs}: U+F900–U+FAFF
#   \p{InAlphabetic_Presentation_Forms}: U+FB00–U+FB4F
#   \p{InArabic_Presentation_Forms-A}: U+FB50–U+FDFF
#   \p{InVariation_Selectors}: U+FE00–U+FE0F
#   \p{InCombining_Half_Marks}: U+FE20–U+FE2F
#   \p{InCJK_Compatibility_Forms}: U+FE30–U+FE4F
#   \p{InSmall_Form_Variants}: U+FE50–U+FE6F
#   \p{InArabic_Presentation_Forms-B}: U+FE70–U+FEFF
#   \p{InHalfwidth_and_Fullwidth_Forms}: U+FF00–U+FFEF
#   \p{InSpecials}: U+FFF0–U+FFFF
#  ,,,,,
#
#LUA REGEXP SYNTAX
#
#  https://perldoc.perl.org/perlrecharclass#Extended-Bracketed-Character-Classes
#    A link for categories in Perl
#
#  Does lua support these? Are they unicode aware?
#
#  * digit, word, space and inverses, 
#  >> \d, \w, \s, \D, \W, \S, .
#  - \w = [:alnum:]
#  - \d = [:digit:] 
#  - \s = [:space:]  (including newline)
#  
#  All the characters below need to be escaped in while/whilenot 
#  and class tests, no? Not sure because in [] you dont have to 
#  escape so many chars
#
#  * special regex chars.
#  >> \, ^, $, ?, *, +, <, >, [, ], {, }, ..
#
#  If the unicode property name is wrong will lua throw exception? 
#
#LUA SYNTAX
#
#  https://www.lua.org/pil/21.2.html
#    docs about io using streams and io.stdin io.stdout which are
#    predefined file handles as below
#
# use assert () or 
# >> n = io.read("*number")
# >> if not n then error("message") end
#
# At end of file nil is returned as well
#
# * read a file as stream in lua
# -----
#   function read_array(file)
#     local arr = {}
#     local handle  = assert( io.open(file,"r") )
#     local value = handle:read("*number")
#     -- or local value = handle:read("*line")
#     -- or local value = handle:read() -- default line
#     while value do
#       table.insert( arr, value )
#       value = handle:read("*number")
#     end
#     handle:close()
#     return arr
#   end
# ,,,,
# 
#  lua has no labelled loops but does have goto
#  >> goto label
#
#  * a label in lua
#  >> ::label::
#
#  * create a class and object in lua
#  -----
#   Account = {balance = 0}
#    
#    function Account:new (o)
#      o = o or {}
#      setmetatable(o, self)
#      self.__index = self
#      return o
#    end
#    
#    function Account:deposit (v)
#      self.balance = self.balance + v
#    end
#    
#    function Account:withdraw (v)
#      if v > self.balance then error"insufficient funds" end
#      self.balance = self.balance - v
#    end
#    a = Account:new()
#    a:deposit(100)
#  ,,,,,
#
#  * remove element from list and return list (2 dots, cascade)
#  -----
#  ,,,,
#
#  * get stdin lines
#  ----------
#  ,,,,,
#
#  * remove last 5 chars from string
#  ----
#  ,,,,
#
#  * synchronous read
#  >> 
#
#STATUS
#
#  8 apr 2025
#    just started based on /tr/nom.todart.pss
#DONE
#TODO
#
#TESTING 
#
#  * a shebang line for lua
#  >> #!/usr/bin/env lua
#
#  * run a lua script. chmod is not required 
#  >> lua script.lua
#
#  Using the bash functions in helpers.pars.sh you can do.
#  This will work, not yet
#
#  * compile an inline nom script to lua and display
#  >> pep.los ' r;t;t;d;'  
#
#  * compile an inline nom script to lua and run with input
#  >> pep.los ' r;t;t;d;' 'abcd'   
#
#  * test with the mini scripts in /tr/translate.test.txt 
#  >> pep.tt lua 
#
#  * test but start at swap tests 
#  >> pep.tt lua blah '# swap'
#
#TOKENS 
#
# This token list is pretty useful for thinking about 
# sequences of tokens. Especially for error sequences.
#
#  Literal BE!<>{}(),.;
#  quoted*  text between "" or ''.  I will put "" around this and escape
#           all " at the time of tokenising. This is because I want \n \r
#           etc to work within strings. But it means I have to be careful
#           about other escape sequences. like $ etc. 
#  class*   eg [:space:] [abcd] [a-z] 
#  word*    eg: eof,reparse,==
#  begin*   the begin word
#  parselabel* 
#  command* eg: add clear print 
#  test*    eg: "x" [:space:] !B"a" B"a" E"a" !E"a"
#  ortest*  test*,*test*
#  andtest*  test*.*test*
#  statement* eg: clear; add "xx"; or "test" { ... }
#  statementset* a list of statements 
#  script*
#
#HISTORY
#
#  7 april 2025
#    started
#
#
read
# sort-of line-relative character numbers 
testclass [\n]
jumpfalse block.end.14239
  nochars
block.end.14239:
# ignore space except in quotes. but be careful about silent
# exit on read at eof
testclass [:space:]
jumpfalse block.end.14397
  clear
  testeof 
  jumpfalse block.end.14372
    jump parse
  block.end.14372:
  testeof 
  jumptrue block.end.14392
    jump start
  block.end.14392:
block.end.14397:
# literal tokens, for readability maybe 'dot*' and 'comma*'
testclass [<>}()!BE,.;]
jumpfalse block.end.14509
  put
  add "*"
  push
  jump parse
block.end.14509:
testclass [{]
jumpfalse block.end.14693
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
block.end.14693:
# parse (eof) etc as tokens? yes
# command names, need to do some tricks to parse ++ -- a+ etc
# here. This is because [:alpha:],[+-] etc is not a union set
# and while cannot do "while [:alpha:],[+-] etc
# subtle bug, [+-^0=] parses as a range!!! [a-z]
testclass [:alpha:]
jumptrue 4
testclass [-+^0=]
jumptrue 2 
jump block.end.19300
  # a much more succint abbreviation code
  testis "0"
  jumpfalse block.end.15058
    clear
    add "zero"
  block.end.15058:
  testis "^"
  jumpfalse block.end.15091
    clear
    add "escape"
  block.end.15091:
  # increment tape pointer ++ command
  testis "+"
  jumpfalse block.end.15154
    while [+]
  block.end.15154:
  # decrement tape pointer -- command
  testis "-"
  jumpfalse block.end.15217
    while [-]
  block.end.15217:
  # tape test (==)
  testis "="
  jumpfalse block.end.15261
    while [=]
  block.end.15261:
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
  jump block.end.15413
    while [:alpha:]
  block.end.15413:
  # parse a+ or a- for the accumulator
  testis "a"
  jumpfalse block.end.15637
    # while [+-] is bug because compile.pss thinks its a range class
    # not a list class
    while [-+]
    testis "a+"
    jumptrue 4
    testis "a-"
    jumptrue 2 
    jump block.end.15599
      put
    block.end.15599:
    testis "a"
    jumpfalse block.end.15631
      clear
      add "add"
    block.end.15631:
  block.end.15637:
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
  jump block.end.17069
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
  block.end.17069:
  testis "+"
  jumptrue 4
  testis "-"
  jumptrue 2 
  jump block.end.17355
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
  block.end.17355:
  # writefile is also a command?
  # commands parsed above
  testis "a+"
  jumptrue 82
  testis "a-"
  jumptrue 80
  testis "zero"
  jumptrue 78
  testis "escape"
  jumptrue 76
  testis "++"
  jumptrue 74
  testis "--"
  jumptrue 72
  testis "add"
  jumptrue 70
  testis "clip"
  jumptrue 68
  testis "clop"
  jumptrue 66
  testis "replace"
  jumptrue 64
  testis "upper"
  jumptrue 62
  testis "lower"
  jumptrue 60
  testis "cap"
  jumptrue 58
  testis "clear"
  jumptrue 56
  testis "print"
  jumptrue 54
  testis "state"
  jumptrue 52
  testis "pop"
  jumptrue 50
  testis "push"
  jumptrue 48
  testis "unstack"
  jumptrue 46
  testis "stack"
  jumptrue 44
  testis "put"
  jumptrue 42
  testis "get"
  jumptrue 40
  testis "swap"
  jumptrue 38
  testis "mark"
  jumptrue 36
  testis "go"
  jumptrue 34
  testis "read"
  jumptrue 32
  testis "until"
  jumptrue 30
  testis "while"
  jumptrue 28
  testis "whilenot"
  jumptrue 26
  testis "count"
  jumptrue 24
  testis "zero"
  jumptrue 22
  testis "chars"
  jumptrue 20
  testis "lines"
  jumptrue 18
  testis "nochars"
  jumptrue 16
  testis "nolines"
  jumptrue 14
  testis "escape"
  jumptrue 12
  testis "unescape"
  jumptrue 10
  testis "delim"
  jumptrue 8
  testis "quit"
  jumptrue 6
  testis "write"
  jumptrue 4
  testis "nop"
  jumptrue 2 
  jump block.end.17809
    clear
    add "command*"
    push
    jump parse
  block.end.17809:
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
  jump block.end.17958
    put
    clear
    add "word*"
    push
    jump parse
  block.end.17958:
  testis "begin"
  jumpfalse block.end.18004
    put
    add "*"
    push
    jump parse
  block.end.18004:
  # lower case and check for command with error
  lower
  testis "add"
  jumptrue 88
  testis "clip"
  jumptrue 86
  testis "clop"
  jumptrue 84
  testis "replace"
  jumptrue 82
  testis "upper"
  jumptrue 80
  testis "lower"
  jumptrue 78
  testis "cap"
  jumptrue 76
  testis "clear"
  jumptrue 74
  testis "print"
  jumptrue 72
  testis "state"
  jumptrue 70
  testis "pop"
  jumptrue 68
  testis "push"
  jumptrue 66
  testis "unstack"
  jumptrue 64
  testis "stack"
  jumptrue 62
  testis "put"
  jumptrue 60
  testis "get"
  jumptrue 58
  testis "swap"
  jumptrue 56
  testis "mark"
  jumptrue 54
  testis "go"
  jumptrue 52
  testis "read"
  jumptrue 50
  testis "until"
  jumptrue 48
  testis "while"
  jumptrue 46
  testis "whilenot"
  jumptrue 44
  testis "count"
  jumptrue 42
  testis "zero"
  jumptrue 40
  testis "chars"
  jumptrue 38
  testis "lines"
  jumptrue 36
  testis "nochars"
  jumptrue 34
  testis "nolines"
  jumptrue 32
  testis "escape"
  jumptrue 30
  testis "unescape"
  jumptrue 28
  testis "delim"
  jumptrue 26
  testis "quit"
  jumptrue 24
  testis "write"
  jumptrue 22
  testis "zero"
  jumptrue 20
  testis "++"
  jumptrue 18
  testis "--"
  jumptrue 16
  testis "a+"
  jumptrue 14
  testis "a-"
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
  jump block.end.18748
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
  block.end.18748:
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
block.end.19300:
# single line comments
# no need to rethink
testis "#"
jumpfalse block.end.19985
  testeof 
  jumpfalse block.end.19387
    clear
    jump parse
  block.end.19387:
  read
  # just delete empty comments
  testclass [#\n]
  jumpfalse block.end.19461
    clear
    jump parse
  block.end.19461:
  # multiline comments this needs to go within '#'
  testis "#*"
  jumpfalse block.end.19907
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
    jumptrue block.end.19833
      clear
      add "* unterminated multiline comment #*... \n  starting at "
      get
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.19833:
    clip
    clip
    put
    clear
    add "comment*"
    push
    jump parse
  block.end.19907:
  clear
  whilenot [\n]
  put
  clear
  add "comment*"
  push
  jump parse
block.end.19985:
# quoted text 
# I will double quote all text and escape $ and \\ 
# double quotes and single quotes are the same in dart, no 
# difference.
testis "\""
jumpfalse block.end.20802
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
  jump block.end.20501
    clear
    add "* unterminated quote (\") or incomplete command starting at "
    get
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.20501:
  # empty quotes are checked later. must escape \\ first 
  clip
  unescape "\""
  # bug! in object/machine.methods.c escape will reescape chars
  # fix
  # escape "\\"; 
  escape "\""
  escape "$"
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
block.end.20802:
# single quotes
testis "'"
jumpfalse block.end.21342
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
  jump block.end.21126
    clear
    add "* unterminated quote (\') or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.21126:
  # empty quotes are checked later . must escape "\\" first 
  clip
  unescape "'"
  escape "\\"
  escape "\""
  escape "$"
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
block.end.21342:
# classes like [:space:] or [abc] or [a-z] 
# these are used in tests and also in while/whilenot
# The *until* command will read past 'escaped' end characters eg \]
# 
testis "["
jumpfalse block.end.29533
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
  jump block.end.21870
    clear
    add "* unterminated class [...] or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.21870:
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
  jump block.end.28663
    # see this for unicode categories in dart and regexp.
    # https://stackoverflow.com/questions/15531928/matching-unicode-letters-with-regexp
    clip
    clop
    put
    # no, no abbreviations, Unicode categories already have many
    # abbreviations, I will use those. I will accept any unicode
    # script/block/category. There are a lot.
    # these are ctype classes which I include for historical reasons.
    # but these will be translated to a unicode equivalent.
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
    jump block.end.23305
      # ascii graph print? todo
      replace "alpha" "\\p{Letter}"
      replace "upper" "\\p{Uppercase_Letter}"
      replace "lower" "\\p{Lowercase_Letter}"
      replace "alnum" "[\\p{Letter}\\p{Number}]"
      replace "space" "\\s"
      # replace "space" "\\p{Separator}"; 
      # separator doesn't match \\n?
      # replace "blank" "\\p{Separator}";  # synonym for space?
      replace "blank" "\\s"
      replace "xdigit" "[0-9a-fA-F]"
      replace "digit" "\\p{Number}"
      # fix: check definition of graph
      replace "graph" "\\S"
      replace "punct" "\\p{Punctuation}"
      replace "cntrl" "\\p{Control}"
      # ascii/latin1 control
      put
      clear
      add "class*"
      push
      jump parse
    block.end.23305:
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
    jump block.end.24584
      put
      clear
      add "\\p{"
      get
      add "}"
      put
      clear
      add "class*"
      push
      jump parse
    block.end.24584:
    # unicode script names
    # If the name is wrong dart will throw exception
    # Unhandled exception:
    #  FormatException: Invalid property name\p{Script=InBasic_Latin}
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
    jump block.end.25380
      clear
      add "\\p{Script="
      get
      add "}"
      put
      clear
      add "class*"
      push
      jump parse
    block.end.25380:
    # blocks
    # unicode block names. These don't seem supported in dart 
    # unicode regular expressions.
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
    jump block.end.28306
      add ":\n"
      add "           Dart apparently does not support unicode block names in \n"
      add "           regular expressions. But it does support script names\n"
      add "           (eg Greek, Gujarati, Han) and property names. Try to use a \n"
      add "           script name instead. "
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.28306:
    clear
    add "* Incorrect unicode character class, category or script name\n"
    add " \n"
    add "      Character classes are used in tests and the nom while \n"
    add "      and whilenot commands\n"
    add "        eg: [:space:] { while [:space:]; clear; } \n"
    add "        or: [:Greek:] { while [:Greek:]; clear; } \n"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.28663:
  # I am just passing classes through to the dart RegExp engine? no.
  # but should escape special chars?
  # \, ^, $, ?, *, +, <, >, [, ], {, }, ..
  # restore brackets and escape
  # escape '\\';  ??? yes or no
  escape "^"
  escape "$"
  escape "?"
  escape "*"
  escape "+"
  # throwing an error because you dont have to escape it.
  # escape '<'; escape '>'; 
  escape "["
  # escape '&'; escape '|';
  # reserved chars
  # (, ), [, ], {, }, *, +, ?, ., ^, $, | and \.
  # I think there is a bug in the pep interp, it doesn't 
  # count escape chars. fix:
  # escape ']';
  escape "."
  escape "{"
  escape "}"
  put
  clear
  add "["
  get
  add "]"
  put
  # use the dart regexp escape method but need to compose the string
  # clear; add "[RegExp.escape("; get; add ")]"; put;
  clear
  add "class*"
  push
  jump parse
block.end.29533:
testis ""
jumptrue block.end.29747
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
block.end.29747:
parse:
# watch the parse-stack resolve.  
# add "--> line "; lines; add " char "; chars; add ": "; print; clear; 
# unstack; print; stack; add "\n"; print; clear;
# ----------------
# error trapping and help here
pop
# parse help token for a topic, category of # topics or everthing. 
testis "nom.help*"
jumpfalse block.end.33315
  # the topic or category to display help for is in the attribute
  clear
  swap
  # a short list of commands and abbreviations 
  testis "commands.shortlist"
  jumptrue 6
  testis "commands"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.30735
    swap
    add "\n"
    add "      # 'D' doesn't actually work in compile.pss !\n"
    add "      nom abbreviations and commands: \n"
    add "\n"
    add "        zero k clip K clop D replace d clear\n"
    add "        t print p pop P push u unstack U stack G put g get x swap\n"
    add "        m mark M go r read R until w while W whilenot n count c chars C nochars \n"
    add "        l lines L nolines v escape unescape z delim S state q quit s write\n"
    add "        o nop .rs .restart .rp .reparse\n"
    add "        (no abbreviations)\n"
    add "        a+ a- ++ --\n"
    add "\n"
    add "          "
  block.end.30735:
  # specific help for the add command 
  testis "command.add"
  jumptrue 6
  testis "commands"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.31137
    swap
    add "\n"
    add "      add command:\n"
    add "        add text to end of the workspace buffer\n"
    add "        see: nomlang.org/doc/commands/nom.add.html\n"
    add "      eg:\n"
    add "        add ':tag:';     # correct\n"
    add "        add [:space:];   # incorrect, cannot have class parameter \n"
    add "        add;             # incorrect, missing parameter\n"
    add "          "
  block.end.31137:
  #  
  testis "semicolon"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.31496
    swap
    add "\n"
    add "       semicolon:\n"
    add "         All statements (commands) must end with a semi-colon \n"
    add "         except .reparse and .restart (even the last command in\n"
    add "         the block)\n"
    add "       eg:\n"
    add "         clear; .reparse       # correct\n"
    add "         clear add '.';        # incorrect, clear needs ; \n"
    add "         "
  block.end.31496:
  # 'brackets' is topic, 'punctuation' is a category, 'all' is everthing 
  testis "brackets"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.31906
    swap
    add "\n"
    add "      brackets () \n"
    add "        are used for tests like (eof) (EOF) (==) \n"
    add "        currently (2025) brackets are not used for logical grouping in \n"
    add "        tests.\n"
    add "      examples:\n"
    add "         (==)                  # correct\n"
    add "         (==,'abc' { nop; }    # incorrect: unbalanced "
  block.end.31906:
  testis "negation"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.32403
    swap
    add "\n"
    add "      negation operator ! \n"
    add "        is used for negating class and equals tests and with the \n"
    add "        B and E modifiers. It should precede the test and the \n"
    add "        B and E modifiers.\n"
    add "\n"
    add "      examples:\n"
    add "         !(eof) { add '.'; }   # correct, not at end-of-file\n"
    add "         ![:space:] { clear; } # correct \n"
    add "         'abc'! { clear; }     # incorrect: ! must precede test.\n"
    add "         B!'abc' { clear; }    # incorrect: ! must precede 'B'  "
  block.end.32403:
  # 
  testis "modifiers"
  jumptrue 6
  testis "tests"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.32751
    swap
    add "\n"
    add "      begins-with 'B' and ends-with 'E' modifiers:\n"
    add "        are used with quoted text tests and cannot be used with \n"
    add "        class tests.\n"
    add "      eg: \n"
    add "        B'abc' { clear; }        # correct \n"
    add "        E\"abc\" { clear; }      # correct \n"
    add "        B[:alpha:] { clear; }  # incorrect  "
  block.end.32751:
  # help for the help system 
  testis "help"
  jumptrue 6
  testis "help"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.33163
    swap
    add "\n"
    add "        help system:\n"
    add "          categories: tests, commands, punctuation etc\n"
    add "          type '#:help <command>' in a [nom] script to get help\n"
    add "          for a particular command or word or category\n"
    add "        eg:\n"
    add "          #:help add    # shows help for the add command\n"
    add "          #:help tests  # shows help nom block tests.\n"
    add "        "
  block.end.33163:
  # This help system quits after showing the help message
  # but you could keep parsing if there is any point. 
  add "\n\n"
  print
  quit
block.end.33315:
testis "nom.error*"
jumpfalse block.end.33807
  # get the parse stack here as well
  clear
  add "! Nom syntax:"
  add " near line:"
  ll
  add " char:"
  cc
  add "\n"
  get
  add "\n run /eg/nom.syntax.reference.pss for more detailed \n"
  add " syntax checking. See www.nomlang.org/doc for complete-ish \n"
  add " pep and nom documentation. \n"
  print
  # provide help from the help* token if one was put on the stack. 
  clear
  pop
  testis "nom.help*"
  jumpfalse block.end.33792
    push
    jump parse
  block.end.33792:
  quit
block.end.33807:
# this error is when the error should have been trapped earlier
testis "nom.untrapped.error*"
jumpfalse block.end.34142
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
block.end.34142:
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
jump block.end.34667
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
block.end.34667:
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
jump block.end.34878
  clear
  add "* misplaced } or ; or > or ) character?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.34878:
testbegins "B*"
jumptrue 4
testbegins "E*"
jumptrue 2 
jump block.end.35163
  testends "!*"
  jumpfalse block.end.35159
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
  block.end.35159:
block.end.35163:
testbegins "B*"
jumpfalse 5
testis "B*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.35370
  clear
  add "* misplaced begin-test modifier 'B' ?"
  add "  eg: B'##' { d; add 'heading*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.35370:
testbegins "E*"
jumpfalse 5
testis "E*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.35573
  clear
  add "* misplaced end-test modifier 'E' ?"
  add "  eg: E'.' { d; add 'phrase*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.35573:
# empty quote after B or E
testbegins "E*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.35869
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.35836
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
  block.end.35836:
  clear
  add "E*quoted*"
block.end.35869:
testbegins "B*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.36136
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.36103
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
  block.end.36103:
  clear
  add "B*quoted*"
block.end.36136:
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
jump block.end.36497
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
block.end.36497:
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
jump block.end.36723
  clear
  add "* misplaced comma ?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.36723:
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
jump block.end.36921
  clear
  add "* misplaced dot?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.36921:
# error eg: {}
testbegins "{*"
jumpfalse 3
testends "}*"
jumptrue 2 
jump block.end.37044
  clear
  add "* empty block {} "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.37044:
# error eg: { ,
testbegins "{*"
jumpfalse 3
testis "{*"
jumpfalse 2 
jump block.end.37252
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
  jump block.end.37248
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
  block.end.37248:
block.end.37252:
# try to diagnose missing close brace errors at end of script
# eg ortest*{*statement*
# we probably need a line/char number in the tape cell
testeof 
jumpfalse block.end.37708
  testis "{*statement*"
  jumptrue 4
  testis "{*statementset*"
  jumptrue 2 
  jump block.end.37704
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
  block.end.37704:
block.end.37708:
# missing dot
# error eg: clear; reparse 
testbegins ".*"
jumptrue 5
testends "word*"
jumpfalse 3
testis "word*"
jumpfalse 2 
jump block.end.37982
  push
  push
  --
  get
  ++
  testis "reparse"
  jumptrue 4
  testis "restart"
  jumptrue 2 
  jump block.end.37957
    clear
    add "* missing dot before reparse/restart ? "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.37957:
  clear
  pop
  pop
block.end.37982:
# error eg: ( add
# currently brackets are only used for tests
testbegins "(*"
jumpfalse 5
testis "(*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.38175
  clear
  add "* strange syntax after '(' "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38175:
testis "<*;*"
jumpfalse block.end.38381
  clear
  add "* '<' used to be an abbreviation for '--' \n"
  add "* but no-longer (mar 2025) since it clashes with <eof> etc "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38381:
# error eg: < add
# currently angle brackets are only used for tests ( <eof> <==> ) 
testbegins "<*"
jumpfalse 5
testis "<*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.38587
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38587:
testis ">*;*"
jumpfalse block.end.38795
  clear
  add "* '>' used to be an abbreviation for '++' \n"
  add "  but no-longer (mar 2025) since it clashes with <eof> etc \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.38795:
# error eg: begin add
testbegins "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.39011
  clear
  add "* begin is always followed by a brace.\n"
  add "   eg: begin { delim '/'; }\n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.39011:
# error eg: clear; begin { clear; }
testends "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testbegins "comment*"
jumpfalse 2 
jump block.end.39201
  clear
  add "* only comments can precede a begin block."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.39201:
testis "command*}*"
jumpfalse block.end.39525
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
block.end.39525:
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
jump block.end.39699
  clear
  add "* bad command syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.39699:
# specific analysis of the token sequences permitted above
testis "command*class*"
jumpfalse block.end.40074
  clear
  get
  testis "while"
  jumptrue 3
  testis "whilenot"
  jumpfalse 2 
  jump block.end.40037
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
  block.end.40037:
  clear
  add "command*class*"
block.end.40074:
testis "command*quoted*"
jumpfalse block.end.40954
  clear
  get
  testis "add"
  jumptrue 15
  testis "replace"
  jumptrue 13
  testis "mark"
  jumptrue 11
  testis "go"
  jumptrue 9
  testis "until"
  jumptrue 7
  testis "delim"
  jumptrue 5
  testis "escape"
  jumptrue 3
  testis "unescape"
  jumpfalse 2 
  jump block.end.40439
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
  block.end.40439:
  # check that not empty argument.
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.40916
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
  block.end.40916:
  clear
  add "command*quoted*"
block.end.40954:
testis "command*;*"
jumpfalse block.end.41282
  clear
  get
  testis "add"
  jumptrue 14
  testis "replace"
  jumptrue 12
  testis "while"
  jumptrue 10
  testis "whilenot"
  jumptrue 8
  testis "delim"
  jumptrue 6
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.41249
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
  block.end.41249:
  clear
  add "command*;*"
block.end.41282:
# end-of-script 2 token command errors.
testeof 
jumpfalse block.end.41686
  testends "command*"
  jumpfalse block.end.41494
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.41494:
  testis "command*quoted*"
  jumptrue 4
  testis "command*class*"
  jumptrue 2 
  jump block.end.41682
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.41682:
block.end.41686:
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
jump block.end.41913
  clear
  add " dubious syntax (eg: missing semicolon ';') after quoted text."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.41913:
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
jump block.end.42166
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
block.end.42166:
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
jump block.end.42390
  clear
  add "* bad syntax after word."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42390:
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
jump block.end.42546
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42546:
# error "xx","yy"."zz"
testbegins "ortest*"
jumpfalse 5
testis "ortest*"
jumptrue 3
testends ".*"
jumptrue 2 
jump block.end.42706
  clear
  add "* AND '.' operator in OR test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42706:
# error eg: "aa" "abc";
testis "ortest*quoted*"
jumptrue 4
testis "ortest*test*"
jumptrue 2 
jump block.end.42865
  clear
  add "* missing comma in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.42865:
# error eg: "aa",E"abc";
testbegins "ortest*"
jumpfalse 7
testis "ortest*"
jumptrue 5
testends ",*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.43026
  clear
  add "* bad OR test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.43026:
# error "xx"."yy","zz"
testbegins "andtest*"
jumpfalse 5
testis "andtest*"
jumptrue 3
testends ",*"
jumptrue 2 
jump block.end.43188
  clear
  add "* OR ',' operator in AND test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.43188:
# error eg: "aa".E"abc";
testis "andtest*quoted*"
jumptrue 4
testis "andtest*test*"
jumptrue 2 
jump block.end.43348
  clear
  add "* missing dot in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.43348:
# error eg: "aa".E"abc";
testbegins "andtest*"
jumpfalse 7
testis "andtest*"
jumptrue 5
testends ".*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.43512
  clear
  add "* bad AND test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.43512:
# end-of-script 2 token test errors.
testeof 
jumpfalse block.end.43762
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
  jump block.end.43758
    clear
    add "* test with no block {} at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.43758:
block.end.43762:
# error eg: add 'x'; { 
testbegins "statement*"
jumpfalse 3
testis "statement*"
jumpfalse 2 
jump block.end.43950
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.43946
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.43946:
block.end.43950:
# error eg: clear;add 'x'; { 
testbegins "statementset*"
jumpfalse 3
testis "statementset*"
jumpfalse 2 
jump block.end.44150
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.44146
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.44146:
block.end.44150:
# specific command errors
# until, mark, go etc have no-parameter versions
testis "command*;*"
jumpfalse block.end.44487
  clear
  get
  testis "add"
  jumptrue 14
  testis "replace"
  jumptrue 12
  testis "while"
  jumptrue 10
  testis "whilenot"
  jumptrue 8
  testis "delim"
  jumptrue 6
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.44454
    clear
    add "* command '"
    get
    add "' requires argument"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.44454:
  clear
  add "command*;*"
block.end.44487:
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
jump block.end.44845
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
block.end.44845:
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
jump block.end.45088
  clear
  add "* missing semi-colon after statement? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.45088:
# error eg: "cd" "ef" {
testbegins "quoted*quoted*"
jumpfalse 3
testends ";*"
jumpfalse 2 
jump block.end.45248
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.45248:
# error eg: , "cd" "ef"
testends "quoted*quoted*"
jumpfalse 3
testbegins "command*"
jumpfalse 2 
jump block.end.45414
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.45414:
testis "command*quoted*quoted*"
jumpfalse block.end.45745
  clear
  get
  testis "replace"
  jumptrue block.end.45700
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
  block.end.45700:
  clear
  add "command*quoted*quoted*"
block.end.45745:
# error eg: clear "x"; already checked above.
# "command*quoted*;*" {}
# error eg: add [:space:] already checked above in 2 tokens
# "command*class*;*" {}
#----------------
# 4 parse token errors
pop
testis "command*quoted*quoted*;*"
jumpfalse block.end.46400
  clear
  get
  testis "replace"
  jumptrue block.end.46157
    clear
    add "* command '"
    get
    add "' does not take 2 arguments."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.46157:
  # check that not 1st argument is empty
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.46353
    clear
    add "* empty quoted text '' is an error here."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.46353:
  clear
  add "command*quoted*quoted*;*"
block.end.46400:
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
jump block.end.46733
  # A translator would try to conserve the comment.
  replace "comment*" ""
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.46733:
testends "comment*"
jumpfalse 3
testis "comment*"
jumpfalse 2 
jump block.end.46808
  replace "comment*" ""
  push
  jump parse
block.end.46808:
#------------ 
# The .restart command jumps to the first instruction after the
# begin block (if there is a begin block), or the first instruction
# of the script.
testis ".*word*"
jumpfalse block.end.47567
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.47131
    clear
    add "continue script;"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.47131:
  testis "reparse"
  jumpfalse block.end.47464
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.47355
      clear
      add "break lex;"
    block.end.47355:
    testis "1"
    jumpfalse block.end.47399
      clear
      add "continue parse;"
    block.end.47399:
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.47464:
  clear
  add "* invalid statement ."
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.47567:
testis "word*>*"
jumpfalse block.end.47979
  clear
  get
  testis "parse"
  jumpfalse block.end.47949
    clear
    count
    testis "0"
    jumptrue block.end.47794
      clear
      add "script error:\n"
      add "  extra parse> label at line "
      ll
      add ".\n"
      print
      quit
    block.end.47794:
    clear
    add "--> parse>"
    put
    clear
    add "parselabel*"
    push
    # use accumulator to indicate after parse> label
    a+
    jump parse
  block.end.47949:
  clear
  add "word*>*"
block.end.47979:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
# eg: E"abc" { ... }
testis "E*quoted*"
jumpfalse block.end.48301
  clear
  add "self.work.endsWith("
  ++
  get
  --
  add ")"
  put
  clear
  add "test*"
  push
  jump parse
block.end.48301:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quoted*"
jumpfalse block.end.48639
  clear
  add "self.work.startsWith("
  ++
  get
  --
  add ")"
  put
  clear
  add "test*"
  push
  jump parse
block.end.48639:
#---------------------------------
# Compiling comments so as to transfer them to the dart code
testis "comment*statement*"
jumptrue 6
testis "statement*comment*"
jumptrue 4
testis "statementset*comment*"
jumptrue 2 
jump block.end.48901
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
block.end.48901:
testis "comment*comment*"
jumpfalse block.end.49014
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
block.end.49014:
# -----------------------
# negated tokens.
#  This format is used to indicate a negative test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
testis "!*test*"
jumpfalse block.end.49360
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
block.end.49360:
# transform quotes and classses to tests, this greatly reduces the number
# of rules required for other reductions
testis ",*quoted*"
jumptrue 6
testis ".*quoted*"
jumptrue 4
testis "!*quoted*"
jumptrue 2 
jump block.end.49612
  push
  clear
  add "self.work == "
  get
  put
  clear
  add "test*"
  push
  jump parse
block.end.49612:
# transform quotes to tests
testis "quoted*,*"
jumptrue 6
testis "quoted*.*"
jumptrue 4
testis "quoted*{*"
jumptrue 2 
jump block.end.49803
  replace "quoted*" "test*"
  push
  push
  --
  --
  add "self.work == "
  get
  put
  ++
  ++
  clear
  jump parse
block.end.49803:
# transform classes to tests, all characters in the workspace need
# to match the (unicode) class, category or unicode script name for the 
# class test to return true. This is why I add r'^' and '+$' to the 
# regexp. Also, an empty workspace cannot match.
testis ",*class*"
jumptrue 6
testis ".*class*"
jumptrue 4
testis "!*class*"
jumptrue 2 
jump block.end.50252
  push
  clear
  add "RegExp(r'^"
  get
  add "+$', unicode:true).hasMatch(self.work)"
  put
  clear
  add "test*"
  push
  jump parse
block.end.50252:
# transform classes to tests
testis "class*,*"
jumptrue 6
testis "class*.*"
jumptrue 4
testis "class*{*"
jumptrue 2 
jump block.end.50498
  replace "class*" "test*"
  push
  push
  --
  --
  add "RegExp(r'^"
  get
  add "+$', unicode:true).hasMatch(self.work)"
  put
  ++
  ++
  clear
  jump parse
block.end.50498:
#--------------------------------------------
# ebnf: command := command ';' ;
# formats: "pop; push; clear; print; " etc
testis "command*;*"
jumpfalse block.end.54289
  clear
  get
  # error trap here .
  testis "go"
  jumptrue 63
  testis "mark"
  jumptrue 61
  testis "until"
  jumptrue 59
  testis "clip"
  jumptrue 57
  testis "clop"
  jumptrue 55
  testis "clear"
  jumptrue 53
  testis "upper"
  jumptrue 51
  testis "lower"
  jumptrue 49
  testis "cap"
  jumptrue 47
  testis "print"
  jumptrue 45
  testis "pop"
  jumptrue 43
  testis "push"
  jumptrue 41
  testis "unstack"
  jumptrue 39
  testis "stack"
  jumptrue 37
  testis "state"
  jumptrue 35
  testis "put"
  jumptrue 33
  testis "get"
  jumptrue 31
  testis "swap"
  jumptrue 29
  testis "++"
  jumptrue 27
  testis "--"
  jumptrue 25
  testis "read"
  jumptrue 23
  testis "count"
  jumptrue 21
  testis "a+"
  jumptrue 19
  testis "a-"
  jumptrue 17
  testis "zero"
  jumptrue 15
  testis "chars"
  jumptrue 13
  testis "lines"
  jumptrue 11
  testis "nochars"
  jumptrue 9
  testis "nolines"
  jumptrue 7
  testis "quit"
  jumptrue 5
  testis "write"
  jumptrue 3
  testis "nop"
  jumpfalse 2 
  jump block.end.51091
    clear
    add "  incorrect command syntax?"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.51091:
  # go; not implemented in pars/compile.pss yet (feb 2025)
  testis "go"
  jumpfalse block.end.51256
    clear
    add "self.goToMark(self.tape[self.cell]);  -->  go (tape) "
  block.end.51256:
  testis "mark"
  jumpfalse block.end.51360
    clear
    add "self.addMark(self.tape[self.cell]);  --> mark (tape) "
  block.end.51360:
  # the new until; command with no argument
  testis "until"
  jumpfalse block.end.51512
    clear
    add "self:until(self.tape[self.cell]);  --> until (tape) "
  block.end.51512:
  testis "clip"
  jumpfalse block.end.51738
    clear
    # are these length tests really necessary
    #add "if (self.work.isNotEmpty) {  --> clip \n";
    add "self.work ="
    add " self.work.skipLast(1);"
    #add "\n}";
  block.end.51738:
  testis "clop"
  jumpfalse block.end.51891
    clear
    #add "if (self.work.isNotEmpty) {  --> clop \n";
    add "self.work ="
    add " self.work.skip(1);"
  block.end.51891:
  testis "clear"
  jumpfalse block.end.51964
    clear
    add "self.work = '';  --> clear "
  block.end.51964:
  testis "upper"
  jumpfalse block.end.52097
    clear
    add "--> upper  \n"
    add "self.work = "
    add "self.work.toUpperCase();"
  block.end.52097:
  testis "lower"
  jumpfalse block.end.52230
    clear
    add "--> lower  \n"
    add "self.work = "
    add "self.work.toLowerCase();"
  block.end.52230:
  testis "cap"
  jumpfalse block.end.52520
    clear
    # capitalize every word not just the first.
    add "--> cap  \n"
    # ${this[0].toUpperCase()}${substring(1).toLowerCase()}
    add "self.work = '${self.work[0].toUpperCase()}"
    add "${self.work.substring(1).toLowerCase()}';"
  block.end.52520:
  testis "print"
  jumpfalse block.end.52598
    clear
    add "self:write(self.work); --> print "
  block.end.52598:
  testis "pop"
  jumpfalse block.end.52639
    clear
    add "self:pop();"
  block.end.52639:
  testis "push"
  jumpfalse block.end.52682
    clear
    add "self:push();"
  block.end.52682:
  testis "unstack"
  jumpfalse block.end.52750
    clear
    add "while (self:pop());   --> unstack "
  block.end.52750:
  testis "stack"
  jumpfalse block.end.52814
    clear
    add "while(self:push());   --> stack "
  block.end.52814:
  testis "state"
  jumpfalse block.end.52878
    clear
    add "self:printState();    --> state "
  block.end.52878:
  testis "put"
  jumpfalse block.end.52963
    clear
    add "self.tape[self.cell] = self.work; --> put "
  block.end.52963:
  testis "get"
  jumpfalse block.end.53067
    clear
    add "self.work = self.work..self.tape[self.cell]; --> get "
  block.end.53067:
  testis "swap"
  jumpfalse block.end.53120
    clear
    add "self:swap(); --> swap "
  block.end.53120:
  testis "++"
  jumpfalse block.end.53176
    clear
    add "self:increment();   --> ++ "
  block.end.53176:
  testis "--"
  jumpfalse block.end.53266
    clear
    add "if (self.cell > 0) self.cell--; --> -- "
  block.end.53266:
  testis "read"
  jumpfalse block.end.53319
    clear
    add "self:read(); --> read "
  block.end.53319:
  testis "count"
  jumpfalse block.end.53425
    clear
    add "self.work = self.work .. self.accumulator; --> count "
  block.end.53425:
  testis "a+"
  jumpfalse block.end.53501
    clear
    add "self.accumulator = self.accumulator + 1 --> a+ "
  block.end.53501:
  testis "a-"
  jumpfalse block.end.53577
    clear
    add "self.accumulator = self.accumulator - 1 --> a- "
  block.end.53577:
  testis "zero"
  jumpfalse block.end.53639
    clear
    add "self.accumulator = 0; --> zero "
  block.end.53639:
  testis "chars"
  jumpfalse block.end.53735
    clear
    add "self.work = self.work .. self.charsRead --> chars "
  block.end.53735:
  testis "lines"
  jumpfalse block.end.53830
    clear
    add "self.work = self.work .. self.linesRead --> lines "
  block.end.53830:
  testis "nochars"
  jumpfalse block.end.53896
    clear
    add "self.charsRead = 0; --> nochars "
  block.end.53896:
  testis "nolines"
  jumpfalse block.end.53962
    clear
    add "self.linesRead = 0; --> nolines "
  block.end.53962:
  # use a goto to quit script? 
  testis "quit"
  jumpfalse block.end.54069
    clear
    add "os.exit(0); --> quit (or goto ::quit:: ?)"
  block.end.54069:
  testis "write"
  jumpfalse block.end.54131
    clear
    add "self:writeToFile(); --> write "
  block.end.54131:
  # just eliminate since it does nothing.
  testis "nop"
  jumpfalse block.end.54228
    clear
    add "--> nop: does nothing "
  block.end.54228:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.54289:
testis "statementset*statement*"
jumptrue 4
testis "statement*statement*"
jumptrue 2 
jump block.end.54438
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
block.end.54438:
# ----------------
# 3 grammar parse tokens 
pop
testis "(*word*)*"
jumptrue 4
testis "<*word*>*"
jumptrue 2 
jump block.end.54849
  clear
  ++
  get
  --
  testis "eof"
  jumptrue 3
  testis "=="
  jumpfalse 2 
  jump block.end.54680
    clear
    add "* invalid test <> or () ."
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.54680:
  testis "eof"
  jumpfalse block.end.54728
    clear
    add "self.eof"
  block.end.54728:
  testis "=="
  jumpfalse block.end.54800
    clear
    add "self.tape[self.cell] == self.work"
  block.end.54800:
  put
  clear
  add "test*"
  push
  jump parse
block.end.54849:
#--------------------------------------------
# quoted text is already double quoted eg "abc" 
# eg: add "text";
testis "command*quoted*;*"
jumpfalse block.end.56428
  clear
  get
  # error trap here 
  testis "mark"
  jumptrue 13
  testis "go"
  jumptrue 11
  testis "delim"
  jumptrue 9
  testis "add"
  jumptrue 7
  testis "until"
  jumptrue 5
  testis "escape"
  jumptrue 3
  testis "unescape"
  jumpfalse 2 
  jump block.end.55306
    clear
    add "  superfluous argument or other error?\n"
    add "  (error should have been trapped in error block: check)"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.55306:
  testis "mark"
  jumpfalse block.end.55393
    clear
    add "self:addMark("
    ++
    get
    --
    add "); --> mark "
  block.end.55393:
  testis "go"
  jumpfalse block.end.55477
    clear
    add "self:goToMark("
    ++
    get
    --
    add "); --> go "
  block.end.55477:
  testis "delim"
  jumpfalse block.end.55718
    # dart does not have a char type I believe. 
    # only the first character of the delimiter argument should be used. 
    clear
    add "self.delimiter = "
    ++
    get
    --
    add ".characterAt(0); --> delim "
  block.end.55718:
  testis "add"
  jumpfalse block.end.55973
    # use dart raw string? no because I want \n to work in add
    clear
    add "self.work = self.work .. "
    ++
    get
    --
    # handle multiline text
    replace "\n" "\"; \nself.work = self.work .. \"\\n"
    add "; --> add "
  block.end.55973:
  # no while/whilenot "quoted"; syntax
  testis "until"
  jumpfalse block.end.56159
    clear
    add "self:until("
    ++
    get
    --
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
  block.end.56159:
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.56373
    # only use the first char or grapheme cluster of escape argument
    clear
    add "self."
    get
    add "Char"
    add "("
    ++
    get
    --
    add ".characterAt(0));"
  block.end.56373:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.56428:
# eg: while [:alpha:]; or whilenot [a-z];
testis "command*class*;*"
jumpfalse block.end.57234
  clear
  get
  # convert to dart code. 
  testis "while"
  jumpfalse block.end.56831
    clear
    add "--> while \n"
    # unicode syntax
    add "while (RegExp(r'"
    ++
    get
    --
    add "', unicode:true).hasMatch(self.peep)) {\n"
    add "  if (self.eof) { break; } self:read();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.56831:
  testis "whilenot"
  jumpfalse block.end.57106
    clear
    add "--> whilenot  \n"
    add "while (!RegExp(r'"
    ++
    get
    --
    add "', unicode:true).hasMatch(self.peep)) {\n"
    add "  if (self.eof) { break; } self.read();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.57106:
  clear
  add "*** unchecked error in rule: statement = command class ;"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.57234:
# brackets around tests will be ignored.
testis "(*test*)*"
jumpfalse block.end.57366
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.57366:
# brackets will allow mixing AND and OR logic 
testis "(*ortest*)*"
jumptrue 4
testis "(*andtest*)*"
jumptrue 2 
jump block.end.57521
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.57521:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "test*,*test*"
jumptrue 4
testis "ortest*,*test*"
jumptrue 2 
jump block.end.57993
  # OR logic concatenation 
  # put brackets around tests even though operator 
  # precedence should take care of it
  testis "test*,*test*"
  jumpfalse block.end.57857
    clear
    add "("
    get
    add ")"
  block.end.57857:
  testis "ortest*,*test*"
  jumpfalse block.end.57894
    clear
    get
  block.end.57894:
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
block.end.57993:
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
jump block.end.58503
  # AND logic concatenation 
  # add brackets 
  testis "test*.*test*"
  jumpfalse block.end.58365
    clear
    add "("
    get
    add ")"
  block.end.58365:
  testis "andtest*.*test*"
  jumpfalse block.end.58403
    clear
    get
  block.end.58403:
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
block.end.58503:
# dont need to reparse 
testis "{*statement*}*"
jumpfalse block.end.58581
  replace "ment*" "mentset*"
block.end.58581:
# ----------------
# 4 grammar parse tokens 
pop
# see below
# "command*quoted*quoted*;*" { clear; add "statement*"; push; .reparse }
# eg:  replace "and" "AND" ; 
testis "command*quoted*quoted*;*"
jumpfalse block.end.59334
  clear
  get
  testis "replace"
  jumpfalse block.end.59207
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    # multiline replace? no.
    clear
    add "--> replace  \n"
    add "if (self.work != '') { \n"
    add "  self.work = self.work.replaceAll("
    ++
    get
    add ", "
    ++
    get
    add ");\n}"
    --
    --
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.59207:
  # error trap
  clear
  add "  incorrect command syntax?"
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.59334:
# reducing blocks
testis "test*{*statementset*}*"
jumptrue 6
testis "ortest*{*statementset*}*"
jumptrue 4
testis "andtest*{*statementset*}*"
jumptrue 2 
jump block.end.59692
  clear
  # indent the dart code for readability
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
block.end.59692:
testis "begin*{*statementset*}*"
jumpfalse block.end.59817
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
block.end.59817:
# end of input stream errors
testeof 
jumpfalse block.end.60016
  testis "test*"
  jumptrue 8
  testis "ortest*"
  jumptrue 6
  testis "andtest*"
  jumptrue 4
  testis "begin*"
  jumptrue 2 
  jump block.end.60012
    clear
    add "* Incomplete script."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.60012:
block.end.60016:
# cannot be reduced to one push;
push
push
push
push
pop
pop
pop
testeof 
jumpfalse block.end.61052
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  # dart has labelled loops
  testis "statementset*parselabel*statementset*"
  jumpfalse block.end.61048
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
    add "::script::\n"
    add "while true do\n"
    add "  lex: { \n"
    get
    add "\n  } --> lex block \n"
    add "  parse: \n"
    add "  while (true) { \n"
    ++
    ++
    get
    --
    --
    add "\n    break parse;  --> run-once parse loop "
    add "\n  } --> parse block "
    add "\nend --> while true (nom script loop) "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.61048:
block.end.61052:
push
push
push
# this cannot be reduced to 'push;'
pop
pop
testeof 
jumpfalse block.end.62286
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*parselabel*"
  jumpfalse block.end.61712
    clear
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    add "::script::\n"
    add "while true do\n"
    add "  lex: { \n"
    get
    add "\n  } --> lex block \n"
    add "  parse:"
    add "\nend --> while true (nom script loop) "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.61712:
  testis "parselabel*statementset*"
  jumpfalse block.end.62159
    clear
    add "    "
    ++
    get
    --
    replace "\n" "\n    "
    put
    clear
    add "::script::\n"
    add "while true do\n"
    add "  parse: \n"
    add "  while true do \n"
    get
    add "\n    break parse;  --> run-once parse loop "
    add "\n  end --> parse block "
    add "\nend --> while true (nom script loop) "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.62159:
  testis "beginblock*script*"
  jumpfalse block.end.62282
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
  block.end.62282:
block.end.62286:
# cannot reduce to push
push
push
pop
testeof 
jumpfalse block.end.62953
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*"
  jumpfalse block.end.62853
    clear
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    add "::script::\n"
    # but how will reparse work here? fix:
    add "while true do\n"
    get
    add "\nend --> while true (nom script loop) "
    put
    clear
    add "script*"
    push
    jump parse
  block.end.62853:
  testis "beginblock*"
  jumptrue 6
  testis "comment*"
  jumptrue 4
  testis "parselabel*"
  jumptrue 2 
  jump block.end.62949
    clear
    add "script*"
    push
    jump parse
  block.end.62949:
block.end.62953:
push
push
push
push
testeof 
jumpfalse block.end.77719
  pop
  pop
  testis ""
  jumpfalse block.end.63072
    add "--> empty nom script\n"
    print
    quit
  block.end.63072:
  testis "script*"
  jumptrue block.end.63362
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
  block.end.63362:
  clear
  add "--> good syntax. \n"
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
  add " --> Lua code generated by \"nom.tolua.pss\" \n"
  add " \n"
  add " --[[\n"
  add " import \"dart:io\";\n"
  add " import \"dart:convert\";\n"
  add " import \"package:characters/characters.dart\";\n"
  add " enum inputType { stdin, string, file }\n"
  add " enum outputType { stdout, string, file }\n"
  add " --]]\n"
  add "\n"
  add " Machine = {\n"
  add "   accumulator = 0,         --> counter for anything\n"
  add "   peep = \"\",               --> next char in input stream\n"
  add "   charsRead = 0,           --> No. of chars read so far\n"
  add "   linesRead = 1,          --> No. of lines read so far\n"
  add "   work = \"\",           --> text manipulation buffer \n"
  add "   --> just treat this lua table like a stack\n"
  add "   stack = {},  --> parse token stack\n"
  add "   tapeLength = 100,    --> tape initial length.\n"
  add "   tape = {},   --> array of token attributes \n"
  add "   marks = {},    --> tape marks\n"
  add "   cell = 0,              --> pointer to current cell\n"
  add "   sourceType = \"stdin\",  --> whether from \"string\",stdin,\"filelines\"/filestream\n"
  add "   sinkType =  \"stdout\",  --> whether to string,stdout,file\n"
  add "   input = io.stdin,    --> text input stream ie stdin or file\n"
  add "   output = io.stdout,  --> input stream ie stdout or file (string is \n"
  add "                        --> read as lines.\n"
  add "   --> all input lines from string \n"
  add "   inputLines = {},     --> a buffer of lines from a string or file\n"
  add "   lineIndex = 0,       --> current line begin read from inputLines\n"
  add "   outputBuffer = \"\",\n"
  add "   lineBuffer = \"\",     --> one line of text input as characters.\n"
  add "   eof = false,         --> end of stream reached?\n"
  add "   escape = \"\\\\\",     --> char used to \"escape\" others \"\\\"\n"
  add "   delimiter = \"*\",     --> push/pop delimiter (default is \"*\")\n"
  add "   markFound = false,   --> if the mark was found in tape\n"
  add " } --> Machine \n"
  add "\n"
  add "   --> make a new machine with a character stream reader \n"
  add "\n"
  add "   function Machine:new (o) \n"
  add "     --> stdin is the default\n"
  add "     o = o or {}\n"
  add "     setmetatable(o, self)\n"
  add "     self.__index = self\n"
  add "\n"
  add "     for ii = 1,self.tapeLength do \n"
  add "       self.tape[ii] = \"\" \n"
  add "       self.marks[ii] = \"\" \n"
  add "     end\n"
  add "     self.sourceType = \"stdin\"\n"
  add "     self.sinkType = \"stdout\"\n"
  add "     self.input = io.stdin \n"
  add "     self.output = io.stdout\n"
  add "\n"
  add "     --> load a value into peep\n"
  add "     self:read(); self.charsRead = 0;\n"
  add "\n"
  add "     --> self.output:write(\"hello \\n\")\n"
  add "     return o\n"
  add "   end \n"
  add "\n"
  add "   --[[ read one character from the input stream and \n"
  add "       update the machine. This reads though a lineBuffer so as to\n"
  add "       handle unicode grapheme clusters (which can be more than \n"
  add "       one \"character\"). This method refills the lineBuffer when empty\n"
  add "       either from stdin or from the inputLines List cache. \n"
  add "   --]]\n"
  add "\n"
  add "   function Machine:read()\n"
  add "     s = \"\"\n"
  add "\n"
  add "     if (self.eof) then\n"
  add "       os.exit(0) --> print(\"eof exit\") \n"
  add "     end\n"
  add "     self.charsRead = self.charsRead + 1\n"
  add "     --> increment lines\n"
  add "     if (self.peep == \"\\n\") then \n"
  add "       self.linesRead = self.linesRead + 1; \n"
  add "     end\n"
  add "     self.work = self.work .. self.peep\n"
  add "\n"
  add "     --> refill the line buffer if empty\n"
  add "     if (self.lineBuffer == \"\") then \n"
  add "       if (self.sourceType == \"stdin\") or (self.sourceType == \"filestream\") then\n"
  add "         --> retaining newline is important. otherwise need some\n"
  add "         --> hack to re-put them, and another hack to remove trailing\n"
  add "         --> newline at EOF\n"
  add "         s = self.input:read(\"*line\")\n"
  add "         --> there are no newlines after read(\"*line\")\n"
  add "         --> but this is a problem for one\n"
  add "         --> line scripts because I add an extra one here.\n"
  add "         s = s .. \"\\n\"\n"
  add "\n"
  add "       elseif (self.sourceType == \"string\") or \n"
  add "              (self.sourceType == \"filelines\") then\n"
  add "         self.lineIndex = self.lineIndex + 1  \n"
  add "         if (self.lineIndex >= #self.inputLines) then\n"
  add "           s = nil\n"
  add "         else \n"
  add "           s = self.inputLines[self.lineIndex]\n"
  add "           -- restore all and normalise to unix LF. The code below may add\n"
  add "           -- and extra newline at the end of the input, but I think we can\n"
  add "           -- live with that.\n"
  add "           --> if (self.inputLines.length > 1) then s = s + \"\\n\" end\n"
  add "           s = s .. \"\\n\"\n"
  add "         end \n"
  add "       else \n"
  add "         print(\"Unsupported input type (not stdin/filestream/filelines/string)\")\n"
  add "         os.exit(1)\n"
  add "       end\n"
  add "\n"
  add "       if not s then \n"
  add "         self.eof = true\n"
  add "         self.peep = \"\"\n"
  add "       else \n"
  add "         self.lineBuffer = s \n"
  add "       end\n"
  add "       -->io.write(\"input:\" + self.lineBuffer)\n"
  add "     end\n"
  add "\n"
  add "     if (self.eof == false) then\n"
  add "       -->  error if no characters.?\n"
  add "       self.peep = self.lineBuffer:sub(1,1)\n"
  add "       self.lineBuffer = self.lineBuffer:sub(2)\n"
  add "     end\n"
  add "   end \n"
  add "\n"
  add "   --> write to current machine destination (stdout/string/file) \n"
  add "   --> no filestream or filelines types for file output because not\n"
  add "   --> required\n"
  add "   function Machine:write(output)\n"
  add "     if (self.sinkType == \"stdout\") or (self.sinkType == \"file\") then\n"
  add "       self.output:write(output)\n"
  add "     elseif (self.sinkType == \"string\") then\n"
  add "       self.outputBuffer = self.outputBuffer .. output\n"
  add "     else \n"
  add "       error(\"unsupported output type: \"..output)\n"
  add "     end\n"
  add "   end\n"
  add "   \n"
  add "   --[[\n"
  add "   --> increment tape pointer by one \n"
  add "   function Machine:increment()\n"
  add "     self.cell = self.cell + 1\n"
  add "     if (self.cell >= self.tapeLength) then\n"
  add "       for ii = self.tapeLength,self.tapeLength+50 do \n"
  add "         self.tape[ii] = \"\" \n"
  add "         self.marks[ii] = \"\" \n"
  add "       end\n"
  add "       self.tapeLength = self.tapeLength + 50\n"
  add "     end\n"
  add "   end\n"
  add "   \n"
  add "   --> remove escape character  \n"
  add "   function Machine:unescapeChar(c)\n"
  add "     --> dont unescape chars that are not escaped!\n"
  add "     countEscapes = 0\n"
  add "     s = \"\"; nextChar = \"\"\n"
  add "     if self.work == \"\" then return; end\n"
  add "     for (nextChar in self.work) do\n"
  add "       if ((nextChar == c ) && (countEscapes % 2 == 1)) then\n"
  add "         s = s.skipLast(1);\n"
  add "       end \n"
  add "       if nextChar == self.escape then\n"
  add "         countEscapes = countEscapes + 1 \n"
  add "       else countEscapes = 0 end\n"
  add "       s = s .. nextChar;\n"
  add "     end \n"
  add "     self.work = s;\n"
  add "   end\n"
  add "   --]]\n"
  add "\n"
  add "   --[[\n"
  add "   --> add escape character  \n"
  add "   function Machine:escapeChar(c) \n"
  add "     --> dont escape chars that are already escaped!\n"
  add "     --> fix this in machine.methods.c\n"
  add "     countEscapes = 0;\n"
  add "     s = \"\"; nextChar = \"\";\n"
  add "     if (self.work == \"\") then return; end\n"
  add "     for (nextChar in self.work) do\n"
  add "       if ((nextChar == c ) && (countEscapes % 2 == 0)) then s = s..self.escape; end\n"
  add "       if (nextChar == self.escape) then \n"
  add "         countEscapes = countEscapes + 1\n"
  add "       else countEscapes = 0; end\n"
  add "       s = s .. nextChar;\n"
  add "     end\n"
  add "     self.work = s;\n"
  add "   end\n"
  add "   --]]\n"
  add "\n"
  add "   --[[\n"
  add "   -- a helper to see how many trailing \\\\ escape chars. I need to \n"
  add "   --   do this because the suffix for until can be multiple chars. \n"
  add "   countEscaped(sSuffix)\n"
  add "     s = \"\";\n"
  add "     count = 0;\n"
  add "     index = 0;\n"
  add "     --> remove suffix if it exists\n"
  add "     --> startswith\n"
  add "     --> str:sub(1, #start) == start\n"
  add "     --> endswith test\n"
  add "     if self.work:sub(-#sSuffix) == sSuffix then\n"
  add "       s = self.work.substring(0, self.work.lastIndexOf(sSuffix));\n"
  add "     else s = self.work end\n"
  add "\n"
  add "     while (s.endsWith(self.escape)) do\n"
  add "       count = count + 1\n"
  add "       s = s.substring(0, s.lastIndexOf(self.escape));\n"
  add "     end\n"
  add "     return count;\n"
  add "   end\n"
  add "   --]]\n"
  add "\n"
  add "   --[[\n"
  add "   --> reads the input stream until the workspace ends with text \n"
  add "   --> can test this with\n"
  add "   function Machine:until(suffix)\n"
  add "     --> read at least one character\n"
  add "     if (self.eof) then return end\n"
  add "     self:read();\n"
  add "     while true do\n"
  add "       if (self.eof) then return; end\n"
  add "       if (self.work.endsWith(suffix)) then\n"
  add "         if (self:countEscaped(suffix) % 2 == 0) then return; end\n"
  add "       end\n"
  add "       self:read();\n"
  add "     end \n"
  add "   end\n"
  add "\n"
  add "   --> pop the first token from the stack into the workspace \n"
  add "   function Machine:pop()\n"
  add "     if (self.stack.isEmpty) then return false end\n"
  add "     self.work = self.stack.last + self.work\n"
  add "     self.stack.removeLast()\n"
  add "     if (self.cell > 0) then self.cell = self.cell - 1;\n"
  add "     return true;\n"
  add "   end\n"
  add "\n"
  add "   --> push the first token from the workspace to the stack \n"
  add "   function Machine:push()\n"
  add "     --> need to use characters api. not string methods.\n"
  add "     \n"
  add "     parts = {}   \n"
  add "     --> dont increment the tape pointer on an empty push\n"
  add "     if (self.work == \"\") then return false end\n"
  add "\n"
  add "     --> the delimiter should be guaranteed to be one unicode char\n"
  add "     -->  self.delimiter.first)) then\n"
  add "\n"
  add "     if (!self.work.contains(self.delimiter)) then\n"
  add "       self.stack.add(self.work)\n"
  add "       self.work = \"\";\n"
  add "     else\n"
  add "       parts = self.work.split(self.delimiter, 2).toList();\n"
  add "       self.stack.add(parts[0] + self.delimiter.first);\n"
  add "       self.work = parts[1];\n"
  add "     end\n"
  add "\n"
  add "     self:increment(); return true\n"
  add "   end\n"
  add "\n"
  add "   --> swap current tape cell with the workspace \n"
  add "   function Machine:swap()\n"
  add "     s = self.work;\n"
  add "     self.work = self.tape[self.cell];\n"
  add "     self.tape[self.cell] = s;\n"
  add "   end\n"
  add "\n"
  add "   --> save the workspace to file \"sav.pp\" \n"
  add "   function Machine:writeToFile()\n"
  add "     try {\n"
  add "       File file = new File(\"sav.pp\");\n"
  add "       file.writeAsStringSync(self.work);\n"
  add "     } catch (e) {\n"
  add "       io.write(\"could not write file: $e\"); \n"
  add "     }\n"
  add "   end\n"
  add "\n"
  add "   function Machine:goToMark(mark)\n"
  add "     ii = self.marks.indexOf(mark);\n"
  add "     if (ii != -1) then\n"
  add "       self.cell = ii\n"
  add "     else\n"
  add "       io.stdout:write(\"badmark \'\" + mark + \"\'!\"); \n"
  add "       os.exit(1);\n"
  add "     end\n"
  add "   end\n"
  add "\n"
  add "   --> remove existing marks with the same name and add new mark \n"
  add "   function Machine:addMark(mark)\n"
  add "     ii = self.marks.indexOf(mark);\n"
  add "     while (ii != -1) do\n"
  add "       self.marks[ii] = \"\";\n"
  add "       ii = self.marks.indexOf(mark);\n"
  add "     end\n"
  add "     self.marks[self.cell] = mark; \n"
  add "   end\n"
  add "\n"
  add "   --> check if the workspace matches given class: not used \n"
  add "   bool matchClass(charclass)\n"
  add "     --> but regExp cant handle emojis?\n"
  add "     var regExp = RegExp(r\'^\' + charclass + r\'+$\', unicode:true);\n"
  add "     return regExp.hasMatch(self.work); \n"
  add "   end\n"
  add "\n"
  add "   --]]\n"
  add "\n"
  add "   --[[ \n"
  add "      print the internal state of the pep/nom parsing machine. This \n"
  add "      is handy for debugging, but for some reason I took this command\n"
  add "      out of some translators ...\n"
  add "\n"
  add "   --]]\n"
  add "\n"
  add "   function Machine:printState() \n"
  add "      -- displayPeep = self.peep.gsub(\"\\n\",\"\\\\n\");\n"
  add "      -- displayPeep = displayPeep:gsub(\"\\r\",\"\\\\r\");\n"
  add "      -- displayBuffer = self.lineBuffer:gsub(\"\\n\",\"\\\\n\");\n"
  add "      -- displayBuffer = displayBuffer:gsub( \"\\r\",\"\\\\r\");\n"
  add "\n"
  add "      print(\"\\n--------- Machine State ------------- \")\n"
  add "      print(\"(line buffer:\"..self.lineBuffer..\")\")\n"
  add "      io.write(\"Stack [\");\n"
  add "      for k,v in pairs(self.stack) do print(v..\",\") end\n"
  add "      io.write(\"] \");\n"
  add "      io.write(\"Work[\"..self.work..\"] \");\n"
  add "      io.write(\"Peep[\"..self.peep..\"]\\n\");\n"
  add "      io.write(\"Acc:\"..self.accumulator..\" \");\n"
  add "      if self.eof then io.write(\"EOF:true \"); else io.write(\"EOF:false \"); end\n"
  add "      io.write(\"Esc:\"..self.escape..\" \");\n"
  add "      io.write(\"Delim:\"..self.delimiter..\" \");\n"
  add "      io.write(\"Chars:\"..self.charsRead..\" \");\n"
  add "      io.write(\"Lines:\"..self.linesRead..\"\\n\");\n"
  add "      print(\"-------------- Tape ----------------- \");\n"
  add "      print(\"Tape Size: \"..self.tapeLength);\n"
  add "      startcell = self.cell - 3\n"
  add "      endcell = self.cell + 3\n"
  add "      if startcell < 0 then startcell = 1 end\n"
  add "      for ii = startcell,endcell do\n"
  add "        io.write(\"   \"..ii);\n"
  add "        if (ii == self.cell) then \n"
  add "          io.write(\"> [\"); \n"
  add "        else \n"
  add "          io.write(\"  [\"); \n"
  add "        end\n"
  add "        io.write(self.tape[ii]..\"]\\n\");\n"
  add "      end \n"
  add "   end --> printState \n"
  add "\n"
  add "   --[[\n"
  add "   --> makes the machine read from a string \n"
  add "   function Machine:setStringInput(input) \n"
  add "     self.sourceType = inputType.string;\n"
  add "     LineSplitter ll = new LineSplitter();\n"
  add "     self.inputLines = ll.convert(input); \n"
  add "   end \n"
  add "\n"
  add "   --> makes the machine write to a string \n"
  add "   function Machine:setStringOutput(input) \n"
  add "     self.sinkType = outputType.string;\n"
  add "   end\n"
  add "\n"
  add "   --> parse/translate from a string and return the translated\n"
  add "   -->  string \n"
  add "   function Machine:parseString(input)\n"
  add "     self.setStringInput(input);\n"
  add "     self.sinkType = outputType.string;\n"
  add "     self:parse();\n"
  add "     return self.outputBuffer;\n"
  add "   end\n"
  add "\n"
  add "   --]] \n"
  add "\n"
  add "   --> makes the machine read from a file stream, not from stdin \n"
  add "   function Machine:setFileInput(fileName)\n"
  add "     self.input = io.open(fileName, \"r\") \n"
  add "     if not self.input then\n"
  add "       error(\" could not open file for reading: \" .. fileName)\n"
  add "       os.exit(1)\n"
  add "     end\n"
  add "     --> filestream read a file as a stream line by line (slower)\n"
  add "     --> filelines reads a file all at once into a line buffer array\n"
  add "     self.sourceType = \"filestream\";\n"
  add "   end\n"
  add "\n"
  add "   --> makes the machine read from a file line buffer array\n"
  add "   function Machine:setFileLinesInput(fileName)\n"
  add "     self.input = io.open(fileName, \"r\") \n"
  add "     if not self.input then\n"
  add "       error(\" could not open file for reading: \" .. fileName)\n"
  add "       os.exit(1)\n"
  add "     end\n"
  add "     --> filelines reads a file all at once into a line buffer array\n"
  add "     self.sourceType = \"filelines\";\n"
  add "     --> read the lines into buffer table \n"
  add "     table.clear(self.inputLines)\n"
  add "     for line in self.input:lines() do\n"
  add "       table.insert(self.inputLines, line)\n"
  add "     end\n"
  add "   end\n"
  add "\n"
  add "\n"
  add "   --> makes the machine write to a file not to stdout (the default)\n"
  add "   function Machine:setFileInput(fileName)\n"
  add "     self.output = io.open(fileName, \"w\") \n"
  add "     if not self.output then\n"
  add "       error(\" could not open file for writing: \" .. fileName)\n"
  add "       os.exit(1)\n"
  add "     end\n"
  add "     self.sinkType = \"file\";\n"
  add "   end\n"
  add "\n"
  add "   --> parse from a file and put result in file \n"
  add "   function Machine:parseFile(inputFile, outputFile)\n"
  add "     self:setFileInput(inputFile)\n"
  add "     self:setFileOutput(outputFile)\n"
  add "     self:parse()\n"
  add "   end\n"
  add "\n"
  add "   function Machine:parseStream(handle)\n"
  add "     self.input = handle;\n"
  add "     self:parse();\n"
  add "   end\n"
  add "\n"
  add "    --> parse with the machines input steam \n"
  add "    function Machine:parse()\n"
  add "      -- self:read(); self.charsRead = 0;"
  # get the compiled code from the tape
  get
  # terminate the dart program.
  add "\n"
  add "    end --> parse method \n"
  add "\n"
  add "  --> start of main code\n"
  add "\n"
  add "    temp = \"\";    \n"
  add "    mm = Machine:new();\n"
  add "    --> testing parse a file not stdin\n"
  add "    --> parseFile reads from a file and writes to a file.\n"
  add "    --> mm:parseFile(\"../index.txt\");\n"
  add "\n"
  add "    --> testing parse a string not stdin. parseString reads from a \n"
  add "    --> string and writes to a string.\n"
  add "    --> final result = mm.parseString(\" ## heading line: \\n next line www.nomlang.org \\n end.\");\n"
  add "    --> io.write(result);\n"
  add "\n"
  add "    --> by default the machine reads from stdin and writes to stdout\n"
  add "    mm:parse();\n"
  add "  \n"
  print
  quit
block.end.77719:
# end of block
jump start 
