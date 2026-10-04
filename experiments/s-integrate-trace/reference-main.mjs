import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const REFERENCE='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const manifest=JSON.parse(readFileSync(new URL('../../.references/sources.json',import.meta.url),'utf8'));
const commit=execFileSync('git',['-C',REFERENCE,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim();
assert.equal(commit,manifest.sources['bevy-ts'].commit);
const results=[], differences=[];
const clone=value=>structuredClone(value);
function check(lane,path,actual,expected){try{assert.deepEqual(actual,expected);}catch{differences.push({lane,path,expected:clone(expected),actual:clone(actual)});}}
function execute(schema,style){
  const lane=schema+'/'+style;
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals');
  const Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor');
  const Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked');
  const Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping'),Audit=Descriptor.Service()('Audit');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{[Ping.name]:Ping}}));
  const Mode=G.StateMachine('Mode',['On','Off']);
  const main=x=>schema==='Motion'?{coordinates:[x,x+1,x+2,x+3],frame:7}:{levels:[x,x+1,x+2,x+3],reserve:9,class:2};
  const aux=()=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
  const first=(value,x)=>schema==='Motion'?{coordinates:[x,...value.coordinates.slice(1)],frame:value.frame}:{levels:[x,...value.levels.slice(1)],reserve:value.reserve,class:value.class};
  const ledger=x=>({totals:[x,101,102,103],epoch:4});
  const Q=G.Query({selection:{main:G.Query.read(Main),flag:G.Query.optional(Flag)}});
  const Plus=G.Query({selection:{main:G.Query.read(Main),flag:G.Query.optional(Flag)},with:[Flag]});
  const Minus=G.Query({selection:{main:G.Query.read(Main),flag:G.Query.optional(Flag)},without:[Flag]});
  const Optional=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
  const AuxRows=G.Query({selection:{aux:G.Query.read(Aux),main:G.Query.optional(Main),flag:G.Query.optional(Flag)}});
  const Added=G.Query({selection:{main:G.Query.read(Main)},filters:[G.Query.added(Main)]});
  const Changed=G.Query({selection:{main:G.Query.read(Main)},filters:[G.Query.changed(Main)]});
  const Write=G.Query({selection:{main:G.Query.write(Main)}});
  const effects=[], reservations=[], invocations=[], reads=[], readerDiagnostics=[], ownWrites=[], snapshots=[], dispatches=[];
  const makeRuntime=(resource=true,service=true,serviceEffects=effects)=>G.Runtime.make({resources:resource?{[Ledger.name]:ledger(100)}:{},
    services:service?G.Runtime.services(G.Runtime.service(Audit,{log:text=>serviceEffects.push(text)})):G.Runtime.services(),
    machines:G.Runtime.machines(G.Runtime.machine(Mode,'On')),debug:true});
  const alpha=makeRuntime(),beta=makeRuntime();
  const ids={alpha:new Map(),beta:new Map()}, handles={alpha:new Map(),beta:new Map()};
  const names={alpha:new Map(),beta:new Map()};
  const D=()=>G.Schedule.applyDeferred(),T=()=>G.Schedule.applyStateTransitions();
  function label(world,id){const name=names[world].get(id.value);assert.notEqual(name,undefined);return name;}
  function reserve(world,commands,name,value,withAux=false,withFlag=false){
    const entries=value===null?[]:[[Main,main(value)]];
    if(withAux)entries.push([Aux,aux()]);if(withFlag)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids[world].set(name,id);handles[world].set(name,G.Entity.handle(id));names[world].set(id.value,name);
    reservations.push({world,label:name,rawId:id.value,rawHandle:handles[world].get(name).value,components:clone(entries.map(([descriptor,value])=>({name:descriptor.name,value})))});
  }
  function row(world,match,optional=false){const value={label:label(world,match.entity.id),rawId:match.entity.id.value,main:clone(match.data.main.get())};
    if(match.data.flag)value.flag=match.data.flag.present?clone(match.data.flag.get()):null;
    if(optional)value.aux=match.data.aux.present?clone(match.data.aux.get()):null;return value;}
  function auxiliary(world,match){return {label:label(world,match.entity.id),rawId:match.entity.id.value,aux:clone(match.data.aux.get()),
    main:match.data.main.present?clone(match.data.main.get()):null,flag:match.data.flag.present?clone(match.data.flag.get()):null};}
  let step='E0',mode='observe',betaApplied=false;let auxLive=[],flagLive=[],alive=new Set();
  const stopReaderDiagnostics=alpha.debug.observe(event=>{
    if(event.type!=='system'||(event.system!=='Fast'&&event.system!=='B'))return;
    const invocation=reads.findLast(read=>read.step===step&&read.who===event.system&&!read.traceDiagnostic);
    assert.notEqual(invocation,undefined,'Public system event must follow its actual reader callback');
    const diagnostic={frame:event.frame,tick:event.tick,outcome:event.outcome,missed:clone(event.missed)};
    invocation.traceDiagnostic=diagnostic;
    readerDiagnostics.push({step,who:event.system,count:invocation.count,...diagnostic});
    check(lane,step+'.'+event.system+'.public-debug-missed',event.missed,[]);
    check(lane,step+'.'+event.system+'.public-debug-outcome',event.outcome,
      event.system==='B'&&(step==='E2'||step==='E7-fail')?'failed':'ok');
  });
  function snapshot(world,name,prior){let data;const Observe=G.System('Snapshot:'+world+':'+name,{queries:{q:Q,plus:Plus,minus:Minus,optional:Optional,aux:AuxRows},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
    const lookups={};for(const [name,handle] of handles[world]){const found=lookup.getHandle(handle,Q);lookups[name]=found.ok?{result:'Found',...row(world,found.value)}:{result:found.error._tag,rawHandle:handle.value};}
    data={world,name,q:queries.q.each().map(x=>row(world,x)),plus:queries.plus.each().map(x=>row(world,x)),minus:queries.minus.each().map(x=>row(world,x)),optional:queries.optional.each().map(x=>row(world,x,true)),aux:queries.aux.each().map(x=>auxiliary(world,x)),ledger:clone(resources.ledger.get()),lookups,
      prior:prior?.ok===false?clone(prior):{ok:true}};
  });assert.equal((world==='alpha'?alpha:beta).tick(G.Schedule(Observe)).ok,true);snapshots.push(data);return data;}
  function local(name){let owner=[0,0,0,0];return {invoke(){if(style==='returned-owner'){owner=[owner[0]+1,...owner.slice(1)];}else{let called=false;const once=()=>{assert.equal(called,false);called=true;return [owner[0]+1,...owner.slice(1)];};owner=once();}
    invocations.push({step,name,owner:[...owner]});return owner[0];},get(){return [...owner];}};}
  const locals={A:local('A'),B:local('B'),Fast:local('Fast')};
  const tails={inner:0,outer:0};
  function read(context,who,count){const result={step,who,count,q:context.queries.q.each().map(x=>row('alpha',x)),
    added:context.queries.added.each().map(x=>row('alpha',x)),changed:context.queries.changed.each().map(x=>row('alpha',x)),
    removed:context.removed.main.all().map(id=>({label:label('alpha',id),rawId:id.value})),
    despawned:context.despawned.entities.all().map(id=>({label:label('alpha',id),rawId:id.value})),
    messages:context.events.input.all().map(x=>clone(x)),lag:{messages:context.events.input.lagged(),removed:'unavailable-public-api',despawned:'unavailable-public-api'}};
    reads.push(result);return result;}
  const readerSpec={queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entities:G.System.readDespawned()},events:{input:G.System.readEvent(Ping)}};
  const Fast=G.System('Fast',readerSpec,context=>{read(context,'Fast',locals.Fast.invoke());});
  const A=G.System('A',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events,commands,services,lookup})=>{
    const count=locals.A.invoke(),a=queries.write.get(ids.alpha.get('a'));assert.equal(a.ok,true);
    a.value.data.main.set(first(a.value.data.main.get(),11));resources.ledger.set({...resources.ledger.get(),totals:[101,...resources.ledger.get().totals.slice(1)]});
    events.out.emit({code:1});reserve('alpha',commands,'p',50,false,true);commands.remove(ids.alpha.get('a'),Flag);
    ownWrites.push({step,who:'A',main:clone(a.value.data.main.get()),ledger:clone(resources.ledger.get()),reserved:lookup.getHandle(handles.alpha.get('p'),Q).error._tag});
    services.audit.log('A:attempt:'+count);
  });
  const B=G.System('B',{...readerSpec,when:[G.Condition.inState(Mode,'On')],queries:{...readerSpec.queries,write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{...readerSpec.events,out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},context=>{
    const count=locals.B.invoke();read(context,'B',count);
    if(mode==='observe-fail')return Fx.fail({code:7});
    if(mode!=='fail'&&mode!=='retry')return;
    const b=context.queries.write.get(ids.alpha.get('b'));assert.equal(b.ok,true);
    b.value.data.main.set(first(b.value.data.main.get(),30));ownWrites.push({step,who:'B:first',main:clone(b.value.data.main.get())});
    b.value.data.main.set(first(b.value.data.main.get(),50));context.resources.ledger.set({...context.resources.ledger.get(),totals:[201,...context.resources.ledger.get().totals.slice(1)]});
    const name=mode==='fail'?'q':'r';reserve('alpha',context.commands,name,60);context.commands.insert(ids.alpha.get('b'),[Flag,{group:8}]);context.events.out.emit({code:mode==='fail'?9:2});
    ownWrites.push({step,who:'B:second',main:clone(b.value.data.main.get()),ledger:clone(context.resources.ledger.get()),reserved:context.lookup.getHandle(handles.alpha.get(name),Q).error._tag});
    context.services.audit.log('B:attempt:'+count);if(mode==='fail')return Fx.fail({code:7});
  });
  const Inner=G.System('TailInner',{},()=>{tails.inner++;}),Outer=G.System('TailOuter',{},()=>{tails.outer++;});
  const SetOff=G.System('SetOff',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>{nextMachines.mode.set('Off');});
  const SetOn=G.System('SetOn',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>{nextMachines.mode.set('On');});
  function tick(name,...systems){step=name;const result=alpha.tick(G.Schedule(...systems));dispatches.push({name,result:clone(result),counts:Object.fromEntries(Object.entries(locals).map(([k,v])=>[k,v.get()])),tails:{...tails}});return result;}
  function tuple(name,who,added,changed,removed,despawned,messages,count){const actual=reads.filter(r=>r.step===name&&r.who===who).at(-1);assert.notEqual(actual,undefined);
    check(lane,name+'.'+who+'.tuple',{added:actual.added.map(r=>r.label),changed:actual.changed.map(r=>r.label),removed:actual.removed.map(r=>r.label),despawned:actual.despawned.map(r=>r.label),messages:actual.messages.map(x=>x.code),count:actual.count,lag:actual.lag.messages},
      {added,changed,removed,despawned,messages,count,lag:false});
    const states={
      'E0-prime':[[],{},[]],
      E1:[['a','b'],{a:main(10),b:main(20)},['a']],
      E2:[['a','b'],{a:first(main(10),11),b:main(20)},['a']],
      E3:[['a','b'],{a:first(main(10),11),b:main(20)},['a']],
      'E4-retry':[['a','b'],{a:first(main(10),11),b:main(20)},['a']],
      'E4-read':[['a','b'],{a:first(main(10),11),b:first(main(20),50)},['a']],
      E5:[['a','b','p','r'],{a:first(main(10),11),b:first(main(20),50),p:main(50),r:main(60)},['b','p']],
      E6b:[['p','r'],{p:first(main(50),51),r:main(60)},['p']],
      'E7-fail':[['p','r'],{p:first(main(50),51),r:main(60)},['p']],
      'E7-retry':[['p','r'],{p:first(main(50),51),r:main(60)},['p']],
      E8:[['a','c','p','r'],{a:main(81),c:main(30),p:main(71),r:main(60)},['c','p']],
      E9:[[],{},[]]};
    const [live,values,flagged]=states[name];
    const basic=label=>({label,rawId:ids.alpha.get(label).value,main:values[label]});
    check(lane,name+'.'+who+'.complete-q',actual.q,live.map(label=>({...basic(label),flag:flagged.includes(label)?{group:8}:null})));
    check(lane,name+'.'+who+'.complete-added',actual.added,added.map(basic));check(lane,name+'.'+who+'.complete-changed',actual.changed,changed.map(basic));
    check(lane,name+'.'+who+'.complete-removed',actual.removed,removed.map(label=>({label,rawId:ids.alpha.get(label).value})));
    check(lane,name+'.'+who+'.complete-despawned',actual.despawned,despawned.map(label=>({label,rawId:ids.alpha.get(label).value})));
    check(lane,name+'.'+who+'.complete-messages',actual.messages,messages.map(code=>({code})));
  }
  function fullSnapshot(name,live,values,flagged,withAux,ledgerFirst=101,prior){const data=snapshot('alpha',name,prior);
    const expected=live.map(label=>({label,rawId:ids.alpha.get(label).value,main:values[label],flag:flagged.includes(label)?{group:8}:null}));
    check(lane,name+'.q',data.q,expected);check(lane,name+'.plus',data.plus,expected.filter(x=>flagged.includes(x.label)));check(lane,name+'.minus',data.minus,expected.filter(x=>!flagged.includes(x.label)));
    check(lane,name+'.optional',data.optional,expected.map(x=>({...x,aux:withAux.includes(x.label)?aux():null})));check(lane,name+'.ledger',data.ledger,ledger(ledgerFirst));
    const auxExpected=auxLive.map(label=>({label,rawId:ids.alpha.get(label).value,aux:aux(),main:values[label]??null,flag:flagLive.includes(label)?{group:8}:null}));
    check(lane,name+'.aux',data.aux,auxExpected);
    for(const label of ids.alpha.keys())check(lane,name+'.lookup.'+label,data.lookups[label],live.includes(label)?{result:'Found',...expected.find(x=>x.label===label)}:{result:alive.has(label)?'QueryMismatch':'MissingEntity',rawHandle:handles.alpha.get(label).value});
    const other=snapshot('beta',name),expectedBeta=betaApplied?[{label:'z',rawId:ids.beta.get('z').value,main:main(90),flag:{group:8}}]:[];
    check(lane,name+'.beta',{q:other.q,plus:other.plus,minus:other.minus,optional:other.optional,aux:other.aux,ledger:other.ledger},
      {q:expectedBeta,plus:expectedBeta,minus:[],optional:expectedBeta.map(x=>({...x,aux:null})),aux:[],ledger:ledger(100)});
    if(ids.beta.has('z'))check(lane,name+'.beta.lookup',other.lookups.z,betaApplied?{result:'Found',...expectedBeta[0]}:{result:'MissingEntity',rawHandle:handles.beta.get('z').value});
    return data;}
  tick('E0-empty');check(lane,'E0.empty-counts',Object.values(locals).map(x=>x.get()),[[0,0,0,0],[0,0,0,0],[0,0,0,0]]);
  tick('E0-prime',Fast,B);tuple('E0-prime','Fast',[],[],[],[],[],1);tuple('E0-prime','B',[],[],[],[],[],1);
  const SeedAlpha=G.System('SeedAlpha',{},({commands})=>{reserve('alpha',commands,'a',10,true,true);reserve('alpha',commands,'b',20);reserve('alpha',commands,'c',null,true,true);});
  const SeedBeta=G.System('SeedBeta',{},({commands})=>{reserve('beta',commands,'z',90,false,true);});
  tick('E0-seed',SeedAlpha);assert.equal(beta.tick(G.Schedule(SeedBeta)).ok,true);
  const pending=fullSnapshot('E0-pending',[],{},[],[],100);for(const name of ['a','b','c'])check(lane,'E0.pending.'+name,pending.lookups[name].result,'MissingEntity');
  tick('E1-empty');fullSnapshot('E1-before-D',[],{},[],[],100);
  tick('E1',D(),Fast);alive=new Set(['a','b','c']);auxLive=['a','c'];flagLive=['a','c'];assert.equal(beta.tick(G.Schedule(D())).ok,true);betaApplied=true;tuple('E1','Fast',['a','b'],['a','b'],[],[],[],2);
  let snap=fullSnapshot('E1',['a','b'],{a:main(10),b:main(20)},['a'],['a'],100);check(lane,'E1.c-mismatch',snap.lookups.c.result,'QueryMismatch');
  const foreign=[];
  function foreignRead(receiver,source,name){const Observe=G.System('ForeignLookup',{},({lookup})=>{const result=lookup.getHandle(handles[source].get(name),Q);foreign.push({receiver,source,label:name,rawHandle:handles[source].get(name).value,result:result.ok?{result:'Found',...row(receiver,result.value)}:{result:result.error._tag}});});assert.equal((receiver==='alpha'?alpha:beta).tick(G.Schedule(Observe)).ok,true);}
  foreignRead('beta','alpha','a');foreignRead('alpha','beta','z');check(lane,'E10.foreign-collision',foreign.map(x=>x.result.label),['z','a']);
  mode='fail';const failure=tick('E2',A,Fast,G.Schedule(B,Inner),Outer);check(lane,'E2.failure',failure,{ok:false,error:{kind:'SystemFailure',system:'B',error:{code:7}}});tuple('E2','Fast',[],['a'],[],[],[1],3);tuple('E2','B',['a','b'],['a','b'],[],[],[1],2);check(lane,'E2.tails',tails,{inner:0,outer:0});
  const base={a:first(main(10),11),b:main(20)};
  fullSnapshot('E3-before-empty',['a','b'],base,['a'],['a'],101,failure);tick('E3-empty');snap=fullSnapshot('E3-after-empty',['a','b'],base,['a'],['a'],101);for(const name of ['p','q'])check(lane,'E3.pending.'+name,snap.lookups[name].result,'MissingEntity');tick('E3',Fast);tuple('E3','Fast',[],[],[],[],[],4);
  mode='retry';tick('E4-retry',G.Schedule(B,Inner),Outer);tuple('E4-retry','B',['a','b'],['a','b'],[],[],[1],3);check(lane,'E4.tails',tails,{inner:1,outer:1});
  const retry={a:base.a,b:first(main(20),50)};fullSnapshot('E4-before-empty',['a','b'],retry,['a'],['a'],201);tick('E4-empty');fullSnapshot('E4-after-empty',['a','b'],retry,['a'],['a'],201);mode='observe';tick('E4-read',Fast,B);tuple('E4-read','Fast',[],['b'],[],[],[2],5);tuple('E4-read','B',[],[],[],[],[2],4);
  tick('E5',D(),Fast,B);alive.add('p');alive.add('r');flagLive=['b','c','p'];tuple('E5','Fast',['p','r'],['p','r'],[],[],[],6);tuple('E5','B',['p','r'],['p','r'],[],[],[],5);
  const four={...retry,p:main(50),r:main(60)};snap=fullSnapshot('E5',['a','b','p','r'],four,['b','p'],['a'],201);check(lane,'E5.q-missing',snap.lookups.q.result,'MissingEntity');tick('E5-empty-D',D());fullSnapshot('E5-after-empty-D',['a','b','p','r'],four,['b','p'],['a'],201);
  const Cleanup=G.System('Cleanup',{queries:{write:Write},events:{out:G.System.writeEvent(Ping)}},({queries,commands,events})=>{const p=queries.write.get(ids.alpha.get('p'));assert.equal(p.ok,true);p.value.data.main.set(first(p.value.data.main.get(),51));commands.remove(ids.alpha.get('a'),Main);commands.despawn(ids.alpha.get('b'));events.out.emit({code:3});});
  tick('E6-off',SetOff,T());tick('E6a',Cleanup);fullSnapshot('E6a',['a','b','p','r'],{...four,p:first(main(50),51)},['b','p'],['a'],201);
  tick('E6b',D(),Fast);alive.delete('b');flagLive=['c','p'];tuple('E6b','Fast',[],['p'],['a','b'],['b'],[3],7);tick('E6-empty1');tick('E6-empty2');tick('E6-empty3');tick('E6-skip',B);check(lane,'E6.skip-count',locals.B.get(),[5,0,0,0]);fullSnapshot('E6b',['p','r'],{p:first(main(50),51),r:main(60)},['p'],[],201);
  mode='observe-fail';const failedReader=tick('E7-fail',SetOn,T(),G.Schedule(B,Inner),Outer);check(lane,'E7.failure',failedReader,{ok:false,error:{kind:'SystemFailure',system:'B',error:{code:7}}});tuple('E7-fail','B',[],['p'],['a','b'],['b'],[],6);check(lane,'E7.failed-tails',tails,{inner:1,outer:1});
  mode='observe';tick('E7-retry',G.Schedule(B,Inner),Outer,Fast);tuple('E7-retry','B',[],['p'],['a','b'],['b'],[],7);tuple('E7-retry','Fast',[],[],[],[],[],8);check(lane,'E7.retry-tails',tails,{inner:2,outer:2});
  const Inserts=G.System('Inserts',{},({commands})=>{for(const [label,value]of [['p',71],['a',80],['c',30],['a',81],['b',90]])commands.insert(ids.alpha.get(label),[Main,main(value)]);});
  tick('E8-pending',Inserts);fullSnapshot('E8-before-D',['p','r'],{p:first(main(50),51),r:main(60)},['p'],[],201);tick('E8',D(),Fast,B);tuple('E8','Fast',['a','c'],['a','c','p'],[],[],[],9);tuple('E8','B',['a','c'],['a','c','p'],[],[],[],8);
  const eight={a:main(81),c:main(30),p:main(71),r:main(60)};snap=fullSnapshot('E8',['a','c','p','r'],eight,['c','p'],['a','c'],201);check(lane,'E8.b-missing',snap.lookups.b.result,'MissingEntity');check(lane,'E8.c-found',snap.lookups.c.result,'Found');
  const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(ids.alpha.get('c'),Main);for(const name of ['a','p','r','c'])commands.despawn(ids.alpha.get(name));});
  tick('E9-pending',Dispose);fullSnapshot('E9-before-D',['a','c','p','r'],eight,['c','p'],['a','c'],201);tick('E9',D(),Fast,B);alive.clear();auxLive=[];flagLive=[];tuple('E9','Fast',[],[],['c','a','p','r'],['a','p','r','c'],[],10);tuple('E9','B',[],[],['c','a','p','r'],['a','p','r','c'],[],9);fullSnapshot('E9-empty',[],{},[],[],201);
  tick('E9-empty-D',D());const SpawnS=G.System('SpawnS',{},({commands})=>{reserve('alpha',commands,'s',70);});tick('E9-spawn-s',SpawnS);fullSnapshot('E9-s-pending',[],{},[],[],201);tick('E9-s-live',D());alive.add('s');snap=fullSnapshot('E9-s',['s'],{s:main(70)},[],[],201);for(const name of ['a','b','c','p','q','r'])check(lane,'E9.stale.'+name,snap.lookups[name].result,'MissingEntity');
  check(lane,'raw-ID-consumption',ids.alpha.get('r').value,ids.alpha.get('q').value+1);check(lane,'all-alpha-reservations-unique',new Set(reservations.filter(x=>x.world==='alpha').map(x=>x.rawId)).size,reservations.filter(x=>x.world==='alpha').length);check(lane,'actual-first-world-ID-collision',ids.alpha.get('a').value,ids.beta.get('z').value);check(lane,'fresh-s-ID',ids.alpha.get('s').value>ids.alpha.get('r').value,true);
  check(lane,'complete-own-write-observations',ownWrites,[
    {step:'E2',who:'A',main:first(main(10),11),ledger:ledger(101),reserved:'MissingEntity'},
    {step:'E2',who:'B:first',main:first(main(20),30)},
    {step:'E2',who:'B:second',main:first(main(20),50),ledger:ledger(201),reserved:'MissingEntity'},
    {step:'E4-retry',who:'B:first',main:first(main(20),30)},
    {step:'E4-retry',who:'B:second',main:first(main(20),50),ledger:ledger(201),reserved:'MissingEntity'}]);
  check(lane,'final-complete-capture-owners',Object.fromEntries(Object.entries(locals).map(([name,owner])=>[name,owner.get()])),{A:[1,0,0,0],B:[9,0,0,0],Fast:[10,0,0,0]});
  check(lane,'Audit effects',effects,['A:attempt:1','B:attempt:2','B:attempt:3']);
  const provisioning=[];
  for(const [resource,service,kind,name]of [[false,true,'resource',Ledger.name],[true,false,'service','Audit']]){
    const preflightEffects=[],fresh=makeRuntime(resource,service,preflightEffects),beforeCalls=invocations.length,beforeTails={...tails},beforeAudit=[...effects];
    const result=fresh.tryTick(G.Schedule(A,Fast,G.Schedule(B,Inner),Outer));
    const preflightCalls=invocations.slice(beforeCalls);
    check(lane,'E10.missing-'+kind,result,{ok:false,error:{kind:'MissingRuntimeRequirements',requirements:[{kind,name}]}});check(lane,'E10.missing-'+kind+'.invocations',preflightCalls,[]);check(lane,'E10.missing-'+kind+'.effects',preflightEffects,[]);
    check(lane,'E10.missing-'+kind+'.tails',tails,beforeTails);check(lane,'E10.missing-'+kind+'.earlier-audit',effects,beforeAudit);
    provisioning.push({missing:kind,result:clone(result),invocations:preflightCalls,effects:preflightEffects,actualE2BaseInstances:true});
  }
  check(lane,'public-reader-diagnostic-count',readerDiagnostics.length,reads.length);
  check(lane,'every-reader-invocation-associated',reads.every(read=>read.traceDiagnostic!==undefined),true);
  stopReaderDiagnostics();
  return {lane,schema,style,rawReservations:reservations,reads,readerDiagnostics,ownWrites,snapshots,dispatches,auditEffects:effects,foreignLookupDivergence:foreign,provisioning,
    finalCounts:Object.fromEntries(Object.entries(locals).map(([name,owner])=>[name,owner.get()])),tails,
    scope:{TS:'public reference execution',BendOwnershipAndNegativeControls:'not executed; future integrated Bend gate',foreignCommandResult:'open; not invented',relocation:'no public TS relocation; future adapter lane'}};
}
const requested=process.argv.includes('--schema')?process.argv[process.argv.indexOf('--schema')+1]:null;
assert.ok(requested===null||requested==='Motion'||requested==='Health');
let defect=null;
try{for(const schema of requested?[requested]:['Motion','Health'])for(const style of ['returned-owner','regenerated-closure'])results.push(execute(schema,style));}catch(error){defect={name:error.name,message:error.message,stack:error.stack};}
const sourceFiles=['index.ts','Descriptor.ts','Schema.ts','Entity.ts','Command.ts','Query.ts','System.ts','Runtime.ts','Schedule.ts','Fx.ts','internal/world.ts','internal/streams.ts','Debug.ts'];
const sha=path=>createHash('sha256').update(readFileSync(path)).digest('hex');
console.log(JSON.stringify({status:defect||differences.length?'FAIL: exact expected trace differs or execution defective':'PASS: fresh E0-E10 public TS main traces',
  node:process.version,reference:{commit,path:REFERENCE,hashes:Object.fromEntries(sourceFiles.map(name=>[name,sha(REFERENCE+'/packages/core/src/'+name)]))},
  adapterSha256:sha(fileURLToPath(import.meta.url)),traceSha256:sha(new URL('../../docs/design/s-integrate-trace.md',import.meta.url)),limits:{runtimeSeconds:5,command:['timeout','5s','node','experiments/s-integrate-trace/reference-main.mjs']},
  results,differences,defect,unexecuted:['E11 separately assigned','Native/JS Bend runtime','compile-negative/ownership checks','index relocation','foreign structural command policy']}));
if(defect||differences.length)process.exitCode=1;
