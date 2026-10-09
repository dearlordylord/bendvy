// Retained initial-IR validation only; no compiler import or execution.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
const strip=node=>{while(node?.$==='Ann')node=node.x;return node;};
const unbanged=node=>{assert(!Object.hasOwn(node,'b')||node.b===false,'true/unknown reference bang token');};
export function validateRetained(report){
 const observed=report.observed;assert(observed.routes.length>0,'no routes');
 const instances=new Map();
 for(const row of report.templateInstances)for(const key of row.instances){assert(!instances.has(key),'ambiguous template');instances.set(key,row.template);}
 const bodies=new Map(observed.bodies.map(body=>[body.key,body]));assert.equal(bodies.size,observed.bodies.length);
 const proofs=[];
 for(const route of observed.routes){
  assert.deepEqual(route.origin,[instances.get(route.key)]);
  assert(instances.get(route.key).endsWith(':check_target_routed'),'wrong routed origin');
  assert(route.arguments.includes('flag'),'selector erased');
  const root=strip(JSON.parse(route.raisedBodyKey));
  assert.equal(root.$,'Mat');assert.equal(root.k,'True');
  const other=strip(root.m);assert.equal(other.$,'Mat');assert.equal(other.k,'False');assert.equal(strip(other.m).$,'Efq');
  assert.equal(route.arms.length,2);assert.deepEqual(route.arms.map(arm=>arm.constructor),['True','False']);
  const keys=[];
  for(const [index,arm]of [root,other].entries()){
   const owner=strip(arm.h);assert.equal(owner.$,'Lam');assert.equal(owner.k,'owner');
   const target=strip(owner.f);assert.equal(target.$,'Lam');assert.equal(target.k,'target');
   // The observed duplicate is this Ann wrapper and its SAME immediate App child.
   const wrapper=target.f;assert.equal(wrapper.$,'Ann','missing observed wrapper');assert.equal(wrapper.x.$,'App');
   const application=wrapper.x, headApplication=strip(application.f);assert.equal(headApplication.$,'App');
   const reference=strip(headApplication.f);assert.equal(reference.$,'Ref');unbanged(reference);
   assert.deepEqual(strip(headApplication.x),{$:'Var',k:'owner',i:0},'original owner argument changed');
   assert.deepEqual(strip(application.x),{$:'Var',k:'target',i:1},'original target argument changed');
   const body=bodies.get(reference.k);assert(body,'unmapped specialized body');
   assert.deepEqual(body.origin,[instances.get(body.key)]);assert(instances.get(body.key).endsWith(':check_target_body'),'wrong body origin');
   assert.equal(body.countedSites,2);assert.equal(body.flat,false);
   const rows=route.arms[index].calls;assert.equal(rows.length,2,'unexpected traversal records');assert.deepEqual(rows[0],rows[1],'wrapper/App facts differ');
   for(const row of rows){assert.equal(row.key,reference.k);assert.equal(row.argumentCount,2);assert.equal(row.countedSites,body.countedSites);assert.equal(row.flatCall,false);assert.equal(row.tail,true);assert(!Object.hasOwn(row,'bang')||row.bang===false,'true/unknown call bang token');}
   keys.push(body.key);
  }
  assert.equal(keys[0],keys[1],'constructor arms call different bodies');
  proofs.push({route:route.key,body:keys[0],countedSites:2,flat:false,logicalCallsPerArm:1,traversalRecordsPerArm:2,annotationWrapperAndImmediateApp:true,bang:'absent-or-explicit-false'});
 }
 return {status:'RETAINED_REFERENCE_INITIAL_SURVIVAL_VALIDATED',scope:'Initial a950fd68 file_book/fun_of only; original collector remains INCOMPLETE; no later fusion/stock2.035/backend qualification',routes:proofs.length,bodies:bodies.size,proofs};
}
if(process.argv[1]===fileURLToPath(import.meta.url)){
 const path=process.argv[2];assert(path,'immutable witness required');
 const report=JSON.parse(fs.readFileSync(path,'utf8'));
 const result=validateRetained(report);fs.writeSync(1,JSON.stringify(result,null,2)+'\n');
}
