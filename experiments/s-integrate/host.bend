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
