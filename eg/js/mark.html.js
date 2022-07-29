/* Assembled with the script 'compile.javascript.pss' */
var pp = require('./Machine'); 
var mm = new pp.Machine(); 
// reserve a tape cell for building a table of contents
mm.mark("top");
mm.add("toc*");
mm.push();
// a fake newline at the start to ease parse
mm.add("\n");
mm.put();
mm.workspace = '';
mm.add("nl*");
mm.push();
script: 
while (mm.peep != null) {
  lex: { 
    mm.read();
    // a fake end-of-file token at the end of file, to ease parsing 
    // (eof) { add "eof*"; push; .reparse }
    if (mm.testClass('[\n]')) {
      mm.put();
      mm.workspace = '';
      mm.add("nl*");
      mm.push();
      break lex;
    }
    if (mm.testClass('[\r]')) {
      mm.workspace = '';
    }
    // space includes \n\r so we cant use the [:space:] class
    if (mm.testClass('[ \t]')) {
      mm.whilePeep('[ \t]');
      mm.put();
      mm.workspace = '';
      mm.add("space*");
      mm.push();
      break lex;
    }
    if ((mm.workspace == "'")) {
      mm.until("'");
      mm.put();
      mm.workspace = '';
      mm.add("quoted*");
      mm.push();
      break lex;
    }
    if ((mm.workspace == "\"")) {
      mm.until("\"");
      mm.put();
      mm.workspace = '';
      mm.add("quoted*");
      mm.push();
      break lex;
    }
    // everything else is a word
    if ((mm.workspace != "")) {
      mm.whilenotPeep('[:space:]');
      mm.put();
      mm.workspace = '';
      mm.add("word*");
      mm.push();
      break lex;
    }
  }
  parse: 
  while (true) { 
    // The parse/compile/translate/transform phase involves 
    // recognising series of tokens on the stack and "reducing" them
    // according to the required bnf grammar rules.
    //-----------------
    // 1 token
    mm.pop();
    if ((mm.workspace == "word*")) {
      mm.workspace = '';
      mm.get();
      // no numbers in headings!
      if (mm.testClass('[A-Z]')) {
        mm.workspace = '';
        mm.add("uword*");
        mm.push();
        continue parse;
      }
      // the subheading marker
      if ((mm.workspace == "....")) {
        mm.workspace = '';
        mm.add("4dots*");
        mm.push();
        continue parse;
      }
      // emphasis or explanation line marker 
      if ((mm.workspace == "*")) {
        mm.workspace = '';
        mm.add("star*");
        mm.push();
        continue parse;
      }
      // the code line marker 
      if ((mm.workspace == ">>")) {
        mm.workspace = '';
        mm.add(">>*");
        mm.push();
        continue parse;
      }
      // the code block marker 
      if (mm.workspace.startsWith("---")) {
        mm.workspace = '';
        mm.put();
        mm.add("---*");
        mm.push();
        continue parse;
      }
      // having an end of document marker is useful for testing and 
      // also embedding documentation in other types of files (code files)
      if (mm.workspace.startsWith("http://") || mm.workspace.startsWith("https://") || mm.workspace.startsWith("www.")) {
        mm.workspace = '';
        mm.add("link*");
        mm.push();
        continue parse;
      }
      if (mm.workspace.startsWith("link:")) {
        mm.workspace = '';
        mm.add("link*");
        mm.push();
        continue parse;
      }
      if (mm.workspace.startsWith("/")) {
        if (mm.workspace.endsWith("/") || mm.workspace.endsWith(".c") || mm.workspace.endsWith(".txt") || mm.workspace.endsWith(".html") || mm.workspace.endsWith(".pss")) {
          mm.workspace = '';
          mm.add("link*");
          mm.push();
          continue parse;
        }
      }
      if ((mm.workspace == "###")) {
        mm.add(" << end of document marker at line ");
        mm.lines();
        mm.add(" \n");
        mm.print();
        mm.workspace = '';
        break script;
      }
      mm.workspace = '';
      mm.add("word*");
      // leave the wordtoken on the workspace.
    }
    //-----------------
    // 2 tokens
    mm.pop();
    // trailing space is not needed, no??
    if ((mm.workspace == "space*nl*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("nl*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "nl*space*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("nl*");
      mm.push();
      continue parse;
    }
    // we need to conserve newline tokens to parse headings etc
    if ((mm.workspace == "nl*nl*")) {
      mm.workspace = '';
      mm.add("\n<p>\n");
      mm.put();
      mm.workspace = '';
      mm.add("nl*");
      mm.push();
      continue parse;
    }
    // code line
    if ((mm.workspace == "nl*>>*")) {
      mm.workspace = '';
      mm.add("nl*text*nl*");
      mm.push();
      mm.push();
      mm.push();
      mm.add("<pre><code>");
      mm.until("\n");
      mm.clip();
      mm.add("</code></pre>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      continue parse;
    }
    // star line
    if ((mm.workspace == "nl*star*")) {
      mm.workspace = '';
      mm.add("nl*starline*nl*");
      mm.push();
      mm.push();
      mm.push();
      mm.add("<em><strong>");
      mm.until("\n");
      mm.clip();
      mm.add("</strong></em>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      continue parse;
    }
    // code blocks which are enclosed in "---" and ",,,"
    if ((mm.workspace == "nl*---*")) {
      mm.workspace = '';
      mm.add("nl*text*nl*");
      mm.push();
      mm.push();
      mm.push();
      mm.add("<pre><code>");
      mm.until(",,,");
      mm.clip();
      mm.clip();
      mm.clip();
      mm.add("</code></pre>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      // get rid of extra 
      mm.whilePeep(",");
      mm.workspace = '';
      continue parse;
    }
    if ((mm.workspace == "space*uword*") || (mm.workspace == "uword*space*") || (mm.workspace == "uword*uword*") || (mm.workspace == "utext*uword*") || (mm.workspace == "utext*utext*") || (mm.workspace == "utext*space*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("utext*");
      mm.push();
      continue parse;
    }
    // check for "file /dir/etc" links here
    // not working. hard to do.
    if ((mm.workspace == "word*file*") || (mm.workspace == "text*file*")) {
      mm.workspace = '';
      mm.get();
      if (mm.workspace.startsWith("file") || mm.workspace.endsWith("file") || mm.workspace.startsWith("folder") || mm.workspace.endsWith("folder")) {
        mm.workspace = '';
        mm.increment();
        mm.add("<a href=\"");
        mm.get();
        mm.add("\"><code><em>");
        mm.get();
        mm.add("</em></code></a>");
        if (mm.tapePointer > 0) mm.tapePointer--; 
        mm.put();
      }
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "text*>>*") || (mm.workspace == "word*>>*") || (mm.workspace == "text*star*") || (mm.workspace == "word*star*") || (mm.workspace == "text*4dots*") || (mm.workspace == "word*4dots*") || (mm.workspace == "4dots*text*") || (mm.workspace == "4dots*word*") || (mm.workspace == "quoted*utext*") || (mm.workspace == "quoted*uword*") || (mm.workspace == "space*word*") || (mm.workspace == "word*space*") || (mm.workspace == "text*text*") || (mm.workspace == "word*word*") || (mm.workspace == "text*word*") || (mm.workspace == "text*utext*") || (mm.workspace == "text*uword*") || (mm.workspace == "text*space*") || (mm.workspace == "utext*word*") || (mm.workspace == "utext*text*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "quoted*text*") || (mm.workspace == "quoted*word*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "quoted*link*")) {
      mm.workspace = '';
      mm.increment();
      mm.add(" <a href='");
      mm.get();
      mm.add("'>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.get();
      mm.add("</a>");
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "quoted*nl*")) {
      mm.workspace = '';
      mm.add("text*nl*");
      mm.push();
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "text*link*") || (mm.workspace == "utext*link*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.add(" <a href='");
      mm.get();
      mm.add("'>");
      mm.get();
      mm.add("</a>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "nl*link*")) {
      mm.workspace = '';
      mm.increment();
      mm.add(" <a href='");
      mm.get();
      mm.add("'>");
      mm.get();
      mm.add("</a>");
      mm.put();
      mm.workspace = '';
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.add("nl*text*");
      mm.push();
      mm.push();
      continue parse;
    }
    // -------------
    // 3 tokens
    mm.pop();
    if ((mm.workspace == "nl*utext*nl*") || (mm.workspace == "nl*uword*nl*")) {
      mm.workspace = '';
      mm.increment();
      mm.add("<h2>");
      mm.get();
      mm.add("</h2><hr/>");
      mm.put();
      // try to build a table of contents in the first tape cell.
      // but the toc gets built in reverse order
      // need to build the TOC as a list. The line below almost works
      // but the toc gets deleted near the end of the script
      // mark "here"; go "top"; get; put; go "here";
      mm.workspace = '';
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.add("nl*heading*nl*");
      mm.push();
      mm.push();
      mm.push();
      // cant use the stack command yet because it
      // doesnt update the tape pointer.
      // stack
      continue parse;
    }
    if ((mm.workspace == "nl*word*nl*") || (mm.workspace == "nl*text*nl*")) {
      mm.workspace = '';
      mm.add("nl*lines*nl*");
      mm.push();
      mm.push();
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "text*text*nl*") || (mm.workspace == "utext*text*nl*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.increment();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.add("text*nl*");
      mm.push();
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "quoted*space*link*")) {
      mm.workspace = '';
      mm.increment();
      mm.increment();
      mm.add(" <a href='");
      mm.get();
      mm.add("'>");
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.get();
      mm.add("</a>");
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    if ((mm.workspace == "quoted*space*word*") || (mm.workspace == "quoted*space*text*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      mm.add("text*");
      mm.push();
      continue parse;
    }
    // -------------
    // 4 tokens
    mm.pop();
    if ((mm.workspace == "nl*utext*4dots*nl*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.add("<h3>");
      mm.get();
      mm.add("</h3>");
      mm.increment();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      if (mm.tapePointer > 0) mm.tapePointer--; 
      // transfer the nl* token value
      mm.increment();
      mm.increment();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.add("nl*subheading*nl*");
      mm.push();
      mm.push();
      mm.push();
      continue parse;
    }
    // -------------
    // 5 tokens
    mm.pop();
    if ((mm.workspace == "nl*starline*nl*codeline*nl*")) {
      // this should create some kind of a table 
      // but what about multiple code lines eg
      // >> ...
      // >> ...
      // nop (eliminated)
    }
    if ((mm.workspace == "nl*lines*nl*lines*nl*") || (mm.workspace == "nl*lines*nl*starline*nl*") || (mm.workspace == "nl*lines*nl*heading*nl*") || (mm.workspace == "nl*lines*nl*subheading*nl*") || (mm.workspace == "nl*heading*nl*lines*nl*") || (mm.workspace == "nl*subheading*nl*lines*nl*")) {
      mm.workspace = '';
      mm.get();
      mm.increment();
      mm.get();
      mm.increment();
      mm.get();
      mm.increment();
      mm.get();
      mm.increment();
      mm.get();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.workspace = '';
      // clear out "nl*" tokens because we have already used them.
      mm.increment();
      mm.put();
      if (mm.tapePointer > 0) mm.tapePointer--; 
      if (mm.tapePointer > 0) mm.tapePointer--; 
      mm.put();
      mm.add("nl*lines*nl*");
      mm.push();
      mm.push();
      mm.push();
      continue parse;
    }
    // -------------
    // 6 tokens
    mm.pop();
    //-------------------
    // push all tokens back on the stack
    mm.push();
    mm.push();
    mm.push();
    mm.push();
    mm.push();
    mm.push();
    if ((mm.peep == null)) {
      mm.pop();
      mm.pop();
      mm.pop();
      if ((mm.workspace == "nl*lines*nl*")) {
        mm.workspace = '';
        mm.add("<html>\n");
        mm.increment();
        mm.get();
        mm.add("</html>\n");
        mm.print();
        mm.workspace = '';
        break script;
      }
      mm.push();
      mm.push();
      mm.push();
      mm.add("Document did not parse as expected!\n");
      mm.print();
      mm.workspace = '';
      break script;
    }
    break parse;
  }
} 
