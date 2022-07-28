## The Pep/Nom parsing Machine and language

Pep is a system for parsing and translating context-free (and some context-sensitive) 
languages. It is based on a very simple idea: that a "stack" and a "tape" (an array) 
working together in synchronisation are ideal for recognising and reducing parse tokens
and their associated attributes.

This idea (which is so simple that I doubt it is original) has been developed into 
a virtual-machine and script language which is useful and enjoyable for parsing and
translating all sorts of patterns.

