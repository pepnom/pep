: '

 some script functions for testing [nom] scripts in this
 folder eg/

'


# test the eg/maths.to.latex.pss script but compiling to latex then pdf
# and then open
function maths.tolatex.open {
  if [ "$1" == "" ]; then
    return
  fi
  pep -f maths.to.latex.pss -i "$1" > test.tex; 
  pdflatex test.tex; open test.pdf
}
alias maths.tlo=maths.tolatex.open

# test the eg/maths.to.latex.pss script but compiling to latex
function maths.tolatex {
  if [ "$1" == "" ]; then
    return
  fi
  pep -f maths.to.latex.pss -i "$1" 
}
alias maths.tl=maths.tolatex
