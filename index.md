## The Pep/Nom parsing Machine and language

Pep is a system for parsing and translating context-free (and some
context-sensitive) languages. It is based on a very simple idea: that a "stack"
and a "tape" (an array) working together in synchronisation are ideal for
recognising and reducing parse tokens and their associated attributes.

This idea (which is so simple that I doubt it is original) has been developed
into a virtual-machine and script language which is useful and enjoyable for
parsing and translating all sorts of patterns.

A Basic Pep script
````
  # parse a document word by word
  [:space:] { clear; }
  [:alnum:] { 
    # save the 'token attribute' (the word text)
    while [:alnum:]; put; clear; 
    # create and push the parse token
    add "word*"; push; .reparse
  }

  # ignore everything else
  !"" { clear; }
  #*
   token reductions and resolutions start after the 
   parse> label
  *#
  parse>
  pop; pop; 
  # A series of words is text
  "word*word*","text*word*" {
    # collate (translate/transpile/compile) the token attributes
    clear; get; add " "; ++; get; --; put; clear;
    # reduce the 2 tokens to one and push to stack.
    add "text*"; push; .reparse
  }

````


