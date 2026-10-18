from pathlib import Path
D=Path('/tmp/bendvy-current-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1');p=D/'subject/tx-metrics.bend';s=p.read_text();s=s.replace('Sample{kind:String,report:Meter.Report}','Sample{kind:String,report:Meter.Report,iteration:Maybe<&2,Nat>,completion:Maybe<&2,Bool>}');s=s.replace('Sample{kind,Meter.report(meter,nu,nc,List.length(&2,E,events))}', 'Sample{kind,Meter.report(meter,nu,nc,List.length(&2,E,events)),None{},None{}}');at=s.index('def render(sample:');s=s[:at]+'''def at_iteration(sample:Sample,iteration:Nat) -> Sample:
  match sample:
    case Sample{kind,report,_,completion}:Sample{kind,report,Some{iteration},completion}
    case sample:sample
def finished(sample:Sample,success:Bool) -> Sample:
  match sample:
    case Sample{kind,report,iteration,_}:Sample{kind,report,iteration,Some{success}}
    case sample:sample
def ordinal(value:Maybe<&2,Nat>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:Nat.show(value)
def completion(value:Maybe<&2,Bool>) -> String:
  match value:
    case None{}:"null"
    case Some{True{}}:"\\\"committed\\\""
    case Some{False{}}:"\\\"discarded\\\""
'''+s[at:];s=s.replace('case Sample{kind,report}:Meter.render(kind,report)','case Sample{kind,report,iteration,done}:"{\\\"iteration\\\":" ++ ordinal(iteration) ++ ",\\\"completion\\\":" ++ completion(done) ++ ",\\\"tx\\\":" ++ Meter.render(kind,report) ++ "}"');s=s.replace('def report(samples:List<&2,Sample>) -> String:', 'def report(count:U32,iterations:U32,samples:List<&2,Sample>) -> String:');s=s.replace('"{\\\"reports\\\":"', '"{\\\"schema\\\":\\\"Motion\\\",\\\"workloadCount\\\":" ++ U32.show(count) ++ ",\\\"iterations\\\":" ++ U32.show(iterations) ++ ",\\\"frame\\\":null,\\\"reports\\\":"');p.write_text(s)
p=D/'subject/motion.bend';s=p.read_text().replace('ProfileOutput{values,sample}', 'ProfileOutput{values,Metrics.finished(sample,True{})}').replace('ProfileFailure{error,sample}', 'ProfileFailure{error,Metrics.finished(sample,False{})}');# seeded's actual outcome preserved and copied only Data
s=s.replace('case Tx.Returned{world,outcome}:Seeded{world,reservations,outcome,sample}', 'case Tx.Returned{world,+outcome}:Seeded{world,reservations,outcome,Metrics.finished(sample,Tx.committed(~Unit,outcome))}');p.write_text(s)
p=D/'subject/motion-driver.bend';s=p.read_text().replace('Shared{audit,statuses,samples},Sys.Completed', 'Shared{audit,+statuses,samples},Sys.Completed').replace('Metrics.Sample,samples,[sample]', 'Metrics.Sample,samples,[Metrics.at_iteration(sample,List.length(&2,Status,statuses))]');p.write_text(s)
p=D/'subject/motion-main.bend';s=p.read_text().replace('def write(metricsPath:String,value:', 'def write(count:U32,iterations:U32,metricsPath:String,value:').replace('Metrics.report(samples)','Metrics.report(count,iterations,samples)').replace('write(metricsPath,created(count,iterations,result))','write(count,iterations,metricsPath,created(count,iterations,result))');p.write_text(s)
