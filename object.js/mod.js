
 // include with modules
 var pp = require('./Machine');
 var mm = new pp.Machine();
 //var fs = require('fs');
 //eval(fs.readFileSync('Machine.js')+'');

 //var mm = new Machine();
 mm.read(); mm.read();
 console.log("work:" + mm.workspace);
