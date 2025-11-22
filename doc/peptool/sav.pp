# Assembled with the script 'compile.pss' 
start:

#  
#ABOUT
#
#  This is another version of a script to transform a "plain" (minimal markup)
#  text document into simple html and css. This is a rewrite of mark.html.pss
#  but does not have lists. I intend to only add the structures which I use
#  frequently.  this script is grammatically simpler than mark.html.pss
#  and feels easier to maintain and extend. 
#
#GRAMMAR TOKENS
#  word*
#    one space delimited word
#  text* 
#    any text including html tags as added
#  space* 
#    whitespace and newlines
#  quoted* 
#    text between double quotes "like this" but one line only.
#  url*
#    anything starting with http:// https:// www. etc
#  file* 
#    a filename
#
#TODO
#
#  
#  think about "quoted". or "quoted", either ending in dot or comma
#  to parse properly.
#
#  lists, but especially definition lists.
#
#DONE 
#
#  images, sort of (need to make a width for the <figure> tag) 
#  made wikipedia links like "link" wp:Peter_Naur
#
#OTHER FILES
#
#  books/pars/www/blog.sh
#    A bash script which contains a set of functions which use this 
#    script to manage blog websites.
#  books/pars/eg/make.html.header.pss
#    Generates the html header and banner for the page (contains css).
#
#NOTES
#
#  The development of this proceeded very quickly. In a few hours I
#  had significant syntax implemented. This was much faster than
#  mark.html.pss and mark.latex.pss
#
#  This is part of an effort to create a pep/nom based blog with
#  rss feed (pars/www/blog.sh) as well as the shrob.org blog
#  and the makethespoon.org site.
#
#  It would be nice to have an "until 'ab','cd','ef'" syntax
#  to that we could parse one line quotes etc. Eg
#    >> until '"','\n';
#  We cant do
#    >> whilenot ["\n]
#  but that has its own problems.
#
#MARKUP FORMAT
#
#  See pars/eg/text.tohtml.format.txt for detailed info about 
#  the minimal markup format that this script recognises and 
#  formats.
#
#  "caption" <image.file.jpg> as an easy image format.
#  and <image.file.jpg> as an image with no caption.
#  
#  No lists, 
#
#  *word* or *some words* emphasis/italic
#  # first level heading
#  ## 2nd level heading
#  ### 3rd level heading
#  
#  hyperlinks:
#    "linktext" http://url.org
#    "more text" file://url.org
#    "some word" local.file.html 
#    "java file" local.file.java
#    and other formats too
#
#  >> single code line starting with '>>'
#  --- multiline code block ending with ,,, 
#  
#  Many other formats and code available.
#
#STATUS
#
#  marking up various formats, see above
#  Script seems to be working well with links headings emphasis.
#  Still missing all lists and all capital heading lines.
#
#HISTORY
#
#  
#  21 feb 2025
#    added a nomsyn:// url schema for writing about nom syntax
#  20 feb 2025
#    really struggled with the images. Had to change the width format
#    to multiples of 5em, because variable length fields were too 
#    hard to extract without regexs
#  13 feb 2025
#    added attributes to images eg <:o:3:<<:imagename.ext> the 
#    parsing is working but have to fix the css and maybe also
#    the <figure> <img> tag interaction.
#  11 feb 2025
#    added forced line breaks >> and horizontal rules
#  9 feb 2025
#    Added some html curly quotes to quoted text which is not a 
#    link. Added ordinal number superscripts in english (which is 
#    a bit silly really. working on images 
#  4 Feb 2025
#    Began this script, created some useful syntax
#
#
read
# newlines and empty lines
testclass [\n]
jumpfalse block.end.3681
  clear
  add "\n"
  put
  # no words on previous line, so this is a blank line
  clear
  count
  testis "0"
  jumpfalse block.end.3518
    clear
    add "<p>\n"
    put
    clear
  block.end.3518:
  # set accumulator == 0 so that we can count words 
  # per line (and know which is the first word)
  clear
  zero
  nochars
  add "space*"
  push
  jump parse
block.end.3681:
# parse space, but maybe [:space:] would be better.
testclass [ \t]
jumpfalse block.end.3827
  while [ \t]
  clear
  add " "
  put
  clear
  add "space*"
  push
  jump parse
block.end.3827:
# ignore other types of space
testclass [:space:]
jumpfalse block.end.3894
  clear
  jump start
block.end.3894:
# everything else is a word
testclass [:space:]
jumptrue block.end.18815
  # read word and increment word counter
  whilenot [:space:]
  a+
  # here parse image files in format <imfile.jpg> before we
  # change > < to entities.
  # --------------
  #B"<" {
  #  E".jpg>",E".jpeg>",E".png>",E".gif>" {
  #    clip; clop; put; clear;
  #    add "imagefile*"; push; .reparse
  #  }
  #}
  # here we build an <img> html tag from minimal and optional markup
  # attributes are <:corners:float:width:filename.ext>
  # this code is quite tricky. See also 
  #   pars/eg/imagetext.tohtml.pss 
  testbegins "<"
  jumpfalse 5
  testends ">"
  jumpfalse 3
  testis "<>"
  jumpfalse 2 
  jump block.end.6818
    testends ".png>"
    jumptrue 10
    testends ".jpg>"
    jumptrue 8
    testends ".jpeg>"
    jumptrue 6
    testends ".bmp>"
    jumptrue 4
    testends ".gif>"
    jumptrue 2 
    jump block.end.6813
      # an example image text format may be 
      # <:0:>>:4em:name.gif> or <name.gif> 
      # The order of the attributes is important but the attributes 
      # are optional eg: <:<<:r:20pt:name.jpg> wont work because the 
      # float attribute '<<' comes before the rounded corner attribute 'r'
      clip
      clop
      put
      clear
      add "<img style='"
      swap
      # we use swap to juggle the built html and the original
      # minimal markup text.
      # :0: is the circle image (avatar) indicator,
      # allow the first colon to be missing
      testbegins ":O:"
      jumptrue 8
      testbegins ":o:"
      jumptrue 6
      testbegins "O:"
      jumptrue 4
      testbegins "o:"
      jumptrue 2 
      jump block.end.5231
        swap
        add "border-radius:50%;"
        swap
        testbegins ":"
        jumpfalse block.end.5216
          clop
        block.end.5216:
        clop
      block.end.5231:
      # small rounded corners on the image
      testbegins ":r:"
      jumptrue 4
      testbegins "r:"
      jumptrue 2 
      jump block.end.5382
        swap
        add "border-radius:5%;"
        swap
        testbegins ":"
        jumpfalse block.end.5367
          clop
        block.end.5367:
        clop
      block.end.5382:
      # large rounded corners 
      testbegins ":R:"
      jumptrue 4
      testbegins "R:"
      jumptrue 2 
      jump block.end.5522
        swap
        add "border-radius:15%;"
        swap
        testbegins ":"
        jumpfalse block.end.5507
          clop
        block.end.5507:
        clop
      block.end.5522:
      # width spec multiple of 5em, allow missing 1st colon
      testbegins ":1:"
      jumptrue 20
      testbegins ":2:"
      jumptrue 18
      testbegins ":3:"
      jumptrue 16
      testbegins ":4:"
      jumptrue 14
      testbegins ":5:"
      jumptrue 12
      testbegins "1:"
      jumptrue 10
      testbegins "2:"
      jumptrue 8
      testbegins "3:"
      jumptrue 6
      testbegins "4:"
      jumptrue 4
      testbegins "5:"
      jumptrue 2 
      jump block.end.5939
        testbegins ":"
        jumpfalse block.end.5690
          clop
        block.end.5690:
        testbegins "1:"
        jumpfalse block.end.5733
          swap
          add "width:5em;"
        block.end.5733:
        testbegins "2:"
        jumpfalse block.end.5777
          swap
          add "width:10em;"
        block.end.5777:
        testbegins "3:"
        jumpfalse block.end.5821
          swap
          add "width:15em;"
        block.end.5821:
        testbegins "4:"
        jumpfalse block.end.5865
          swap
          add "width:20em;"
        block.end.5865:
        testbegins "5:"
        jumpfalse block.end.5909
          swap
          add "width:25em;"
        block.end.5909:
        swap
        clop
      block.end.5939:
      # add a default width
      swap
      testends "em;"
      jumptrue block.end.6012
        add "width:10em;"
      block.end.6012:
      # finish off the style attribute
      add "' "
      swap
      # the float right indicator, it needs to come after :0:
      testbegins ":>>:"
      jumptrue 4
      testbegins ">>:"
      jumptrue 2 
      jump block.end.6257
        swap
        add "class='float-right' "
        swap
        testbegins ":"
        jumpfalse block.end.6236
          clop
        block.end.6236:
        clop
        clop
      block.end.6257:
      # float left 
      testbegins ":<<:"
      jumptrue 4
      testbegins ">>:"
      jumptrue 2 
      jump block.end.6396
        swap
        add "class='float-left' "
        swap
        testbegins ":"
        jumpfalse block.end.6375
          clop
        block.end.6375:
        clop
        clop
      block.end.6396:
      # centre indicator  
      testbegins ":cc:"
      jumpfalse block.end.6617
        # need to fix this todo
        swap
        # this is not going to work.
        # add "style='text-align:center;' "; 
        swap
        clop
        clop
        clop
      block.end.6617:
      testbegins ":"
      jumpfalse block.end.6640
        clop
      block.end.6640:
      # build the html image src= attribute. 
      swap
      add " src='"
      get
      add "'/>"
      swap
      clear
      clear
      add "imagefile*"
      push
      jump parse
    block.end.6813:
  block.end.6818:
  # make < and > html entities because they will wreck our page
  # but not if is >> as 1st word
  testis ">>"
  jumptrue block.end.6971
    replace ">" "&gt;"
    replace "<" "&lt;"
  block.end.6971:
  # some curly quotes, why not? A half hearted attempt for english
  # insert some apostrophes
  testis "doesnt"
  jumptrue 22
  testis "isnt"
  jumptrue 20
  testis "cant"
  jumptrue 18
  testis "arent"
  jumptrue 16
  testis "couldnt"
  jumptrue 14
  testis "didnt"
  jumptrue 12
  testis "hasnt"
  jumptrue 10
  testis "havent"
  jumptrue 8
  testis "shouldnt"
  jumptrue 6
  testis "mustnt"
  jumptrue 4
  testis "wasnt"
  jumptrue 2 
  jump block.end.7203
    replace "nt" "n't"
  block.end.7203:
  testis "thats"
  jumptrue 4
  testis "whats"
  jumptrue 2 
  jump block.end.7254
    replace "ts" "t's"
  block.end.7254:
  testis "I'm"
  jumptrue 106
  testis "you're"
  jumptrue 104
  testis "he's"
  jumptrue 102
  testis "she's"
  jumptrue 100
  testis "it's"
  jumptrue 98
  testis "we're"
  jumptrue 96
  testis "they're"
  jumptrue 94
  testis "aren't"
  jumptrue 92
  testis "can't"
  jumptrue 90
  testis "couldn't"
  jumptrue 88
  testis "didn't"
  jumptrue 86
  testis "doesn't"
  jumptrue 84
  testis "hadn't"
  jumptrue 82
  testis "hasn't"
  jumptrue 80
  testis "haven't"
  jumptrue 78
  testis "isn't"
  jumptrue 76
  testis "mightn't"
  jumptrue 74
  testis "mustn't"
  jumptrue 72
  testis "oughtn't"
  jumptrue 70
  testis "shouldn't"
  jumptrue 68
  testis "wasn't"
  jumptrue 66
  testis "weren't"
  jumptrue 64
  testis "won't"
  jumptrue 62
  testis "wouldn't"
  jumptrue 60
  testis "I've"
  jumptrue 58
  testis "you've"
  jumptrue 56
  testis "he's"
  jumptrue 54
  testis "she's"
  jumptrue 52
  testis "it's"
  jumptrue 50
  testis "we've"
  jumptrue 48
  testis "they've"
  jumptrue 46
  testis "I'd"
  jumptrue 44
  testis "you'd"
  jumptrue 42
  testis "he'd"
  jumptrue 40
  testis "she'd"
  jumptrue 38
  testis "it'd"
  jumptrue 36
  testis "we'd"
  jumptrue 34
  testis "they'd"
  jumptrue 32
  testis "I'll"
  jumptrue 30
  testis "you'll"
  jumptrue 28
  testis "he'll"
  jumptrue 26
  testis "she'll"
  jumptrue 24
  testis "it'll"
  jumptrue 22
  testis "we'll"
  jumptrue 20
  testis "they'll"
  jumptrue 18
  testis "there's"
  jumptrue 16
  testis "that's"
  jumptrue 14
  testis "what's"
  jumptrue 12
  testis "who's"
  jumptrue 10
  testis "where's"
  jumptrue 8
  testis "when's"
  jumptrue 6
  testis "why's"
  jumptrue 4
  testis "how's"
  jumptrue 2 
  jump block.end.7779
    replace "'" "&rsquo;"
  block.end.7779:
  # some common typos for apostrophe contractions in english
  testis "dont"
  jumptrue 14
  testis "Im"
  jumptrue 12
  testis "theyre"
  jumptrue 10
  testis "arent"
  jumptrue 8
  testis "cant"
  jumptrue 6
  testis "isnt"
  jumptrue 4
  testis "couldnt"
  jumptrue 2 
  jump block.end.8032
    replace "dont" "don&rsquo;t"
    replace "Im" "I&rsquo;m"
    replace "cant" "can&rsquo;t"
    replace "arent" "aren&rsquo;t"
  block.end.8032:
  put
  # ordinals in english, very perfunctory but sort of fun. 
  # eg: 1st, 2nd, 301rd
  testclass [0123456789stndrdth]
  jumpfalse block.end.8758
    testends "1st"
    jumpfalse block.end.8315
      # check matches [0-9]*1st
      clip
      clip
      clip
      testis ""
      jumptrue 4
      testclass [0-9]
      jumptrue 2 
      jump block.end.8308
        clear
        get
        clip
        clip
        add "<sup>st</sup>"
      block.end.8308:
    block.end.8315:
    testends "2nd"
    jumpfalse block.end.8478
      # check matches [0-9]*2nd
      clip
      clip
      clip
      testis ""
      jumptrue 4
      testclass [0-9]
      jumptrue 2 
      jump block.end.8471
        clear
        get
        clip
        clip
        add "<sup>nd</sup>"
      block.end.8471:
    block.end.8478:
    testends "3rd"
    jumpfalse block.end.8607
      clip
      clip
      clip
      testis ""
      jumptrue 4
      testclass [0-9]
      jumptrue 2 
      jump block.end.8600
        clear
        get
        clip
        clip
        add "<sup>rd</sup>"
      block.end.8600:
    block.end.8607:
    testends "th"
    jumpfalse block.end.8753
      # check matches [0-9]*[4-9]th 
      clip
      clip
      testis ""
      jumptrue 9
      testends "1"
      jumptrue 7
      testends "2"
      jumptrue 5
      testends "3"
      jumptrue 3
      testclass [0-9]
      jumptrue 2 
      jump block.end.8746
        add "<sup>th</sup>"
      block.end.8746:
    block.end.8753:
  block.end.8758:
  put
  clear
  count
  # deal with ">>" when not first word
  testis "1"
  jumptrue block.end.8916
    clear
    get
    testis ">>"
    jumpfalse block.end.8892
      clear
      add "&gt;&gt;"
      put
    block.end.8892:
    clear
    count
  block.end.8916:
  # check if this is the first word on the line
  # because several markup elements (as in markdown) need to be
  # the 1st word to be significant.
  testis "1"
  jumpfalse block.end.12099
    clear
    get
    # asterix as first word on line marks the description of 
    # a code line or block which follows (like a caption)
    # format this later in 2 token parsing. 
    # starlines are used as captions for code and also citations
    # for quotations.
    testis "*"
    jumpfalse block.end.9504
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "starline*"
      push
      jump parse
    block.end.9504:
    # document or page title  
    testis "&&"
    jumpfalse block.end.9827
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<!-- ------------ page title -------------------- -->\n"
      add "<h1 class='page-title'>"
      get
      add "</h1>\n"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.9827:
    # markdown style headings. I would prefer to use one # as 
    # a comment.
    testis "#"
    jumpfalse block.end.10167
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<!-- ------------------------------- -->\n"
      add "<h1>"
      get
      add "</h1>\n"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.10167:
    testis "##"
    jumpfalse block.end.10426
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<!-- ------------------------------- -->\n"
      add "<h2>"
      get
      add "</h2>\n"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.10426:
    testis "###"
    jumpfalse block.end.10686
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<!-- ------------------------------- -->\n"
      add "<h3>"
      get
      add "</h3>\n"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.10686:
    # one line of code etc
    testis ">>"
    jumpfalse block.end.10951
      clear
      whilenot [\n]
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<pre class='codeline'>\n"
      get
      add "\n</pre>\n"
      put
      clear
      add "codeline*"
      push
      jump parse
    block.end.10951:
    # horizontal rules >--------  (> is already &gt;)
    testbegins "&gt;---"
    jumpfalse block.end.11189
      # ensure matches regex ">[-]{3,}"
      clop
      clop
      clop
      clop
      testclass [-]
      jumpfalse block.end.11182
        clear
        add "<hr/>\n"
        put
        add "text*"
        push
        jump parse
      block.end.11182:
    block.end.11189:
    # codeblocks begin with --- or ---- etc
    testbegins "---"
    jumpfalse 3
    testclass [-]
    jumptrue 2 
    jump block.end.11503
      clear
      until ",,,"
      clip
      clip
      clip
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "<pre class='codeblock'>\n"
      get
      add "</pre>\n"
      put
      clear
      while [,]
      clear
      add "codeblock*"
      push
      jump parse
    block.end.11503:
    # multiline quotes, start and end with 3 quotes """. Starting """ 
    # must be first on line. The only problem is that they can chew up the 
    # whole doc. This may be rendered with a big curly quote at the 
    # beginning. If this is preceded by a star line, then that is the 
    # author of the quotation. The html <blockquote> will be added later
    # during 2 grammar token parsing.
    testbegins "\"\"\""
    jumpfalse block.end.12093
      clop
      clop
      clop
      until "\"\"\""
      clip
      clip
      clip
      replace ">" "&gt;"
      replace "<" "&lt;"
      put
      clear
      add "blockquote*"
      push
      jump parse
    block.end.12093:
  block.end.12099:
  clear
  get
  # force a line break with '>>' (but not first word on line), 
  # could be a way to imitate lists
  testis "&gt;&gt;"
  jumpfalse block.end.12304
    clear
    add "<br/>\n"
    put
    add "text*"
    push
    jump parse
  block.end.12304:
  # urls, we need to add html formatting later because of the
  # "text" http://dada.org syntax There are a lot of "fake" schemas 
  # here for convenience.
  testbegins "oed:"
  jumptrue 20
  testbegins "wp:"
  jumptrue 18
  testbegins "nom:"
  jumptrue 16
  testbegins "nomsf:"
  jumptrue 14
  testbegins "pep:"
  jumptrue 12
  testbegins "http://"
  jumptrue 10
  testbegins "https://"
  jumptrue 8
  testbegins "nntp://"
  jumptrue 6
  testbegins "file://"
  jumptrue 4
  testbegins "www."
  jumptrue 2 
  jump block.end.14927
    testis "oed:"
    jumptrue 19
    testis "wp:"
    jumptrue 17
    testis "nom:"
    jumptrue 15
    testis "nomsf:"
    jumptrue 13
    testis "pep:"
    jumptrue 11
    testis "http://"
    jumptrue 9
    testis "https://"
    jumptrue 7
    testis "nntp://"
    jumptrue 5
    testis "file://"
    jumptrue 3
    testis "www."
    jumpfalse 2 
    jump block.end.14922
      testbegins "file://"
      jumpfalse block.end.12742
        replace "file://" ""
        put
      block.end.12742:
      # make the fake schema wp:// or wp: wikipedia links after wp:// should
      # just be the wikipedia page name
      # todo: better to parse this in the E"url*".!"url*" block so that 
      # we can make a nice visible link text for the wikipedia page.
      # ie. do the same as the nom:// fake url
      testbegins "wp:"
      jumptrue 4
      testbegins "wp://"
      jumptrue 2 
      jump block.end.13275
        clop
        clop
        clop
        testbegins "//"
        jumpfalse block.end.13127
          clop
          clop
        block.end.13127:
        # I dont like writing underscores
        replace "." "_"
        put
        clear
        add "https://en.wikipedia.org/wiki/"
        get
        put
      block.end.13275:
      # schema for oed eg oed:// with search
      # oxford english dictionary
      testbegins "oed:"
      jumptrue 4
      testbegins "oed://"
      jumptrue 2 
      jump block.end.13681
        # allow trailing dot or comma
        testends "."
        jumptrue 4
        testends ","
        jumptrue 2 
        jump block.end.13451
          clip
        block.end.13451:
        replace "nomsf:" ""
        testbegins "//"
        jumpfalse block.end.13504
          clop
          clop
        block.end.13504:
        clop
        clop
        clop
        clop
        testbegins "//"
        jumpfalse block.end.13559
          clop
          clop
        block.end.13559:
        put
        clear
        add "https://www.oed.com/search/dictionary/?scope=Entries&q="
        get
        put
      block.end.13681:
      # this is just a convenience so I dont have to type out the url
      # to the pep/nom sourceforge site everytime
      testbegins "nomsf:"
      jumptrue 4
      testbegins "nomsf://"
      jumptrue 2 
      jump block.end.14028
        testends "."
        jumptrue 4
        testends ","
        jumptrue 2 
        jump block.end.13864
          clip
        block.end.13864:
        # allow trailing ./,
        replace "nomsf:" ""
        testbegins "//"
        jumpfalse block.end.13938
          clop
          clop
        block.end.13938:
        put
        clear
        add "https://bumble.sf.net/books/pars/"
        get
        put
      block.end.14028:
      # convenience schema, this time for nom language commands 
      # eg: push pop get put
      testbegins "nom:"
      jumpfalse block.end.14328
        # allow trailing dot or comma
        testends "."
        jumptrue 4
        testends ","
        jumptrue 2 
        jump block.end.14210
          clip
        block.end.14210:
        # add the url later, much easier.
        testbegins "nom://"
        jumptrue block.end.14303
          replace "nom:" "nom://"
        block.end.14303:
        put
      block.end.14328:
      # another convenience schema, nom syntax documentation
      # eg: blocks, tests, parselabel 
      testbegins "nomsyn:"
      jumpfalse block.end.14576
        # add the url later, much easier.
        testbegins "nomsyn://"
        jumptrue block.end.14551
          replace "nomsyn:" "nomsyn://"
        block.end.14551:
        put
      block.end.14576:
      # pep virtual machine structure eg: stack, tape, peep 
      testbegins "pep:"
      jumpfalse block.end.14787
        testends "."
        jumptrue 4
        testends ","
        jumptrue 2 
        jump block.end.14685
          clip
        block.end.14685:
        # allow trailing ./,
        testbegins "pep://"
        jumptrue block.end.14756
          replace "pep:" "pep://"
        block.end.14756:
        put
        clear
      block.end.14787:
      # add a schema to www. urls
      testbegins "www."
      jumpfalse block.end.14874
        clear
        add "http://"
        get
        put
      block.end.14874:
      clear
      add "url*"
      push
      jump parse
    block.end.14922:
  block.end.14927:
  # a fake uri schema syntax eg google:"pratt parsers"
  # --> https://www.google.com/search?q=distance+colombia+to+tasmania
  # this is separate to the code above because it has to read ahead
  # in the input stream
  testbegins "google:"
  jumptrue 4
  testbegins "google://"
  jumptrue 2 
  jump block.end.15589
    replace "google://" ""
    replace "google:" ""
    # read until next " or newline
    testbegins "\""
    jumpfalse block.end.15584
      clop
      whilenot [\n"]
      #replace ">" "&gt;"; replace "<" "&lt;";
      replace " " "+"
      put
      clear
      add "https://www.google.com/search?q="
      get
      put
      clear
      testeof 
      jumptrue block.end.15526
        read
        testclass [\n]
        jumpfalse block.end.15524
          zero
          nochars
        block.end.15524:
      block.end.15526:
      clear
      add "url*"
      push
      jump parse
    block.end.15584:
  block.end.15589:
  # local files with no schema, imagefile tokens have already been parsed
  testends ".h"
  jumptrue 72
  testends ".c"
  jumptrue 70
  testends ".a"
  jumptrue 68
  testends ".txt"
  jumptrue 66
  testends ".doc"
  jumptrue 64
  testends ".py"
  jumptrue 62
  testends ".rb"
  jumptrue 60
  testends ".rs"
  jumptrue 58
  testends ".java"
  jumptrue 56
  testends ".class"
  jumptrue 54
  testends ".tcl"
  jumptrue 52
  testends ".tk"
  jumptrue 50
  testends ".sw"
  jumptrue 48
  testends ".js"
  jumptrue 46
  testends ".go"
  jumptrue 44
  testends ".pp"
  jumptrue 42
  testends ".pss"
  jumptrue 40
  testends ".cpp"
  jumptrue 38
  testends ".pl"
  jumptrue 36
  testends ".html"
  jumptrue 34
  testends ".pdf"
  jumptrue 32
  testends ".tex"
  jumptrue 30
  testends ".sh"
  jumptrue 28
  testends ".css"
  jumptrue 26
  testends ".out"
  jumptrue 24
  testends ".log"
  jumptrue 22
  testends ".png"
  jumptrue 20
  testends ".jpg"
  jumptrue 18
  testends ".jpeg"
  jumptrue 16
  testends ".bmp"
  jumptrue 14
  testends ".mp3"
  jumptrue 12
  testends ".wav"
  jumptrue 10
  testends ".aux"
  jumptrue 8
  testends ".tar"
  jumptrue 6
  testends ".gz"
  jumptrue 4
  testends "/"
  jumptrue 2 
  jump block.end.16405
    testis ".h"
    jumpfalse 72
    testis ".c"
    jumpfalse 70
    testis ".a"
    jumpfalse 68
    testis ".txt"
    jumpfalse 66
    testis ".doc"
    jumpfalse 64
    testis ".py"
    jumpfalse 62
    testis ".rb"
    jumpfalse 60
    testis ".rs"
    jumpfalse 58
    testis ".java"
    jumpfalse 56
    testis ".class"
    jumpfalse 54
    testis ".tcl"
    jumpfalse 52
    testis ".tk"
    jumpfalse 50
    testis ".sw"
    jumpfalse 48
    testis ".js"
    jumpfalse 46
    testis ".go"
    jumpfalse 44
    testis ".pp"
    jumpfalse 42
    testis ".pss"
    jumpfalse 40
    testis ".cpp"
    jumpfalse 38
    testis ".pl"
    jumpfalse 36
    testis ".html"
    jumpfalse 34
    testis ".pdf"
    jumpfalse 32
    testis ".tex"
    jumpfalse 30
    testis ".sh"
    jumpfalse 28
    testis ".css"
    jumpfalse 26
    testis ".out"
    jumpfalse 24
    testis ".log"
    jumpfalse 22
    testis ".png"
    jumpfalse 20
    testis ".jpg"
    jumpfalse 18
    testis ".jpeg"
    jumpfalse 16
    testis ".bmp"
    jumpfalse 14
    testis ".mp3"
    jumpfalse 12
    testis ".wav"
    jumpfalse 10
    testis ".aux"
    jumpfalse 8
    testis ".tar"
    jumpfalse 6
    testis ".gz"
    jumpfalse 4
    testis "/"
    jumpfalse 2 
    jump block.end.16400
      testbegins "http://"
      jumptrue 9
      testbegins "https://"
      jumptrue 7
      testbegins "nntp://"
      jumptrue 5
      testbegins "file://"
      jumptrue 3
      testbegins "www."
      jumpfalse 2 
      jump block.end.16393
        clear
        add "file*"
        push
        jump parse
      block.end.16393:
    block.end.16400:
  block.end.16405:
  # quoted text between "and and", maximum one line
  testbegins "\""
  jumpfalse 5
  testis "\""
  jumptrue 3
  testends "\""
  jumpfalse 2 
  jump block.end.16900
    clop
    whilenot [\n"]
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    # The code below is not great, but is required because we
    # dont have "until 'ab','cd','ef'" syntax. ie multiple end delimiters
    # all this is to prevent multiline quotes (which could eat up the 
    # whole document.
    testeof 
    jumptrue block.end.16848
      read
      testclass [\n]
      jumpfalse block.end.16846
        zero
        nochars
      block.end.16846:
    block.end.16848:
    clear
    add "quoted*"
    push
    jump parse
  block.end.16900:
  # single quoted word, multiline quotes (blockquotes) may begin with
  # """
  testbegins "\""
  jumpfalse 9
  testis "\""
  jumptrue 7
  testis "\"\""
  jumptrue 5
  testis "\"\"\""
  jumptrue 3
  testends "\""
  jumptrue 2 
  jump block.end.17133
    clip
    clop
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    add "quoted*"
    push
    jump parse
  block.end.17133:
  # single bold emphasised word eg: **strong**
  testbegins "**"
  jumpfalse 9
  testis "**"
  jumptrue 7
  testis "****"
  jumptrue 5
  testis "***"
  jumptrue 3
  testends "**"
  jumptrue 2 
  jump block.end.17415
    clip
    clip
    clop
    clop
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    add "<strong><em>"
    get
    add "</em></strong>\n"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.17415:
  # bold emphasised text between **double asterixes**
  # single line maximum, multiple words
  testbegins "**"
  jumpfalse block.end.18137
    clop
    clop
    whilenot [\n*]
    # find the next * if its there. This is clumsy code because we
    # cant say "until '**','\n';" which would be better
    # actually this code accepts ** text* with only one terminating 
    # asterix, but its not important. It's a text format...
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    add "<strong><em>"
    get
    add "</em></strong>\n"
    put
    clear
    # If there is some emphasised text immediately on the next line
    # this will not be good, but we aren't flying an aeroplane.
    while [*]
    clear
    add "text*"
    push
    jump parse
  block.end.18137:
  # emphasised italic text between *two asterixes*
  # single line maximum, multiple words
  testbegins "*"
  jumpfalse 5
  testis "*"
  jumptrue 3
  testends "*"
  jumpfalse 2 
  jump block.end.18528
    clop
    whilenot [\n*]
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    add "<em>"
    get
    add "</em>"
    put
    clear
    # could i just use "while [*];" here?
    testeof 
    jumptrue block.end.18478
      read
      testclass [\n]
      jumpfalse block.end.18476
        zero
        nochars
      block.end.18476:
    block.end.18478:
    clear
    add "text*"
    push
    jump parse
  block.end.18528:
  # single emphasised word, no special grammar token needed.
  testbegins "*"
  jumpfalse 7
  testis "*"
  jumptrue 5
  testis "**"
  jumptrue 3
  testends "*"
  jumptrue 2 
  jump block.end.18782
    clip
    clop
    replace ">" "&gt;"
    replace "<" "&lt;"
    put
    clear
    add "<em>"
    get
    add "</em>"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.18782:
  clear
  add "word*"
  push
block.end.18815:
testis ""
jumptrue block.end.19294
  clear
  # just delete weird characters, we don't need them.
  # but probably should investigate further
  
  #   add "! An unexpected character '"; get; add "'";
  #   add "  in text input was encountered at \n";
  #   add "  line "; lines; add " char "; chars; add "\n";
  #   add "  Check the 'lexical parsing' phase of the script \n";
  #   add "    pars/eg/text.tohtml.pss ";
  #   add "  This is the section of the script above the parse> label \n";
  #   print; quit;
  #   
block.end.19294:
parse:
# for debugging, add % as a latex comment.
# add "<!-- line "; lines; add " char "; chars; add ": "; print; clear; 
# unstack; print; stack; add " -->\n"; print; clear;
# maximum 2 tokens
pop
pop
# starline*codeline* or starline*codeblock* is significant
testis "starline*space*"
jumpfalse block.end.19703
  # dont really need this space
  clear
  get
  ++
  get
  --
  put
  clear
  add "starline*"
  push
  jump parse
block.end.19703:
# This is another use for starline, as the "citation" or author
# for a multiline quote ("""..."""). This has to go above here because
# starlines are about to disappear
testends "blockquote*"
jumpfalse 3
testis "blockquote*"
jumpfalse 2 
jump block.end.20344
  testbegins "starline*"
  jumpfalse block.end.20121
    clear
    add "<blockquote class='quotation'>\n"
    ++
    get
    --
    add "<cite>"
    get
    add "</cite>\n"
    add "</blockquote>\n"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.20121:
  # blockquote with no citation, treat the unknown 1st token as 
  # text.
  clear
  get
  add "\n<blockquote class='quotation'>\n"
  ++
  get
  --
  add "</blockquote>\n"
  put
  clear
  add "text*"
  push
  jump parse
block.end.20344:
# a caption followed by some code
testbegins "starline*"
jumpfalse 3
testis "starline*"
jumpfalse 2 
jump block.end.20868
  testends "codeline*"
  jumptrue 4
  testends "codeblock*"
  jumptrue 2 
  jump block.end.20665
    clear
    add "<figure class='code-with-caption'>\n"
    add "<figcaption class='code-caption'>\n"
    get
    add "</figcaption>\n"
    ++
    get
    --
    add "</figure>"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.20665:
  clear
  # format star-lines, then reduce to text (token no longer needed)
  add "<em class='starline'>\n"
  get
  add "\n</em>\n"
  put
  clear
  replace "starline*" "text*"
  push
  push
  jump parse
block.end.20868:
# format and reduce image files, but the <img> tag has already
# been built above so we can just add the figure and caption if 
# required
testends "imagefile*"
jumpfalse 3
testis "imagefile*"
jumpfalse 2 
jump block.end.21945
  # "link text" http://abc syntax
  testbegins "quoted*"
  jumpfalse block.end.21833
    # the problem here is that <figure> needs to set the width 
    # and alignment not the image, but the <img> tag has already
    # been built. Maybe we can just accept that captioned images
    # are not going to look much good.
    clear
    ++
    get
    # check if image is floating left or right
    # a hack to get around no "contains" test eg C"float-right"
    replace "float-right" ""
    testtape 
    jumptrue block.end.21576
      clear
      add "\n<figure class='float-right'>\n  "
    block.end.21576:
    testtape 
    jumpfalse block.end.21650
      clear
      add "\n<figure class='float-left'>\n  "
    block.end.21650:
    get
    --
    add "\n  <figcaption class='image-caption'>\n  "
    get
    add "\n  </figcaption>"
    add "\n</figure>\n"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.21833:
  # image with no caption 
  clear
  get
  ++
  get
  --
  add "\n"
  put
  clear
  add "text*"
  push
  jump parse
block.end.21945:
# format and reduce urls
testends "url*"
jumpfalse block.end.24843
  # "link text" http://abc syntax
  testbegins "quoted*"
  jumpfalse block.end.23080
    clear
    ++
    get
    --
    # deal with nom schema, nom: has been normalised to nom://
    # nom command filenames in format nom.<command>.txt
    testbegins "nom://"
    jumpfalse block.end.22406
      replace "nom://" ""
      ++
      put
      clear
      add "<a href='http://nomlang.org/doc/commands/nom."
      get
      --
      add ".html'>"
      get
      add "</a>"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.22406:
    testbegins "nomsyn://"
    jumpfalse block.end.22641
      replace "nomsyn://" ""
      ++
      put
      clear
      add "<a href='http://nomlang.org/doc/syntax/nom.syntax."
      get
      --
      add ".html'>"
      get
      add "</a>"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.22641:
    # pep machine filenames in format pep.<part>.txt
    testbegins "pep://"
    jumpfalse block.end.22919
      replace "pep://" ""
      ++
      put
      clear
      add "<a href='http://nomlang.org/doc/machine/pep."
      get
      --
      add ".html'>"
      get
      add "</a>"
      put
      clear
      add "text*"
      push
      jump parse
    block.end.22919:
    # other "quote" url:// formats
    clear
    add "<a href='"
    ++
    get
    --
    add "'>"
    get
    add "</a>"
    put
    clear
    add "text*"
    push
    jump parse
  block.end.23080:
  # plain url link, add html link to text
  clear
  ++
  get
  --
  testbegins "nom://"
  jumpfalse block.end.23804
    # is nom://-- valid? yes and also nom://minusminus 
    replace "nom://" ""
    ++
    put
    --
    clear
    get
    add "<a href='http://nomlang.org/doc/commands/nom."
    ++
    get
    add ".html'>"
    # allow nom://++ syntax etc
    replace "++.html" "plusplus.html"
    replace "--.html" "minusminus.html"
    get
    add "</a>"
    # allow nom://plusplus syntax etc (make visible link correct)
    replace "html'>plusplus" "html'>++"
    replace "html'>minusminus" "html'>--"
    replace "html'>reparse" "html'>.reparse"
    replace "html'>restart" "html'>.restart"
    --
    put
    clear
    add "text*"
    push
    jump parse
  block.end.23804:
  testbegins "nomsyn://"
  jumpfalse block.end.24303
    replace "nomsyn://" ""
    ++
    put
    --
    clear
    get
    add "<a href='http://nomlang.org/doc/syntax/nom.syntax."
    ++
    get
    add ".html'>"
    # allow nomsyn://reparse> syntax etc
    replace "parse>.html" "parselabel.html"
    replace "class.html" "classes.html"
    get
    add "</a>"
    # allow nom://parselabel syntax etc (make visible link correct)
    replace "html'>parselabel" "html'>parse&gt;"
    --
    put
    clear
    add "text*"
    push
    jump parse
  block.end.24303:
  testbegins "pep://"
  jumpfalse block.end.24528
    replace "pep://" ""
    ++
    put
    --
    clear
    get
    add "<a href='http://nomlang.org/doc/machine/pep."
    ++
    get
    add ".html'>"
    get
    add "</a>"
    --
    put
    clear
    add "text*"
    push
    jump parse
  block.end.24528:
  clear
  get
  add "<a href='"
  ++
  get
  add "'>"
  swap
  # remove the https:// etc from the visible link because
  # they look ugly in the text.
  replace "https" ""
  replace "http" ""
  replace "nntp" ""
  replace "://" ""
  swap
  get
  --
  add "</a>"
  put
  clear
  add "text*"
  push
  jump parse
block.end.24843:
# "text" file.txt syntax to be linked
testis "quoted*file*"
jumpfalse block.end.25021
  clear
  add "<a href='"
  ++
  get
  --
  add "'>"
  get
  add "</a>"
  put
  clear
  add "text*"
  push
  jump parse
block.end.25021:
# reduce file* grammar tokens separately so we can html format them
testbegins "file*"
jumpfalse 3
testis "file*"
jumpfalse 2 
jump block.end.25233
  replace "file*" "text*"
  push
  push
  --
  --
  add "<code>"
  get
  add "</code>"
  put
  ++
  ++
  clear
  jump parse
block.end.25233:
# quoted*url* or quoted*file* is significant
testis "quoted*space*"
jumpfalse block.end.25382
  clear
  get
  ++
  get
  --
  put
  clear
  add "quoted*"
  push
  jump parse
block.end.25382:
# reduce "quoted" separately so we can add some html curly quotes
# the !"quoted*" clause is supposed to ensure 2 tokens (this should only
# really be a problem if the "quoted" is the first word of the document)
testbegins "quoted*"
jumpfalse 3
testis "quoted*"
jumpfalse 2 
jump block.end.26139
  testends "url*"
  jumptrue 3
  testends "file*"
  jumpfalse 2 
  jump block.end.26136
    clear
    # The quoted attribute may have a space (or many?) at the end
    # so need to put it after the curly quotes
    # add some html curly quotes and get saved space
    add "&ldquo;"
    get
    add "&rdquo;"
    # remove the space just before the last quote (which is added
    # during "space*" reductions.
    replace " &rdquo;" "&rdquo;"
    # add a space to separate from next word.
    add " "
    ++
    get
    --
    put
    clear
    add "text*"
    push
    jump parse
  block.end.26136:
block.end.26139:
# tokens to reduce to text
# codeline, codeblock, word, text, space, quoted,
#B"word*",B"text*",B"space*",B"quoted*",B"codeline*",B"codeblock*" {
testbegins "word*"
jumptrue 10
testbegins "text*"
jumptrue 8
testbegins "space*"
jumptrue 6
testbegins "codeline*"
jumptrue 4
testbegins "codeblock*"
jumptrue 2 
jump block.end.26631
  # need to conserve quoted at end
  testends "word*"
  jumptrue 10
  testends "text*"
  jumptrue 8
  testends "space*"
  jumptrue 6
  testends "codeline*"
  jumptrue 4
  testends "codeblock*"
  jumptrue 2 
  jump block.end.26628
    # check that there really are 2 tokens (not one)
    push
    testis ""
    jumptrue block.end.26613
      pop
      clear
      get
      ++
      get
      --
      put
      clear
      add "text*"
      push
      jump parse
    block.end.26613:
    pop
  block.end.26628:
block.end.26631:
push
push
testeof 
jumpfalse block.end.27151
  add "<!-- final stack: "
  print
  clear
  unstack
  add " -->\n"
  print
  clear
  stack
  add "<!-- html rendered by Nom script (www.nomlang.org): -->\n"
  add "<!--   bumble.sf.net/books/pars/eg/text.tohtml.pss -->\n"
  add "<!--   pep -f eg/text.tohtml.pss file.txt -->\n"
  add "<!-- see eg/text.tohtml.format.txt for text format -->\n"
  print
  clear
  # print the rendered html
  pop
  clear
  get
  print
  quit
  # The html header and footer are made in pars/www/blog.sh
block.end.27151:
jump start 
