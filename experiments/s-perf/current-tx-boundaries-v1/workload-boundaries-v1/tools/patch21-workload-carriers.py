from pathlib import Path
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1'
p=F/'motion-local.bend';s=p.read_text();s='import ../../../../../meter.bend as Meter\n'+s
# root private/.../failedtxn path to OUT meter: five? private/experiments/s-perf/canonical-api-v1/failedtxn -> ../../../../../ reaches OUT.
s=s.replace('Returned{meta:Meta(),tick:Nat,call:Call}','Returned{meta:Meta(),tick:Nat,call:Call,reports:List<&2,Meter.Report>}')
s=s.replace('case Tx.Returned{world,+outcome}:','case Tx.Returned{world,+outcome,report}:').replace('ACall{outcome,output,facts}}}','ACall{outcome,output,facts},[report]}}')
s=s.replace('reader:Reader.Provider(),status:U32','reader:Reader.Provider(),reports:List<&2,Meter.Report>,status:U32')
s=s.replace('Returned{meta,tick,BCall{status,error,output}}','Returned{meta,tick,BCall{status,error,output},reports}')
s=s.replace('b_context(Array.set(U32,capture,0,U32.add(count,1)),reader,status,','b_context(Array.set(U32,capture,0,U32.add(count,1)),reader,reports,status,')
s=s.replace('O.RunCompleted{context,provider,output}:b_bumped(provider,0,','O.RunCompleted{context,provider,output,report}:b_bumped(provider,[report],0,').replace('O.RunFailed{context,provider,error,output}:b_bumped(provider,1,','O.RunFailed{context,provider,error,output,report}:b_bumped(provider,[report],1,')
for n in [2,3,4]:s=s.replace(f'b_context(capture,provider,{n},',f'b_context(capture,provider,[],{n},')
s=s.replace('Tx.begin(~F.World(),~E.event_type(),world)','Cmd.tx_begin(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)');p.write_text(s)
p=F/'motion-dispose.bend';s='import ../../../../../meter.bend as Meter\n'+p.read_text();s=s.replace('Output{statuses:List<&2,W.Status>,facts:Inspect.Facts,outcome:Tx.Outcome<Unit>}','Output{statuses:List<&2,W.Status>,facts:Inspect.Facts,outcome:Tx.Outcome<Unit>,report:Meter.Report}').replace('case Tx.Returned{world,outcome}:Sys.Succeeded{world,Output{statuses,facts,outcome}}','case Tx.Returned{world,outcome,report}:Sys.Succeeded{world,Output{statuses,facts,outcome,report}}').replace('Tx.begin(~F.World(),~E.event_type(),world)','Cmd.tx_begin(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)');p.write_text(s)
