import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [generated,oraclePath,mutant,variantOraclePath]=process.argv.slice(2);
assert(['lost-retry','premature-publication','whole-marker-rollback'].includes(mutant));
const api=(await import(pathToFileURL(generated))).default;
const expected=JSON.parse(fs.readFileSync(oraclePath,'utf8')).bend;
const names=['A','B'].flatMap(s=>['exit','transition','enter'].flatMap(p=>[0,1].flatMap(i=>['','_missing'].map(suffix=>`schema${s}_${p}${i}${suffix}`))));
const actual=[];
for(let xs=api.all_observations();;xs=xs.tail){if(xs.$==='Nil')break;assert.equal(xs.$,'Con');actual.push(xs.head);}
assert.equal(actual.length,names.length,'complete24 positive/refusal observations required');
const variantExpected=JSON.parse(fs.readFileSync(variantOraclePath,'utf8')).bend;
assert.deepEqual(Object.keys(variantExpected).sort(),[...names].sort());
assert.deepEqual(actual,names.map(name=>`${name}|[${variantExpected[name].join(', ')}]`),'all96 complete physical mutant checkpoints and12 complete actual refusals must equal independent variant oracle');
const checkpoints=['initial','queued','handler-failure','reader-failure','handler-retry','reader-retry','later-marker','repeat-readers'];
const refused=['before','after','requirements','status'];
function rows(text,name,labels){
  const prefix=`${name}|[`;assert(text.startsWith(prefix)&&text.endsWith(']'));
  const body=text.slice(prefix.length,-1),result=[];let cursor=0;
  for(let i=0;i<labels.length;i++){
    assert(body.startsWith(`${labels[i]}|`,cursor));
    const end=i+1<labels.length?body.indexOf(`, ${labels[i+1]}|`,cursor):body.length;
    assert(end>=cursor);result.push(body.slice(cursor,end));cursor=end+2;
  }
  assert.equal(result.length,labels.length);return result;
}
const parsed={};
for(let i=0;i<names.length;i++){
  const name=names[i],labels=name.endsWith('_missing')?refused:checkpoints;
  parsed[name]=rows(actual[i],name,labels);
  if(name.endsWith('_missing'))assert.deepEqual(parsed[name],expected[name],'actual before-callback requirement refusal must survive mutation');
  else assert.deepEqual(parsed[name].slice(0,2),expected[name].slice(0,2),'initial and queued full physical prefixes must survive mutation');
}
function between(row,start,end){const at=row.indexOf(start);assert(at>=0,start);const from=at+start.length;const stop=end?row.indexOf(end,from):row.length;assert(stop>=from,end);return row.slice(from,stop);}
const witnesses=[];
for(const schema of ['A','B']){
  const name=`schema${schema}_exit${mutant==='whole-marker-rollback'?1:0}`;
  const value=parsed[name][2],normal=expected[name][2];
  assert(value.startsWith(`handler-failure|hook-failed:exit${mutant==='whole-marker-rollback'?1:0}|`),'same actual handler failure required');
  if(mutant==='lost-retry'){
    assert(between(value,';flow=',';level=').includes('pending=none'));
    assert(between(normal,';flow=',';level=').includes('pending=Play:false'));
  }else if(mutant==='premature-publication'){
    const stream=between(value,';flowStream=',';levelStream=');
    assert(stream.includes('Boot>Play'),'actual premature Flow transition required');
    assert(between(normal,';flowStream=',';levelStream=').startsWith('batches=[]'));
  }else{
    for(const [start,end] of [[';cells=',';owned='],[';owned=',';flow='],[';pingStream=',';selector='],[';queue=',';registrations='],[';busEvents=',null]]){
      assert.notEqual(between(value,start,end),between(normal,start,end),`actual earlier committed ${start} must be rolled back`);
    }
    for(const [start,end] of [[';locals=',';pingStream='],[';attempts=',';deliveries='],[';deliveries=',';queue=']]){
      assert.equal(between(value,start,end),between(normal,start,end),`current owner/log ${start} must survive; unrelated Local fault is not witness`);
    }
  }
  assert.notEqual(value,normal);witnesses.push({name,checkpoint:checkpoints[2],normal,actual:value});
}
// Retain every complete actual string plus exact selected before/after witnesses.
console.log(JSON.stringify({mutant,observations:actual,witnesses,status:'REACHED_COMPLETE_TWO_SCHEMA_SEMANTIC_MUTANT_KILLED'}));
