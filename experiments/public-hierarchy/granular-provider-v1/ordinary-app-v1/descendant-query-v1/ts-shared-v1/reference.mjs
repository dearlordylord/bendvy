import { Descriptor as D, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone = value => JSON.parse(JSON.stringify(value));
const result = value => value.ok ? (value.value === undefined ? {ok:true} : {ok:true,value:clone(value.value)}) : {ok:false,error:clone(value.error)};
export function run() {
  const output=[];
  for (const name of ['HierarchyAlpha','HierarchyBeta']) {
    const scenarios=[];
    for (const kind of ['descendant-query','root-repeat']) {
      const Cells=D.Component()('Cells');
      const Owned=D.Resource()('Owned'),Owners=D.Resource()('Owners');
      const {relation:Parent}=D.Hierarchy('Parent','Children');
      const {relation:Link}=D.Relation('Link','Incoming');
      const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned,Owners},relations:{Parent,Link}}),Schema.defineRoot(name));
      const runtime=G.Runtime.make({resources:{Owned:kind==='descendant-query'?[17,18]:[[17],[18]],Owners:kind==='descendant-query'?[901,902]:[19]},debug:true});
      const ids=[],records=[],attempts=[];
      const query=G.Query({selection:{cells:G.Query.write(Cells)}});
      const flush=G.Schedule.applyDeferred();
      const tick=(...steps)=>runtime.tick(G.Schedule(...steps));
      const observer=G.System('Observe',{queries:{all:query},removed:{cells:G.System.readRemoved(Cells)},despawned:{all:G.System.readDespawned()}},({lookup,queries,removed,despawned})=>{
        const handles=r=>r.ok?{ok:true,value:Array.isArray(r.value)?r.value.map(h=>h.value):r.value.value}:{ok:false,error:clone(r.error)};
        const traversal=ids.map(id=>({id:id.value,root:handles(lookup.root(id,Parent)),ancestors:handles(lookup.ancestors(id,Parent)),depth:handles(lookup.descendants(id,Parent,{order:'depth'})),breadth:handles(lookup.descendants(id,Parent,{order:'breadth'})),children:handles(lookup.relatedSources(id,Parent)),link:handles(lookup.related(id,Link)),incoming:handles(lookup.relatedSources(id,Link))}));
        records.push({logical:{rows:queries.all.each().map(row=>({id:row.entity.id.value,cells:clone(row.data.cells.get())})),traversal,removed:removed.cells.all().map(h=>h.value),despawned:despawned.all.all().map(h=>h.value)}});
      });
      const snapshot=label=>{const outcome=tick(observer);if(!outcome.ok)throw new Error(JSON.stringify(outcome));Object.assign(records.at(-1),{label,physical:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams())});};
      tick(G.System('Spawn',{},({commands})=>{for(let id=1;id<=4;id++)ids.push(commands.spawn(kind==='root-repeat'||id===2||id===4?G.Command.spawn([Cells,kind==='root-repeat'?{cells:[id,id*10],tag:id}:[id,id*10]]):G.Command.spawn()));}),flush);
      const seed=G.System('Seed',{},({commands})=>{commands.relate(ids[1],Parent,ids[0]);commands.relate(ids[2],Parent,ids[0]);commands.relate(ids[3],Parent,ids[1]);if(kind==='root-repeat')commands.relate(ids[2],Link,ids[1]);});
      if(kind==='descendant-query') {
        snapshot('BEFORE');tick(seed);snapshot('PENDING');
        let order='depth',fail=false;
        const visit=G.System('Visit',{queries:{selected:query}},({lookup})=>{const selected=lookup.descendantMatches(ids[0],Parent,query,{order});const rows=[];attempts.push({order,fail,path:result(lookup.descendants(ids[0],Parent,{order})),selected:selected.ok?selected.value.map(row=>row.entity.id.value):result(selected),rows});if(!selected.ok)return Fx.fail(selected.error);for(const row of selected.value){const id=row.entity.id.value;rows.push({id,before:clone(row.data.cells.get())});row.data.cells.set([id+100,id+200]);if(fail&&id===4)return Fx.fail(4);}});
        attempts.push({label:'PENDING_DEPTH',outcome:result(tick(visit))});tick(flush);snapshot('APPLIED');fail=true;attempts.push({label:'FAILED_DEPTH',outcome:result(tick(visit))});snapshot('AFTER_FAILURE');fail=false;attempts.push({label:'RETRY_DEPTH',outcome:result(tick(visit))});snapshot('AFTER_RETRY');order='breadth';attempts.push({label:'BREADTH',outcome:result(tick(visit))});snapshot('FINAL');
      } else {
        tick(seed,flush);snapshot('INITIAL');let target=ids[1],fail=true;
        const cleanup=G.System('Cleanup',{},({commands})=>{commands.despawn(target);if(fail)return Fx.fail(77);});
        attempts.push({label:'ABORT',outcome:result(tick(cleanup))});tick(flush);snapshot('ABORTED');fail=false;attempts.push({label:'QUEUE',outcome:result(tick(cleanup))});snapshot('PENDING');tick(flush);snapshot('APPLIED');target=ids[0];attempts.push({label:'ROOT_QUEUE',outcome:result(tick(cleanup))});snapshot('ROOT_PENDING');attempts.push({label:'DUPLICATE_QUEUE',outcome:result(tick(cleanup))});snapshot('DUPLICATE_PENDING');tick(flush);snapshot('ROOT_APPLIED');attempts.push({label:'DEAD_REPEAT_QUEUE',outcome:result(tick(cleanup))});snapshot('DEAD_REPEAT_PENDING');tick(flush);snapshot('DEAD_REPEAT_APPLIED');
      }
      scenarios.push({kind,records,attempts});
    }
    output.push({schema:name,scenarios});
  }
  return output;
}
if (import.meta.main) console.log(JSON.stringify(run()));
