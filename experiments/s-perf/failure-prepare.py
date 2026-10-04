#!/usr/bin/env python3
"""Reproducible copied baseline overlay; shared subjects are immutable."""
import pathlib,json,hashlib,re
R=pathlib.Path(__file__).resolve().parents[2];H=R/'experiments/s-perf';D=H/'failure-overlay';freeze=json.loads((H/'failure-freeze.json').read_text())
for label,path in [('binary','/home/node/.bend/bin/bend'),('base','/home/node/.bend/bend2/base.bend')]:
 assert hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()==freeze['compiler'][label],('frozen compiler input changed',label)
for name,digest in freeze['subjects'].items():
 p=R/name;assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,name
 q=D/name;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
B=D/'experiments/s-integrate'
p=B/'host-observations.bend';s=p.read_text();anchor='  OwnWrites{step:String,system:String,views:List<&2,OwnView>}'
s=s.replace(anchor,anchor+'\n  FailureObserved{schema:String,iteration:U32,phase:String,rows:List<&2,O.QueryRow<Schema,V,AV,F>>,ledger:Maybe<&2,LV>,lookups:List<&2,Lookup<Schema,V,AV,F>>}\n  FailureRead{iteration:U32,system:String,count:U32,messages:List<&2,P>,lag:Bool,tick:U32,frame:U32}\n  FailureResult{label:String,outcome:D.DispatchOutcome}')
p.write_text(s)
p=B/'measurement-failure-observe.bend';s=p.read_text()
for lane,sc,v,av,fl in [('motion','Motion','PositionView','VelocityView','Selected'),('health','Health','VitalsView','ArmorView','Tracked')]:
 lookup=f'E.Lookup<T.{sc}Schema,T.{v},T.{av},T.{fl}>'
 # Retain actual lookup result instead of encoding it.
 start=s.index('def '+lane+'_lookup_done');end=s.index('def '+lane+'_append_handle',start)
 block=s[start:end].replace('List<&2,String>',f'List<&2,{lookup}>')
 line=next(x for x in block.splitlines() if 'case (world,result):' in x)
 block=block.replace(line,f'    case (world,result): next(world,List.append(&2,{lookup},seen,[E.Lookup{{"",handle,result}}]))')
 s=s[:start]+block+s[end:]
 start=s.index('def '+lane+'_resource_done');end=s.index('def '+lane+'_observe(',start)
 block=s[start:end].replace('List<&2,String>',f'List<&2,{lookup}>')
 line=next(x for x in block.splitlines() if 'IO.bind(Unit' in x)
 event=f'E.TraceEvent<T.{sc}Schema,T.{v},T.{av},T.{fl},T.LedgerView,T.{sc}Mode,T.{sc}Ping>'
 block=block.replace(line,f'      IO.pure(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>,D.Invoked{{F.{sc}Failure{{H.Host{{world,logs,bindings,name,step,prior,List.append(&2,{event},events,[E.FailureObserved{{"{sc}",iteration,step,rows,ledger,lookups}}])}},iteration,failed}},audit,run,T.Success{{}},clock,None{{}},[]}})')
 s=s[:start]+block+s[end:]
p.write_text(s)
p=B/'measurement-failure-host.bend';s=p.read_text()
for lane,sc,v,av,fl in [('motion','Motion','PositionView','VelocityView','Selected'),('health','Health','VitalsView','ArmorView','Tracked')]:
 start=s.index('def '+lane+'_read_done');end=s.index('def '+lane+'_active',start);block=s[start:end]
 line=next(x for x in block.splitlines() if 'IO.print("FAILURE-READ:' in x)
 event=f'E.TraceEvent<T.{sc}Schema,T.{v},T.{av},T.{fl},T.LedgerView,T.{sc}Mode,T.{sc}Ping>'
 block=block.replace(line,f'      {lane}_read_body(Bool.or(is_fast(kind),Bool.and(is_b(kind),Bool.not(U.writes(mode)))),i,kind,mode,name,count,clock,H.Host{{world,RH.Logs{{ping,removed,despawned}},bindings,worldName,step,prior,List.append(&2,{event},events,[E.FailureRead{{i,name,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)}}])}},audit,run)')
 s=s[:start]+block+s[end:]
p.write_text(s)
p=B/'host-render.bend';s=p.read_text();start=s.index('def render_event(');pos=s.index('    case H.Provisioning',start)
extra='''    case H.FailureObserved{schema,iteration,phase,rows,ledger,lookups}: render_concat(["{\\"kind\\":\\"FailureObserved\\",\\"schema\\":",render_string(schema),",\\"iteration\\":",U32.show(iteration),",\\"phase\\":",render_string(phase),",\\"rows\\":",render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),rows),",\\"ledger\\":",render_optional(~LV,~lv,ledger),",\\"lookups\\":",render_list(~H.Lookup<Schema,V,AV,F>,~render_lookup(~Schema,~V,~AV,~F,~v,~av,~f),lookups),"}"])
    case H.FailureRead{iteration,system,count,messages,lag,tick,frame}: render_concat(["{\\"kind\\":\\"FailureRead\\",\\"iteration\\":",U32.show(iteration),",\\"system\\":",render_string(system),",\\"count\\":",U32.show(count),",\\"messages\\":",render_list(~P,~ping,messages),",\\"lag\\":",render_boolean(lag),",\\"tick\\":",U32.show(tick),",\\"frame\\":",U32.show(frame),"}"])
    case H.FailureResult{label,outcome}: render_concat(["{\\"kind\\":\\"FailureResult\\",\\"label\\":",render_string(label),",\\"outcome\\":",render_dispatch_outcome(outcome),"}"])
'''
s=s[:pos]+extra+s[pos:];p.write_text(s)
p=B/'measurement-failure-driver.bend';s=p.read_text()
for lane,sc,v,av,fl in [('motion','Motion','PositionView','VelocityView','Selected'),('health','Health','VitalsView','ArmorView','Tracked')]:
 start=s.index('def '+lane+'_accept');s=s[:start]+f'''def {lane}_result(label:String,outcome:D.DispatchOutcome,owner:F.{sc}Failure) -> F.{sc}Failure:
  match owner:
    case F.{sc}Failure{{H.Host{{world,logs,bindings,name,step,prior,events}},i,failed}}: F.{sc}Failure{{H.Host{{world,logs,bindings,name,step,prior,List.append(&2,E.TraceEvent<T.{sc}Schema,T.{v},T.{av},T.{fl},T.LedgerView,T.{sc}Mode,T.{sc}Ping>,events,[E.FailureResult{{label,outcome}}])}},i,failed}}
'''+s[start:]
 start=s.index('def '+lane+'_accept');end=s.index('def '+lane+'_checked',start);block=s[start:end]
 line=next(x for x in block.splitlines() if 'IO.print("FAILURE-RESULT:' in x)
 block=block.replace(line,f'    case True{{}}: IO.pure(D.Runtime<F.{sc}Failure,S.Handle<T.{sc}Schema>>,L.runtime_map(F.{sc}Failure,S.Handle<T.{sc}Schema>,owner => {lane}_result(label,outcome,owner),runtime))');s=s[:start]+block+s[end:]
 start=s.index('def '+lane+'_final');end=s.index('def '+lane+'_ready',start)
 event=f'E.TraceEvent<T.{sc}Schema,T.{v},T.{av},T.{fl},T.LedgerView,T.{sc}Mode,T.{sc}Ping>'
 block=f'''def {lane}_events(events:List<&2,{event}>) -> IO(Unit):
  match events:
    case Nil{{}}: IO.pure(Unit,Unit{{}})
    case Con{{head,tail}}:
      do IO<Unit>:
        IO.write("FAILURE-DEFERRED:")
        J.write_{lane}(head)
        {lane}_events(tail)
def {lane}_final(runtime:D.Runtime<F.{sc}Failure,S.Handle<T.{sc}Schema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{{F.{sc}Failure{{H.Host{{_,_,_,_,_,_,events}},_,_}},registry,_,+clock,_,_,_,_,_}}:
      do IO<Unit>:
        {lane}_events(events)
        {lane}_counts(clock,H.count_registry(registry))
'''
 s=s[:start]+block+s[end:]
 # Time only actual iteration loops; rendering final records follows end time.
 old=f'        final : D.Runtime<F.{sc}Failure,S.Handle<T.{sc}Schema>> <- {lane}_loops(fuel,systems,prime)\n        {lane}_final(final)'
 new=f'        start : Nat <- IO.now()\n        final : D.Runtime<F.{sc}Failure,S.Handle<T.{sc}Schema>> <- {lane}_loops(fuel,systems,prime)\n        end : Nat <- IO.now()\n        IO.print("FAILURE-TIMING:" ++ Nat.show(Nat.sub(end,start)))\n        {lane}_final(final)'
 assert old in s;s=s.replace(old,new)
p.write_text(s)
# Force independent full-field and reader validation inside the interval.
for lane,sc,v,av,fl in [('motion','Motion','PositionView','VelocityView','Selected'),('health','Health','VitalsView','ArmorView','Tracked')]:
 p=B/'measurement-failure-observe.bend';t=p.read_text()
 if ' as FV' not in t:t=t.replace('import Base','import Base\nimport ../../../failure-checks.bend as FV',1)
 at=t.index('def '+lane+'_resource_done')
 t=t[:at]+f'\ndef {lane}_guard(valid:Bool,owner:D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>) -> IO(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>):\n  match valid:\n    case True{{}}: IO.pure(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>,owner)\n    case False{{}}: IO.die(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>,22,"quiet observation full-field guard")\n'+t[at:]
 a=t.index('def '+lane+'_resource_done');b=t.index('def '+lane+'_resource(',a);block=t[a:b]
 block=block.replace('(rows:','(+rows:').replace(',lookups:',',+lookups:').replace(',ledger:',',+ledger:').replace('{logs,bindings,name,','{logs,+bindings,name,')
 block=block.replace(f'IO.pure(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>,D.Invoked',f'{lane}_guard(FV.{lane}(FV.seed_count(T.{sc}Schema,bindings),iteration,step,rows,lookups,ledger),D.Invoked')
 t=t[:a]+block+t[b:];p.write_text(t)
 p=B/'measurement-failure-host.bend';t=p.read_text()
 if ' as FV' not in t:t=t.replace('import Base','import Base\nimport ../../../failure-checks.bend as FV',1)
 at=t.index('def '+lane+'_read_done')
 t=t[:at]+f'\ndef {lane}_read_guard(valid:Bool,next:Unit -> IO(D.Invoked<H.{sc}Host(),S.Handle<T.{sc}Schema>>)) -> IO(D.Invoked<H.{sc}Host(),S.Handle<T.{sc}Schema>>):\n  match valid:\n    case True{{}}: next(Unit{{}})\n    case False{{}}: IO.die(D.Invoked<H.{sc}Host(),S.Handle<T.{sc}Schema>>,23,"quiet reader full-field guard")\n'+t[at:]
 a=t.index('def '+lane+'_read_done');b=t.index('def '+lane+'_active',a);block=t[a:b];block=block.replace(',step:String',',+step:String')
 line=next(x for x in block.splitlines() if x.strip().startswith(lane+'_read_body('));new=f'      {lane}_read_guard(FV.read(~T.{sc}Ping,~FV.{lane}_code,i,name,step,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)),unit => '+line.strip()+')';block=block.replace(line,new)
 t=t[:a]+block+t[b:];p.write_text(t)
# Inspect actual returned service values while preserving the actual affine world/Audit.
p=B/'measurement-failure-host.bend';t=p.read_text().replace('import Base','import Base\nimport ../../../failure-service-guard.bend as FG',1)
for lane,sc,v,av,flag,main,aux in [('motion','Motion','PositionView','VelocityView','Selected','Position','Velocity'),('health','Health','VitalsView','ArmorView','Tracked','Vitals','Armor')]:
 a=t.index('def '+lane+'_transaction');b=t.index('def '+lane+'_body',a);block=t[a:b].replace('(i:','(+i:').replace('{world,logs,bindings,','{world,logs,+bindings,')
 line=next(x for x in block.splitlines() if 'result => H.'+lane+'_service' in x)
 world=f'S.World<T.{sc}Schema,T.{main},T.{aux},T.{flag},T.{sc}Ledger,T.{sc}Mode>'
 typ=f'AI.ServiceResult<{world},S.Handle<T.{sc}Schema>,T.{v},T.{av},T.{flag}>'
 inv=f'D.Invoked<H.{sc}Host(),S.Handle<T.{sc}Schema>>'
 check='position' if lane=='motion' else 'vitals'
 prefix=f',result => IO.bind({typ},{inv},FG.guard(~{world},~T.{sc}Schema,~T.{v},~T.{av},~T.{flag},~FV.{check},FV.seed_count(T.{sc}Schema,bindings),i,is_b(kind),'+('True{}' if lane=='motion' else 'False{}')+',result),checked => H.'+lane+'_service'
 new=line.replace(',result => H.'+lane+'_service',prefix)
 assert new.endswith(',result))');new=new[:-len(',result))')]+',checked)))';block=block.replace(line,new);t=t[:a]+block+t[b:]
p.write_text(t)
# Explicit experimental Audit instance records the actual callback effects like TS.
p=B/'dispatcher.bend';t=p.read_text().replace('  Console{}','  Console{}\n  Recorded{effects:List<&2,String>}',1)
a=t.index('def audit_log');b=t.index('def audit_present',a)
t=t[:a]+"""def recorded_audit(valid:Bool,effects:List<&2,String>,text:String) -> IO(Audit):
  match valid:
    case True{}: IO.pure(Audit,Recorded{text <> effects})
    case False{}: IO.die(Audit,25,"quiet frozen Audit payload length guard")
def audit_log(owner: Audit,+text: String) -> IO(Audit):
  match owner:
    case Console{}:
      do IO<Audit>:
        IO.print(text)
        return Console{}
    case Recorded{effects}: recorded_audit(Nat.is_le(String.length(text),100n),effects,text)
"""+t[b:];p.write_text(t)
p=B/'measurement-failure-fixture.bend';t=p.read_text().replace('Some{D.Console{}}','Some{D.Recorded{[]}}');assert 'D.Recorded' in t;p.write_text(t)
p=B/'measurement-failure-driver.bend';t=p.read_text();at=t.index('def motion_events(')
t=t[:at]+"""def audit_lines(values:List<&2,String>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(head)
        audit_lines(tail)
def audit_records(value:Maybe<D.Audit>) -> IO(Unit):
  match value:
    case Some{D.Recorded{effects}}: audit_lines(List.reverse(&2,String,effects))
    case _: IO.die(Unit,26,"quiet actual Audit recording owner required")
"""+t[at:]
for lane in ['motion','health']:
 a=t.index('def '+lane+'_final(');b=t.index('def '+lane+'_ready(',a);block=t[a:b].replace('registry,_,+clock,_,_,_,_,_','registry,_,+clock,audit,_,_,_,_').replace('        '+lane+'_events(events)','        audit_records(audit)\n        '+lane+'_events(events)');t=t[:a]+block+t[b:]
p.write_text(t)
# Extract byte-identical helper definitions; avoid checking unrelated workload bodies.
extractions={}
def selected(original,names,imports):
 text=(R/original).read_text();chunks={m.group(1):m.group(0) for m in re.finditer(r'^def (\w+)\([^\n]*(?:\n(?!def |type |import |#)[^\n]*)*',text,re.M)}
 # Definition slices end at the next top-level declaration, preserving actual body text.
 starts=list(re.finditer(r'^def (\w+)\(',text,re.M));chunks={}
 for i,m in enumerate(starts):
  end=starts[i+1].start() if i+1<len(starts) else len(text)
  body=text[m.start():end];body=re.split(r'\n(?:type |#)',body)[0].rstrip()+'\n';chunks[m.group(1)]=body
 values=[chunks[n] for n in names];extractions[original]={n:hashlib.sha256(chunks[n].encode()).hexdigest() for n in names}
 return imports+'\n'.join(values)
(B/'measurement-bend.bend').write_text(selected('experiments/s-integrate/measurement-bend.bend',['quad','motion_main','motion_aux','motion_flag','motion_bundle','motion_ledger','health_main','health_aux','health_flag','health_bundle','health_ledger'],'import Base\nimport ./types.bend as T\nimport ./storage.bend as S\n\n'))
(B/'measurement-lifecycle.bend').write_text(selected('experiments/s-integrate/measurement-lifecycle.bend',['runtime_map'],'import Base\nimport ./dispatcher.bend as D\n\n'))
report={'baseline':'a976667','extracted_original_definition_sha256':extractions,'copies':{name:hashlib.sha256((D/name).read_bytes()).hexdigest() for name in freeze['subjects']},'changed':[name for name,old in freeze['subjects'].items() if hashlib.sha256((D/name).read_bytes()).hexdigest()!=old]}
(H/'failure-overlay-manifest.json').write_text(json.dumps(report,indent=2)+'\n');print('Copied exact closure; changed only:',report['changed'])
