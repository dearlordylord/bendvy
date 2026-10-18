import { Descriptor as D, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
// Ordinary TS Schedule values are retained by this fixture Map. This is not a TS Schedules API.
const Counter = D.Resource()('Counter');
function scene(schema, debug) {
  const G = Schema.bind(Schema.fragment({resources:{Counter}}));
  const runtime = G.Runtime.make({resources:{Counter:9},services:G.Runtime.services(), ...(debug ? {debug:true} : {})});
  const memory = [0,0];
  let trace=[], skipped=[];
  const access = {resources:{counter:G.System.readResource(Counter)}};
  const local = (name,index) => G.System(name,access,({resources}) => {
    trace.push(name);memory[index]++;
    if(resources.counter.get() === 99) return Fx.fail('planned');
  });
  const shared = local('Shared',0), separate = local('Independent',1);
  let requested=null;
  const reader = G.System('Reader',{resources:{counter:G.System.writeResource(Counter)}},({resources})=>{trace.push('Reader');if(requested===null)resources.counter.get();else resources.counter.set(requested);});
  const never = G.Condition.check('false',{},()=>{skipped.push('Shared');return false;});
  const definitions = [shared,separate,reader];
  const plans = new Map();
  const plan = (id,skip=false) => {
    const ids = [id,3];
    const schedule = skip ? G.Schedule(G.Schedule.when([never],definitions[id-1]),reader)
      : G.Schedule(definitions[id-1],reader,G.Schedule.applyDeferred());
    return {ids,skip,schedule};
  };
  const records = [], diagnostics = [];
  const counterView=G.Inspector('CounterView',access,({resources})=>resources.counter.get());
  const describe = () => {
    if(!debug) return null;
    runtime.debug.nameSchedules(Object.fromEntries([...plans].map(([name,p])=>[name,p.schedule])));
    const full = runtime.debug.describe();
    diagnostics.push(full);
    const schedules=full.schedules.map(p=>({label:p.name,steps:p.steps.map(s=>s.kind==='system'?s.system:'barrier'),
      reads:p.steps.filter(s=>s.kind==='system').map(s=>({name:s.system,resources:full.systems.find(x=>x.name===s.system).resources.reads,writes:full.systems.find(x=>x.name===s.system).resources.writes}))}));
    const access=full.schedules.map(p=>{const names=p.steps.filter(s=>s.kind==='system').map(s=>s.system);return {label:p.name,resources:full.access.resources.map(r=>({name:r.name,readers:r.readers.filter(x=>names.includes(x)),writers:r.writers.filter(x=>names.includes(x))})).filter(r=>r.readers.length||r.writers.length)};});
    return {schedules,access};
  };
  const shape = p => p ? {ids:p.ids,skip:p.skip,barrier:!p.skip} : null;
  const record = (op,result,view=null) => records.push({op,result,view,memory:[...memory],counter:runtime.inspect(counterView),
    plans:[...plans].map(([label,p])=>({label,...shape(p)}))});
  const set = value => {requested=value;const outcome=runtime.tick(G.Schedule(reader));requested=null;if(!outcome.ok)throw Error('mode');};
  const insert=(label,id,skip=false,invalid=false)=>{
    if(invalid){
      let rejected=false;
      try {if(id===99)G.Schedule(undefined,reader,G.Schedule.applyDeferred());else G.Schedule(definitions[id-1],reader,G.Schedule.applyDeferred(),definitions[id-1],reader,G.Schedule.applyDeferred());}
      catch(error){if(!(error instanceof Error))throw error;rejected=true;}
      if(!rejected)throw Error('invalid plan admitted');
      record('insert:'+label,'invalid');return;
    }
    const next=plan(id,skip),old=plans.get(label);plans.set(label,next);record('insert:'+label,shape(old));
  };
  const run=label=>{const p=plans.get(label);if(!p){record('run:'+label,'unknown');return;}trace=[];skipped=[];const result=runtime.tick(p.schedule);record('run:'+label,{status:result.ok?'finished':'failed:'+result.error.error,ran:[...trace],skipped:[...skipped],barrier:result.ok&&!p.skip});};
  insert('First',1);insert('Second',1);insert('Separate',2);
  insert('First',99,false,true);insert('Separate',2,false,true);
  run('First');run('Second');run('First');run('Separate');
  set(99);record('failure-mode','true');run('First');set(9);record('failure-mode','false');run('Second');
  insert('First',2);run('First');
  const remove=label=>{const old=plans.get(label);plans.delete(label);record('remove:'+label,shape(old));};
  remove('Second');run('Second');record('get:First',shape(plans.get('First')));record('get:Missing',null);remove('Missing');
  insert('Skip',1,true);run('Skip');remove('Skip');
  record('snapshot',null,describe());run('First');record('snapshot',null,describe());
  return {schema,debug,records,diagnostics};
}
export function run(n=1) {
  const out=[];
  for(let i=0;i<n;i++)for(const schema of ['Workshop','Garden'])for(const debug of [false,true]) {
    const {diagnostics,...logical}=scene(schema,debug);out.push(logical);
  }
  return JSON.stringify(out);
}
export function physical() {return scene('Workshop',true);}

// Per-mode entry executes complete scenes; it never filters a completed run.
export function runMode(n, debug) {
  const out=[];
  for(let i=0;i<n;i++)for(const schema of ['Workshop','Garden']) {
    const {diagnostics,...logical}=scene(schema,debug);out.push(logical);
  }
  return JSON.stringify(out);
}
