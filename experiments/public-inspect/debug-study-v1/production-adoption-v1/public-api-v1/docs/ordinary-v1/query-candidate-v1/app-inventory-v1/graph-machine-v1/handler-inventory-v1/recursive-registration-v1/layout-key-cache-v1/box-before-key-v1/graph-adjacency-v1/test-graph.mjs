import fs from 'node:fs';
import assert from 'node:assert/strict';
const source=fs.readFileSync(new URL('./optimized/comp.ts',import.meta.url),'utf8');
const block=source.slice(source.indexOf('function graph_close<K>'),source.indexOf('// Term',source.indexOf('function graph_close<K>')));
const after=new Function('return '+block.replace('graph_close<K>(set: Set<K>, edges: K[][]): Set<K>','graph_close(set, edges)').replace('new Map<K, K[]>()','new Map()'))();
const before=(set,edges)=>{for(const k of set)edges.forEach(([a,b])=>a===k&&set.add(b));return set;};
const object={}, other={};
const cases=[ [[],[]], [['a'],[]], [['a'],[['b','c']]], [['a'],[['a','b'],['a','b'],['b','c']]], [['a'],[['a','a']]], [['a'],[['a','b'],['b','a']]], [['b','a'],[['a','c'],['b','d'],['c','e']]], [[NaN],[[NaN,'bad']]], [[0],[[-0,'ok']]], [[object],[[other,'bad'],[object,other],[other,'ok']]], [[undefined],[[undefined,null],[null,false],[false,'end']]] ];
for(const [seeds,edges] of cases){const a=new Set(seeds),b=new Set(seeds);assert.equal(before(a,edges),a);assert.equal(after(b,edges),b);assert.deepEqual([...a],[...b]);}
console.log(JSON.stringify({cases:cases.length,strictNaN:true,setIdentity:true,insertionOrder:true,result:'PASS'}));
