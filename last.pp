# Assembly listing 
read 
testis "\n"
jumpfalse 8
whilenot [\n]
testclass [\n \t]
jumpfalse 3
testis "\n"
jumpfalse 2
jump 10
a+ 
clear 
testeof 
jumpfalse 6
add "Paragraphs: "
count 
add "\n"
print 
quit 
jump 0
# End of program. 
