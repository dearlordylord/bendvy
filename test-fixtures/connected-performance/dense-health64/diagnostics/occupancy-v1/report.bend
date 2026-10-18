import Base
import tx-metrics.bend as Metrics
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
def joined(label:String,count:U32,iterations:U32,measurements:List<&2,Sys.Measurement>,observed:Driver.State & String) -> Driver.State & String:
  match observed:
    case (state,history):(state,"{\"schema\":\"Health\",\"workload\":\"Dense\",\"phase\":\"" ++ label ++ "\",\"count\":" ++ U32.show(count) ++ ",\"iterations\":" ++ U32.show(iterations) ++ ",\"frame\":null,\"reports\":" ++ records(measurements) ++ ",\"columnHistories\":" ++ history ++ "}\n")
def measured(label:String,count:U32,iterations:U32,observed:Driver.State & List<&2,Sys.Measurement>) -> Driver.State & String:
  match observed:
    case (state,measurements):joined(label,count,iterations,measurements,Driver.inspect(~String,Driver.history_view,state))
def observe(label:String,count:U32,iterations:U32,state:Driver.State) -> Driver.State & String:measured(label,count,iterations,Driver.measurements(state))
