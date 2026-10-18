import Base
import health-stream.bend as Stream
import ../dense-runtime-v1/types.bend as T
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
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/event-family-routing.bend as Route

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
def primed(prefix:String,iterations:U32,value:Program.State & String) -> List<&2,String>:
  match value:
    case (owner,snapshot):Stream.final(prefix ++ "primed={" ++ snapshot ++ "}\n",Program.loops(U32.to_nat(iterations),0,owner))
def registered(prefix:String,iterations:U32,value:Program.State & String) -> List<&2,String>:
  match value:
    case (owner,snapshot):primed(prefix ++ "registered={" ++ snapshot ++ "}\n",iterations,state(Program.run_phase(0,owner)))
def named(prefix:String,iterations:U32,owners:Reg.Owners,dispose:Dispose.Registry(),first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,observed:F.World() & U32) -> List<&2,String>:
  match observed:
    case (world,ns):registered(prefix,iterations,state(Program.start(world,S.Owners{owners,dispose,S.Frame{first,second,0,0,None{},None{},[],[]}},ns)))
def dispose_registered(prefix:String,iterations:U32,owners:Reg.Owners,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Sys.RegistrationResult<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Dispose.Output,Dispose.runner>) -> List<&2,String>:
  match value:
    case Sys.Registered{world,registry}:named(prefix,iterations,owners,registry,first,second,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Sys.RegistrationFailed{world}:[prefix ++ "DisposeRegistrationFailed;world={" ++ text(~F.World(),O.world(world)) ++ "};owners={" ++ text(~Reg.Owners,Owners.registered(owners)) ++ "}\n"]
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
def setup(prefix:String,iterations:U32,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Reg.Registration) -> List<&2,String>:
  match value:
    case Reg.Ready{world,owners}:dispose_registered(prefix,iterations,owners,first,second,Sys.register(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,world,"FailedTxn/DisposeTransient",[Identity.key(~T.HealthSchema,~T.Vitals,F.main_identity()),Identity.key(~T.HealthSchema,~T.Armor,F.aux_identity()),Identity.key(~T.HealthSchema,~T.Tracked,F.flag_identity())]))
    case Reg.Stopped{context,stage,a,reader,pub,local}:[prefix ++ "RegistrationStopped{stage=" ++ U32.show(stage) ++ ";context={" ++ text(~Family.Context(),RT.context(context)) ++ "};a=" ++ optional_instance(a) ++ ";reader=" ++ optional_reader(reader) ++ ";publications=" ++ optional_publications(pub) ++ ";local=" ++ optional_local(local) ++ "}\n"]
def targets(prefix:String,iterations:U32,world:F.World(),reservations:List<&2,W.Reservation<T.HealthSchema>>) -> List<&2,String>:
  match reservations:
    case W.Reserved{first} <> W.Reserved{second} <> _:setup(prefix,iterations,first,second,Reg.run(world))
    case _:[prefix ++ "MissingSeedTargets;world={" ++ text(~F.World(),O.world(world)) ++ "}\n"]
def seed_applied(prefix:String,iterations:U32,reservations:List<&2,W.Reservation<T.HealthSchema>>,observed:F.World() & String) -> List<&2,String>:
  match observed:
    case (world,snapshot):targets(prefix ++ "seedApplied={" ++ snapshot ++ "}\n",iterations,world,reservations)
def seed_pending(prefix:String,iterations:U32,reservations:List<&2,W.Reservation<T.HealthSchema>>,observed:F.World() & String) -> List<&2,String>:
  match observed:
    case (world,snapshot):seed_applied(prefix ++ "seedPending={" ++ snapshot ++ "}\n",iterations,reservations,O.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure(Unit)"
def seeded(prefix:String,iterations:U32,value:F.Seeded) -> List<&2,String>:
  match value:
    case F.Seeded{world,+reservations,outcome}:seed_pending(prefix ++ "seedOutcome=" ++ seed_outcome(outcome) ++ ";reservations=" ++ List.show(&2,W.Reservation<T.HealthSchema>,O.reservation,reservations) ++ "\n",iterations,reservations,O.world(world))
def created(+count:U32,+iterations:U32,observed:F.World() & String) -> List<&2,String>:
  match observed:
    case (world,snapshot):seeded("count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ ";created={" ++ snapshot ++ "}\n",iterations,F.seed(count,world))
def program(count:U32,iterations:U32,world:F.World()) -> List<&2,String>:created(count,iterations,O.world(world))
