const fs=require('fs'),vm=require('vm'),assert=require('assert');
const code=fs.readFileSync(process.argv[2],'utf8');const tail=code.slice(code.indexOf('function BVY_N54F_RESET()'));assert(tail.startsWith('function BVY_N54F_RESET()'));
const state={};const context={BVY_N54C_STATE:()=>state,String};vm.createContext(context);vm.runInContext(tail,context);
const reset=context.BVY_N54F_RESET,add=context.BVY_N54F_ADD;const order=[];
class ObservedSet extends Set{add(key){order.push(key);return super.add(key);}}
const fl={own:new ObservedSet(),hot:new ObservedSet(),stat:new ObservedSet(),def:'owner:definition'};
for(const name of ['own','hot','stat']){for(let i=0;i<40;i++){const k='x'.repeat(400)+i;assert.strictEqual(add(fl,name,k,'producer'),fl[name]);assert.strictEqual(add(fl,name,k,'producer'),fl[name]);}assert.strictEqual(fl[name].size,40);const group=state.factOrigins[name];assert.strictEqual(group.attempts,80);assert.strictEqual(group.newKeys,40);assert.strictEqual(group.samples.length,16);assert(group.samples.every(x=>x.key.length===256&&x.keyLength>400));assert.strictEqual(group.producers.producer.newKeys,40);}
assert.strictEqual(order.length,240);assert.strictEqual(order[0],order[1]);state.factOrigins=reset();assert.strictEqual(add(fl,'own','x'.repeat(400)+'0','later'),fl.own);assert.strictEqual(state.factOrigins.own.newKeys,0);assert.strictEqual(state.factOrigins.own.samples.length,0);assert.strictEqual(add(fl,'own','fresh','later','callee'),fl.own);assert.strictEqual(state.factOrigins.own.newKeys,1);assert.strictEqual(state.factOrigins.own.samples[0].definition,'callee');
process.stdout.write('FACT_ORIGIN_CONTROL_PASS\n');
