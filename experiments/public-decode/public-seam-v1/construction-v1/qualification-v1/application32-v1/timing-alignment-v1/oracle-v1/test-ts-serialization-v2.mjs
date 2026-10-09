// Portable pure built-in serialization controls; no ECS imports or execution.
import assert from 'node:assert/strict';
const clone=value=>JSON.parse(JSON.stringify(value,(_key,value)=>value===undefined?{undefined:true}:value));
function trace(operation,accepted){
 const spawnedId=accepted?{value:2}:undefined;
 return {operation,checked:clone(accepted?{ok:true,value:undefined}:{ok:false,error:{actual:undefined}}),
  target:operation==='resource'?null:(operation==='spawn'?spawnedId?.value:1)};
}
const rejected=trace('spawn',false);
assert(Object.hasOwn(rejected,'target'));
assert.equal(rejected.target,undefined);
assert.deepEqual(JSON.parse(JSON.stringify(rejected)),{operation:'spawn',checked:{ok:false,error:{actual:{undefined:true}}}});
assert.deepEqual(JSON.parse(JSON.stringify(trace('spawn',true))),{operation:'spawn',checked:{ok:true,value:{undefined:true}},target:2});
assert.equal(JSON.parse(JSON.stringify(trace('resource',false))).target,null);
assert.equal(JSON.parse(JSON.stringify(trace('insert',false))).target,1);
assert.deepEqual(clone({target:undefined}),{target:{undefined:true}});
assert.deepEqual(JSON.parse(JSON.stringify([undefined])),[null]);
assert.notEqual(JSON.stringify(rejected),JSON.stringify(clone(rejected)));
console.log('PASS plain undefined omission, cloned marker preservation, null/number/array distinctions; no ECS');
