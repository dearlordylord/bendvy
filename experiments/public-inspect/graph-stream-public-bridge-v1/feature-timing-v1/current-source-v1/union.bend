import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/inspector-stream-frame.bend as F
import ../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/machine-stream.bend as St
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-query.bend as RQ
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/inspector-query-projection.bend as Q
import ../../../../../src/ecs/inspector-relation-projection.bend as RP
import ../../../../../src/ecs/inspector-failure-projection.bend as Fail
import ../../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/inspector-runtime.bend as IR
import ./state.bend as State
import ./declarations.bend as D
import ./render.bend as Render

def World(~S:Data) -> Type: W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
def Frame(~S:Data) -> Type: F.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32>
def Runtime(~S:Data) -> Type: Ev.Runtime<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
# IMPORT-ONLY prototype body is the candidate public inspector-runtime module;
# its canonical root dependencies preserve nominal identities during development.
def lift(~S:Data,~V:Data,~cap:Cap.ValueRead<I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,V>) -> Cap.ValueRead<Frame(~S),V>:
  IR.lift_world_read(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~V,~cap)

def flow_decl(~S:Data) -> MD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>: MD.declared(~S,~State.FlowToken,~U32,~State.Resources<S>,~State.flow(~S),"Flow",[4,7,8,9])
def level_decl(~S:Data) -> MD.Declaration<S,State.LevelToken,U32,State.Resources<S>,State.level(~S)>: MD.declared(~S,~State.LevelToken,~U32,~State.Resources<S>,~State.level(~S),"Level",[10,11,12])
def relation_spec(~S:Data) -> RQ.Spec<S>:
  RQ.Spec{[RQ.optional_relation(~S,"link",D.link(~S)),RQ.optional_related(~S,"linkedBy",D.link(~S)),RQ.optional_relation(~S,"parent",D.parent(~S)),RQ.optional_related(~S,"children",D.parent(~S))]}
def current(~S:Data,~Token:Data,view:M.CurrentView<S,Token,U32>) -> String:
  match view:
    case M.Unavailable{}:"null"
    case M.Current{value}:U32.show(value)
def transition(value:M.Transition<U32>) -> String:
  match value:
    case M.Transition{from,to}:"{\"from\":" ++ U32.show(from) ++ ",\"to\":" ++ U32.show(to) ++ "}"
    case M.Initial{to}:"{\"from\":null,\"to\":" ++ U32.show(to) ++ "}"
def transitions(values:List<&2,M.Transition<U32>>) -> List<&2,String>:
  match values:
    case []:[]
    case value <> rest:transition(value) <> transitions(rest)
def reading(value:Ev.Reading<M.Transition<U32>>) -> String & String:
  match value:
    case Ev.Reading{values,lagged}:(Render.array(transitions(values)),Render.boolean(lagged))
# Every failure field is mapped; descriptor-only numeric tokens stay in the
# separate physical diagnostic, while shared names/kind/flags are retained.
def error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"{\"kind\":\"MissingEntity\",\"entity\":" ++ U32.show(source) ++ "}"
    case G.MissingTargetEntity{source,target,relation}:"{\"kind\":\"MissingTargetEntity\",\"entity\":" ++ U32.show(source) ++ ",\"target\":" ++ U32.show(target) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.SelfRelationNotAllowed{source,relation}:"{\"kind\":\"SelfRelationNotAllowed\",\"entity\":" ++ U32.show(source) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.HierarchyCycle{source,target,relation}:"{\"kind\":\"HierarchyCycle\",\"entity\":" ++ U32.show(source) ++ ",\"target\":" ++ U32.show(target) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.MissingChildEntity{source,child,relation}:"{\"kind\":\"MissingChildEntity\",\"entity\":" ++ U32.show(source) ++ ",\"child\":" ++ U32.show(child) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.DuplicateChild{source,child,relation}:"{\"kind\":\"DuplicateChild\",\"entity\":" ++ U32.show(source) ++ ",\"child\":" ++ U32.show(child) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.ChildNotRelatedToParent{source,child,relation}:"{\"kind\":\"ChildNotRelatedToParent\",\"entity\":" ++ U32.show(source) ++ ",\"child\":" ++ U32.show(child) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
    case G.ChildSetMismatch{source,relation}:"{\"kind\":\"ChildSetMismatch\",\"entity\":" ++ U32.show(source) ++ ",\"relation\":" ++ Render.quoted(relation) ++ "}"
def kind(value:G.RelationKind) -> String & String & String:
  match value:
    case G.Ordinary{}:("relation",("false","false"))
    case G.Hierarchy{}:("hierarchy",("true","true"))
def failure_fields(~S:Data,name:String,inverse:String,operation:String,source:U32,target:U32,err:G.Error,flags:String & String & String) -> String:
  (tag,(linked,ordered))=flags
  "{\"relation\":" ++ Render.quoted(name) ++ ",\"related\":" ++ Render.quoted(inverse) ++ ",\"kind\":" ++ Render.quoted(tag) ++ ",\"linked\":" ++ linked ++ ",\"allowSelf\":false,\"ordered\":" ++ ordered ++ ",\"operation\":" ++ Render.quoted(operation) ++ ",\"source\":" ++ U32.show(source) ++ ",\"target\":" ++ U32.show(target) ++ ",\"error\":" ++ error(err) ++ "}"
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"relate"
    case G.ReorderChildren{}:"reorderChildren"
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{G.Descriptor{_,name,inverse,tag},op,source,target,err}:failure_fields(~S,name,inverse,operation(op),source,target,err,kind(tag))
def failures(~S:Data,values:List<&2,G.Failure<S>>) -> List<&2,String>:
  match values:
    case []:[]
    case value <> rest:failure(~S,value) <> failures(~S,rest)
def parent_reading(~S:Data,value:Ev.Reading<A.Notice<S,U32>>) -> String & String:
  match value:
    case Ev.Reading{values,lagged}:(Render.array(failures(~S,Fail.failures(~S,~U32,D.parent(~S),values))),Render.boolean(lagged))

def resource_streams(~S:Data,resources:State.Resources<S>) -> State.Resources<S> & Q.Product<St.Stream<U32>,St.Stream<U32>>:
  match resources:
    case State.Resources{owned,siblingOwned,flow,level,ran,+flowStream,+levelStream}:(State.Resources{owned,siblingOwned,flow,level,ran,flowStream,levelStream},Q.Product{flowStream,levelStream})
def stream_fields(flow:String & String,level:String & String,parent:String & String) -> String:
  (flowValues,flowLagged)=flow
  (levelValues,levelLagged)=level
  (parentValues,parentLagged)=parent
  "\"flowTransitions\":" ++ flowValues ++ ",\"levelTransitions\":" ++ levelValues ++ ",\"flowLagged\":" ++ flowLagged ++ ",\"levelLagged\":" ++ levelLagged ++ ",\"parentFailures\":" ++ parentValues ++ ",\"parentLagged\":" ++ parentLagged
# ID zero is an unregistered fresh-view context, never passed to activate,
# complete, skip or registered run. Transition registration uses World.clock;
# Parent event registration uses its actual Event Runtime.tick domain.
def streams_returned(~S:Data,+tick:Nat,observed:Frame(~S) & Q.Product<St.Stream<U32>,St.Stream<U32>>) -> Frame(~S) & String:
  match observed:
    case (F.Frame{Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+rtTick,+frameStart,+boundary,+capacity,+dropped},cursor},Q.Product{flow,level}):
      (F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,rtTick,frameStart,boundary,capacity,dropped},cursor},stream_fields(reading(St.observe(~U32,flow,0,tick)),reading(St.observe(~U32,level,0,tick)),parent_reading(~S,Ev.reading(~A.Notice<S,U32>,Ev.Position{0,0n,rtTick},batches,dropped))))
def streams_clocked(~S:Data,tick:U32,frame:Frame(~S)) -> Frame(~S) & String:
  streams_returned(~S,U32.to_nat(tick),Cap.value_read(~Frame(~S),~Q.Product<St.Stream<U32>,St.Stream<U32>>,~lift(~S,~Q.Product<St.Stream<U32>,St.Stream<U32>>,~I.read_resource(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Q.Product<St.Stream<U32>,St.Stream<U32>>,~resource_streams(~S))),frame))
def clock_returned(~S:Data,cursor:U32,clocked:World(~S) & U32) -> I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & U32:
  (world,tick)=clocked
  (I.Frame{world,cursor},tick)
def world_clock(~S:Data,frame:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & U32:
  match frame:
    case I.Frame{world,cursor}:clock_returned(~S,cursor,W.clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
def streams_at_clock(~S:Data,observed:Frame(~S) & U32) -> Frame(~S) & String:
  (frame,tick)=observed
  streams_clocked(~S,tick,frame)
def streams(~S:Data,frame:Frame(~S)) -> Frame(~S) & String:
  streams_at_clock(~S,Cap.value_read(~Frame(~S),~U32,~lift(~S,~U32,~Cap.ValueRead{world_clock(~S)}),frame))
def union_finished(~S:Data,flow:M.CurrentView<S,State.FlowToken,U32>,level:M.CurrentView<S,State.LevelToken,U32>,rows:List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,observed:Frame(~S) & String) -> Frame(~S) & String:
  (frame,streamText)=observed
  (frame,"{\"flow\":" ++ current(~S,~State.FlowToken,flow) ++ ",\"level\":" ++ current(~S,~State.LevelToken,level) ++ "," ++ streamText ++ ",\"rows\":" ++ Render.row_array(~S,rows) ++ "}")
def union_rows(~S:Data,flow:M.CurrentView<S,State.FlowToken,U32>,level:M.CurrentView<S,State.LevelToken,U32>,observed:Frame(~S) & List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>) -> Frame(~S) & String:
  (frame,rows)=observed
  union_finished(~S,flow,level,rows,streams(~S,frame))
# Composed query grant is lifted with its original get/each closures; all
# selected rows/cells are retained, with no count-only result or sorting.
def world_relation_rows(~S:Data,frame:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>:
  IQ.each_composed(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~RP.grant(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~relation_spec(~S)),frame)
def relation_rows(~S:Data,frame:Frame(~S)) -> Frame(~S) & List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>:
  Cap.value_read(~Frame(~S),~List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,~lift(~S,~List<&2,IQ.ProjectedRow<S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>>,~Cap.ValueRead{world_relation_rows(~S)}),frame)
def union_level(~S:Data,flow:M.CurrentView<S,State.FlowToken,U32>,observed:Frame(~S) & M.CurrentView<S,State.LevelToken,U32>) -> Frame(~S) & String:
  (frame,level)=observed
  union_rows(~S,flow,level,relation_rows(~S,frame))
def union_flow(~S:Data,observed:Frame(~S) & M.CurrentView<S,State.FlowToken,U32>) -> Frame(~S) & String:
  (frame,flow)=observed
  union_level(~S,flow,Cap.value_read(~Frame(~S),~M.CurrentView<S,State.LevelToken,U32>,~lift(~S,~M.CurrentView<S,State.LevelToken,U32>,~MD.inspect(~S,~State.LevelToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.level(~S),~level_decl(~S))),frame))
def get(~S:Data,frame:Frame(~S)) -> Frame(~S) & String:
  union_flow(~S,Cap.value_read(~Frame(~S),~M.CurrentView<S,State.FlowToken,U32>,~lift(~S,~M.CurrentView<S,State.FlowToken,U32>,~MD.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~flow_decl(~S))),frame))
def grant(~S:Data) -> Cap.ValueRead<Frame(~S),String>: Cap.ValueRead{get(~S)}
def body_result(~H:Type,observed:H & String) -> H & Result<&2,&2,Unit,String>:
  (owner,value)=observed
  (owner,Done{value})
def body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,String>,_:Unit,owner:H) -> H & Result<&2,&2,Unit,String>:
  body_result(~H,Cap.value_read(~H,~String,~cap,owner))
def plan(~S:Data) -> IR.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32,H => Cap.ValueRead<H,String>>:
  IR.Plan{grant(~S)}
def run(~S:Data,runtime:Runtime(~S)) -> IR.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32,Unit,String>:
  IR.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~(H => Cap.ValueRead<H,String>),~Unit,~Unit,~String,~plan(~S),~body(~S),I.Fresh{},Unit{},runtime)
