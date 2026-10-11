import assert from 'node:assert/strict';
import {context,timed,current,snapshot} from './layout-attribution.mjs';
const token={};assert.equal(context('outer',()=>timed('lay_of',()=>token)),token);
context('outer',()=>{assert.equal(current(),'outer');context('inner',()=>assert.equal(current(),'inner'));assert.equal(current(),'outer');});
const error=new Error('sentinel');assert.throws(()=>context('failed',()=>timed('lay_eq',()=>{throw error;})),e=>e===error);assert.equal(current(),'<outside-definition>');
let calls=0;assert.equal(context('same',()=>timed('lay_eq',()=>true||timed('stringify',()=>{calls++;return false;}))),true);assert.equal(calls,0);
assert.equal(snapshot().definitions.find(r=>r.definition==='failed').metrics.lay_eq.calls,1);
console.log(JSON.stringify({nestedContext:true,errorIdentity:true,resultIdentity:true,shortCircuit:true,outsideRestored:true}));
