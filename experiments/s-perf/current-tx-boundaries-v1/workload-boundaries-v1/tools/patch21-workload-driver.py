from pathlib import Path
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';p=F/'motion-driver.bend';s=p.read_text();a=s.index('def measured_created');s='import ../../../../../meter.bend as Meter\n'+s[:a]+'''def output(label:String,result:Doc.Doc & List<&2,Meter.Sample>) -> IO(List<&2,Meter.Sample>):
  match result:
    case (wire,metrics):IO.bind(Unit,List<&2,Meter.Sample>,Stream.write(Doc.wrap(label ++ "={",wire,"}\\n")),_=>IO.pure(List<&2,Meter.Sample>,metrics))
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
def metrics(path:String,count:U32,iterations:U32,warm:List<&2,Meter.Sample>,measured:List<&2,Meter.Sample>) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),metrics_opened("{\\\"scope\\\":\\\"ordinary-workload-tx-boundaries\\\",\\\"workload\\\":\\\"FailedTxn\\\",\\\"schema\\\":\\\"Motion\\\",\\\"workloadCount\\\":" ++ U32.show(count) ++ ",\\\"iterations\\\":" ++ U32.show(iterations) ++ ",\\\"worlds\\\":[{\\\"run\\\":\\\"warmup\\\",\\\"reports\\\":" ++ Meter.samples_render(warm) ++ "},{\\\"run\\\":\\\"measured\\\",\\\"reports\\\":" ++ Meter.samples_render(measured) ++ "}]}\\n"))
def run(+count:U32,+iterations:U32,path:String) -> IO(Unit):
  do IO<Unit>:
    first:Creation() <- make()
    warm:List<&2,Meter.Sample> <- created("warmup",count,iterations,first)
    second:Creation() <- make()
    measured:List<&2,Meter.Sample> <- created("measured",count,iterations,second)
    metrics(path,count,iterations,warm,measured)
''';p.write_text(s)
p=F/'motion-main.bend';s=p.read_text().replace('def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>)','def parsed(path:String,count:Maybe<&2,U32>,iterations:Maybe<&2,U32>)').replace('Driver.run(count,iterations)','Driver.run(count,iterations,path)').replace('_ <> count <> iterations <> _:parsed(U32.read(count),U32.read(iterations))','_ <> count <> iterations <> path <> _:parsed(path,U32.read(count),U32.read(iterations))').replace('"count iterations required"','"count iterations uniqueMetricsPath required"');p.write_text(s)
