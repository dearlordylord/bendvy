import Base
import ../../src/ecs/query-contract.bend as QC
import ../../src/ecs/world.bend as W
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/component.bend as C
import ../../src/ecs/lifecycle.bend as L
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/declarations.bend as D
import ../../examples/query-composition/gameplay.bend as G
import ../../examples/query-composition/scenario-ops.bend as Ops
import ../../examples/query-composition/observe.bend as O
import ../../examples/query-composition/json.bend as J

type Grants<-H: Type> is Type:
  Grants{work: G.WorkOps(H),remove: Cap.Action<H>,event: Cap.Send<H,Unit>}
def work(~H: Type,caps: Grants<H>) -> G.WorkOps(H):
  match caps:
    case Grants{work,_,_}: work
def remove(~H: Type,caps: Grants<H>) -> Cap.Action<H>:
  match caps:
    case Grants{_,remove,_}: remove
def event(~H: Type,caps: Grants<H>) -> Cap.Send<H,Unit>:
  match caps:
    case Grants{_,_,event}: event
def completed(~H: Type,~caps: Grants<H>,observed: H & (T.Outcome<G.Error> & Unit)) -> H & (T.Outcome<G.Error> & Unit):
  (ctx,result) = observed
  (Cap.action(~H,~remove(~H,caps),Cap.send(~H,~Unit,~event(~H,caps),ctx,Unit{})),result)
def body(~H: Type,~caps: Grants<H>,args: Unit,ctx: H) -> H & (T.Outcome<G.Error> & Unit):
  completed(~H,~caps,G.work_body(~H,~work(~H,caps),args,ctx))
def GrantsOps(H: Type) -> Type:
  Grants<H>
def plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,GrantsOps>:
  Q.Plan{Grants{D.work_caps(),Q.command_despawn(~S.Schema,~S.Store,~Unit,~Unit,~S.clear),Q.event_write(~S.Schema,~S.Store,~Unit,~Unit)},D.work_match}
def length_join(command: S.World() -> S.World(),observed: List<(S.World() -> S.World())> & U32) -> List<(S.World() -> S.World())> & U32:
  (commands,n) = observed
  (command <> commands,(n + 1 : U32))
def length(commands: List<(S.World() -> S.World())>) -> List<(S.World() -> S.World())> & U32:
  match commands:
    case []: ([],0)
    case command <> rest: length_join(command,length(rest))
def metadata_join(+ns: U32,+next: U32,+high: U32,live: Array<Bool>,+capacity: U32,+depth: Nat,store: S.Store,resource: Unit,+events: List<&2,Unit>,+regs: List<&2,W.RegistrationMeta>,+nextSystem: U32,+clock: U32,observed: List<(S.World() -> S.World())> & U32) -> S.World() & String:
  (pending,count) = observed
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,nextSystem,clock},U32.show(clock) ++ ":" ++ U32.show(count) ++ ":" ++ Nat.show(List.length(&2,Unit,events)) ++ ":" ++ U32.show(next) ++ ":" ++ U32.show(nextSystem))
def metadata_base(world: S.World()) -> S.World() & String:
  match world:
    case W.World{+ns,+next,+high,live,+capacity,+depth,store,resource,+events,pending,+regs,+nextSystem,+clock}: metadata_join(ns,next,high,live,capacity,depth,store,resource,events,regs,nextSystem,clock,length(pending))
def stamped_join(before: String,observed: S.World() & L.Stamp) -> S.World() & String:
  match observed:
    case (world,L.Stamp{added,changed}): (world,before ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
def stamped_named(before: String,observed: S.World() & U32) -> S.World() & String:
  (world,ns) = observed
  stamped_join(before,C.lifecycle(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),world,W.Handle{ns,1}))
def stamped(observed: S.World() & String) -> S.World() & String:
  (world,before) = observed
  stamped_named(before,W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def metadata(world: S.World()) -> S.World() & String:
  stamped(metadata_base(world))
def compare(before: String,observed: S.World() & String) -> S.World() & Bool:
  (world,after) = observed
  (world,String.eq(before,after))
def failed(before: String,observed: QC.Executed<S.World(),G.Error,Unit>) -> S.World() & Bool:
  match observed:
    case QC.Executed{world,Fail{QC.MultipleEntities{2}}}: compare(before,metadata(world))
    case QC.Executed{world,_}: (world,False{})
def check(observed: S.World() & String) -> S.World() & Bool:
  (world,before) = observed
  failed(before,QC.single(~S.Schema,~S.Store,~Unit,~Unit,~GrantsOps,~plan(),~Unit,~G.Error,~Unit,~body,Unit{},world,17))
def lookup_tag(expected: Bool,before: String,world: S.World()) -> S.World() & Bool:
  match expected:
    case False{}: (world,False{})
    case True{}: compare(before,metadata(world))
def lookup_failed(+id: U32,before: String,observed: QC.Executed<S.World(),G.Error,Unit>) -> S.World() & Bool:
  match observed:
    case QC.Executed{world,Fail{QC.QueryMismatch{4}}}: lookup_tag(U32.is_eq(id,4),before,world)
    case QC.Executed{world,Fail{QC.MissingEntity{99}}}: lookup_tag(U32.is_eq(id,99),before,world)
    case QC.Executed{world,_}: (world,False{})
def lookup_named(+id: U32,before: String,observed: S.World() & U32) -> S.World() & Bool:
  (world,ns) = observed
  lookup_failed(id,before,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~GrantsOps,~plan(),~Unit,~G.Error,~Unit,~body,Unit{},world,W.Handle{ns,id},17))
def lookup_before(id: U32,observed: S.World() & String) -> S.World() & Bool:
  (world,before) = observed
  lookup_named(id,before,W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def lookup_attempt(id: U32,observed: S.World() & Bool) -> S.World() & Bool:
  match observed:
    case (world,False{}): (world,False{})
    case (world,True{}): lookup_before(id,metadata(world))
def final(observed: S.World() & List<&2,String>) -> String:
  (_,rows) = observed
  J.array(rows)
def shown(observed: S.World() & Bool) -> String:
  match observed:
    case (world,True{}): final(O.all(W.barrier(~S.Schema,~S.Store,~Unit,~Unit,world)))
    case (_,False{}): "null"
def created(creation: W.Creation<S.Schema,S.Store,Unit,Unit>) -> String:
  match creation:
    case W.Created{_,world}: shown(lookup_attempt(99,lookup_attempt(4,check(metadata(Ops.insert(W.barrier(~S.Schema,~S.Store,~Unit,~Unit,Ops.seed(world))))))))
    case W.CreateRejected{_,_}: "null"
def main() -> IO(Unit):
  IO.print(created(S.create(W.factory())))
