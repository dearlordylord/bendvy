import Base
import ./types.bend as T
import ./storage.bend as W
import ./commands.bend as C
import ./host.bend as H
import ./reader-host.bend as L
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as Q
import ./capture.bend as LC
import ./systems.bend as U

def host_queued(-Schema:Data,-M:Type,-A:Type,-F:Data,-Ledger:Type,-Mode:Data,-Ping:Data,-V:Data,-AV:Data,-LV:Data,logs:L.Logs<Schema,Ping>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,Ping>>,result:T.CommandResult<W.World<Schema,M,A,F,Ledger,Mode>,M>) -> T.CommandResult<H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,M>:
  match result:
    case T.CommandQueued{world}: T.CommandQueued{H.Host{world,logs,bindings,worldName,step,prior,events}}
    case T.CommandMissing{world,payload}: T.CommandMissing{H.Host{world,logs,bindings,worldName,step,prior,events},payload}
def host_insert(-Schema:Data,-M:Type,-A:Type,-F:Data,-Ledger:Type,-Mode:Data,-Ping:Data,-V:Data,-AV:Data,-LV:Data,owner:H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,handle:W.Handle<Schema>,payload:M) -> T.CommandResult<H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,M>:
  match owner:
    case H.Host{world,logs,bindings,worldName,step,prior,events}: host_queued(Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV,logs,bindings,worldName,step,prior,events,C.insert_main(Schema,M,A,F,Ledger,Mode,world,handle,payload))
def runtime_queued(-World:Type,-Handle:Data,-Payload:Type,registry:Q.Registry,readers:R.Readers,clock:R.Clock,audit:Maybe<D.Audit>,style:LC.Style,escaped:List<&2,Handle>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,result:T.CommandResult<World,Payload>) -> T.CommandResult<D.Runtime<World,Handle>,Payload>:
  match result:
    case T.CommandQueued{world}: T.CommandQueued{D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}}
    case T.CommandMissing{world,payload}: T.CommandMissing{D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode},payload}
def insert(-Schema:Data,-M:Type,-A:Type,-F:Data,-Ledger:Type,-Mode:Data,-Ping:Data,-V:Data,-AV:Data,-LV:Data,owner:D.Runtime<H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,W.Handle<Schema>>,handle:W.Handle<Schema>,payload:M) -> T.CommandResult<D.Runtime<H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,W.Handle<Schema>>,M>:
  match owner:
    case D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}: runtime_queued(H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>,W.Handle<Schema>,M,registry,readers,clock,audit,style,escaped,observations,nextMode,host_insert(Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV,world,handle,payload))
