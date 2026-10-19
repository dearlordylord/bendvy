import Base
import tx-metrics.bend as Metrics
import metadata.bend as Metadata
import private/occupancy.bend as O
import private/src/ecs/system.bend as Sys
import private/test-fixtures/connected-performance/dense-health64/consumer/health-driver.bend as Driver

def measurement(value:Sys.Measurement) -> String:
  match value:
    case Sys.Measurement{sample,metadata}:"{\"sample\":" ++ Metrics.render(sample) ++ ",\"prefinish\":" ++ metadata ++ "}"
def tail(values:List<&2,Sys.Measurement>) -> String:
  match values:
    case []:"]"
    case value <> rest:"," ++ measurement(value) ++ tail(rest)
def records(values:List<&2,Sys.Measurement>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ measurement(value) ++ tail(rest)
type Text is Data:
  Text{prefix:String,history:Metadata.WorldHistory}
def joined(label:String,count:U32,iterations:U32,measurements:List<&2,Sys.Measurement>,observed:Driver.State & Metadata.WorldHistory) -> Driver.State & Text:
  match observed:
    case (state,history):(state,Text{"{\"schema\":\"Health\",\"workload\":\"Dense\",\"phase\":\"" ++ label ++ "\",\"count\":" ++ U32.show(count) ++ ",\"iterations\":" ++ U32.show(iterations) ++ ",\"frame\":null,\"reports\":" ++ records(measurements) ++ ",\"columnHistories\":",history})
def measured(label:String,count:U32,iterations:U32,observed:Driver.State & List<&2,Sys.Measurement>) -> Driver.State & Text:
  match observed:
    case (state,measurements):joined(label,count,iterations,measurements,Driver.inspect(~Metadata.WorldHistory,Driver.history_view,state))
def observe(label:String,count:U32,iterations:U32,state:Driver.State) -> Driver.State & Text:measured(label,count,iterations,Driver.measurements(state))
def appended(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(code,message)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,code,message))
def append_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),appended)
    case Fail{(code,message)}:IO.die(Unit,code,message)
def append(path:String,text:String) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"a"),append_opened(text))
def write_chunk(path:String,reversed:List<&2,String>) -> IO(Unit):append(path,String.concat(List.reverse(&2,String,reversed)))
def write_piece(value:O.Sample,first:Bool) -> String:
  match first:
    case True{}:Metadata.sample(value)
    case False{}:"," ++ Metadata.sample(value)
def write_go(+path:String,values:List<&2,O.Sample>,first:Bool,remaining:Nat,reversed:List<&2,String>) -> IO(Unit):
  match values:
    case []:IO.bind(Unit,Unit,write_chunk(path,reversed),_=>append(path,"]"))
    case value <> rest:
      match remaining:
        case 0n:IO.bind(Unit,Unit,write_chunk(path,reversed),_=>write_go(path,rest,False{},63n,[write_piece(value,first)]))
        case 1n+next:write_go(path,rest,False{},next,write_piece(value,first) <> reversed)
def write_history(+path:String,value:Metadata.History) -> IO(Unit):
  match value:
    case Metadata.Unmonitored{}:append(path,"null")
    case Metadata.Recorded{values}:IO.bind(Unit,Unit,append(path,"["),_=>write_go(path,values,True{},64n,[]))
def write_world(+path:String,value:Metadata.WorldHistory) -> IO(Unit):
  match value:
    case Metadata.WorldHistory{namespace,tick,Metadata.ColumnHistories{main,aux,flag}}:
      do IO<Unit>:
        append(path,"{\"namespace\":" ++ U32.show(namespace) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"columns\":{\"main\":")
        write_history(path,main)
        append(path,",\"aux\":")
        write_history(path,aux)
        append(path,",\"flag\":")
        write_history(path,flag)
        append(path,"}}")
def write(+path:String,suffix:String,value:Text) -> IO(Unit):
  match value:
    case Text{prefix,history}:
      do IO<Unit>:
        append(path,prefix)
        write_world(path,history)
        append(path,"}\n" ++ suffix)
