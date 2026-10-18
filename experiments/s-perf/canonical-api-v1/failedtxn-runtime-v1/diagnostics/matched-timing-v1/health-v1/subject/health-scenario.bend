import Base
import ../method.bend as Method
import health-stream.bend as Stream
import /tmp/bendvy-failedtxn-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-registration.bend as Reg
import health-local.bend as L
import health-reader.bend as Reader
import health-publications.bend as Publications
import health-dispose.bend as Dispose
import health-systems.bend as S
import health-schedule.bend as Schedule
import health-program.bend as Program
import health-boundary.bend as Boundary
import health-render.bend as Render
import health-owner-observe.bend as Owners
import health-reader-owner-observe.bend as RO
import health-runtime-observe.bend as RT
import health-observe.bend as O
import health-family.bend as Family
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/transaction.bend as Tx
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/system.bend as Sys
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/ordinary-declaration.bend as Identity
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/event-family-routing.bend as Route

def text(~A:Type,observed:A & String) -> String:
  match observed:
    case (_,value):value
def status(value:Program.Status) -> String:
  match value:
    case Program.Complete{}:"Complete"
    case Program.Stopped{reason}:"Stopped{" ++ O.audit_effect(reason) ++ "}"
def state_view(value:Program.State & Program.Snapshot) -> Program.State & String:
  match value:
    case (Program.State{app,+namespace,+boundaries,+schedules,+result},Program.Snapshot{sw,so,ids}):(Program.State{app,namespace,boundaries,schedules,result},"namespace=" ++ U32.show(namespace) ++ ";ids=" ++ List.show(&2,U32,U32.show,ids) ++ ";world={" ++ sw ++ "};owners={" ++ so ++ "};boundaries=" ++ List.show(&2,Boundary.Boundary,Boundary.render,boundaries) ++ ";schedules=" ++ List.show(&2,String,O.audit_effect,schedules) ++ ";status=" ++ status(result))
def state(value:Program.State) -> Program.State & String:state_view(Program.observe(value))
type Prepared is Type:
  Prepared{prefix:String,state:Program.State}
  PreparationFailed{report:List<&2,String>}
def primed(prefix:String,iterations:U32,value:Program.State & String) -> Prepared:
  match value:
    case (owner,snapshot):Prepared{prefix ++ "primed={" ++ snapshot ++ "}\n",owner}
def registered(prefix:String,iterations:U32,value:Program.State & String) -> Prepared:
  match value:
    case (owner,snapshot):primed(prefix ++ "registered={" ++ snapshot ++ "}\n",iterations,state(Program.run_phase(0,owner)))
def named(method:Method.State,prefix:String,iterations:U32,owners:Reg.Owners,dispose:Dispose.Registry(),first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,ns):registered(prefix,iterations,state(Program.start(world,S.Owners{owners,dispose,S.Frame{first,second,0,0,None{},None{},[],[],method}},ns)))
def dispose_registered(method:Method.State,prefix:String,iterations:U32,owners:Reg.Owners,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Sys.RegistrationResult<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Dispose.Output,Dispose.runner>) -> Prepared:
  match value:
    case Sys.Registered{world,registry}:named(method,prefix,iterations,owners,registry,first,second,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Sys.RegistrationFailed{world}:PreparationFailed{[prefix ++ "DisposeRegistrationFailed;world={" ++ text(~F.World(),O.world(world)) ++ "};owners={" ++ text(~Reg.Owners,Owners.registered(owners)) ++ "}\n"]}
def optional_instance(value:Maybe<&1,L.Instance()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~L.Instance(),Render.instance(owner)) ++ "}"
def optional_reader(value:Maybe<&1,Reader.Provider()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~Reader.Provider(),RO.provider(owner)) ++ "}"
def optional_publications(value:Maybe<&1,Publications.Provider()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~Publications.Provider(),RO.publications(owner)) ++ "}"
def optional_local(value:Maybe<&1,L.State>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~L.State,Render.local(owner)) ++ "}"
def setup(method:Method.State,prefix:String,iterations:U32,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Reg.Registration) -> Prepared:
  match value:
    case Reg.Ready{world,owners}:dispose_registered(method,prefix,iterations,owners,first,second,Sys.register(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,world,"FailedTxn/DisposeTransient",[Identity.key(~T.HealthSchema,~T.Vitals,F.main_identity()),Identity.key(~T.HealthSchema,~T.Armor,F.aux_identity()),Identity.key(~T.HealthSchema,~T.Tracked,F.flag_identity())]))
    case Reg.Stopped{context,stage,a,reader,pub,local}:PreparationFailed{[prefix ++ "RegistrationStopped{stage=" ++ U32.show(stage) ++ ";context={" ++ text(~Family.Context(),RT.context(context)) ++ "};a=" ++ optional_instance(a) ++ ";reader=" ++ optional_reader(reader) ++ ";publications=" ++ optional_publications(pub) ++ ";local=" ++ optional_local(local) ++ "}\n"]}
def targets(prefix:String,iterations:U32,world:F.World(),+reservations:List<&2,W.Reservation<T.HealthSchema>>) -> Prepared:
  match reservations:
    case W.Reserved{first} <> W.Reserved{second} <> _:setup(Method.start(reservations),prefix,iterations,first,second,Reg.run(world))
    case _:PreparationFailed{[prefix ++ "MissingSeedTargets;world={" ++ text(~F.World(),O.world(world)) ++ "}\n"]}
def seed_applied(prefix:String,iterations:U32,reservations:List<&2,W.Reservation<T.HealthSchema>>,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,snapshot):targets(prefix ++ "seedApplied={" ++ snapshot ++ "}\n",iterations,world,reservations)
def seed_pending(prefix:String,iterations:U32,reservations:List<&2,W.Reservation<T.HealthSchema>>,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,snapshot):seed_applied(prefix ++ "seedPending={" ++ snapshot ++ "}\n",iterations,reservations,O.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure(Unit)"
def seeded(prefix:String,iterations:U32,value:F.Seeded) -> Prepared:
  match value:
    case F.Seeded{world,+reservations,outcome}:seed_pending(prefix ++ "seedOutcome=" ++ seed_outcome(outcome) ++ ";reservations=" ++ List.show(&2,W.Reservation<T.HealthSchema>,O.reservation,reservations) ++ "\n",iterations,reservations,O.world(world))
def created(+count:U32,+iterations:U32,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,snapshot):seeded("count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ ";created={" ++ snapshot ++ "}\n",iterations,F.seed(count,world))
def prepare(count:U32,iterations:U32,world:F.World()) -> Prepared:created(count,iterations,O.world(world))
def completed(iterations:U32,value:Prepared) -> List<&2,String>:
  match value:
    case Prepared{prefix,state}:Stream.final(prefix,Program.loops(U32.to_nat(iterations),0,state))
    case PreparationFailed{report}:report
def program(count:U32,+iterations:U32,world:F.World()) -> List<&2,String>:completed(iterations,prepare(count,iterations,world))
