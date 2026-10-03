import fs from 'node:fs';
const read=p=>fs.readFileSync(p,'utf8').trimEnd().split('\n');
const [original,mutant]=process.argv.slice(2).map(read);
if(original.length!==6 || mutant.length!==6) throw Error('missing checkpoints');
for(let i=0;i<6;i++) if(original[i].split(':')[0]!==mutant[i].split(':')[0]) throw Error('checkpoint changed');
for(const i of [0,1]) if(original[i]!==mutant[i]) throw Error('setup changed');
if(mutant.slice(2).some(line=>line.slice(line.indexOf(':'))!==mutant[0].slice(mutant[0].indexOf(':')))) throw Error('mutant is not unchanged storage');
if(original[2]===mutant[2]) throw Error('no-update mutant survived');
console.log('statement 2 finite mutant detected: '+original[2]+' versus '+mutant[2]);
