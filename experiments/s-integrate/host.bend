import Base
import ./types.bend as T
import ./storage.bend as W
import ./commands.bend as C
import ./dispatcher.bend as D
import ./readers.bend as R
import ./reader-host.bend as H
import ./host-observations.bend as E
import ./observations.bend as O
import ./payload.bend as PV
import ./query.bend as Q
import ./schedule.bend as K
import ./capture.bend as LC
import ./transaction-dispatch-adapters.bend as TA
import ./audited-invoker.bend as IA
import ./systems.bend as U

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

def marked_value(changed:Bool,added:U32,last:U32) -> U32:
  match changed:
    case True{}: last
    case False{}: added
def marked_case(hit:Bool,changed:Bool,added:U32,last:U32,tail:U32) -> U32:
  match hit:
    case True{}: marked_value(changed,added,last)
    case False{}: tail
def marked(-V:Data,-AV:Data,-F:Data,+id:U32,+changed:Bool,rows:List<&2,O.RowView<V,AV,F>>) -> U32:
  match rows:
    case Nil{}: 0
    case Con{O.RowView{key,_,_,_,added,last},tail}: marked_case(U32.is_eq(id,key),changed,added,last,marked(V,AV,F,id,changed,tail))
def filter_mark_case(-Schema:Data,-V:Data,-AV:Data,-F:Data,included:Bool,value:O.QueryRow<Schema,V,AV,F>,tail:List<&2,O.QueryRow<Schema,V,AV,F>>) -> List<&2,O.QueryRow<Schema,V,AV,F>>:
  match included:
    case True{}: value <> tail
    case False{}: tail
def filter_mark(-Schema:Data,-V:Data,-AV:Data,-F:Data,+rows:List<&2,O.RowView<V,AV,F>>,+changed:Bool,+since:U32,+thisRun:U32,values:List<&2,O.QueryRow<Schema,V,AV,F>>) -> List<&2,O.QueryRow<Schema,V,AV,F>>:
  match values:
    case Nil{}: []
    case Con{O.QueryRow{W.Handle{+ns,+id},main,aux,flag},tail}:
      +tick = {marked(V,AV,F,id,changed,rows):U32}
      filter_mark_case(Schema,V,AV,F,Bool.and(U32.is_gt(tick,since),U32.is_le(tick,thisRun)),O.QueryRow{W.Handle{ns,id},main,aux,flag},filter_mark(Schema,V,AV,F,rows,changed,since,thisRun,tail))
def query_return(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,result:W.World<Schema,M,A,F,L,Mode> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>:
  match result:
    case (world,values): (Host{world,logs,bindings,worldName,step,prior,events},values)
def query(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),selection:Q.Selection,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>:
  match owner:
    case Host{world,logs,bindings,worldName,step,prior,events}:
      query_return(Schema,M,A,F,L,Mode,P,V,AV,LV,logs,bindings,worldName,step,prior,events,Q.each(~Schema,~M,~A,~F,~Tok,~V,~AV,~O.QueryRow<Schema,V,AV,F>,~L,~Mode,~main_get,~aux_get,~client,selection,world))
def read_since(boundary:T.ReadBoundary) -> U32:
  match boundary:
    case T.ReadBoundary{since,_,_}: since
def read_now(boundary:T.ReadBoundary) -> U32:
  match boundary:
    case T.ReadBoundary{_,_,thisRun}: thisRun
def read_delivery(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,system:String,count:U32,world:W.World<Schema,M,A,F,L,Mode>,bindings:List<&2,E.Binding<Schema>>,worldName:String,+step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,+query:List<&2,O.QueryRow<Schema,V,AV,F>>,+rows:List<&2,O.RowView<V,AV,F>>,result:H.Read<Schema,P>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Run:
  match result:
    case H.Read{logs,run,H.Delivery{+boundary,messages,removed,despawned,messageLag,removedLag,despawnedLag}}:
      (Host{world,logs,bindings,worldName,step,prior,List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.Read{step,system,count,boundary,query,filter_mark(Schema,V,AV,F,rows,False{},read_since(boundary),read_now(boundary),query),filter_mark(Schema,V,AV,F,rows,True{},read_since(boundary),read_now(boundary),query),removed,despawned,messages,messageLag,removedLag,despawnedLag}])},run)
def read_world(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~ledger_get:L -> L & LV,system:String,count:U32,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,query:List<&2,O.QueryRow<Schema,V,AV,F>>,run:R.Run,result:W.World<Schema,M,A,F,L,Mode> & O.WorldView<V,AV,F,LV,Mode>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Run:
  match result:
    case (world,O.WorldView{_,_,rows,_,_,_}): read_delivery(Schema,M,A,F,L,Mode,P,V,AV,LV,system,count,world,bindings,worldName,step,prior,events,query,rows,H.read(Schema,P,logs,run))
def read_query(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~ledger_get:L -> L & LV,system:String,count:U32,run:R.Run,result:Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Run:
  match result:
    case (Host{world,logs,bindings,worldName,step,prior,events},query):
      read_world(Schema,M,A,F,L,Mode,P,V,AV,LV,ledger_get,system,count,logs,bindings,worldName,step,prior,events,query,run,O.world(~Schema,~M,~A,~F,~L,~Mode,~V,~AV,~LV,~main_get,~aux_get,~ledger_get,world))
def read(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,system:String,count:U32,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,run:R.Run) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Run:
  read_query(Schema,M,A,F,L,Mode,P,V,AV,LV,main_get,aux_get,ledger_get,system,count,run,query(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,Q.Required{},owner))
def lookup_result(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,label:String,handle:W.Handle<Schema>,tail:List<&2,E.Lookup<Schema,V,AV,F>>,result:W.World<Schema,M,A,F,L,Mode> & T.Access<O.QueryRow<Schema,V,AV,F>>) -> W.World<Schema,M,A,F,L,Mode> & List<&2,E.Lookup<Schema,V,AV,F>>:
  match result:
    case (world,value): (world,E.Lookup{label,handle,value} <> tail)
def lookup_join(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),label:String,+handle:W.Handle<Schema>,tail:W.World<Schema,M,A,F,L,Mode> & List<&2,E.Lookup<Schema,V,AV,F>>) -> W.World<Schema,M,A,F,L,Mode> & List<&2,E.Lookup<Schema,V,AV,F>>:
  match tail:
    case (world,values): lookup_result(Schema,M,A,F,L,Mode,P,V,AV,LV,label,handle,values,Q.lookup(~Schema,~M,~A,~F,~Tok,~V,~AV,~O.QueryRow<Schema,V,AV,F>,~L,~Mode,~main_get,~aux_get,~client,Q.Required{},world,handle))
def lookups(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),bindings:List<&2,E.Binding<Schema>>,world:W.World<Schema,M,A,F,L,Mode>) -> W.World<Schema,M,A,F,L,Mode> & List<&2,E.Lookup<Schema,V,AV,F>>:
  match bindings:
    case Nil{}: (world,[])
    case Con{E.Binding{label,handle},tail}: lookup_join(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,label,handle,lookups(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,tail,world))
def snapshot_end(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,+worldName:String,+step:String,+prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,view:O.WorldView<V,AV,F,LV,Mode>,query:List<&2,O.QueryRow<Schema,V,AV,F>>,plus:List<&2,O.QueryRow<Schema,V,AV,F>>,minus:List<&2,O.QueryRow<Schema,V,AV,F>>,optional:List<&2,O.QueryRow<Schema,V,AV,F>>,result:W.World<Schema,M,A,F,L,Mode> & List<&2,E.Lookup<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (world,values): Host{world,logs,bindings,worldName,step,prior,List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.Snapshot{step,worldName,prior,view,query,plus,minus,optional,values}])}
def snapshot_world(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),logs:H.Logs<Schema,P>,+bindings:List<&2,E.Binding<Schema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,query:List<&2,O.QueryRow<Schema,V,AV,F>>,plus:List<&2,O.QueryRow<Schema,V,AV,F>>,minus:List<&2,O.QueryRow<Schema,V,AV,F>>,optional:List<&2,O.QueryRow<Schema,V,AV,F>>,result:W.World<Schema,M,A,F,L,Mode> & O.WorldView<V,AV,F,LV,Mode>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (world,view): snapshot_end(Schema,M,A,F,L,Mode,P,V,AV,LV,logs,bindings,worldName,step,prior,events,view,query,plus,minus,optional,lookups(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,bindings,world))
def snapshot_optional(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,query:List<&2,O.QueryRow<Schema,V,AV,F>>,plus:List<&2,O.QueryRow<Schema,V,AV,F>>,minus:List<&2,O.QueryRow<Schema,V,AV,F>>,result:Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (Host{world,logs,bindings,worldName,step,prior,events},optional): snapshot_world(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,logs,bindings,worldName,step,prior,events,query,plus,minus,optional,O.world(~Schema,~M,~A,~F,~L,~Mode,~V,~AV,~LV,~main_get,~aux_get,~ledger_get,world))
def snapshot_minus(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,required:List<&2,O.QueryRow<Schema,V,AV,F>>,plus:List<&2,O.QueryRow<Schema,V,AV,F>>,result:Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (owner,minus): snapshot_optional(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,ledger_get,required,plus,minus,query(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,Q.Optional{},owner))
def snapshot_plus(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,required:List<&2,O.QueryRow<Schema,V,AV,F>>,result:Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (owner,plus): snapshot_minus(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,ledger_get,required,plus,query(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,Q.Absent{},owner))
def snapshot_required(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,result:Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & List<&2,O.QueryRow<Schema,V,AV,F>>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match result:
    case (owner,required): snapshot_plus(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,ledger_get,required,query(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,Q.Present{},owner))
def snapshot(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,~P:Data,~V:Data,~AV:Data,~LV:Data,~Tok:Data,~main_get:M -> M & V,~aux_get:A -> A & AV,~client:@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) -> W.Handle<Schema> -> Maybe<&2,F> -> Owner -> Aux -> Owner & (Aux & O.QueryRow<Schema,V,AV,F>),~ledger_get:L -> L & LV,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  snapshot_required(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,ledger_get,query(Schema,M,A,F,L,Mode,P,V,AV,LV,Tok,main_get,aux_get,client,Q.Required{},owner))
def MotionHost() -> Type:
  Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>
def motion_snapshot(owner:MotionHost()) -> MotionHost():
  snapshot(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,T.PositionToken,PV.position_get,PV.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),PV.motion_ledger_get,owner)
def motion_read(system:String,count:U32,owner:MotionHost(),run:R.Run) -> MotionHost() & R.Run:
  read(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,T.PositionToken,PV.position_get,PV.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),PV.motion_ledger_get,system,count,owner,run)
def HealthHost() -> Type:
  Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>
def health_snapshot(owner:HealthHost()) -> HealthHost():
  snapshot(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,T.VitalsToken,PV.vitals_get,PV.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),PV.health_ledger_get,owner)
def health_read(system:String,count:U32,owner:HealthHost(),run:R.Run) -> HealthHost() & R.Run:
  read(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,T.VitalsToken,PV.vitals_get,PV.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),PV.health_ledger_get,system,count,owner,run)
def motion_on(mode:T.MotionMode) -> Bool:
  match mode:
    case T.MotionOn{}: True{}
    case T.MotionOff{}: False{}
def motion_presence_ledger(ns:U32,next:U32,rows:List<W.Row<T.Position,T.Velocity,T.Selected>>,pending:List<W.Command<T.Position,T.Velocity,T.Selected>>,+mode:T.MotionMode,logs:H.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,pair:Maybe<T.MotionLedger> & Bool) -> MotionHost() & D.Presence:
  match pair:
    case (ledger,available): (Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,worldName,step,prior,events},D.Presence{available,motion_on(mode)})
def motion_presence(owner:MotionHost()) -> MotionHost() & D.Presence:
  match owner:
    case Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,worldName,step,prior,events}:
      motion_presence_ledger(ns,next,rows,pending,mode,logs,bindings,worldName,step,prior,events,ledger_presence(T.MotionLedger,ledger))
def motion_desired(value:Bool) -> T.MotionMode:
  match value:
    case True{}: T.MotionOn{}
    case False{}: T.MotionOff{}
def motion_transition(owner:MotionHost(),pending:Maybe<&2,Bool>,clock:R.Clock) -> MotionHost() & R.Clock:
  match owner pending:
    case world None{}: (world,clock)
    case Host{W.World{ns,next,rows,commands,ledger,_},logs,bindings,worldName,step,prior,events} Some{value}:
      (Host{W.World{ns,next,rows,commands,ledger,motion_desired(value)},logs,bindings,worldName,step,prior,events},R.advance(clock))
def health_on(mode:T.HealthMode) -> Bool:
  match mode:
    case T.HealthOn{}: True{}
    case T.HealthOff{}: False{}
def health_presence_ledger(ns:U32,next:U32,rows:List<W.Row<T.Vitals,T.Armor,T.Tracked>>,pending:List<W.Command<T.Vitals,T.Armor,T.Tracked>>,+mode:T.HealthMode,logs:H.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,pair:Maybe<T.HealthLedger> & Bool) -> HealthHost() & D.Presence:
  match pair:
    case (ledger,available): (Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,worldName,step,prior,events},D.Presence{available,health_on(mode)})
def health_presence(owner:HealthHost()) -> HealthHost() & D.Presence:
  match owner:
    case Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,worldName,step,prior,events}:
      health_presence_ledger(ns,next,rows,pending,mode,logs,bindings,worldName,step,prior,events,ledger_presence(T.HealthLedger,ledger))
def health_desired(value:Bool) -> T.HealthMode:
  match value:
    case True{}: T.HealthOn{}
    case False{}: T.HealthOff{}
def health_transition(owner:HealthHost(),pending:Maybe<&2,Bool>,clock:R.Clock) -> HealthHost() & R.Clock:
  match owner pending:
    case world None{}: (world,clock)
    case Host{W.World{ns,next,rows,commands,ledger,_},logs,bindings,worldName,step,prior,events} Some{value}:
      (Host{W.World{ns,next,rows,commands,ledger,health_desired(value)},logs,bindings,worldName,step,prior,events},R.advance(clock))
type Lag is Data:
  Lag{message:Bool,removed:Bool,despawned:Bool}
def lag_keep(tail:Maybe<&2,Lag>,head:Maybe<&2,Lag>) -> Maybe<&2,Lag>:
  match tail:
    case Some{value}: Some{value}
    case None{}: head
def lag_match(hit:Bool,value:Lag) -> Maybe<&2,Lag>:
  match hit:
    case True{}: Some{value}
    case False{}: None{}
def lag_find(-Schema:Data,-V:Data,-AV:Data,-F:Data,-LV:Data,-Mode:Data,-P:Data,+system:String,+count:U32,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>) -> Maybe<&2,Lag>:
  match events:
    case Nil{}: None{}
    case Con{E.Read{_,name,key,_,_,_,_,_,_,_,m,r,d},tail}:
      lag_keep(lag_find(Schema,V,AV,F,LV,Mode,P,system,count,tail),lag_match(Bool.and(String.eq(system,name),U32.is_eq(count,key)),Lag{m,r,d}))
    case Con{_,tail}: lag_find(Schema,V,AV,F,LV,Mode,P,system,count,tail)
def clock_frame(clock:R.Clock) -> U32:
  match clock:
    case R.Clock{_,_,_,frame}: frame
def own_values(values:List<&2,U.Observation>) -> List<&2,E.OwnView>:
  match values:
    case Nil{}: []
    case Con{U.MainObserved{view},tail}: E.Main{view} <> own_values(tail)
    case Con{U.LedgerObserved{view},tail}: E.Ledger{view} <> own_values(tail)
    case Con{U.ReservedObserved{view},tail}: E.ReservedLookup{view} <> own_values(tail)
def own_record(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,write:Bool,system:String,views:List<&2,U.Observation>,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match write owner:
    case False{} world: world
    case True{} Host{world,logs,bindings,worldName,+step,prior,events}:
      Host{world,logs,bindings,worldName,step,prior,List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.OwnWrites{step,system,own_values(views)}])}
def diag_event(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,+system:String,+count:U32,clock:R.Clock,+outcome:T.Outcome,boundary:T.ReadBoundary,+events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,step:String,lag:Maybe<&2,Lag>) -> List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>:
  match lag:
    case None{}: events
    case Some{Lag{m,r,d}}: List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.ReadDone{step,system,clock_frame(clock),read_now(boundary),outcome,m,r,d}])
def done_run(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,+system:String,+count:U32,+clock:R.Clock,audit:Maybe<D.Audit>,+outcome:T.Outcome,escaped:Maybe<&2,W.Handle<Schema>>,observations:List<&2,U.Observation>,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,info:R.RunInfo) -> D.Invoked<Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,W.Handle<Schema>>:
  match owner info:
    case Host{world,logs,bindings,worldName,+step,prior,+events} R.RunInfo{run,_,boundary}:
      D.Invoked{Host{world,logs,bindings,worldName,step,prior,diag_event(Schema,M,A,F,L,Mode,P,V,AV,LV,system,count,clock,outcome,boundary,events,step,lag_find(Schema,V,AV,F,LV,Mode,P,system,count,events))},audit,Some{run},outcome,clock,escaped,observations}
def done(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,system:String,count:U32,clock:R.Clock,audit:Maybe<D.Audit>,outcome:T.Outcome,escaped:Maybe<&2,W.Handle<Schema>>,observations:List<&2,U.Observation>,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,run:Maybe<R.Run>) -> D.Invoked<Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,W.Handle<Schema>>:
  match run:
    case None{}: D.Invoked{owner,audit,None{},outcome,clock,escaped,observations}
    case Some{run}: done_run(Schema,M,A,F,L,Mode,P,V,AV,LV,system,count,clock,audit,outcome,escaped,observations,owner,R.project(run))
def reserve_record(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,+label:String,escaped:Maybe<&2,W.Handle<Schema>>,components:Maybe<&2,O.BundleView<V,AV,F>>,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV>:
  match escaped components owner:
    case Some{+handle} Some{values} Host{world,logs,bindings,+worldName,+step,prior,events}:
      Host{world,logs,List.append(&2,E.Binding<Schema>,bindings,[E.Binding{label,handle}]),worldName,step,prior,List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.Reserved{step,worldName,label,handle,values}])}
    case _ _ state: state
def publish(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,owner:Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,clock:R.Clock,values:List<&2,P>) -> Host<Schema,M,A,F,L,Mode,P,V,AV,LV> & R.Clock:
  match owner values:
    case world Nil{}: (world,clock)
    case Host{world,logs,bindings,worldName,step,prior,events} Con{head,tail}:
      +next = {R.advance(clock):R.Clock}
      (Host{world,H.append_ping(Schema,P,logs,D.clock_tick(next),head <> tail),bindings,worldName,step,prior,events},next)
def reservation_name(kind:K.BodyKind,mode:K.Mode) -> String:
  match kind mode:
    case K.A{} _: "p"
    case K.B{} K.BFail{}: "q"
    case K.B{} _: "r"
    case _ _: ""
def own_writes(kind:K.BodyKind,mode:K.Mode) -> Bool:
  match kind:
    case K.A{}: True{}
    case K.B{}: U.writes(mode)
    case _: False{}
def selected_name(kind:K.BodyKind) -> String:
  match kind:
    case K.A{}: "a"
    case _: "b"
def motion_pings(values:List<&2,U32>) -> List<&2,T.MotionPing>:
  match values:
    case Nil{}: []
    case Con{value,tail}: T.MotionPing{value} <> motion_pings(tail)
def motion_published(system:String,count:U32,audit:D.Audit,outcome:T.Outcome,escaped:Maybe<&2,W.Handle<T.MotionSchema>>,views:List<&2,U.Observation>,run:Maybe<R.Run>,result:MotionHost() & R.Clock) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match result:
    case (owner,clock): IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,Some{audit},outcome,escaped,views,owner,run))
def motion_service(+kind:K.BodyKind,+mode:K.Mode,+system:String,count:U32,clock:R.Clock,logs:H.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,run:Maybe<R.Run>,result:IA.ServiceResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match result:
    case IA.ServiceResult{TA.RunResult{world,outcome,+escaped,+views,pings},audit,reservation}:
      motion_published(system,count,audit,outcome,escaped,views,run,publish(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,own_record(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,own_writes(kind,mode),system,views,reserve_record(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,reservation_name(kind,mode),escaped,reservation,Host{world,logs,bindings,worldName,step,prior,events})),clock,motion_pings(pings)))
def motion_transaction_found(+kind:K.BodyKind,+mode:K.Mode,+system:String,+count:U32,+clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,W.Handle<T.MotionSchema>>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match kind owner audit selected:
    case K.A{} Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(IA.ServiceResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,IA.motion_a(count,T.Failure{7},D.clock_tick(clock),world,handle,audit),result => motion_service(K.A{},mode,system,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case K.B{} Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(IA.ServiceResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,IA.motion_b(mode,count,D.clock_tick(clock),world,handle,audit),result => motion_service(K.B{},mode,system,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case _ state service _: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,service,T.Failure{7},None{},[],state,run))
def motion_transaction(+kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match owner:
    case Host{world,logs,+bindings,worldName,step,prior,events}:
      motion_transaction_found(kind,mode,system,count,clock,Host{world,logs,bindings,worldName,step,prior,events},audit,run,binding_find(T.MotionSchema,selected_name(kind),bindings))
def health_pings(values:List<&2,U32>) -> List<&2,T.HealthPing>:
  match values:
    case Nil{}: []
    case Con{value,tail}: T.HealthPing{value} <> health_pings(tail)
def health_published(system:String,count:U32,audit:D.Audit,outcome:T.Outcome,escaped:Maybe<&2,W.Handle<T.HealthSchema>>,views:List<&2,U.Observation>,run:Maybe<R.Run>,result:HealthHost() & R.Clock) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match result:
    case (owner,clock): IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,Some{audit},outcome,escaped,views,owner,run))
def health_service(+kind:K.BodyKind,+mode:K.Mode,+system:String,count:U32,clock:R.Clock,logs:H.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,run:Maybe<R.Run>,result:IA.ServiceResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match result:
    case IA.ServiceResult{TA.RunResult{world,outcome,+escaped,+views,pings},audit,reservation}:
      health_published(system,count,audit,outcome,escaped,views,run,publish(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,own_record(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,own_writes(kind,mode),system,views,reserve_record(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,reservation_name(kind,mode),escaped,reservation,Host{world,logs,bindings,worldName,step,prior,events})),clock,health_pings(pings)))
def health_transaction_found(+kind:K.BodyKind,+mode:K.Mode,+system:String,+count:U32,+clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,W.Handle<T.HealthSchema>>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match kind owner audit selected:
    case K.A{} Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(IA.ServiceResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,IA.health_a(count,T.Failure{7},D.clock_tick(clock),world,handle,audit),result => health_service(K.A{},mode,system,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case K.B{} Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(IA.ServiceResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,IA.health_b(mode,count,D.clock_tick(clock),world,handle,audit),result => health_service(K.B{},mode,system,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case _ state service _: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,service,T.Failure{7},None{},[],state,run))
def health_transaction(+kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match owner:
    case Host{world,logs,+bindings,worldName,step,prior,events}:
      health_transaction_found(kind,mode,system,count,clock,Host{world,logs,bindings,worldName,step,prior,events},audit,run,binding_find(T.HealthSchema,selected_name(kind),bindings))
def motion_reserved(label:String,logs:H.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,view:O.BundleView<T.PositionView,T.VelocityView,T.Selected>,result:T.Reservation<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,W.Bundle<T.Position,T.Velocity,T.Selected>>) -> MotionHost():
  match result:
    case T.Reserved{world,handle}: reserve_record(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,label,Some{handle},Some{view},Host{world,logs,bindings,worldName,step,prior,events})
    case T.ReserveRejected{world,_}: Host{world,logs,bindings,worldName,step,D.SetupRejected{"reservation bound"},events}
def motion_reserve_view(label:String,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,logs:H.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,result:W.Bundle<T.Position,T.Velocity,T.Selected> & O.BundleView<T.PositionView,T.VelocityView,T.Selected>) -> MotionHost():
  match result:
    case (bundle,view): motion_reserved(label,logs,bindings,worldName,step,prior,events,view,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,bundle))
def motion_reserve(owner:MotionHost(),label:String,bundle:W.Bundle<T.Position,T.Velocity,T.Selected>) -> MotionHost():
  match owner:
    case Host{world,logs,bindings,worldName,step,prior,events}:
      motion_reserve_view(label,world,logs,bindings,worldName,step,prior,events,O.bundle(T.Position,T.Velocity,T.Selected,T.PositionView,T.VelocityView,PV.position_get,PV.velocity_get,bundle))
def health_reserved(label:String,logs:H.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,view:O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>,result:T.Reservation<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,W.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> HealthHost():
  match result:
    case T.Reserved{world,handle}: reserve_record(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,label,Some{handle},Some{view},Host{world,logs,bindings,worldName,step,prior,events})
    case T.ReserveRejected{world,_}: Host{world,logs,bindings,worldName,step,D.SetupRejected{"reservation bound"},events}
def health_reserve_view(label:String,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,logs:H.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,result:W.Bundle<T.Vitals,T.Armor,T.Tracked> & O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>) -> HealthHost():
  match result:
    case (bundle,view): health_reserved(label,logs,bindings,worldName,step,prior,events,view,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,bundle))
def health_reserve(owner:HealthHost(),label:String,bundle:W.Bundle<T.Vitals,T.Armor,T.Tracked>) -> HealthHost():
  match owner:
    case Host{world,logs,bindings,worldName,step,prior,events}:
      health_reserve_view(label,world,logs,bindings,worldName,step,prior,events,O.bundle(T.Vitals,T.Armor,T.Tracked,T.VitalsView,T.ArmorView,PV.vitals_get,PV.armor_get,bundle))
def motion_simple(kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match kind:
    case K.Snapshot{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],motion_snapshot(owner),run))
    case K.Seed{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.motion_seed(MotionHost(),motion_reserve,motion_reserve,motion_reserve,owner),run))
    case K.SeedBeta{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.motion_seed_beta(MotionHost(),motion_reserve,owner),run))
    case K.SpawnS{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.motion_spawn_s(MotionHost(),motion_reserve,owner),run))
    case K.B{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,U.failed(mode),None{},[],owner,run))
    case K.Fast{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.ReadOnlyLate{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.Tail{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.SetOn{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.SetOff{}: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case _: IO.pure(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>,done(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,system,count,clock,audit,T.Failure{7},None{},[],owner,run))
def motion_b_choose(write:Bool,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match write:
    case True{}: motion_transaction(K.B{},mode,system,count,clock,owner,audit,run)
    case False{}: motion_simple(K.B{},mode,system,count,clock,owner,audit,run)
def motion_body(kind:K.BodyKind,+mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match kind:
    case K.A{}: motion_transaction(K.A{},mode,system,count,clock,owner,audit,run)
    case K.B{}: motion_b_choose(U.writes(mode),mode,system,count,clock,owner,audit,run)
    case other: motion_simple(other,mode,system,count,clock,owner,audit,run)
def motion_read_done(kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,audit:Maybe<D.Audit>,pair:MotionHost() & R.Run) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match pair:
    case (owner,run): motion_body(kind,mode,system,count,clock,owner,audit,Some{run})
def motion_invoke_count(system:K.System,mode:K.Mode,+count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  match system run:
    case K.System{_,+name,kind,_,_,_,_} Some{run}: motion_read_done(kind,mode,name,count,clock,audit,motion_read(name,count,owner,run))
    case K.System{_,name,kind,_,_,_,_} None{}: motion_body(kind,mode,name,count,clock,owner,audit,None{})
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionHost(),W.Handle<T.MotionSchema>>):
  motion_invoke_count(system,mode,count,clock,owner,audit,run)
def motion_barrier(owner:MotionHost(),clock:R.Clock) -> MotionHost() & R.Clock:
  barrier(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,owner,clock)
def motion_frame(owner:MotionHost(),readers:R.Readers,boundary:R.Frame) -> MotionHost() & (R.Readers & R.Clock):
  frame(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,owner,readers,boundary)
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionHost(),W.Handle<T.MotionSchema>>):
  D.tick(~MotionHost(),~W.Handle<T.MotionSchema>,~motion_presence,~motion_invoke,~motion_barrier,~motion_transition,~motion_frame,nodes,"MotionLedger","MotionMode",runtime)
def health_simple(kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match kind:
    case K.Snapshot{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],health_snapshot(owner),run))
    case K.Seed{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.health_seed(HealthHost(),health_reserve,health_reserve,health_reserve,owner),run))
    case K.SeedBeta{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.health_seed_beta(HealthHost(),health_reserve,owner),run))
    case K.SpawnS{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],U.health_spawn_s(HealthHost(),health_reserve,owner),run))
    case K.B{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,U.failed(mode),None{},[],owner,run))
    case K.Fast{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.ReadOnlyLate{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.Tail{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.SetOn{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case K.SetOff{}: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Success{},None{},[],owner,run))
    case _: IO.pure(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>,done(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,system,count,clock,audit,T.Failure{7},None{},[],owner,run))
def health_b_choose(write:Bool,mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match write:
    case True{}: health_transaction(K.B{},mode,system,count,clock,owner,audit,run)
    case False{}: health_simple(K.B{},mode,system,count,clock,owner,audit,run)
def health_body(kind:K.BodyKind,+mode:K.Mode,system:String,count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match kind:
    case K.A{}: health_transaction(K.A{},mode,system,count,clock,owner,audit,run)
    case K.B{}: health_b_choose(U.writes(mode),mode,system,count,clock,owner,audit,run)
    case other: health_simple(other,mode,system,count,clock,owner,audit,run)
def health_read_done(kind:K.BodyKind,mode:K.Mode,system:String,count:U32,clock:R.Clock,audit:Maybe<D.Audit>,pair:HealthHost() & R.Run) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match pair:
    case (owner,run): health_body(kind,mode,system,count,clock,owner,audit,Some{run})
def health_invoke_count(system:K.System,mode:K.Mode,+count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  match system run:
    case K.System{_,+name,kind,_,_,_,_} Some{run}: health_read_done(kind,mode,name,count,clock,audit,health_read(name,count,owner,run))
    case K.System{_,name,kind,_,_,_,_} None{}: health_body(kind,mode,name,count,clock,owner,audit,None{})
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthHost(),W.Handle<T.HealthSchema>>):
  health_invoke_count(system,mode,count,clock,owner,audit,run)
def health_barrier(owner:HealthHost(),clock:R.Clock) -> HealthHost() & R.Clock:
  barrier(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,owner,clock)
def health_frame(owner:HealthHost(),readers:R.Readers,boundary:R.Frame) -> HealthHost() & (R.Readers & R.Clock):
  frame(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,owner,readers,boundary)
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthHost(),W.Handle<T.HealthSchema>>):
  D.tick(~HealthHost(),~W.Handle<T.HealthSchema>,~health_presence,~health_invoke,~health_barrier,~health_transition,~health_frame,nodes,"HealthLedger","HealthMode",runtime)
def system_name(system:K.System) -> String:
  match system:
    case K.System{_,name,_,_,_,_,_}: name
def count_local(+system:K.System,tail:List<K.Entry>,counts:List<&2,E.Count>,pair:LC.Local & T.Four) -> List<K.Entry> & List<&2,E.Count>:
  match pair:
    case (owner,view): (K.Entry{system,owner} <> tail,E.Count{system_name(system),view} <> counts)
def count_tail(system:K.System,owner:LC.Local,pair:List<K.Entry> & List<&2,E.Count>) -> List<K.Entry> & List<&2,E.Count>:
  match pair:
    case (entries,values): count_local(system,entries,values,LC.observe(owner))
def count_entries(entries:List<K.Entry>) -> List<K.Entry> & List<&2,E.Count>:
  match entries:
    case Nil{}: ([],[])
    case Con{K.Entry{system,owner},tail}: count_tail(system,owner,count_entries(tail))
def count_registry_return(next:U32,pair:List<K.Entry> & List<&2,E.Count>) -> K.Registry & List<&2,E.Count>:
  match pair:
    case (entries,values): (K.Registry{next,entries},values)
def count_registry(registry:K.Registry) -> K.Registry & List<&2,E.Count>:
  match registry:
    case K.Registry{next,entries}: count_registry_return(next,count_entries(entries))
def dispatched_counts(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,world:W.World<Schema,M,A,F,L,Mode>,logs:H.Logs<Schema,P>,bindings:List<&2,E.Binding<Schema>>,+worldName:String,+step:String,tracked:Bool,events:List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>>,readers:R.Readers,+clock:R.Clock,audit:Maybe<D.Audit>,style:LC.Style,escaped:List<&2,W.Handle<Schema>>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,+outcome:D.DispatchOutcome,pair:K.Registry & List<&2,E.Count>) -> D.Dispatched<Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,W.Handle<Schema>>:
  match pair:
    case (registry,counts): D.Dispatched{D.Runtime{Host{world,logs,bindings,worldName,step,outcome,List.append(&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,P>,events,[E.Dispatch{step,worldName,tracked,outcome,D.clock_tick(clock),clock_frame(clock),counts}])},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}
def dispatched(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,tracked:Bool,result:D.Dispatched<Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,W.Handle<Schema>>) -> D.Dispatched<Host<Schema,M,A,F,L,Mode,P,V,AV,LV>,W.Handle<Schema>>:
  match result:
    case D.Dispatched{D.Runtime{Host{world,logs,bindings,worldName,step,_,events},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}:
      dispatched_counts(Schema,M,A,F,L,Mode,P,V,AV,LV,world,logs,bindings,worldName,step,tracked,events,readers,clock,audit,style,escaped,observations,nextMode,outcome,count_registry(registry))
def motion_label(step:String,runtime:D.Runtime<MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<MotionHost(),W.Handle<T.MotionSchema>>:
  match runtime:
    case D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      D.Runtime{label(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,step,owner),registry,readers,clock,audit,style,escaped,observations,nextMode}
def motion_dispatch(tracked:Bool,step:String,nodes:List<&2,K.Node>,runtime:D.Runtime<MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionHost(),W.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<MotionHost(),W.Handle<T.MotionSchema>>,D.Dispatched<MotionHost(),W.Handle<T.MotionSchema>>,motion_tick(nodes,motion_label(step,runtime)),result => IO.pure(D.Dispatched<MotionHost(),W.Handle<T.MotionSchema>>,dispatched(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,tracked,result)))
def health_label(step:String,runtime:D.Runtime<HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<HealthHost(),W.Handle<T.HealthSchema>>:
  match runtime:
    case D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      D.Runtime{label(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,step,owner),registry,readers,clock,audit,style,escaped,observations,nextMode}
def health_dispatch(tracked:Bool,step:String,nodes:List<&2,K.Node>,runtime:D.Runtime<HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthHost(),W.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<HealthHost(),W.Handle<T.HealthSchema>>,D.Dispatched<HealthHost(),W.Handle<T.HealthSchema>>,health_tick(nodes,health_label(step,runtime)),result => IO.pure(D.Dispatched<HealthHost(),W.Handle<T.HealthSchema>>,dispatched(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,tracked,result)))
