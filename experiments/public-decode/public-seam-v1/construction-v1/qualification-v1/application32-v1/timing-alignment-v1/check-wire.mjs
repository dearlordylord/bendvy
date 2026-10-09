// Mock framing controls only, no model synthesized from backend outputs.
import assert from 'node:assert/strict';
import {bendPublicWire,tsPublicWire} from './wire.mjs';
const text=JSON.stringify(Array.from({length:32},(_,i)=>({name:`row${i}`,raw:'"escaped"'})));
const encoded=new TextEncoder();
assert.equal(bendPublicWire(encoded.encode(JSON.stringify(text)+'\n')).text,text);
assert.equal(tsPublicWire(encoded.encode(text+'\n')).text,text);
assert.throws(()=>bendPublicWire(encoded.encode(text+'\n')));
assert.throws(()=>bendPublicWire(encoded.encode(JSON.stringify(text)+'\n\n')));
assert.throws(()=>bendPublicWire(encoded.encode('"SERIALIZATION_INCOMPLETE"\n')));
assert.throws(()=>bendPublicWire(encoded.encode(JSON.stringify('[]')+'\n')));
console.log('MOCK_PURE_STRING_FRAMING_PASS');
