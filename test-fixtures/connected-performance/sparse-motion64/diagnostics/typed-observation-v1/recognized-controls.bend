import Base
import ../../../../../src/ecs/internal/compact-operational-frame.bend as Compact
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/owner-product.bend as Product
import ../../../../../src/ecs/commands.bend as Cmd
import ../../../../../src/ecs/entity-key.bend as Key
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-logical.bend as Logical
import ../../../../../src/ecs/inspector.bend as Inspector
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion.bend as M
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as S
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as Payload
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-driver.bend as Driver
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-observe.bend as Dump
import ../../../../../src/ecs/recognized-query-declaration.bend as N
import ../../../../../src/ecs/recognized-system.bend as Run
import ../../../../../src/ecs/recognized-app-component.bend as App
import ../../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../src/ecs/ordinary-query-observable.bend as O
import ../../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../src/ecs/compose.bend as Q
import ../../../../../src/ecs/component.bend as C
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/entity-allocator.bend as A
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/trace-facts.bend as Facts
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/string-equality.bend as Eq

def created(result:W.Creation<S.MotionSchema,M.Store(),M.Resources(),Nat>) -> M.World():
  match result:
    case W.Created{_,world}:world
    case W.CreateRejected{_,resource}:W.World{0,A.empty(),M.empty(Unit{}),resource,[],[],[],1,0}
def seeded(result:M.Seeded) -> M.World():
  match result:
    case M.Seeded{world,_,_}:W.barrier(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,world)
def world() -> M.World():seeded(M.seed(8,created(W.create(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.empty,W.factory(),M.initial_resources()))))
def text_world(prefix:String,observed:M.World() & String) -> String:
  match observed:
    case (_,text):prefix ++ ":" ++ text
def error_text(error:Q.Error<Unit>) -> String:
  match error:
    case Q.UserError{_}:"UserError(Unit)"
    case Q.AccessError{reason}:"AccessError(" ++ Dump.error(reason) ++ ")"
def output(result:Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>) -> String:
  match result:
    case Sys.Succeeded{world,values}:text_world("ok:" ++ List.show(&2,U32,U32.show,values),Dump.world(world))
    case Sys.Failed{world,error}:text_world("failed:" ++ error_text(error),Dump.world(world))
def legacy(~query:N.Declaration<S.MotionSchema,M.Store(),M.Resources(),Nat,M.Ops>,~body:@-H:Type -> @-caps:M.Ops(H) -> Unit -> H -> H & (T.Outcome<Unit> & U32)) -> Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>:
  Ordinary.completed(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Unit,~U32,Q.each(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~Ordinary.plan_parts(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,N.ordinary(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,query)),~body,Unit{},world()))
def compact(~query:N.Declaration<S.MotionSchema,M.Store(),M.Resources(),Nat,M.Ops>,~body:@-H:Type -> @-caps:M.Ops(H) -> Unit -> H -> H & (T.Outcome<Unit> & U32)) -> Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>:
  Run.runner(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~query,~body,world(),(Unit{},0))
def compared(expected:Bool,left:Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>,right:Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>) -> Bool:
  match expected left right:
    case True{} Sys.Succeeded{wa,va} Sys.Succeeded{wb,vb}:Eq.equal(output(Sys.Succeeded{wa,va}),output(Sys.Succeeded{wb,vb}))
    case False{} Sys.Failed{wa,Q.UserError{Unit{}}} Sys.Failed{wb,Q.UserError{Unit{}}}:Eq.equal(output(Sys.Failed{wa,Q.UserError{Unit{}}}),output(Sys.Failed{wb,Q.UserError{Unit{}}}))
    case _ _ _:False{}
def compare(~query:N.Declaration<S.MotionSchema,M.Store(),M.Resources(),Nat,M.Ops>,~body:@-H:Type -> @-caps:M.Ops(H) -> Unit -> H -> H & (T.Outcome<Unit> & U32),expected:Bool) -> Bool:
  compared(expected,legacy(~query,~body),compact(~query,~body))
def failed(~H:Type,observed:H & (T.Outcome<Unit> & U32)) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (owner,(_,value)):(owner,(T.Failure{Unit{}},value))
def fail_body(~H:Type,~caps:M.Ops(H),args:Unit,owner:H) -> H & (T.Outcome<Unit> & U32):failed(~H,M.body(~H,~caps,args,owner))
def mutated(observed:S.Position & S.PositionView) -> S.Position & S.PositionView:
  match observed:
    case (S.Position{values,frame},view):(S.Position{values,U32.add(frame,1)},view)
def mutate(value:S.Position) -> S.Position & S.PositionView:mutated(Payload.position_get(value))
def mut_binding() -> Binding.Binding<S.MotionSchema,M.Store(),M.Rest(),S.Position,S.PositionView,S.PositionToken,M.take_main,M.put_main,mutate>:Binding.bind(~S.MotionSchema,~M.Store(),~M.Rest(),~S.Position,~S.PositionView,~S.PositionToken,~M.take_main,~M.put_main,~mutate,M.main_identity())
def mut_query() -> N.Declaration<S.MotionSchema,M.Store(),M.Resources(),Nat,M.Ops>:
  N.pair(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~(H=>Cap.Write<H,S.Position,S.PositionView>),~(H=>Cap.ValueWrite<H,S.MotionLedger,S.LedgerView>),~N.write(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Rest(),~S.Position,~S.PositionView,~S.PositionToken,~M.take_main,~M.put_main,~mutate,~mut_binding()),~N.resource_write(~S.MotionSchema,~M.Store(),~S.MotionLedger,~Unit,~Nat,~S.LedgerView,~M.ledger_identity(),~Payload.motion_ledger_get))
# Deliberately wrong supplied operational grant: same Ops type, zero selected
# rows and different metadata. The app must use it for inspection only.
def never(frame:Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>) -> Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat> & Bool:(frame,False{})
def wrong() -> Decl.Declaration<S.MotionSchema,Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>,M.Ops(Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>)>:
  Decl.Declaration{Decl.grant(~S.MotionSchema,~Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>,~M.Ops(Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>),M.declaration()),never,[Decl.Clause{"WRONG",Decl.Read{}}]}
def IFrame() -> Type:Inspector.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>
def Value() -> Data:Logical.Value()
def mismatch() -> O.Declaration<S.MotionSchema,Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>,M.Ops(Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>),IFrame(),Value()>:
  O.Declaration{_=>wrong(),_=>O.inspection(~S.MotionSchema,~Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>,~M.Ops(Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>),~IFrame(),~Value(),Driver.query())}

def Registry() -> Type:Sys.Registry<S.MotionSchema,M.Store(),M.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Run.runner(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~M.recognized(),~M.body)>
def metadata(clauses:List<&2,Decl.Clause<S.MotionSchema>>) -> Bool:
  match clauses:
    case Decl.Clause{a,Decl.Write{}} <> Decl.Clause{b,Decl.Write{}} <> []:Bool.and(Eq.equal(a,"Position"),Eq.equal(b,"MotionLedger"))
    case _:False{}
def rendered_run(result:Sys.RunResult<S.MotionSchema,M.Store(),M.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Run.runner(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~M.recognized(),~M.body)> & Facts.State) -> Bool & String:
  match result:
    case (Sys.Completed{Sys.Registry{+ns,+id,+name,+access,+cursor},Sys.Succeeded{world,+values}},_):(Bool.and(Nat.is_eq(List.length(&2,U32,values),1n),Bool.and(U32.is_gt(cursor,0),Bool.and(Eq.equal(name,"Control"),Eq.access_equal(access,["Position","MotionLedger"])))),U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ U32.show(cursor) ++ ":" ++ output(Sys.Succeeded{world,values}))
    case _: (False{},"unexpected-registration-or-run-outcome")
def metadata_run(valid:Bool,slot:String,clauses:List<&2,Decl.Clause<S.MotionSchema>>,result:Bool & String) -> Bool & String:
  match result:
    case (ok,text):(Bool.and(valid,ok),slot ++ ":" ++ List.show(&2,Decl.Clause<S.MotionSchema>,Dump.clause,clauses) ++ ":" ++ text)
def registered(trace:Facts.State,result:Ordinary.Defined<S.MotionSchema,M.World(),Registry()>) -> Bool & String:
  match result:
    case Ordinary.Rejected{_}:(False{},"define-rejected")
    case Ordinary.Defined{world,Ordinary.Owner{registry,+slot,+clauses}}:metadata_run(Bool.and(Eq.equal(slot,"slot"),metadata(clauses)),slot,clauses,rendered_run(Sys.run_observed(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~(Unit & U32),~Q.Error<Unit>,~List<&2,U32>,~Run.runner(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~M.recognized(),~M.body),~App.observed(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~Value(),~mismatch(),~M.recognized(),~M.body),registry,trace,world,(Unit{},0))))
def authority(trace:Facts.State) -> Bool & String:registered(trace,Run.define(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Ops,~Unit,~Unit,~U32,~M.recognized(),~M.body,world(),"Control","slot"))
def authority_equal(left:Bool & String,right:Bool & String) -> Bool:
  match left right:
    case Tuple{a,x} Tuple{b,y}:Bool.and(a,Bool.and(b,Eq.equal(x,y)))
# Both canonical grants deliberately address the same affine column.
def Two(H:Type) -> Type:Cap.Write<H,S.Position,S.PositionView> & Cap.Write<H,S.Position,S.PositionView>
def two_first(~H:Type,caps:Two(H)) -> Cap.Write<H,S.Position,S.PositionView>:
  match caps:
    case (a,_):a
def two_second(~H:Type,caps:Two(H)) -> Cap.Write<H,S.Position,S.PositionView>:
  match caps:
    case (_,b):b
def first_view(value:S.PositionView) -> U32:
  match value:
    case S.PositionView{coordinates,_}:M.first(coordinates)
def overlap_final(~H:Type,first:U32,observed:H & C.Access<S.PositionView>) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (owner,C.Found{view}):(owner,(T.Success{},U32.add(U32.mul(first,10),first_view(view))))
    case (owner,_):(owner,(T.Failure{Unit{}},0))
def overlap_second(~H:Type,~caps:Two(H),observed:H & C.Access<S.PositionView>) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (owner,C.Found{+view}):overlap_final(~H,first_view(view),Cap.get(~H,~S.Position,~S.PositionView,~two_first(~H,caps),Cap.set(~H,~S.Position,~S.PositionView,~two_second(~H,caps),owner,M.increment_main(view))))
    case (owner,_):(owner,(T.Failure{Unit{}},0))
def overlap_first(~H:Type,~caps:Two(H),observed:H & C.Access<S.PositionView>) -> H & (T.Outcome<Unit> & U32):
  match observed:
    case (owner,C.Found{view}):overlap_second(~H,~caps,Cap.get(~H,~S.Position,~S.PositionView,~two_second(~H,caps),Cap.set(~H,~S.Position,~S.PositionView,~two_first(~H,caps),owner,M.increment_main(view))))
    case (owner,_):(owner,(T.Failure{Unit{}},0))
def overlap_body(~H:Type,~caps:Two(H),_:Unit,owner:H) -> H & (T.Outcome<Unit> & U32):overlap_first(~H,~caps,Cap.get(~H,~S.Position,~S.PositionView,~two_first(~H,caps),owner))
def overlap_query() -> N.Declaration<S.MotionSchema,M.Store(),M.Resources(),Nat,Two>:
  N.pair(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~(H=>Cap.Write<H,S.Position,S.PositionView>),~(H=>Cap.Write<H,S.Position,S.PositionView>),~N.write(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Rest(),~S.Position,~S.PositionView,~S.PositionToken,~M.take_main,~M.put_main,~Payload.position_get,~M.main_binding()),~N.write(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Rest(),~S.Position,~S.PositionView,~S.PositionToken,~M.take_main,~M.put_main,~Payload.position_get,~M.main_binding()))
def overlap_result(left:Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>,right:Sys.Outcome<M.World(),Q.Error<Unit>,List<&2,U32>>) -> Bool:
  match left right:
    case Sys.Succeeded{wa,12 <> []} Sys.Succeeded{wb,12 <> []}:Eq.equal(output(Sys.Succeeded{wa,[12]}),output(Sys.Succeeded{wb,[12]}))
    case _ _:False{}
def overlap() -> Bool:
  overlap_result(Ordinary.completed(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Unit,~U32,Q.each(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Two,~Unit,~Unit,~U32,~Ordinary.plan_parts(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Two,N.ordinary(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Two,overlap_query())),~overlap_body,Unit{},world())),Run.runner(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~Two,~Unit,~Unit,~U32,~overlap_query(),~overlap_body,world(),(Unit{},0)))
# Direct helper-boundary controls: canonical read/write/resource gameplay cannot
# invalidate its allocator. Handles below come from actual created/seeded worlds.
def cleared(~P:Type,result:Col.SwapOutcome<S.MotionSchema,P>) -> Col.Column<S.MotionSchema,P>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def clear_store(+id:U32,store:M.Store()) -> M.Store():
  match store:
    case Product.Owner{main,Product.Owner{aux,flag}}:Product.Owner{cleared(~S.Position,Col.clear(~S.MotionSchema,~S.Position,main,id)),Product.Owner{cleared(~S.Velocity,Col.clear(~S.MotionSchema,~S.Velocity,aux,id)),cleared(~S.Selected,Col.clear(~S.MotionSchema,~S.Selected,flag,id))}}
def clear(store:M.Store(),handle:W.Handle<S.MotionSchema>) -> M.Store():clear_store(W.handle_index(~S.MotionSchema,handle),store)
def same_world(before:String,observed:M.World() & String) -> Bool:
  match observed:
    case (_,after):Eq.equal(before,after)
def missing_world(before:String,frame:Q.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat>) -> Bool:
  match frame:
    case Q.Frame{T.Tx{world,_,_,_,_},_,_,_}:same_world(before,Dump.world(world))
def missing_after(before:String,observed:Compact.Frame<S.MotionSchema,M.Store(),M.Resources(),Nat> & C.Access<S.PositionView>) -> Bool:
  match observed:
    case (frame,C.MissingEntity{}):missing_world(before,Compact.restore(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,frame))
    case _:False{}
def missing_before(handle:W.Handle<S.MotionSchema>,observed:M.World() & String) -> Bool:
  match observed:
    case (world,before):missing_after(before,Compact.read(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.Rest(),~S.Position,~S.PositionView,~M.take_main,~M.put_main,~Payload.position_get,Compact.extract(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,Q.Frame{T.begin(~M.World(),~Nat,world),handle,None{},0})))
def stale_handles(observed:M.World() & List<&2,W.Handle<S.MotionSchema>>) -> Bool:
  match observed:
    case (world,+handle <> _):missing_before(handle,Dump.world(Cmd.despawn_apply_with(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~clear,world,handle)))
    case _:False{}
def stale() -> Bool:stale_handles(W.handles(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,world()))
def foreign_handles(observed:M.World() & List<&2,W.Handle<S.MotionSchema>>) -> Bool:
  match observed:
    case (_,handle <> _):missing_before(handle,Dump.world(world()))
    case _:False{}
def foreign() -> Bool:foreign_handles(W.handles(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,seeded(M.seed(8,created(W.create(~S.MotionSchema,~M.Store(),~M.Resources(),~Nat,~M.empty,W.Factory{2},M.initial_resources()))))))
def check() -> Bool:
  Bool.and(Bool.and(stale(),foreign()),Bool.and(overlap(),Bool.and(compare(~M.recognized(),~M.body,True{}),Bool.and(compare(~M.recognized(),~fail_body,False{}),Bool.and(compare(~mut_query(),~M.body,True{}),Bool.and(compare(~mut_query(),~fail_body,False{}),authority_equal(authority(Facts.Off{}),authority(Facts.On{[]}))))))))
def render(ok:Bool) -> String:
  match ok:
    case True{}:"recognized:ok"
    case False{}:"recognized:FAIL"
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(render(check()))
