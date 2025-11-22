# Assembled with the script 'compile.pss' 
start:

#
#ABOUT 
#
#  Translate nom to the dart language. This uses the 
#  new script organisation from /eg/nom.syntax.reference.pss
#
#  I am not sure how much error trapping I will retain here.  Hopefully this
#  will become a template for other new translation scripts.  I will call these
#  scripts nom.to<lang>.pss rather than translate.<lang>.pss
#
#BUGS AND ISSUES
#
# - escape and unescape methods have a bug when escaping the escape character
#   eg escape '\\' may not work as it should.
# - no need to split lines of file. Either read whole file/stdin/string
#   or read as stream.
# - check if eof before reading (see nom.tolua.pss) and return if so.
# - dont read from stdin etc when creating new Machine object
#   because that will hang when using a different sourceType. 
#   Do it at the start of Machine.parse() method if sourceType not 
#   set. See the lua translator for details.
# - Handle grapheme clusters.
#
#STATUS
#
#  7 apr 2025
#    many scripts working. /eg/text.tohtml.pss is working when
#    translated. stdin/string/file parsing working with minimal testing.
#    No file/string output. 
#
#TODO
#
#  - use the Regexp.escape() method and compose the class string so
#    that the right chars are escaped.
#  - output write to string,stdout or file.
#  - test grapheme clusters in /tr/translate.unicode.test.txt
#
#DONE
#
#  - compile class matching into dart.
#  - while and whilenot code, how to match single character 
#    in peep
#  - make class parsing better (unicode script names and categories)
#  - push code, how to split off 1st token using characters.
#  - change the eof script block, need to do pop; pop etc
#    so that beginblocks will resolve with just a parselabel or comment.
#    Move to end of script.
#  - read code. read one character (unicode) from the input, from string
#    or file. only reading from stdin at the moment.
#
#TESTING 
#
#  The dart compiler strikes me as being slow, so the tests which
#  are in translate.test.txt and translate.unicode.test.txt will take
#  quite some time. But you can just start the 'pep.tt' function 
#  from any test block. see below.
#
#  * test with the function in helpers.pars.sh
#  >> pep.tt dart
#
#  * test but start at swap tests 
#  >> pep.tt dart blah '# swap'
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
#    String and file parsing also working but outputting to 
#    string/file needs work. Trying to use a StringBuffer to get 
#    the result but it is empty for some reason.
#
#    There was a bug in this because \p{Separator} did not match
#    the newline \n . /eg/text.tohtml.pss seems to work now when
#    translated to dart.
#  5 april 2025
#    all first gen tests working with stdin input stdout output.
#    Can't find a simple way to read from stdin or string or file
#    as stream because of async issues.
#  4 april 2025
#    made a complicated looking (eof) block to reduce statementset/parselabel
#    combinations to scripts and then combine with begin blocks. I have 
#    to do this in 'reverse' (reducing 3 token combinations, before 2 token
#    etc). Also, surprisingly, in this situation 'push;push;pop;' is 
#    *not* the same as 'push;'
#  3 april 2025
#    lots of work. many 1st gen ascii tests working. classes are 
#    unicode aware with script names and unicode categories.
#    working on escapeChar and unescapeChar. These seem to be 
#    working. Walk through the workspace and count escape chars.
#  21 mar 2025
#    started based on /eg/nom.syntax.reference.pss and translate.java.pss
#    significant work.
#
#NOTES
#
#  The advantages of these new translation scripts over the old
#  translate.<lang>.pss scripts is as follows:
#    - much better error checking, systematic, using an error token.
#    - all parsing is in a parse() method which allows the translator 
#      to be used from within other code of the same language.
#    - better tokenisation and better grammar
#    - If the language can execute a string as code (eg Perl) then these
#      scripts can also be used as nom interpreters.
#    - Better unicode class support with unicode category/script/block
#      names for classes (if the target language supports this in it 
#      regular expression engine.
#    - Better nom://read method which takes into account (hopefully) 
#      unicode grapheme clusters, again, if the target language supports
#      it
#    - A read method that should be able to read from stdin, a file 
#      or a string which also facilitates using the translator from
#      within code.
#
#  You need to install the 'characters' api with "dart pub get" 
#  after putting it into a pubspec.yaml file.
#
#  https://www.regular-expressions.info/unicode.html#category
#    important unicode regexp info for different languages. The 
#    unicode script names and properties which are included here 
#    were copied from this website.
#
#  When reading with until we stop at the end text, but not if 
#  it is escaped with the machine escape char (usually '\\' ?). 
#
#  After some research, it seems that I have to read one line at 
#  a time from a stream with LineSplitter, then read one Character 
#  (character api) at a time into the pep machine. 
#  Use await for to get one line from the stream. 
#  
#  I will probably 
#  use this technique for all the *modern* translation scripts
#  (which are called nom.to<lang>.pss , the old ones are called 
#  translate.<lang>.pss ) The reason for this is that reading from 
#  some kind of input-stream or file one line at a time seems 
#  better supported in most languages and maybe more efficient.
#  Also it gives me a chance to wrestle with unicode grapheme clusters
#  (combining marks, diacritics and what-not). But to the user of 
#  nom it will still appear that the nom://read command reads one 
#  (grapheme cluster, hopefully) at a time.
#
#  This translator escapes $ and \\ and double quotes all quoted text
#  at the tokenizing phase because it is less work. In some cases
#  I may have to unquote and unescape this text. Double and single quotes
#  are the same in Dart.
#
#  This script when finished should handle unicode grapheme clusters 
#  correctly because of the dart characters api. The other translators,
#  so far, do not.
#
#  Details to check. Quoting. escaping special sequences. Will "\n"
#  work in strings?
#
#  This uses a different grammar and organisation, with an error and help
#  system. The error and help system can be cut and paste into all the scripts
#
#  error checking is now quite systematic using the list of 
#  tokens. Especially in 2 token error sequences
#
#UNICODE CATEGORIES
#
#  Dart appears to support these categories, so here is a list.
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
#  dart >= 2.4 supports these but not block names
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
#  It appears that dart does not support blocks as a property name.
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
#DART REGEXP SYNTAX
#
#  https://perldoc.perl.org/perlrecharclass#Extended-Bracketed-Character-Classes
#    A link for categories in Perl
#
#  Dart categories, not sure if these work in unicode mode.
#
#  * digit, word, space and inverses, I think not unicode aware
#  >> \d, \w, \s, \D, \W, \S, .
#
#  These dont seem to be unicode aware in RegExp even when the 
#  unicode: true flag is set
#
#  - \w = [:alnum:]
#  - \d = [:digit:] 
#  - \s = [:space:]  (including newline)
#  
#
#  https://blog.0xba1.xyz/0522/dart-flutter-regexp/
#    good page about regex in dart.
#
#  All the characters below need to be escaped in while/whilenot 
#  and class tests, no?
#
#  * special regex chars.
#  >> \, ^, $, ?, *, +, <, >, [, ], {, }, ..
#
#  * matching unicode scripts in dart regexp
#  ----
#   RegExp exp = RegExp(r'(\p{Script=Greek})', unicode: true);
#   Iterable<RegExpMatch> matches;
#   matches = exp.allMatches('ΓβγΔδΕεζηΘθ');
#   for (Match m in matches) {
#     print('${m.group(1)}');
#   }
#  ,,,,,
#
#  * unicode category matching regexp since dart 2.4
#  ------
#   RegExp alpha = RegExp(r'\p{Letter}', unicode: true);
#   print(alpha.hasMatch("f")); // true
#   print(alpha.hasMatch("ת")); // true
#   print(alpha.hasMatch("®")); // false
# ,,,,
#
#    If the unicode property name is wrong dart will throw exception
#    Unhandled exception:
#     FormatException: Invalid property name\p{Script=InBasic_Latin}
#
#DART SYNTAX
#
#  * run a process in a shell in dart
#  ------
#     import 'dart:io';
#     void main() async {
#       try {
#         var result = await Process.run('ls -l | wc -l', [], runInShell: true);
#         if (result.exitCode == 0) {
#           print('Number of files: ${result.stdout}');
#         } else {
#           print('Command failed: ${result.stderr}');
#         }
#       } catch (e) {
#         print('An error occurred: $e');
#       }
#     }
#  ,,,,
#
#  * remove element from list and return list (2 dots, cascade)
#  -----
#  void main() {
#    print(['a', 'b', 'c', 'd']..removeAt(2));
#  }
#  ,,,,
#
#  * get stdin lines
#  ----------
#    import 'dart:convert';
#    import 'dart:io';
#
#    void main() async {
#      await for (final line in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
#        //do stuff with line or simply
#        print(line);
#      }
#    }
#
#    import 'dart:io';
#    import 'dart:convert';
#    import 'dart:async';
#    void main() async {
#      final file = File('file.txt');
#      Stream<String> lines = file.openRead()
#        .transform(utf8.decoder)       // Decode bytes to UTF-8.
#        .transform(LineSplitter());    // Convert stream to individual lines.
#      try {
#        await for (var line in lines) {
#          print('$line: ${line.length} characters');
#        }
#        print('File is now closed.');
#      } catch (e) {
#        print('Error: $e');
#      }
#    }
#  ,,,,,
#
#  * try catch with specific exception.
#  ------
#    try {
#    } on FormatException catch (fe) {
#      print(fe); return 1;
#    } catch (e) {
#    }
#  ,,,,,
#
#  * remove last 5 chars from string
#  ----
#    if (str != null && str.length >= 5) {
#     str = str.substring(0, str.length - 5);
#    }
#  ,,,,
#
#  * synchronous read
#  >> String? name = stdin.readLineSync(); 
#
#  * compile dart
#  >> dart compile exe prog.dart
#
#  * read utf8 stream one char at a time
#  ----
#   import 'dart:convert';
#   import 'dart:io';
#
#   main() {
#     // these threw an error for me, but probably doesnt matter
#     // stdin.echoMode = false;
#     // stdin.lineMode = false;
#     var subscription;
#     subscription = stdin
#       .map((List<int> data) {
#         if (data.contains(4)) {
#           // stdin.echoMode = true;
#           subscription.cancel();
#         }
#         return data;
#       })
#       .transform(utf8.decoder)
#       .map((String s) => s.toUpperCase()+":")
#       .listen(stdout.write);
#   }
# ,,,,
#
# * read file as stream
# >> file.openRead() which returns a Stream<List<int>>
#
# To read one char just dont call transform(const LineSplitter())
#
# * read stdin as stream
# ----
# import 'dart:convert';
# import 'dart:io';
#  void main() async {
#    await for (final line in 
#      stdin.transform(utf8.decoder).transform(const LineSplitter())) {
#      //do stuff with line or simply
#      stdout.write(line); // no line feed
#      print(line);
#    }
#  }
# ,,,,
#
#  
# * get file contents now
# ----
#    File file = File('random_path.txt');
#    Future<String> contents = file.readAsString();
#    var value = await contents; // <- await gets value, or reth
#  ,,,,
#
#  * handle file stream errors
#  -----
#
#     final stream = File('does-not-exist')
#    .openRead()
#    .handleError((e) => print('Error reading file: $e'));
#    await for (final data in stream) {
#      print(data);
#    }
#
#  ,,,,
#
# * read stdin one char at a time
# ------
#   import 'dart:convert';
#   import 'dart:io';
#   main() {
#     // Stop your keystrokes being printed automatically.
#     stdin.echoMode = false;
#     // This will cause the stdin stream to provide the input as soon as it
#     // arrives, so in interactive mode this will be one key press at a time.
#     stdin.lineMode = false;
#     var subscription;
#     subscription = stdin.listen((List<int> data) {
#       // Ctrl-D in the terminal sends an ascii end of transmission character.
#       // http://www.asciitable.com/
#       if (data.contains(4)) {
#         // On my computer (linux) if you don't switch this back on the console
#         // will do wierd things.
#         stdin.echoMode = true;
#         // Stop listening.
#         subscription.cancel();
#       } else {
#         // Translate character codes into a string.
#         var s = LATIN1.decode(data);
#         // Capitalise the input and write it back to the screen.
#         stdout.write(s.toUpperCase());
#       }
#      });
#
# }
# ,,,,
#
# * splitting on a character in string, maximum 4 in list
# ---
#  var c = 'abracadabra'.characters;
#  var parts = c.split('a'.characters, 4).toList();
# ,,,
# 
# * characters
# >> return this!.characters.takeLast(n).string;
#
# This sections just has some random notes about dart syntax and 
# code.
#
# * methods in string interp 
# >> " x ${str.isNotEmpty} "
#
# * List and methods
# ----
#   final List<String> s = [];
#   var s = [''];
#   if (s.isEmpty ) ...
#   String last = s.last; 
#   s.removeLast()
#   s.toString();
#   s.add('newstring');
# ,,,
#
# * constructors, new is not necessary
# ----
#  var p1 = new Point(2, 2);
#  var p2 = new Point.fromJson({'x': 1, 'y': 2});
# ,,,,
#
#  * maps maybe better than 2 Lists ? no
#  >> static final Map<String, Logger> _cache = <String, Logger>{};
#
# * create an input stream from a string
# -------
# import 'dart:io';
#  main() {
#    var input = "hello from dart";
#    var inputStream = new ListInputStream();
#    inputStream.onData = () {
#      print(new String.fromCharCodes(inputStream.read()));
#    };
#    inputStream.write(input.charCodes());
#  }
#  ,,,,,
#
#  * get the first character (Rune) of a string
#  >> '${mystring[0]}'
#  >> word.substring(0,1); 
#  But probably use characters api instead.
#
# * loop through chars of string
# -----
#   void main() {
#    String mystring = 'Hello World';
#    String search = ''; 
#    for (int i=0;i<mystring.length;i++){
#    search += mystring[i];
#    print(search);
#   } 
#  }
# ,,,
#
# * use characters api
# >> var length = input.characters.length;
#
# * remove last char from string
# >> return text.characters.skipLast(1).toString();
#
# * split on a character (string)
# -------
# List<String> splitEmojiSeparatedWords(String text, String separator) {
#  // Split returns an iterable, which we need to convert to a list.
#  return [...text.characters.split(separator.characters)]; 
# ,,,,
#
# * get first char of string
# >> firstName.characters.first
#
read
# sort-of line-relative character numbers 
testclass [\n]
jumpfalse block.end.24939
  nochars
block.end.24939:
# ignore space except in quotes. but be careful about silent
# exit on read at eof
testclass [:space:]
jumpfalse block.end.25097
  clear
  testeof 
  jumpfalse block.end.25072
    jump parse
  block.end.25072:
  testeof 
  jumptrue block.end.25092
    jump start
  block.end.25092:
block.end.25097:
# literal tokens, for readability maybe 'dot*' and 'comma*'
testclass [<>}()!BE,.;]
jumpfalse block.end.25209
  put
  add "*"
  push
  jump parse
block.end.25209:
testclass [{]
jumpfalse block.end.25393
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
block.end.25393:
# parse (eof) etc as tokens? yes
# command names, need to do some tricks to parse ++ -- a+ etc
# here. This is because [:alpha:],[+-] etc is not a union set
# and while cannot do "while [:alpha:],[+-] etc
# subtle bug, [+-^0=] parses as a range!!! [a-z]
testclass [:alpha:]
jumptrue 4
testclass [-+^0=]
jumptrue 2 
jump block.end.30017
  # a much more succint abbreviation code
  testis "0"
  jumpfalse block.end.25758
    clear
    add "zero"
  block.end.25758:
  testis "^"
  jumpfalse block.end.25791
    clear
    add "escape"
  block.end.25791:
  # increment tape pointer ++ command
  testis "+"
  jumpfalse block.end.25854
    while [+]
  block.end.25854:
  # decrement tape pointer -- command
  testis "-"
  jumpfalse block.end.25917
    while [-]
  block.end.25917:
  # tape test (==)
  testis "="
  jumpfalse block.end.25961
    while [=]
  block.end.25961:
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
  jump block.end.26113
    while [:alpha:]
  block.end.26113:
  # parse a+ or a- for the accumulator
  testis "a"
  jumpfalse block.end.26337
    # while [+-] is bug because compile.pss thinks its a range class
    # not a list class
    while [-+]
    testis "a+"
    jumptrue 4
    testis "a-"
    jumptrue 2 
    jump block.end.26299
      put
    block.end.26299:
    testis "a"
    jumpfalse block.end.26331
      clear
      add "add"
    block.end.26331:
  block.end.26337:
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
  jump block.end.27769
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
  block.end.27769:
  testis "+"
  jumptrue 4
  testis "-"
  jumptrue 2 
  jump block.end.28055
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
  block.end.28055:
  # writefile is also a command?
  # commands parsed above
  testis "a+"
  jumptrue 84
  testis "a-"
  jumptrue 82
  testis "zero"
  jumptrue 80
  testis "escape"
  jumptrue 78
  testis "++"
  jumptrue 76
  testis "--"
  jumptrue 74
  testis "add"
  jumptrue 72
  testis "clip"
  jumptrue 70
  testis "clop"
  jumptrue 68
  testis "replace"
  jumptrue 66
  testis "upper"
  jumptrue 64
  testis "lower"
  jumptrue 62
  testis "cap"
  jumptrue 60
  testis "clear"
  jumptrue 58
  testis "print"
  jumptrue 56
  testis "state"
  jumptrue 54
  testis "pop"
  jumptrue 52
  testis "push"
  jumptrue 50
  testis "unstack"
  jumptrue 48
  testis "stack"
  jumptrue 46
  testis "put"
  jumptrue 44
  testis "get"
  jumptrue 42
  testis "swap"
  jumptrue 40
  testis "mark"
  jumptrue 38
  testis "go"
  jumptrue 36
  testis "read"
  jumptrue 34
  testis "until"
  jumptrue 32
  testis "while"
  jumptrue 30
  testis "whilenot"
  jumptrue 28
  testis "count"
  jumptrue 26
  testis "zero"
  jumptrue 24
  testis "chars"
  jumptrue 22
  testis "lines"
  jumptrue 20
  testis "nochars"
  jumptrue 18
  testis "nolines"
  jumptrue 16
  testis "escape"
  jumptrue 14
  testis "unescape"
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
  jump block.end.28517
    clear
    add "command*"
    push
    jump parse
  block.end.28517:
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
  jump block.end.28666
    put
    clear
    add "word*"
    push
    jump parse
  block.end.28666:
  testis "begin"
  jumpfalse block.end.28712
    put
    add "*"
    push
    jump parse
  block.end.28712:
  # lower case and check for command with error
  lower
  testis "add"
  jumptrue 90
  testis "clip"
  jumptrue 88
  testis "clop"
  jumptrue 86
  testis "replace"
  jumptrue 84
  testis "upper"
  jumptrue 82
  testis "lower"
  jumptrue 80
  testis "cap"
  jumptrue 78
  testis "clear"
  jumptrue 76
  testis "print"
  jumptrue 74
  testis "state"
  jumptrue 72
  testis "pop"
  jumptrue 70
  testis "push"
  jumptrue 68
  testis "unstack"
  jumptrue 66
  testis "stack"
  jumptrue 64
  testis "put"
  jumptrue 62
  testis "get"
  jumptrue 60
  testis "swap"
  jumptrue 58
  testis "mark"
  jumptrue 56
  testis "go"
  jumptrue 54
  testis "read"
  jumptrue 52
  testis "until"
  jumptrue 50
  testis "while"
  jumptrue 48
  testis "whilenot"
  jumptrue 46
  testis "count"
  jumptrue 44
  testis "zero"
  jumptrue 42
  testis "chars"
  jumptrue 40
  testis "lines"
  jumptrue 38
  testis "nochars"
  jumptrue 36
  testis "nolines"
  jumptrue 34
  testis "escape"
  jumptrue 32
  testis "unescape"
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
  jump block.end.29465
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
  block.end.29465:
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
block.end.30017:
# single line comments
# no need to rethink
testis "#"
jumpfalse block.end.30702
  testeof 
  jumpfalse block.end.30104
    clear
    jump parse
  block.end.30104:
  read
  # just delete empty comments
  testclass [#\n]
  jumpfalse block.end.30178
    clear
    jump parse
  block.end.30178:
  # multiline comments this needs to go within '#'
  testis "#*"
  jumpfalse block.end.30624
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
    jumptrue block.end.30550
      clear
      add "* unterminated multiline comment #*... \n  starting at "
      get
      put
      clear
      add "nom.error*"
      push
      jump parse
    block.end.30550:
    clip
    clip
    put
    clear
    add "comment*"
    push
    jump parse
  block.end.30624:
  clear
  whilenot [\n]
  put
  clear
  add "comment*"
  push
  jump parse
block.end.30702:
# quoted text 
# I will double quote all text and escape $ and \\ 
# double quotes and single quotes are the same in dart, no 
# difference.
testis "\""
jumpfalse block.end.31519
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
  jump block.end.31218
    clear
    add "* unterminated quote (\") or incomplete command starting at "
    get
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.31218:
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
block.end.31519:
# single quotes
testis "'"
jumpfalse block.end.32059
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
  jump block.end.31843
    clear
    add "* unterminated quote (\') or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.31843:
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
block.end.32059:
# classes like [:space:] or [abc] or [a-z] 
# these are used in tests and also in while/whilenot
# The *until* command will read past 'escaped' end characters eg \]
# 
testis "["
jumpfalse block.end.40250
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
  jump block.end.32587
    clear
    add "* unterminated class [...] or incomplete command starting at "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.32587:
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
  jump block.end.39380
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
    jump block.end.34022
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
    block.end.34022:
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
    jump block.end.35301
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
    block.end.35301:
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
    jump block.end.36097
      clear
      add "\\p{Script="
      get
      add "}"
      put
      clear
      add "class*"
      push
      jump parse
    block.end.36097:
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
    jump block.end.39023
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
    block.end.39023:
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
  block.end.39380:
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
block.end.40250:
testis ""
jumptrue block.end.40464
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
block.end.40464:
parse:
# watch the parse-stack resolve.  
# add "// line "; lines; add " char "; chars; add ": "; print; clear; 
# unstack; print; stack; add "\n"; print; clear;
# ----------------
# error trapping and help here
pop
# parse help token for a topic, category of # topics or everthing. 
testis "nom.help*"
jumpfalse block.end.44031
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
  jump block.end.41451
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
  block.end.41451:
  # specific help for the add command 
  testis "command.add"
  jumptrue 6
  testis "commands"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.41853
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
  block.end.41853:
  #  
  testis "semicolon"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.42212
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
  block.end.42212:
  # 'brackets' is topic, 'punctuation' is a category, 'all' is everthing 
  testis "brackets"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.42622
    swap
    add "\n"
    add "      brackets () \n"
    add "        are used for tests like (eof) (EOF) (==) \n"
    add "        currently (2025) brackets are not used for logical grouping in \n"
    add "        tests.\n"
    add "      examples:\n"
    add "         (==)                  # correct\n"
    add "         (==,'abc' { nop; }    # incorrect: unbalanced "
  block.end.42622:
  testis "negation"
  jumptrue 6
  testis "punctuation"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.43119
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
  block.end.43119:
  # 
  testis "modifiers"
  jumptrue 6
  testis "tests"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.43467
    swap
    add "\n"
    add "      begins-with 'B' and ends-with 'E' modifiers:\n"
    add "        are used with quoted text tests and cannot be used with \n"
    add "        class tests.\n"
    add "      eg: \n"
    add "        B'abc' { clear; }        # correct \n"
    add "        E\"abc\" { clear; }      # correct \n"
    add "        B[:alpha:] { clear; }  # incorrect  "
  block.end.43467:
  # help for the help system 
  testis "help"
  jumptrue 6
  testis "help"
  jumptrue 4
  testis "all"
  jumptrue 2 
  jump block.end.43879
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
  block.end.43879:
  # This help system quits after showing the help message
  # but you could keep parsing if there is any point. 
  add "\n\n"
  print
  quit
block.end.44031:
testis "nom.error*"
jumpfalse block.end.44523
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
  jumpfalse block.end.44508
    push
    jump parse
  block.end.44508:
  quit
block.end.44523:
# this error is when the error should have been trapped earlier
testis "nom.untrapped.error*"
jumpfalse block.end.44858
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
block.end.44858:
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
jump block.end.45383
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
block.end.45383:
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
jump block.end.45594
  clear
  add "* misplaced } or ; or > or ) character?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.45594:
testbegins "B*"
jumptrue 4
testbegins "E*"
jumptrue 2 
jump block.end.45879
  testends "!*"
  jumpfalse block.end.45875
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
  block.end.45875:
block.end.45879:
testbegins "B*"
jumpfalse 5
testis "B*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.46086
  clear
  add "* misplaced begin-test modifier 'B' ?"
  add "  eg: B'##' { d; add 'heading*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46086:
testbegins "E*"
jumpfalse 5
testis "E*"
jumptrue 3
testends "quoted*"
jumpfalse 2 
jump block.end.46289
  clear
  add "* misplaced end-test modifier 'E' ?"
  add "  eg: E'.' { d; add 'phrase*'; push; .reparse } "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.46289:
# empty quote after B or E
testbegins "E*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.46585
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.46552
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
  block.end.46552:
  clear
  add "E*quoted*"
block.end.46585:
testbegins "B*"
jumpfalse 3
testends "quoted*"
jumptrue 2 
jump block.end.46852
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.46819
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
  block.end.46819:
  clear
  add "B*quoted*"
block.end.46852:
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
jump block.end.47213
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
block.end.47213:
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
jump block.end.47439
  clear
  add "* misplaced comma ?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47439:
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
jump block.end.47637
  clear
  add "* misplaced dot?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47637:
# error eg: {}
testbegins "{*"
jumpfalse 3
testends "}*"
jumptrue 2 
jump block.end.47760
  clear
  add "* empty block {} "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.47760:
# error eg: { ,
testbegins "{*"
jumpfalse 3
testis "{*"
jumpfalse 2 
jump block.end.47968
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
  jump block.end.47964
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
  block.end.47964:
block.end.47968:
# try to diagnose missing close brace errors at end of script
# eg ortest*{*statement*
# we probably need a line/char number in the tape cell
testeof 
jumpfalse block.end.48424
  testis "{*statement*"
  jumptrue 4
  testis "{*statementset*"
  jumptrue 2 
  jump block.end.48420
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
  block.end.48420:
block.end.48424:
# missing dot
# error eg: clear; reparse 
testbegins ".*"
jumptrue 5
testends "word*"
jumpfalse 3
testis "word*"
jumpfalse 2 
jump block.end.48698
  push
  push
  --
  get
  ++
  testis "reparse"
  jumptrue 4
  testis "restart"
  jumptrue 2 
  jump block.end.48673
    clear
    add "* missing dot before reparse/restart ? "
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.48673:
  clear
  pop
  pop
block.end.48698:
# error eg: ( add
# currently brackets are only used for tests
testbegins "(*"
jumpfalse 5
testis "(*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.48891
  clear
  add "* strange syntax after '(' "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.48891:
testis "<*;*"
jumpfalse block.end.49097
  clear
  add "* '<' used to be an abbreviation for '--' \n"
  add "* but no-longer (mar 2025) since it clashes with <eof> etc "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49097:
# error eg: < add
# currently angle brackets are only used for tests ( <eof> <==> ) 
testbegins "<*"
jumpfalse 5
testis "<*"
jumptrue 3
testends "word*"
jumpfalse 2 
jump block.end.49303
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49303:
testis ">*;*"
jumpfalse block.end.49511
  clear
  add "* '>' used to be an abbreviation for '++' \n"
  add "  but no-longer (mar 2025) since it clashes with <eof> etc \n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49511:
# error eg: begin add
testbegins "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.49727
  clear
  add "* begin is always followed by a brace.\n"
  add "   eg: begin { delim '/'; }\n"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49727:
# error eg: clear; begin { clear; }
testends "begin*"
jumpfalse 5
testis "begin*"
jumptrue 3
testbegins "comment*"
jumpfalse 2 
jump block.end.49917
  clear
  add "* only comments can precede a begin block."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.49917:
testis "command*}*"
jumpfalse block.end.50241
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
block.end.50241:
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
jump block.end.50415
  clear
  add "* bad command syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.50415:
# specific analysis of the token sequences permitted above
testis "command*class*"
jumpfalse block.end.50790
  clear
  get
  testis "while"
  jumptrue 3
  testis "whilenot"
  jumpfalse 2 
  jump block.end.50753
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
  block.end.50753:
  clear
  add "command*class*"
block.end.50790:
testis "command*quoted*"
jumpfalse block.end.51670
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
  jump block.end.51155
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
  block.end.51155:
  # check that not empty argument.
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.51632
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
  block.end.51632:
  clear
  add "command*quoted*"
block.end.51670:
testis "command*;*"
jumpfalse block.end.51998
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
  jump block.end.51965
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
  block.end.51965:
  clear
  add "command*;*"
block.end.51998:
# end-of-script 2 token command errors.
testeof 
jumpfalse block.end.52402
  testends "command*"
  jumpfalse block.end.52210
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.52210:
  testis "command*quoted*"
  jumptrue 4
  testis "command*class*"
  jumptrue 2 
  jump block.end.52398
    clear
    add "* unterminated command '"
    get
    add "' at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.52398:
block.end.52402:
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
jump block.end.52629
  clear
  add " dubious syntax (eg: missing semicolon ';') after quoted text."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.52629:
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
jump block.end.52882
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
block.end.52882:
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
jump block.end.53106
  clear
  add "* bad syntax after word."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53106:
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
jump block.end.53262
  clear
  add "* bad test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53262:
# error "xx","yy"."zz"
testbegins "ortest*"
jumpfalse 5
testis "ortest*"
jumptrue 3
testends ".*"
jumptrue 2 
jump block.end.53422
  clear
  add "* AND '.' operator in OR test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53422:
# error eg: "aa" "abc";
testis "ortest*quoted*"
jumptrue 4
testis "ortest*test*"
jumptrue 2 
jump block.end.53581
  clear
  add "* missing comma in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53581:
# error eg: "aa",E"abc";
testbegins "ortest*"
jumpfalse 7
testis "ortest*"
jumptrue 5
testends ",*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.53742
  clear
  add "* bad OR test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53742:
# error "xx"."yy","zz"
testbegins "andtest*"
jumpfalse 5
testis "andtest*"
jumptrue 3
testends ",*"
jumptrue 2 
jump block.end.53904
  clear
  add "* OR ',' operator in AND test."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.53904:
# error eg: "aa".E"abc";
testis "andtest*quoted*"
jumptrue 4
testis "andtest*test*"
jumptrue 2 
jump block.end.54064
  clear
  add "* missing dot in test?"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.54064:
# error eg: "aa".E"abc";
testbegins "andtest*"
jumpfalse 7
testis "andtest*"
jumptrue 5
testends ".*"
jumptrue 3
testends "{*"
jumpfalse 2 
jump block.end.54228
  clear
  add "* bad AND test syntax."
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.54228:
# end-of-script 2 token test errors.
testeof 
jumpfalse block.end.54478
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
  jump block.end.54474
    clear
    add "* test with no block {} at end of script"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.54474:
block.end.54478:
# error eg: add 'x'; { 
testbegins "statement*"
jumpfalse 3
testis "statement*"
jumpfalse 2 
jump block.end.54666
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.54662
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.54662:
block.end.54666:
# error eg: clear;add 'x'; { 
testbegins "statementset*"
jumpfalse 3
testis "statementset*"
jumpfalse 2 
jump block.end.54866
  testends ",*"
  jumptrue 4
  testends "{*"
  jumptrue 2 
  jump block.end.54862
    clear
    add "* misplaced dot/comma/brace ?"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.54862:
block.end.54866:
# specific command errors
# until, mark, go etc have no-parameter versions
testis "command*;*"
jumpfalse block.end.55203
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
  jump block.end.55170
    clear
    add "* command '"
    get
    add "' requires argument"
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.55170:
  clear
  add "command*;*"
block.end.55203:
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
jump block.end.55561
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
block.end.55561:
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
jump block.end.55804
  clear
  add "* missing semi-colon after statement? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.55804:
# error eg: "cd" "ef" {
testbegins "quoted*quoted*"
jumpfalse 3
testends ";*"
jumpfalse 2 
jump block.end.55964
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.55964:
# error eg: , "cd" "ef"
testends "quoted*quoted*"
jumpfalse 3
testbegins "command*"
jumpfalse 2 
jump block.end.56130
  clear
  add "* missing comma or dot in test? "
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.56130:
testis "command*quoted*quoted*"
jumpfalse block.end.56461
  clear
  get
  testis "replace"
  jumptrue block.end.56416
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
  block.end.56416:
  clear
  add "command*quoted*quoted*"
block.end.56461:
# error eg: clear "x"; already checked above.
# "command*quoted*;*" {}
# error eg: add [:space:] already checked above in 2 tokens
# "command*class*;*" {}
#----------------
# 4 parse token errors
pop
testis "command*quoted*quoted*;*"
jumpfalse block.end.57116
  clear
  get
  testis "replace"
  jumptrue block.end.56873
    clear
    add "* command '"
    get
    add "' does not take 2 arguments."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.56873:
  # check that not 1st argument is empty
  clear
  ++
  get
  --
  testis "\"\""
  jumpfalse block.end.57069
    clear
    add "* empty quoted text '' is an error here."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.57069:
  clear
  add "command*quoted*quoted*;*"
block.end.57116:
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
jump block.end.57449
  # A translator would try to conserve the comment.
  replace "comment*" ""
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.57449:
testends "comment*"
jumpfalse 3
testis "comment*"
jumpfalse 2 
jump block.end.57524
  replace "comment*" ""
  push
  jump parse
block.end.57524:
#------------ 
# The .restart command jumps to the first instruction after the
# begin block (if there is a begin block), or the first instruction
# of the script.
testis ".*word*"
jumpfalse block.end.58424
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.57847
    clear
    add "continue script;"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.57847:
  testis "reparse"
  jumpfalse block.end.58321
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumptrue 3
    testis "1"
    jumpfalse 2 
    jump block.end.58173
      clear
      add "* multiple parse label error?"
      put
      clear
      add "nom.untrapped.error*"
      push
      jump parse
    block.end.58173:
    testis "0"
    jumpfalse block.end.58212
      clear
      add "break lex;"
    block.end.58212:
    testis "1"
    jumpfalse block.end.58256
      clear
      add "continue parse;"
    block.end.58256:
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.58321:
  clear
  add "* invalid statement ."
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.58424:
testis "word*>*"
jumpfalse block.end.58835
  clear
  get
  testis "parse"
  jumpfalse block.end.58805
    clear
    count
    testis "0"
    jumptrue block.end.58651
      clear
      add "script error:\n"
      add "  extra parse> label at line "
      ll
      add ".\n"
      print
      quit
    block.end.58651:
    clear
    add "// parse>"
    put
    clear
    add "parselabel*"
    push
    # use accumulator to indicate after parse> label
    a+
    jump parse
  block.end.58805:
  clear
  add "word*>*"
block.end.58835:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
# eg: E"abc" { ... }
testis "E*quoted*"
jumpfalse block.end.59179
  clear
  add "this.work.characters.endsWith("
  ++
  get
  --
  add ".characters)"
  put
  clear
  add "test*"
  push
  jump parse
block.end.59179:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quoted*"
jumpfalse block.end.59539
  clear
  add "this.work.characters.startsWith("
  ++
  get
  --
  add ".characters)"
  put
  clear
  add "test*"
  push
  jump parse
block.end.59539:
#---------------------------------
# Compiling comments so as to transfer them to the dart code
testis "comment*statement*"
jumptrue 6
testis "statement*comment*"
jumptrue 4
testis "statementset*comment*"
jumptrue 2 
jump block.end.59801
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
block.end.59801:
testis "comment*comment*"
jumpfalse block.end.59914
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
block.end.59914:
# -----------------------
# negated tokens.
#  This format is used to indicate a negative test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
testis "!*test*"
jumpfalse block.end.60260
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
block.end.60260:
# transform quotes and classses to tests, this greatly reduces the number
# of rules required for other reductions
testis ",*quoted*"
jumptrue 6
testis ".*quoted*"
jumptrue 4
testis "!*quoted*"
jumptrue 2 
jump block.end.60512
  push
  clear
  add "this.work == "
  get
  put
  clear
  add "test*"
  push
  jump parse
block.end.60512:
# transform quotes to tests
testis "quoted*,*"
jumptrue 6
testis "quoted*.*"
jumptrue 4
testis "quoted*{*"
jumptrue 2 
jump block.end.60703
  replace "quoted*" "test*"
  push
  push
  --
  --
  add "this.work == "
  get
  put
  ++
  ++
  clear
  jump parse
block.end.60703:
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
jump block.end.61152
  push
  clear
  add "RegExp(r'^"
  get
  add "+$', unicode:true).hasMatch(this.work)"
  put
  clear
  add "test*"
  push
  jump parse
block.end.61152:
# transform classes to tests
testis "class*,*"
jumptrue 6
testis "class*.*"
jumptrue 4
testis "class*{*"
jumptrue 2 
jump block.end.61398
  replace "class*" "test*"
  push
  push
  --
  --
  add "RegExp(r'^"
  get
  add "+$', unicode:true).hasMatch(this.work)"
  put
  ++
  ++
  clear
  jump parse
block.end.61398:
#--------------------------------------------
# ebnf: command := command ';' ;
# formats: "pop; push; clear; print; " etc
testis "command*;*"
jumpfalse block.end.65905
  clear
  get
  # error trap here .
  testis "go"
  jumptrue 65
  testis "mark"
  jumptrue 63
  testis "until"
  jumptrue 61
  testis "clip"
  jumptrue 59
  testis "clop"
  jumptrue 57
  testis "clear"
  jumptrue 55
  testis "upper"
  jumptrue 53
  testis "lower"
  jumptrue 51
  testis "cap"
  jumptrue 49
  testis "print"
  jumptrue 47
  testis "pop"
  jumptrue 45
  testis "push"
  jumptrue 43
  testis "unstack"
  jumptrue 41
  testis "stack"
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
  jump block.end.62001
    clear
    add "  incorrect command syntax?"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.62001:
  # go; not implemented in pars/compile.pss yet (feb 2025)
  testis "go"
  jumpfalse block.end.62166
    clear
    add "this.goToMark(this.tape[this.cell]);  /* go (tape) */"
  block.end.62166:
  testis "mark"
  jumpfalse block.end.62271
    clear
    add "this.addMark(this.tape[this.cell]);  /* mark (tape) */"
  block.end.62271:
  # the new until; command with no argument
  testis "until"
  jumpfalse block.end.62424
    clear
    add "this.until(this.tape[this.cell]);  /* until (tape) */"
  block.end.62424:
  testis "clip"
  jumpfalse block.end.62673
    clear
    # are these length tests really necessary
    #add "if (this.work.isNotEmpty) {  /* clip */\n";
    add "this.work ="
    add " this.work.characters.skipLast(1).toString();"
    #add "\n}";
  block.end.62673:
  testis "clop"
  jumpfalse block.end.62849
    clear
    #add "if (this.work.isNotEmpty) {  /* clop */\n";
    add "this.work ="
    add " this.work.characters.skip(1).toString();"
  block.end.62849:
  testis "clear"
  jumpfalse block.end.62923
    clear
    add "this.work = '';  /* clear */"
  block.end.62923:
  testis "upper"
  jumpfalse block.end.63079
    clear
    add "/* upper */ \n"
    add "this.work = "
    add "this.work.characters.toUpperCase().toString();"
  block.end.63079:
  testis "lower"
  jumpfalse block.end.63235
    clear
    add "/* lower */ \n"
    add "this.work = "
    add "this.work.characters.toLowerCase().toString();"
  block.end.63235:
  testis "cap"
  jumpfalse block.end.63526
    clear
    # capitalize every word not just the first.
    add "/* cap */ \n"
    # ${this[0].toUpperCase()}${substring(1).toLowerCase()}
    add "this.work = '${this.work[0].toUpperCase()}"
    add "${this.work.substring(1).toLowerCase()}';"
  block.end.63526:
  testis "print"
  jumpfalse block.end.63605
    clear
    add "this.write(this.work); /* print */"
  block.end.63605:
  testis "pop"
  jumpfalse block.end.63646
    clear
    add "this.pop();"
  block.end.63646:
  testis "push"
  jumpfalse block.end.63689
    clear
    add "this.push();"
  block.end.63689:
  testis "unstack"
  jumpfalse block.end.63758
    clear
    add "while (this.pop());   /* unstack */"
  block.end.63758:
  testis "stack"
  jumpfalse block.end.63823
    clear
    add "while(this.push());   /* stack */"
  block.end.63823:
  testis "state"
  jumpfalse block.end.63888
    clear
    add "this.printState();    /* state */"
  block.end.63888:
  testis "put"
  jumpfalse block.end.63974
    clear
    add "this.tape[this.cell] = this.work; /* put */"
  block.end.63974:
  testis "get"
  jumpfalse block.end.64069
    clear
    add "this.work += this.tape[this.cell]; /* get */"
  block.end.64069:
  testis "swap"
  jumpfalse block.end.64123
    clear
    add "this.swap(); /* swap */"
  block.end.64123:
  testis "++"
  jumpfalse block.end.64180
    clear
    add "this.increment();   /* ++ */"
  block.end.64180:
  testis "--"
  jumpfalse block.end.64271
    clear
    add "if (this.cell > 0) this.cell--; /* -- */"
  block.end.64271:
  testis "read"
  jumpfalse block.end.64410
    clear
    # return from parse on eof
    add "if (this.eof) { return; } this.read(); /* read */"
  block.end.64410:
  testis "count"
  jumpfalse block.end.64516
    clear
    add "this.work += this.accumulator.toString(); /* count */"
  block.end.64516:
  testis "a+"
  jumpfalse block.end.64573
    clear
    add "this.accumulator++; /* a+ */"
  block.end.64573:
  testis "a-"
  jumpfalse block.end.64630
    clear
    add "this.accumulator--; /* a- */"
  block.end.64630:
  testis "zero"
  jumpfalse block.end.64693
    clear
    add "this.accumulator = 0; /* zero */"
  block.end.64693:
  testis "chars"
  jumpfalse block.end.64790
    clear
    add "this.work += this.charsRead.toString(); /* chars */"
  block.end.64790:
  testis "lines"
  jumpfalse block.end.64886
    clear
    add "this.work += this.linesRead.toString(); /* lines */"
  block.end.64886:
  testis "nochars"
  jumpfalse block.end.64953
    clear
    add "this.charsRead = 0; /* nochars */"
  block.end.64953:
  testis "nolines"
  jumpfalse block.end.65020
    clear
    add "this.linesRead = 0; /* nolines */"
  block.end.65020:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.65118
    clear
    add "break script; /* quit */"
  block.end.65118:
  testis "write"
  jumpfalse block.end.65181
    clear
    add "this.writeToFile(); /* write */"
  block.end.65181:
  testis "system"
  jumpfalse block.end.65734
    clear
    add "\n"
    add "       /* system */\n"
    add "       try {\n"
    add "         var result = await Process.run(this.work, [], runInShell: true);\n"
    add "         if (result.exitCode == 0) {\n"
    add "           this.work = result.stdout;\n"
    add "           // print('result: ${result.stdout}');\n"
    add "         } else {\n"
    add "           this.work = ''; this.accumulator = -111;\n"
    add "           // print('Command failed: ${result.stderr}');\n"
    add "         }\n"
    add "       } catch (e) { this.work = ''; this.accumulator = -111; } "
    # align with indentation
    replace "\n       " "\n"
  block.end.65734:
  # just eliminate no-operation since it does nothing.
  testis "nop"
  jumpfalse block.end.65845
    clear
    add "/* nop: does nothing */"
  block.end.65845:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.65905:
testis "statementset*statement*"
jumptrue 4
testis "statement*statement*"
jumptrue 2 
jump block.end.66054
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
block.end.66054:
# ----------------
# 3 grammar parse tokens 
pop
testis "(*word*)*"
jumptrue 4
testis "<*word*>*"
jumptrue 2 
jump block.end.66465
  clear
  ++
  get
  --
  testis "eof"
  jumptrue 3
  testis "=="
  jumpfalse 2 
  jump block.end.66296
    clear
    add "* invalid test <> or () ."
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.66296:
  testis "eof"
  jumpfalse block.end.66344
    clear
    add "this.eof"
  block.end.66344:
  testis "=="
  jumpfalse block.end.66416
    clear
    add "this.tape[this.cell] == this.work"
  block.end.66416:
  put
  clear
  add "test*"
  push
  jump parse
block.end.66465:
#--------------------------------------------
# quoted text is already double quoted eg "abc" 
# eg: add "text";
testis "command*quoted*;*"
jumpfalse block.end.68068
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
  jump block.end.66922
    clear
    add "  superfluous argument or other error?\n"
    add "  (error should have been trapped in error block: check)"
    put
    clear
    add "nom.untrapped.error*"
    push
    jump parse
  block.end.66922:
  testis "mark"
  jumpfalse block.end.67010
    clear
    add "this.addMark("
    ++
    get
    --
    add "); /* mark */"
  block.end.67010:
  testis "go"
  jumpfalse block.end.67095
    clear
    add "this.goToMark("
    ++
    get
    --
    add "); /* go */"
  block.end.67095:
  testis "delim"
  jumpfalse block.end.67359
    # dart does not have a char type I believe. 
    # only the first character of the delimiter argument should be used. 
    clear
    add "this.delimiter = "
    ++
    get
    --
    add ".characters.characterAt(0).toString(); /* delim */"
  block.end.67359:
  testis "add"
  jumpfalse block.end.67591
    # use dart raw string? no because I want \n to work in add
    clear
    add "this.work += "
    ++
    get
    --
    # handle multiline text
    replace "\n" "\"; \nthis.work += \"\\n"
    add "; /* add */"
  block.end.67591:
  # no while/whilenot "quoted"; syntax
  testis "until"
  jumpfalse block.end.67777
    clear
    add "this.until("
    ++
    get
    --
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
  block.end.67777:
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.68013
    # only use the first char or grapheme cluster of escape argument
    clear
    add "this."
    get
    add "Char"
    add "("
    ++
    get
    --
    add ".characters.characterAt(0).toString());"
  block.end.68013:
  put
  clear
  add "statement*"
  push
  jump parse
block.end.68068:
# eg: while [:alpha:]; or whilenot [a-z];
testis "command*class*;*"
jumpfalse block.end.68876
  clear
  get
  # convert to dart code. 
  testis "while"
  jumpfalse block.end.68472
    clear
    add "/* while */\n"
    # unicode syntax
    add "while (RegExp(r'"
    ++
    get
    --
    add "', unicode:true).hasMatch(this.peep)) {\n"
    add "  if (this.eof) { break; } this.read();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.68472:
  testis "whilenot"
  jumpfalse block.end.68748
    clear
    add "/* whilenot */ \n"
    add "while (!RegExp(r'"
    ++
    get
    --
    add "', unicode:true).hasMatch(this.peep)) {\n"
    add "  if (this.eof) { break; } this.read();\n}"
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.68748:
  clear
  add "*** unchecked error in rule: statement = command class ;"
  put
  clear
  add "nom.error*"
  push
  jump parse
block.end.68876:
# brackets around tests will be ignored.
testis "(*test*)*"
jumpfalse block.end.69008
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.69008:
# brackets will allow mixing AND and OR logic 
testis "(*ortest*)*"
jumptrue 4
testis "(*andtest*)*"
jumptrue 2 
jump block.end.69163
  clear
  ++
  get
  --
  put
  clear
  add "test*"
  push
  jump parse
block.end.69163:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "test*,*test*"
jumptrue 4
testis "ortest*,*test*"
jumptrue 2 
jump block.end.69635
  # OR logic concatenation 
  # put brackets around tests even though operator 
  # precedence should take care of it
  testis "test*,*test*"
  jumpfalse block.end.69499
    clear
    add "("
    get
    add ")"
  block.end.69499:
  testis "ortest*,*test*"
  jumpfalse block.end.69536
    clear
    get
  block.end.69536:
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
block.end.69635:
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
jump block.end.70145
  # AND logic concatenation 
  # add brackets 
  testis "test*.*test*"
  jumpfalse block.end.70007
    clear
    add "("
    get
    add ")"
  block.end.70007:
  testis "andtest*.*test*"
  jumpfalse block.end.70045
    clear
    get
  block.end.70045:
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
block.end.70145:
# dont need to reparse 
testis "{*statement*}*"
jumpfalse block.end.70223
  replace "ment*" "mentset*"
block.end.70223:
# ----------------
# 4 grammar parse tokens 
pop
# see below
# "command*quoted*quoted*;*" { clear; add "statement*"; push; .reparse }
# eg:  replace "and" "AND" ; 
testis "command*quoted*quoted*;*"
jumpfalse block.end.71026
  clear
  get
  testis "replace"
  jumpfalse block.end.70899
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    # multiline replace? no.
    clear
    add "/* replace */ \n"
    add "if (this.work.isNotEmpty) { \n"
    add "  this.work = this.work.characters.replaceAll("
    ++
    get
    add ".characters, "
    ++
    get
    add ".characters).toString();\n}"
    --
    --
    put
    clear
    add "statement*"
    push
    jump parse
  block.end.70899:
  # error trap
  clear
  add "  incorrect command syntax?"
  put
  clear
  add "nom.untrapped.error*"
  push
  jump parse
block.end.71026:
# reducing blocks
testis "test*{*statementset*}*"
jumptrue 6
testis "ortest*{*statementset*}*"
jumptrue 4
testis "andtest*{*statementset*}*"
jumptrue 2 
jump block.end.71384
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
block.end.71384:
testis "begin*{*statementset*}*"
jumpfalse block.end.71842
  clear
  # need to add a 'begin {} rust block so as to implement
  # .restart and .reparse in the begin block.
  ++
  ++
  add "begin: {\n"
  get
  replace "\n" "\n  "
  add "\n}"
  # make .restart work
  replace "continue script;" "break begin;"
  # make .reparse work
  replace "break lex;" "jumptoparse=true;break begin;"
  --
  --
  put
  clear
  add "beginblock*"
  push
  jump parse
block.end.71842:
# end of input stream errors
testeof 
jumpfalse block.end.72042
  testis "test*"
  jumptrue 8
  testis "ortest*"
  jumptrue 6
  testis "andtest*"
  jumptrue 4
  testis "begin*"
  jumptrue 2 
  jump block.end.72038
    clear
    add "* Incomplete script."
    put
    clear
    add "nom.error*"
    push
    jump parse
  block.end.72038:
block.end.72042:
# cannot be reduced to one push;
push
push
push
push
pop
pop
pop
testeof 
jumpfalse block.end.73335
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  # dart has labelled loops
  testis "statementset*parselabel*statementset*"
  jumpfalse block.end.73331
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
    add "script:\n"
    add "while (true) {\n"
    add "  lex: { \n"
    add "    if (jumptoparse) { jumptoparse=false;break lex; }\n"
    get
    add "\n  } /* lex block */\n"
    add "  parse: \n"
    # need while true because you cant continue a labelled block
    add "   while (true) {\n"
    ++
    ++
    get
    --
    --
    add "\n    break parse;  /* run-once parse loop */"
    add "\n  } /* parse block */"
    add "\n} /* nom script loop */"
    put
    clear
    add "script*"
    push
    jump parse
    # actually this "run-once" thing is not required. Just a brace block. 
    # add "  while (true) { \n"; ++; ++; get; --; --;
  block.end.73331:
block.end.73335:
push
push
push
# this cannot be reduced to 'push;'
pop
pop
testeof 
jumpfalse block.end.74623
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*parselabel*"
  jumpfalse block.end.74063
    clear
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    add "script:\n"
    add "while (true) {\n"
    add "  lex: { \n"
    add "    if (jumptoparse) { jumptoparse=false;break lex; }\n"
    get
    add "\n  } /* lex block */\n"
    add "  parse:"
    add "\n} /* while true (nom script loop) */"
    put
    clear
    add "script*"
    push
    jump parse
  block.end.74063:
  testis "parselabel*statementset*"
  jumpfalse block.end.74496
    clear
    add "    "
    ++
    get
    --
    replace "\n" "\n    "
    put
    clear
    add "script:\n"
    add "while (true) {\n"
    add "  parse: \n"
    add "  while (true) { \n"
    get
    add "\n    break parse;  /* run-once parse loop */"
    add "\n  } /* parse block */"
    add "\n} /* nom script loop */"
    put
    clear
    add "script*"
    push
    jump parse
  block.end.74496:
  testis "beginblock*script*"
  jumpfalse block.end.74619
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
  block.end.74619:
block.end.74623:
# cannot reduce to push
push
push
pop
testeof 
jumpfalse block.end.75287
  # need to arrange the labelled loops or gotos here. Because the 
  # loop cannot include the beginblock.
  # just a trick to make the following rules simpler
  replace "statement*" "statementset*"
  testis "statementset*"
  jumpfalse block.end.75187
    clear
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    add "script:\n"
    # but how will reparse work here? fix:
    add "while (true) {\n"
    get
    add "\n} /* while true (nom script loop) */"
    put
    clear
    add "script*"
    push
    jump parse
  block.end.75187:
  testis "beginblock*"
  jumptrue 6
  testis "comment*"
  jumptrue 4
  testis "parselabel*"
  jumptrue 2 
  jump block.end.75283
    clear
    add "script*"
    push
    jump parse
  block.end.75283:
block.end.75287:
push
push
push
push
testeof 
jumpfalse block.end.90358
  pop
  pop
  testis ""
  jumpfalse block.end.75405
    add "// empty nom script\n"
    print
    quit
  block.end.75405:
  testis "script*"
  jumptrue block.end.75695
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
  block.end.75695:
  clear
  add "/* good syntax. */\n"
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
  add " /* Dart code generated by \"nom.todart.pss\" */\n"
  add " import \"dart:io\";\n"
  add " import \"dart:convert\";\n"
  add " import \"package:characters/characters.dart\";\n"
  add "\n"
  add " /* I am using Dart Strings not stringbuffers because the \n"
  add "    string class seems to give better unicode support through the \n"
  add "    characters api. And unicode is essential */\n"
  add "\n"
  add " enum inputType { stdin, string, file }\n"
  add " enum outputType { stdout, string, file }\n"
  add "\n"
  add " class Machine {\n"
  add "   int accumulator = 0;         // counter for anything\n"
  add "   String peep = \"\";            // next char in input stream\n"
  add "   int charsRead = 0;           // No. of chars read so far\n"
  add "   int linesRead = 1;           // No. of lines read so far\n"
  add "   String work = \"\";            // text manipulation buffer \n"
  add "   // just treat this like a stack\n"
  add "   var stack = <String>[];   // parse token stack\n"
  add "   int tapeLength = 100;     // tape initial length. This may not be \n"
  add "                             // necessary in dart.\n"
  add "   var tape = <String>[];    // array of token attributes \n"
  add "   var marks = <String>[];   // tape marks\n"
  add "   int cell = 0;             // pointer to current cell\n"
  add "   inputType sourceType = inputType.stdin;   // whether from string,stdin,file\n"
  add "   outputType sinkType =  outputType.stdout; // whether to string,stdout,file\n"
  add "   Stream<List<int>> inputSource = stdin;    // text input stream ie stdin or file\n"
  add "   // Stream<List<int>> outputSource = stdout;  // text outputstream \n"
  add "                                             // ie stdout or file or string\n"
  add "\n"
  add "   // may have to load all the input lines from file or string here.\n"
  add "   // use File.readAsLinesSync and LineSplitter for string input.\n"
  add "   // LineSplitter ls = new LineSplitter();\n"
  add "   // List<String> l = ls.convert(text);\n"
  add "   List<String> inputLines = <String>[];\n"
  add "   StringBuffer outputBuffer = StringBuffer(\"\");\n"
  add "   String lineBuffer = \"\";    // one line of text input as characters.\n"
  add "   bool eof = false;     // end of stream reached?\n"
  add "   String escape = \"\\\\\";   // char used to \"escape\" others \"\\\"\n"
  add "   String delimiter = \"*\";   // push/pop delimiter (default is \"*\")\n"
  add "   bool markFound = false;   // if the mark was found in tape\n"
  add "   \n"
  add "   /** make a new machine with a character stream reader */\n"
  add "   Machine() {\n"
  add "     // stdin is the default\n"
  add "     this.sourceType = inputType.stdin;\n"
  add "     this.sinkType = outputType.stdout;\n"
  add "     for (int ii = 0; ii < this.tapeLength; ii++) {\n"
  add "       this.tape.add(\"\"); this.marks.add(\"\");\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** read one character from the input stream and \n"
  add "       update the machine. This reads though a lineBuffer so as to\n"
  add "       handle unicode grapheme clusters (which can be more than \n"
  add "       one \"character\"). This method refills the lineBuffer when empty\n"
  add "       either from stdin or from the inputLines List cache. */\n"
  add "   void read() {\n"
  add "     int iChar;\n"
  add "     String? s;\n"
  add "     try {\n"
  add "       // this should not be called in the parse() method\n"
  add "       // because parse() should return, not quit.\n"
  add "       if (this.eof) { exit(0); /* print(\"eof exit\"); */ }\n"
  add "       this.charsRead++;\n"
  add "       // increment lines\n"
  add "       if (this.peep == \"\\n\") { this.linesRead++; }\n"
  add "       this.work += this.peep;\n"
  add "\n"
  add "       // refill the line buffer if empty\n"
  add "       if (this.lineBuffer.isEmpty) { \n"
  add "         if (this.sourceType == inputType.stdin) {\n"
  add "           // retaining newline is important. otherwise need some\n"
  add "           // hack to reput them, and another hack to remove trailing\n"
  add "           // newline at EOF\n"
  add "           s = stdin.readLineSync(retainNewlines:true);\n"
  add "\n"
  add "           // try to make ms windows line ending \\r\\n or \\r into unix \\n\n"
  add "           // untested on ms windows.\n"
  add "           s = s?.replaceAll(\"\\r\\n\",\"\\n\"); \n"
  add "           // apparently, sometime ms endings can be just \\r\n"
  add "           s = s?.replaceAll(\"\\r\",\"\\n\"); \n"
  add "\n"
  add "         } else if ((this.sourceType == inputType.file) || \n"
  add "                   (this.sourceType == inputType.string)) {\n"
  add "           if (this.inputLines.isEmpty) {\n"
  add "             s = null;\n"
  add "           } else {\n"
  add "             s = this.inputLines.first;\n"
  add "             /*\n"
  add "              File.readAsLinesSync seems to remove line endings\n"
  add "              as does the LineSplitter class for strings.\n"
  add "              restore all and normalise to unix LF. The code below may add\n"
  add "              and extra newline at the end of the input, but I think we can\n"
  add "              live with that.\n"
  add "             */ \n"
  add "             // if (this.inputLines.length > 1) { s = s + \"\\n\"; }\n"
  add "             s = s + \"\\n\";\n"
  add "             this.inputLines.removeAt(0);\n"
  add "           } \n"
  add "           \n"
  add "         } else {\n"
  add "           print(\"Unsupported input type (not stdin/file/string)\");\n"
  add "           exit(1);\n"
  add "         }\n"
  add "\n"
  add "         if (s != null) { \n"
  add "           this.lineBuffer = s; \n"
  add "         } else { \n"
  add "           this.eof = true;\n"
  add "           this.peep = \"\";\n"
  add "         }\n"
  add "         //stdout.write(\"input:\" + this.lineBuffer);\n"
  add "       }\n"
  add "\n"
  add "       if (this.eof == false) {\n"
  add "         // throws \"bad state\" StateError error if no characters.\n"
  add "         this.peep = this.lineBuffer.characters.first; \n"
  add "         this.lineBuffer = \n"
  add "           this.lineBuffer.characters.skip(1).toString();\n"
  add "       }\n"
  add "     }\n"
  add "     catch (e) {\n"
  add "       this.printState();\n"
  add "       print(\"nom.todart: Error in machine.read() method: \" + e.toString());\n"
  add "       exit(-1);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /* write to current machine destination (stdout/string/file) */\n"
  add "   void write(String output) {\n"
  add "     if (this.sinkType == outputType.stdout) {\n"
  add "       stdout.write(output);\n"
  add "     } else if (this.sinkType == outputType.file) {\n"
  add "       // a string buffer \n"
  add "       this.outputBuffer.write(output);\n"
  add "     } else if (this.sinkType == outputType.string) {\n"
  add "       this.outputBuffer.write(output);\n"
  add "     }\n"
  add "   }\n"
  add "   \n"
  add "\n"
  add "   /** increment tape pointer by one */\n"
  add "   void increment() {\n"
  add "     this.cell++;\n"
  add "     if (this.cell >= this.tapeLength) {\n"
  add "       this.tape.add(\"\");\n"
  add "       this.marks.add(\"\");\n"
  add "       this.tapeLength++;\n"
  add "     }\n"
  add "   }\n"
  add "   \n"
  add "   /** remove escape character  */\n"
  add "   void unescapeChar(String c) {\n"
  add "     // dont unescape chars that are not escaped!\n"
  add "     int countEscapes = 0;\n"
  add "     String s = \"\"; String nextChar = \"\";\n"
  add "     if (this.work.isEmpty) { return; }\n"
  add "     for (nextChar in this.work.characters) {\n"
  add "       if ((nextChar == c ) && (countEscapes % 2 == 1)) { \n"
  add "         s = s.characters.skipLast(1).toString();\n"
  add "       }\n"
  add "       if (nextChar == this.escape) \n"
  add "         { countEscapes++; } else { countEscapes = 0; }\n"
  add "       s += nextChar;\n"
  add "     }\n"
  add "     this.work = s;\n"
  add "   }\n"
  add "\n"
  add "   /** add escape character  */\n"
  add "   void escapeChar(String c) {\n"
  add "     // dont escape chars that are already escaped!\n"
  add "     int countEscapes = 0;\n"
  add "     String s = \"\"; String nextChar = \"\";\n"
  add "     if (this.work.isEmpty) { return; }\n"
  add "     for (nextChar in this.work.characters) {\n"
  add "       if ((nextChar == c ) && (countEscapes % 2 == 0)) { s += this.escape; }\n"
  add "       if (nextChar == this.escape) \n"
  add "         { countEscapes++; } else { countEscapes = 0; }\n"
  add "       s += nextChar;\n"
  add "     }\n"
  add "     this.work = s;\n"
  add "   }\n"
  add "\n"
  add "   /* a helper to see how many trailing \\\\ escape chars. I need to \n"
  add "      do this because the suffix for until can be multiple chars. */\n"
  add "   int countEscaped(String sSuffix) {\n"
  add "     String s = \"\";\n"
  add "     int count = 0;\n"
  add "     int index = 0;\n"
  add "     // remove suffix if it exists\n"
  add "     if (this.work.endsWith(sSuffix)) {\n"
  add "       s = this.work.substring(0, this.work.lastIndexOf(sSuffix));\n"
  add "     } else { s = this.work; }\n"
  add "     while (s.endsWith(this.escape)) {\n"
  add "       count++;\n"
  add "       s = s.substring(0, s.lastIndexOf(this.escape));\n"
  add "     }\n"
  add "     return count;\n"
  add "   }\n"
  add "\n"
  add "   /** reads the input stream until the workspace ends with text */\n"
  add "   // can test this with\n"
  add "   void until(String suffix) {\n"
  add "     // read at least one character\n"
  add "     if (this.eof) return; \n"
  add "     this.read();\n"
  add "     while (true) {\n"
  add "       if (this.eof) return;\n"
  add "       if (this.work.endsWith(suffix)) {\n"
  add "         if (this.countEscaped(suffix) % 2 == 0) { return; }\n"
  add "       }\n"
  add "       this.read();\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** pop the first token from the stack into the workspace */\n"
  add "   bool pop() {\n"
  add "     if (this.stack.isEmpty) return false;\n"
  add "     this.work = this.stack.last + this.work;\n"
  add "     this.stack.removeLast();\n"
  add "     if (this.cell > 0) this.cell--;\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /** push the first token from the workspace to the stack */\n"
  add "   bool push() {\n"
  add "     // need to use characters api. not string methods.\n"
  add "     \n"
  add "     List<Characters> parts = [];   \n"
  add "     // dont increment the tape pointer on an empty push\n"
  add "     if (this.work.isEmpty) return false;\n"
  add "\n"
  add "     // the delimiter should be guaranteed to be one unicode char\n"
  add "     //  this.delimiter.characters.first.toString())) {\n"
  add "\n"
  add "     if (!this.work.characters.contains(this.delimiter)) {\n"
  add "       this.stack.add(this.work);\n"
  add "       this.work = \"\";\n"
  add "     } else {\n"
  add "       parts = this.work.characters.split(\n"
  add "         this.delimiter.characters, 2).toList();\n"
  add "       this.stack.add(parts[0].toString() + this.delimiter.characters.first);\n"
  add "       this.work = parts[1].toString();\n"
  add "     }\n"
  add "\n"
  add "     this.increment(); \n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /** swap current tape cell with the workspace */\n"
  add "   void swap() {\n"
  add "     String s = this.work;\n"
  add "     this.work = this.tape[this.cell];\n"
  add "     this.tape[this.cell] = s;\n"
  add "   }\n"
  add "\n"
  add "   /** save the workspace to file \"sav.pp\" */\n"
  add "   void writeToFile() {\n"
  add "     try {\n"
  add "       File file = new File(\"sav.pp\");\n"
  add "       file.writeAsStringSync(this.work);\n"
  add "     } catch (e) {\n"
  add "       stdout.write(\"could not write file: $e\"); \n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   void goToMark(String mark) {\n"
  add "     var ii = this.marks.indexOf(mark);\n"
  add "     if (ii != -1) {\n"
  add "       this.cell = ii;\n"
  add "     } else {\n"
  add "       stdout.write(\"badmark \'\" + mark + \"\'!\"); \n"
  add "       exit(1);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /* remove existing marks with the same name and add new mark */\n"
  add "   void addMark(String mark) {\n"
  add "     var ii = this.marks.indexOf(mark);\n"
  add "     while (ii != -1) {\n"
  add "       this.marks[ii] = \"\";\n"
  add "       ii = this.marks.indexOf(mark);\n"
  add "     }\n"
  add "     this.marks[this.cell] = mark; \n"
  add "   }\n"
  add "\n"
  add "   /** check if the workspace matches given class: \n"
  add "       see the nom.tolua.pss translator for a utf8 match class \n"
  add "       implementation. */\n"
  add "   bool matchClass(String charclass) {\n"
  add "     // but regExp cant handle emojis?\n"
  add "     var regExp = RegExp(r\'^\' + charclass + r\'+$\', unicode:true);\n"
  add "     return regExp.hasMatch(this.work); \n"
  add "   }\n"
  add "\n"
  add "   /* print the internal state of the pep/nom parsing machine. This \n"
  add "      is handy for debugging, but for some reason I took this command\n"
  add "      out of some translators ... */\n"
  add "\n"
  add "   void printState() {\n"
  add "      var displayPeep = \n"
  add "        this.peep.characters.replaceAll(\"\\n\".characters,\"\\\\n\".characters);\n"
  add "      displayPeep = \n"
  add "        displayPeep.replaceAll(\"\\r\".characters,\"\\\\r\".characters);\n"
  add "      var displayBuffer = \n"
  add "        this.lineBuffer.characters.replaceAll(\n"
  add "          \"\\n\".characters,\"\\\\n\".characters);\n"
  add "      displayBuffer = \n"
  add "        displayBuffer.replaceAll( \"\\r\".characters,\"\\\\r\".characters);\n"
  add "\n"
  add "      print(\"\\n--------- Machine State ------------- \");\n"
  add "      print(\"(line buffer:${displayBuffer})\");\n"
  add "      stdout.write(\"Stack${this.stack} \");\n"
  add "      stdout.write(\"Work[${this.work}] \");\n"
  add "      stdout.write(\"Peep[${displayPeep}]\\n\");\n"
  add "      stdout.write(\"Acc:${this.accumulator} \");\n"
  add "      stdout.write(\"EOF:${this.eof} \");\n"
  add "      stdout.write(\"Esc:${this.escape} \");\n"
  add "      stdout.write(\"Delim:${this.delimiter} \");\n"
  add "      stdout.write(\"Chars:${this.charsRead} \");\n"
  add "      stdout.write(\"Lines:${this.linesRead}\\n\");\n"
  add "      print(\"-------------- Tape ----------------- \");\n"
  add "      print(\"Tape Size: ${tapeLength}\");\n"
  add "      var start = this.cell - 3; \n"
  add "      var end = this.cell + 3; \n"
  add "      if (start < 0) { start = 0; }\n"
  add "      for (var ii = start; ii <= end; ii++) {\n"
  add "        stdout.write(\"   ${ii}\");\n"
  add "        if (ii == this.cell) { stdout.write(\"> [\"); }\n"
  add "        else { stdout.write(\"  [\"); }\n"
  add "        stdout.write(\"${this.tape[ii]}]\\n\");\n"
  add "      }\n"
  add "   }\n"
  add "\n"
  add "   /* makes the machine read from stdin and write to stdin\n"
  add "      this is the default and should be set at the start of the \n"
  add "      parse method if no other sourceType is set */\n"
  add "   void setStandardInput(String input) {\n"
  add "     this.sourceType = inputType.stdin;\n"
  add "     this.sinkType = outputType.stdout;\n"
  add "     // .... incomplete.\n"
  add "   }\n"
  add "\n"
  add "   /* makes the machine read from a string */\n"
  add "   void setStringInput(String input) {\n"
  add "     this.sourceType = inputType.string;\n"
  add "     LineSplitter ll = new LineSplitter();\n"
  add "     this.inputLines = ll.convert(input); \n"
  add "   }\n"
  add "\n"
  add "   /* makes the machine write to a string */\n"
  add "   void setStringOutput(String input) {\n"
  add "     this.sinkType = outputType.string;\n"
  add "   }\n"
  add "\n"
  add "   /* parse/translate from a string and return the translated\n"
  add "       string */\n"
  add "   String parseString(String input) {\n"
  add "     this.setStringInput(input);\n"
  add "     this.sinkType = outputType.string;\n"
  add "     this.parse();\n"
  add "     return this.outputBuffer.toString();\n"
  add "   }\n"
  add "\n"
  add "   /* makes the machine read from a file stream, not from \n"
  add "      stdin */\n"
  add "   void setFileInput(String fileName) {\n"
  add "     File inputFile = File(fileName);\n"
  add "     if (!inputFile.existsSync()) {\n"
  add "       print(\"File Doesnt exist\");\n"
  add "       exit(1);\n"
  add "     }\n"
  add "     // I couldnt work out how to make streams work with dart and pep/nom\n"
  add "     // so I am just reading the whole file into a cache.\n"
  add "     this.sourceType = inputType.file;\n"
  add "     this.inputLines = inputFile.readAsLinesSync(encoding:utf8);\n"
  add "   }\n"
  add "\n"
  add "   /* parse from a file and put result in file */\n"
  add "   void parseFile(String inputFile, String outputFile) {\n"
  add "     this.setFileInput(inputFile);\n"
  add "     this.sinkType = outputType.file;\n"
  add "     this.parse();\n"
  add "     // result may be in this.outputBuffer\n"
  add "   }\n"
  add "\n"
  add "   /* I dont know how to do this with dart and nom \n"
  add "   void parseStream(Stream<List<int>> input) {\n"
  add "     this.inputSource = input;\n"
  add "     this.parse();\n"
  add "   }\n"
  add "\n"
  add "   */\n"
  add "\n"
  add "    /** parse with the machines input steam */\n"
  add "    void parse() {\n"
  add "      bool jumptoparse = false;\n"
  add "      try { this.read(); this.charsRead = 0; } \n"
  add "      catch (e) { print(\"read error: \" + e.toString()); exit(-1); }"
  # get the compiled code from the tape
  get
  # terminate the dart program.
  add "\n"
  add "    } /* parse method */\n"
  add "  }\n"
  add "  void main() { \n"
  add "    String temp = \"\";    \n"
  add "    Machine mm = new Machine();\n"
  add "    // testing parse a file not stdin\n"
  add "    // parseFile reads from a file and writes to a file.\n"
  add "    // mm.parseFile(\"../index.txt\");\n"
  add "\n"
  add "    // testing parse a string not stdin. parseString reads from a \n"
  add "    // string and writes to a string.\n"
  add "    // final result = mm.parseString(\" ## heading line: \\n next line www.nomlang.org \\n end.\");\n"
  add "    // stdout.write(result);\n"
  add "\n"
  add "    // by default the machine reads from stdin and writes to stdout\n"
  add "    mm.parse();\n"
  add "    // use the accumulator as an exit code.\n"
  add "    exit(mm.accumulator);\n"
  add "\n"
  add "  }  \n"
  print
  quit
block.end.90358:
# end of block
jump start 
