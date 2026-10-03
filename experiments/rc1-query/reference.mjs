import { Descriptor, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

// All finite inputs are fixed before execution. IDs are recorded at reservation.
const inputs = [
  {name:'motion', value:'Position', extra:'Tag', rows:[{label:'a',value:0,extra:{}},{label:'b',value:10}]},
  {name:'health', value:'HitPoints', extra:'Armor', rows:[{label:'a',value:20,damage:3,extra:1},{label:'b',value:30,damage:2}]},
];
for (const input of inputs) {
  const Value=Descriptor.Component()(input.value);
  const Extra=Descriptor.Component()(input.extra);
  const Damage=Descriptor.Component()('Damage');
  const health=input.name==='health';
  const components=health?{HitPoints:Value,Damage,Armor:Extra}:{Position:Value,Tag:Extra};
  const G=Schema.bind(Schema.fragment({components}));
  const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{}});
  const labels=new Map(), handles=new Map();
  const Spawn=G.System(input.name+'/Spawn',{},({commands})=>{
    for(const row of input.rows) {
      const bundle=[[Value,health?row.value:{x:row.value}]];
      if(health) bundle.push([Damage,row.damage]);
      if(Object.hasOwn(row,'extra')) bundle.push([Extra,row.extra]);
      const id=commands.spawn(G.Command.spawn(...bundle));
      // Public ID value is only a key into this runtime's reservation mapping.
      // Labels are supplied by the input, never guessed from ID numbering.
      if(labels.has(id.value)) throw Error('duplicate reservation');
      labels.set(id.value,row.label); handles.set(row.label,id);
    }
  });
  const selection={value:G.Query.read(Value),extra:G.Query.optional(Extra)};
  if(health) selection.damage=G.Query.read(Damage);
  const required=G.Query({selection});
  const queries={Required:required,Present:G.Query({selection,with:[Extra]}),Absent:G.Query({selection,without:[Extra]}),Optional:G.Query({selection})};
  function rowText(m) {
    const label=labels.get(m.entity.id.value);
    if(label===undefined) throw Error('unmapped entity');
    const payload=m.data.extra.present?m.data.extra.get():undefined;
    const extra=m.data.extra.present?(health?'present='+payload:'present'+JSON.stringify(payload)):'absent';
    const value=m.data.value.get();
    return label+':'+(health?value:value.x)+':'+(health?m.data.damage.get()+':':'')+extra+';';
  }
  let checkpoint='setup';
  const Read=G.System(input.name+'/Read',{queries},({queries,lookup})=>{
    for(const name of ['Required','Present','Absent','Optional'])
      console.log(`${input.name}:${checkpoint}:${name}:`+queries[name].each().map(rowText).join(''));
    for(const name of ['Required','Present','Optional']) {
      const result=lookup.get(handles.get('b'),queriesSpec(name));
      console.log(`${input.name}:${checkpoint}:lookup-b-${name}:`+(result.ok?'match:'+rowText(result.value):result.error._tag));
    }
  });
  function queriesSpec(name) { return queries[name]; }
  const writeSelection={...selection,value:G.Query.write(Value)};
  const Step=G.System(input.name+'/Step',{queries:{Writable:G.Query({selection:writeSelection})}},({queries})=>{
    const own=[];
    for(const m of queries.Writable.each()) {
      m.data.value.update(x=>health?x-m.data.damage.get():{x:x.x+1});
      own.push(rowText(m)); // get() of the writable cell immediately after update
    }
    console.log(`${input.name}:${checkpoint}:own:`+own.join(''));
  });
  runtime.tick(G.Schedule(Spawn,G.Schedule.applyDeferred(),Read));
  const sequence=G.Schedule(Step,Read); // same Step value; no structural marker
  for(let i=1;i<=3;i++) { checkpoint='step'+i; runtime.tick(sequence); }
}
