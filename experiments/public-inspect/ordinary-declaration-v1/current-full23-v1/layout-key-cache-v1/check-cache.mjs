import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=new URL('.',import.meta.url),line=JSON.parse(fs.readFileSync(new URL('LINEAGE.json',here),'utf8'));
const sha=b=>createHash('sha256').update(b).digest('hex');
let source=fs.readFileSync(new URL('compiler/candidate.mjs',here),'utf8');assert.equal(sha(source),line.candidateSHA256);
for(const p of [...line.patches].reverse()){assert.equal(source.split(p.replacement).length-1,1);source=source.replace(p.replacement,p.original);}
assert.equal(sha(source),line.originalSHA256);assert.equal(source,fs.readFileSync(line.original,'utf8'));
const candidate=fs.readFileSync(new URL('compiler/candidate.mjs',here),'utf8');
const helper=candidate.slice(candidate.indexOf('function lay_key(t) {'),candidate.indexOf('function lay_of(book, A) {'));
const memo=source.slice(source.indexOf('function memo(m, k, f) {'),source.indexOf('function memo_gc() {'));
const originalLay=source.slice(source.indexOf('function lay_of(book, A) {'),source.indexOf('function lay_el(book, A) {'));
const candidateLay=candidate.slice(candidate.indexOf('function lay_of(book, A) {'),candidate.indexOf('function lay_el(book, A) {'));
// Exercise actual helper/layout bodies with a finite ADT/Var lowering model and actual invalidation statements.
function instance(lay){return new Function(`let LAY_KEYS=new WeakMap,LAYS=new Map,calls=0; const BOX={box:true},WORDS={},WIDE=255;
function term_lower(t){if(t.$==='Var')return term_lower(t.v);return {$:t.$,k:t.k,x:t.x.map(term_lower),r:t.r};}
function term_key(t){calls++;return JSON.stringify(t);}
function ty_adt(book,A){return A;}function ctr_doms(book,c){return c.fields??[];}function ty_holds(){return false;}function lay_pack(arms){return {ks:[],arms};}
${memo}${helper}${lay}
return {key:t=>lay_key(t),layout:(b,t)=>lay_of(b,t),calls:()=>calls,normalize:(fr,tm)=>{${line.patches.find(p=>p.name==='normalization-invalidation').replacement.replace('Ann(tm, term_cell(fr.a.T), fr.a.s)','tm')}},equal:(rhs,lhs)=>{${line.patches.find(p=>p.name==='equality-invalidation').replacement}},reset:()=>{LAY_KEYS=new WeakMap;LAYS=new Map;}};`)();}
const cached=instance(candidateLay),baseline=instance(originalLay);const adt=(k,x=[])=>({$: 'ADT',k,x,r:[]});
const child={$:'Var',v:adt('Old')},root=adt('Root',[child]);const k0=cached.key(root),calls=cached.calls();assert.equal(cached.key(root),k0);assert.equal(cached.calls(),calls);
cached.normalize({l:child,a:undefined},adt('New'));const k1=cached.key(root);assert.notEqual(k1,k0);
cached.equal(child,{v:adt('AfterEquality')});assert.notEqual(cached.key(root),k1);
const book={tlds:{Leaf:{$:'ADT',c:[]},Cycle:{$:'ADT',c:[{k:'Cycle',fields:[]}]}}};const cycle=adt('Cycle');book.tlds.Cycle.c[0].fields=[cycle];
for(const t of [adt('Leaf'),cycle])assert.deepEqual(cached.layout(book,t),baseline.layout(book,t));
cached.reset();assert.deepEqual(cached.layout(book,cycle),baseline.layout(book,cycle));
for(const name of ['base.bend','bendtt.lean','effs'])assert.equal(fs.realpathSync(new URL('compiler/'+name,here)),fs.realpathSync(line.baseResourceRoot+'/'+name));
console.log(JSON.stringify({status:'CACHE_SOURCE_CONTROL_PASS',inversePatches:6,sameObjectHit:true,normalizationMutationInvalidates:true,equalityMutationInvalidates:true,recursivePlaceholderMatches:true,perBookReset:true,limits:'Finite extracted actual helper/layout controls, not universal semantic proof or speed claim.'}));
