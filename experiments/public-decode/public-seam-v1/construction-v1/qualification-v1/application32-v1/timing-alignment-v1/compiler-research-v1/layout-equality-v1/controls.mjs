// Prepared portable source controls. Not run before batch admission.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import vm from 'node:vm';
const source=fs.readFileSync(new URL('./comp.ts',import.meta.url),'utf8');
const body=source.slice(source.indexOf('function lay_text('),source.indexOf('function lay_c('))
  .replaceAll(': Lay', '').replaceAll(': string', '').replaceAll(': boolean', '');
let strings=0;
const context={JSON:{stringify:x=>{strings++;return JSON.stringify(x);}}};
vm.createContext(context);
vm.runInContext('let LAY_TEXT = new WeakMap();\n'+body+'\nthis.eq=lay_eq; this.reset=()=>{LAY_TEXT=new WeakMap();};',context);
const word=()=>({ks:['w32'],arms:null});
const box=()=>({ks:['box'],arms:null});
const record=(a,b)=>({ks:['w32','box'],arms:{Pair:[a,b]}});
const a=record(word(),box()),b=record(word(),box());
assert.equal(context.eq(a,a),true);assert.equal(strings,0);
assert.equal(context.eq(a,b),true);assert.equal(strings,2);
assert.equal(context.eq(a,b),true);assert.equal(strings,2);
assert.equal(context.eq(a,record(box(),word())),false);
const sum1={ks:['w32','w32'],arms:{Left:[word()],Right:[word()]}};
const sum2={ks:['w32','w32'],arms:{Right:[word()],Left:[word()]}};
assert.equal(context.eq(sum1,sum2),false);
context.reset();const prior=strings;
assert.equal(context.eq(a,b),true);assert.equal(strings,prior+2);
assert.match(source,/function file_book\([^]*?LAY_TEXT = new WeakMap<Lay, string>\(\);/);
console.log('layout equality identity/order/nested/reset controls PASS');
