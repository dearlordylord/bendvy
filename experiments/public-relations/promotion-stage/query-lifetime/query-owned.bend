import Base
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-query.bend as RQ
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as X
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/query.bend as Q
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/system.bend as Sys
import owned-world.bend as O

type Rest<S:Data> is Type:
  Rest{graph:G.Graph<S>}
type Token<S:Data> is Data:
  Token{}
def take(~S:Data,store:A.Store<S,O.Components<S>>) -> Rest<S> & Col.Column<S,O.Payload>:
  match store:
    case A.Store{O.Components{column},graph}: (Rest{graph},column)
def put(~S:Data,rest:Rest<S>,column:Col.Column<S,O.Payload>) -> A.Store<S,O.Components<S>>:
  match rest:
    case Rest{graph}: A.Store{O.Components{column},graph}
def enlarged(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>>:
  match store:
    case A.Store{O.Components{column},graph}: A.Store{O.Components{Col.ensure(~S,~O.Payload,column,8)},graph}
def empty(~S:Data,_:Unit) -> A.Store<S,O.Components<S>>:
  enlarged(~S,O.empty(~S,Unit{}))
def family(~S:Data) -> Cmp.Family<S,A.Store<S,O.Components<S>>,Rest<S>,O.Payload,List<&2,U32>,Token<S>,take(~S),put(~S),O.project_payload>:
  Cmp.Family{"Payload"}
def projected(~S:Data,observed:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Cmp.Access<List<&2,U32>>,selected:Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & (Bool & List<&2,U32>):
  match observed:
    case (tx,Cmp.Found{view}): (tx,(selected,view))
    case (tx,_): (tx,(False{},[]))
def selected(~S:Data,observed:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & (Bool & List<&2,U32>):
  (tx,good) = observed
  projected(~S,Cmp.tx_get(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Rest<S>,~O.Payload,~List<&2,U32>,~Token<S>,~take(~S),~put(~S),~O.project_payload,family(~S),tx,handle),good)
def component_selected(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,handle:W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & (Bool & List<&2,U32>):
  +handle = handle
  selected(~S,Q.selected(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Rest<S>,~O.Payload,~List<&2,U32>,~Token<S>,~take(~S),~put(~S),~O.project_payload,~Rest<S>,~O.Payload,~List<&2,U32>,~Token<S>,~take(~S),~put(~S),~O.project_payload,family(~S),family(~S),Q.Optional{},tx,handle),handle)
def read_body(~S:Data,-H:Type,caps:Cap.ValueRead<H,RQ.Row<S,List<&2,U32>>>,owner:H) -> H & RQ.Row<S,List<&2,U32>>:
  match caps:
    case Cap.ValueRead{get}: get(owner)
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
def other(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"OtherLink","OtherIncoming",G.Ordinary{}}
def spec_optional(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.optional_relation(~S,"target",link(~S)),RQ.optional_related(~S,"sources",link(~S))]}
def spec_outgoing(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.read_relation(~S,"target",link(~S))]}
def spec_incoming(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.read_related(~S,"sources",link(~S))]}
def spec_with_out(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.with_relation(~S,link(~S))]}
def spec_without_out(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.without_relation(~S,link(~S))]}
def spec_with_in(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.with_related(~S,link(~S))]}
def spec_without_in(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.without_related(~S,link(~S))]}
def spec_multi(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.read_relation(~S,"target",link(~S)),RQ.optional_relation(~S,"otherTarget",other(~S)),RQ.optional_related(~S,"otherSources",other(~S)),RQ.without_related(~S,other(~S))]}
def spec_cross_filters(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.with_relation(~S,other(~S)),RQ.without_relation(~S,link(~S)),RQ.optional_related(~S,"sources",link(~S))]}
def spec_empty(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[]}
def spec_other_optional(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.optional_relation(~S,"otherTarget",other(~S)),RQ.optional_related(~S,"otherSources",other(~S))]}
def show_handle(~S:Data,handle:W.Handle<S>) -> String:
  match handle:
    case W.Handle{ns,id}: U32.show(ns) ++ ":" ++ U32.show(id)
def show_handles(~S:Data,handles:List<&2,W.Handle<S>>) -> String:
  match handles:
    case []: ""
    case handle <> rest: show_handle(~S,handle) ++ "," ++ show_handles(~S,rest)
def show_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}: "none"
    case RQ.Target{handle}: show_handle(~S,handle)
    case RQ.Sources{handles}: "[" ++ show_handles(~S,handles) ++ "]"
def show_cells(~S:Data,cells:List<&2,RQ.Cell<S>>) -> String:
  match cells:
    case []: ""
    case RQ.Cell{key,_,value} <> rest: key ++ "=" ++ show_value(~S,value) ++ ";" ++ show_cells(~S,rest)
def show_row(~S:Data,row:RQ.Row<S,List<&2,U32>>) -> String:
  match row:
    case RQ.Row{handle,cells,component}: show_handle(~S,handle) ++ "[" ++ O.show_ids(component) ++ "]{" ++ show_cells(~S,cells) ++ "}"
def show_rows(~S:Data,rows:List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  match rows:
    case []: ""
    case row <> rest: show_row(~S,row) ++ "|" ++ show_rows(~S,rest)
def observed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,rows:List<&2,RQ.Row<S,List<&2,U32>>>,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text ++ show_rows(~S,rows))
def query_join(~S:Data,name:String,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,RQ.Row<S,List<&2,U32>>>,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,rows) = observed
  (world,text ++ name ++ "=" ++ show_rows(~S,rows) ++ "\n")
def queries_empty(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  query_join(~S,"empty",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_empty(~S),~component_selected(~S),~read_body(~S),world),text)
def queries_cross_filters(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_empty(~S,query_join(~S,"cross-filters",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_cross_filters(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_multi(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_cross_filters(~S,query_join(~S,"multi",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_multi(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_without_in(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_multi(~S,query_join(~S,"without-in",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_without_in(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_with_in(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_without_in(~S,query_join(~S,"with-in",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_with_in(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_without_out(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_with_in(~S,query_join(~S,"without-out",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_without_out(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_with_out(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_without_out(~S,query_join(~S,"with-out",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_with_out(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_incoming(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_with_out(~S,query_join(~S,"incoming",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_incoming(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_outgoing(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_incoming(~S,query_join(~S,"outgoing",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_outgoing(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_optional(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_outgoing(~S,query_join(~S,"optional",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_optional(~S),~component_selected(~S),~read_body(~S),world),text))
def queries_other_optional(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = observed
  queries_optional(~S,query_join(~S,"other-optional",RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_other_optional(~S),~component_selected(~S),~read_body(~S),world),text))
def runner_join(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,String>:
  (world,text) = observed
  Sys.Succeeded{world,text}
def runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,_:Unit) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,String>:
  runner_join(~S,queries_other_optional(~S,(world,"")))
def queued_done(~S:Data,observed:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = observed
  tx
def queue(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,descriptor:G.Descriptor<S>,source:U32,target:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  queued_done(~S,A.queue_relate(~S,~O.Components<S>,~U32,~U32,tx,descriptor,W.Handle{1,source},W.Handle{1,target}))
def seeded(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,O.commit(~S,queue(~S,queue(~S,queue(~S,queue(~S,queue(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),link(~S),3,1),link(~S),2,1),link(~S),5,1),other(~S),1,4),other(~S),4,2),X.Success{}))
def rendered(~S:Data,text:String,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (_,owners) = observed
  text ++ "owners=" ++ owners

def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Unit,U32,String,runner(~S)>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,text}}: (world,text)
    case Sys.Completed{_,Sys.Failed{world,_}}: (world,"SYSTEM_FAILED")
    case Sys.RegistrationRejected{_,world,_}: (world,"RUN_REJECTED")
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Unit,U32,String,runner(~S)>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  match result:
    case Sys.Registered{world,registry}: ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~U32,~String,~runner(~S),registry,world,Unit{}))
    case Sys.RegistrationFailed{world}: (world,"REGISTER_REJECTED")
def registered_world(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,name:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Unit,~U32,~String,~runner(~S),world,name,["Payload.read","Link.read","LinkedBy.read","OtherLink.read","OtherIncoming.read"]))
def phase_applied(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,text:String,retained:List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  (world,after) = observed
  rendered(~S,text ++ "applied\n" ++ after ++ "retained=" ++ show_rows(~S,retained) ++ "\n",O.observe_complete(~S,world))
def phase_queued(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,text:String,retained:List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  (world,before) = observed
  phase_applied(~S,registered_world(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),"query-applied"),text ++ "queued\n" ++ before,retained)
def captured(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,RQ.Row<S,List<&2,U32>>>,text:String) -> String:
  (world,retained) = observed
  phase_queued(~S,registered_world(~S,O.commit(~S,queue(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),link(~S),3,2),X.Success{}),"query-queued"),"initial\n" ++ text,retained)
def lifetime(~S:Data,observed:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (world,text) = observed
  captured(~S,RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~spec_optional(~S),~component_selected(~S),~read_body(~S),world),text)
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: lifetime(~S,registered_world(~S,seeded(~S,O.spawn(~S,5n,world)),"query-initial"))
    case _: "CREATE_REJECTED"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
