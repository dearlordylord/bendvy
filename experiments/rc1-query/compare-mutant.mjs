import fs from 'node:fs';
const original=fs.readFileSync(process.argv[2],'utf8').trimEnd().split('\n');
const mutant=fs.readFileSync(process.argv[3],'utf8').trimEnd().split('\n');
if(original.length!==31 || mutant.length!==31) throw Error('missing mutant checkpoint');
for(let i=0;i<7;i++) if(original[i]!==mutant[i]) throw Error('mutant altered setup');
if(!original[7].startsWith('motion:step1:own:') || original[7]===mutant[7]) throw Error('no-update mutant survived first own-read checkpoint');
for(let i=0;i<31;i++) {
  const key=original[i].split(':').slice(0,3).join(':');
  if(!mutant[i].startsWith(key+':')) throw Error('mutant skipped/reordered checkpoint');
}
console.log('Compiling no-update mutant detected: '+mutant[7]+' differs from '+original[7]);
