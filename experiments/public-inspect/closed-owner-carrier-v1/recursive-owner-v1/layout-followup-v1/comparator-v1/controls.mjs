import assert from 'node:assert/strict';
import {layEqual} from './comparator.mjs';
const word = k => ({ks:[k],arms:null});
const pack = pairs => ({ks:['w32','box'],arms:Object.fromEntries(pairs)});
const corpus=[word('w32'),word('box'),word('w64'),pack([]),pack([['A',[word('w32')]]]),pack([['A',[]],['B',[word('box')]]]),pack([['B',[word('box')]],['A',[]]]),pack([['2',[]],['1',[]]]),pack([['__proto__',[]]])];
for(let depth=0;depth<5;++depth)corpus.push(pack([['Nested',[corpus.at(-1),word('w64')]]]));
let checks=0;
for(const a of corpus)for(const b of corpus){assert.equal(layEqual(a,b),a===b||JSON.stringify(a)===JSON.stringify(b));++checks;}
const a=pack([['A',[word('box')]]]),b=structuredClone(a);
assert(layEqual(a,b));b.ks.push('w32');assert(!layEqual(a,b));a.ks.push('w32');assert(layEqual(a,b));
b.arms.A[0].ks[0]='w64';assert(!layEqual(a,b));a.arms.A[0].ks[0]='w64';assert(layEqual(a,b));
b.arms.B=[];assert(!layEqual(a,b));a.arms.B=[];assert(layEqual(a,b));delete b.arms.A;b.arms.A=a.arms.A;assert(!layEqual(a,b));
console.log(JSON.stringify({status:'LAY_DOMAIN_DIFFERENTIAL_CONTROLS_PASS',pairChecks:checks,mutationChecks:7,scope:'Synthetic source-domain cases; no actual consuming compiler layouts captured'}));
