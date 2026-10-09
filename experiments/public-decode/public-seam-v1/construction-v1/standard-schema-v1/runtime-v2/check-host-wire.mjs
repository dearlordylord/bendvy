import assert from 'node:assert/strict';
import {rawTokens,decodeObservation} from './host-wire.mjs';
import {cases,packet} from './cases.mjs';
const text=value=>({$: 'Text',value});const field=(name,value)=>({$: 'Field',name,value});
assert.deepEqual(rawTokens({$:'Missing'}),['missing']);assert.deepEqual(rawTokens({$:'Null'}),['null']);
assert.deepEqual(rawTokens({$:'Number',value:4294967295}),['number','4294967295']);
assert.deepEqual(rawTokens({$:'SignedInteger',negative:true,magnitude:281474976710655}),['signed','1','281474976710655']);
assert.throws(()=>rawTokens({$:'SignedInteger',negative:false,magnitude:281474976710656}),/signed Nat/);
for(const [value,bits] of [[0,0],[-0,2147483648],[2**-149,1],[Infinity,2139095040],[-Infinity,4286578688],[NaN,2143289344]]) {
 assert.deepEqual(rawTokens({$:'Float',value}),['float',String(bits)]);
 assert.ok(Object.is(decodeObservation({$f32Bits:bits}),value));
}
assert.deepEqual(rawTokens({$:'Binary64',high:4294967295,low:2147483648}),['binary64','4294967295','2147483648']);
assert.deepEqual(rawTokens(text('A🌍')),['text','2','65','127757']);
assert.equal(decodeObservation({$codepoints:[65,127757]}),'A🌍');
assert.throws(()=>rawTokens(text('\ud800')),/scalar representation/);
assert.throws(()=>decodeObservation({$codepoints:[55296]}),/invalid scalar/);
assert.deepEqual(rawTokens({$:'Utf16Text',units:[55296,65536]}),['utf16','2','55296','65536']);
assert.deepEqual(rawTokens({$:'Boolean',value:false}),['bool','0']);
assert.deepEqual(rawTokens({$:'Handle',namespace:17,id:19}),['handle','17','19']);
const nested={$:'Object',fields:[field('x',text('first')),field('x',{$:'Array',items:[{$:'Boolean',value:true},{$:'Null'}]}),field('🌍',{$:'Binary64',high:1,low:2})]};
assert.deepEqual(rawTokens(nested),['object','3','1','120','text','5','102','105','114','115','116','1','120','array','2','bool','1','null','1','127757','binary64','1','2']);
assert.throws(()=>rawTokens({$:'Object',fields:[field('\ud800',{$:'Null'})]}),/scalar representation/);
assert.equal(cases.length,28);
for(const item of cases) {
 const result=packet(item);
 if(item.label==='hostRefusal') {assert.equal(result.host.ok,false);assert.equal(result.argv,null);assert.deepEqual(result.host.input,item.input);}
 else {
  assert.equal(result.host.ok,true);assert.deepEqual(result.argv.slice(0,2),[item.schema,item.operation]);
  assert.deepEqual(result.argv.slice(2),rawTokens(result.host.value));
  if(item.label==='spawn'||item.label==='insert'||item.label==='resource')assert.deepEqual(result.host.value,text('7,8'));
 }
}
console.log('PASS full Raw host wire and 28 adapter-derived runtime packets; no generated runtime execution');
