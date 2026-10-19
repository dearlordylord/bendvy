import assert from 'node:assert/strict';
import {detachedSnapshot,typedObservationFold,prototypeVersion} from './reference.mjs';
assert.equal(prototypeVersion,'typed-observation-v1');
const cases=[
  [[],4355],
  [[null,false,true,0,4294967295,4294967296,281474976710655,'','A\né😀',[],{},{a:[1,{x:'\\"'}],b:null}],2780255302],
  [[{a:1,b:2}],1423231218],
  [[{b:2,a:1}],1159766642],
];
for(const [value,expected] of cases)assert.equal(typedObservationFold(value),expected);
const original={nested:[{value:7},['é😀',null]],flag:false};
const observed=detachedSnapshot(original),token=typedObservationFold(observed);
assert.notStrictEqual(observed,original);assert.notStrictEqual(observed.nested,original.nested);assert.notStrictEqual(observed.nested[0],original.nested[0]);
original.nested[0].value=9;original.nested[1].push('later');original.flag=true;
assert.deepEqual(observed,{nested:[{value:7},['é😀',null]],flag:false});assert.equal(typedObservationFold(observed),token);
function frozen(value){if(value!==null&&typeof value==='object'){assert.ok(Object.isFrozen(value));for(const child of Object.values(value))frozen(child);}}
frozen(observed);assert.equal(Object.isFrozen(original),false);assert.throws(()=>{observed.nested[0].value=1;},TypeError);
for(const invalid of [-1,0.5,NaN,Infinity,9007199254740992,281474976710656,1n,undefined,()=>0,new Date(),new Array(1),'\ud800'])assert.throws(()=>typedObservationFold(invalid),TypeError);
assert.throws(()=>typedObservationFold([],4294967296),TypeError);
console.log('PASS typed-observation-v1: four independent tokens, detached frozen snapshots, numeric/type/Unicode rejections');
