import Base
import ./types.bend as T
import ./storage.bend as W
import ./commands.bend as C
import ./dispatcher.bend as D
import ./readers.bend as R
import ./reader-host.bend as H
import ./host-observations.bend as E
import ./observations.bend as O
import ./payload.bend as P
import ./query.bend as Q

type Host<-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data> is Type:
  Host{world:W.World<Schema,M,A,F,L,Mode>,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>}
def initial(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,worldName:String,world:W.World<Schema,M,A,F,L,Mode>,capacity:U32) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  Host{world,H.initial(Schema,P,capacity),[],worldName,"",D.Complete{},[]}
def label(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,step:String,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match owner:
    case Host{world,logs,bindings,worldName,_,prior,events}: Host{world,logs,bindings,worldName,step,prior,events}
def frame_return(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,world:W.World<Schema,M,A,F,L,Mode>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,result:H.Framed<Schema,P>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & (R.Readers & R.Clock):
  match result:
    case H.Framed{logs,readers,clock}: (Host{world,logs,bindings,worldName,step,prior,events},(readers,clock))
def frame(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,readers:R.Readers,boundary:R.Frame) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & (R.Readers & R.Clock):
  match owner:
    case Host{world,logs,bindings,worldName,step,prior,events}: frame_return(Schema,M,A,F,L,Mode,P,V,AV,LV,world,bindings,worldName,step,prior,events,H.frame(Schema,P,logs,readers,boundary))
def barrier_applied(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,+clock:R.Clock,result:W.World<Schema,M,A,F,L,Mode> & List<&2,W.Change<Schema>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Clock:
  match result:
    case (world,changes): (Host{world,H.append_changes(Schema,P,logs,D.clock_tick(clock),changes),bindings,worldName,step,prior,events},clock)
def barrier(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,clock:R.Clock) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Clock:
  match owner:
    case Host{world,logs,bindings,worldName,step,prior,events}:
      +next = {R.advance(clock):R.Clock}
      barrier_applied(Schema,M,A,F,L,Mode,P,V,AV,LV,logs,bindings,worldName,step,prior,events,next,C.apply(Schema,M,A,F,L,Mode,world,D.clock_tick(next)))
def ledger_presence(-L:Type,ledger:Maybe<L>) -> Maybe<L> & Bool:
  match ledger:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})
def binding_hit(-Schema:Data,hit:Bool,handle:W.Handle<Schema>,tail:Maybe<&2,W.Handle<Schema>>) -> Maybe<&2,W.Handle<Schema>>:
  match hit:
    case True{}: Some{handle}
    case False{}: tail
def binding_find(-Schema:Data,+name:String,values:List<&2,E.Binding<Schema>>) -> Maybe<&2,W.Handle<Schema>>:
  match values:
    case Nil{}: None{}
    case Con{E.Binding{label,handle},tail}: binding_hit(Schema,String.eq(name,label),handle,binding_find(Schema,name,tail))
