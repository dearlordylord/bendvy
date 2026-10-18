from pathlib import Path
import re,os
D=Path('/tmp/bendvy-workload-health-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/health-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';A=Path('/workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');meter='import '+os.path.relpath(A/'meter.bend',F)+' as Meter\n';p=F/'health-scenario.bend';s=meter+p.read_text();names=['primed','registered','named','dispose_registered','setup','targets','seed_applied','seed_pending','seeded','created','program'];lines=s.splitlines()
for i,line in enumerate(lines):
 if any(line.startswith('def '+n+'(') for n in names):lines[i]=line.replace('-> List<&2,String>:','-> List<&2,String> & List<&2,Meter.Sample>:')
s='\n'.join(lines)+'\n';s=s.replace('Stream.final(prefix','Stream.final_profile(prefix')
ns={};tool=(D/'tools/prepare-private.py').read_text();exec(tool[tool.index('def split(s):'):tool.index('# Functions accepting')],ns);end=ns['end'];targets=['named','dispose_registered','setup','targets','seed_applied','seed_pending'];edits=[]
for m in re.finditer(r'(?<![\w.])('+'|'.join(targets)+r')\(',s):
 a=m.end()-1;defining=bool(re.search(r'def\s+$',s[max(0,m.start()-5):m.start()]));edits.append((a+1,a+1,'seed:Meter.Sample,' if defining else 'seed,'))
for a,e,r in reversed(edits):s=s[:a]+r+s[e:]
s=s.replace('S.Frame{first,second,0,0,None{},None{},[],[],[]}','S.Frame{first,second,0,0,None{},None{},[],[],[seed]}')
s=s.replace('case F.Seeded{world,+reservations,outcome}:seed_pending(seed,','case F.Seeded{world,+reservations,+outcome,report}:seed_pending(Meter.Sample{"seed",None{},None{},0n,Tx.committed(~Unit,outcome),report},')
lines=s.splitlines()
for i,line in enumerate(lines):
 if re.match(r'\s+case .*:\[prefix',line):
  left,right=line.split(':[prefix',1);lines[i]=left+':([prefix'+right+',[])'
s='\n'.join(lines)+'\n';p.write_text(s)
# Preserve the original String chunk list writer; only pair detached metrics with original chunks.
p=F/'health-driver.bend';s=meter+p.read_text();a=s.index('def measured_created');s=s[:a]+'''def output(label:String,result:List<&2,String> & List<&2,Meter.Sample>) -> IO(List<&2,Meter.Sample>):
  match result:
    case (wire,metrics):IO.bind(Unit,List<&2,Meter.Sample>,Stream.write(Stream.append([label ++ "={"],Stream.append(wire,["}\\n"]))),_=>IO.pure(List<&2,Meter.Sample>,metrics))
def created(label:String,count:U32,iterations:U32,result:Creation()) -> IO(List<&2,Meter.Sample>):
  match result:
    case WI.Created{world}:output(label,Scenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.bind(Unit,List<&2,Meter.Sample>,refused(label,resource),_=>IO.pure(List<&2,Meter.Sample>,[]))
def metrics_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(_,text)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,3,text))
def metrics_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),metrics_written)
    case Fail{(_,error)}:IO.die(Unit,3,error)
def metrics(path:String,count:U32,iterations:U32,warm:List<&2,Meter.Sample>,measured:List<&2,Meter.Sample>) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),metrics_opened("{\\\"scope\\\":\\\"ordinary-workload-tx-boundaries\\\",\\\"workload\\\":\\\"FailedTxn\\\",\\\"schema\\\":\\\"Health\\\",\\\"workloadCount\\\":" ++ U32.show(count) ++ ",\\\"iterations\\\":" ++ U32.show(iterations) ++ ",\\\"worlds\\\":[{\\\"run\\\":\\\"warmup\\\",\\\"reports\\\":" ++ Meter.samples_render(warm) ++ "},{\\\"run\\\":\\\"measured\\\",\\\"reports\\\":" ++ Meter.samples_render(measured) ++ "}]}\\n"))
def run(+count:U32,+iterations:U32,path:String) -> IO(Unit):
  do IO<Unit>:
    first:Creation() <- make()
    warm:List<&2,Meter.Sample> <- created("warmup",count,iterations,first)
    second:Creation() <- make()
    measured:List<&2,Meter.Sample> <- created("measured",count,iterations,second)
    metrics(path,count,iterations,warm,measured)
''';p.write_text(s)
p=F/'health-main.bend';s=p.read_text().replace('def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>)','def parsed(path:String,count:Maybe<&2,U32>,iterations:Maybe<&2,U32>)').replace('Driver.run(count,iterations)','Driver.run(count,iterations,path)').replace('_ <> count <> iterations <> _:parsed(U32.read(count),U32.read(iterations))','_ <> count <> iterations <> path <> _:parsed(path,U32.read(count),U32.read(iterations))').replace('"count iterations required"','"count iterations uniqueMetricsPath required"');p.write_text(s)
