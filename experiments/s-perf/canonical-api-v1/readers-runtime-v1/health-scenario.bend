import Base
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-domain.bend as D
import health-systems.bend as S
import health-registration.bend as Registration
import health-program.bend as Program
import health-render.bend as Render
import health-observe.bend as O
import health-reader-observe.bend as RO
import health-reader.bend as Reader
import health-parameters.bend as P
import health-family.bend as Family
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/reader-parameter.bend as RP

def after_logical(prefix:String,world:F.World() & String) -> String:
  match world:
    case (_,text):prefix ++ ";afterLogicalWorld={" ++ text ++ "}
"
def logical(prefix:String,world:F.World() & String) -> String:
  match world:
    case (world,rows):after_logical(prefix ++ ";finalLogicalRows=" ++ rows,O.world(world))
def final_state(prefix:String,observed:Program.State & String) -> String:
  match observed:
    case (state,text):logical(prefix ++ "final={" ++ text ++ "}",O.rows(Program.finish_world(state)))
def initial_state(prefix:String,iterations:U32,observed:Program.State & String) -> String:
  match observed:
    case (state,text):final_state(prefix ++ "seededRegistered={" ++ text ++ "}
",Render.state(Program.drain(Program.loops(U32.to_nat(iterations),Program.phase(1,Program.prime(state))))))
def initial_named(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> String:
  match observed:
    case (world,namespace):initial_state(prefix,iterations,Render.state(Program.start(world,owners,namespace)))
def seed_applied(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> String:
  match observed:
    case (world,text):initial_named(prefix ++ "seedApplied={" ++ text ++ "}
",iterations,owners,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def seed_pending(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> String:
  match observed:
    case (world,text):seed_applied(prefix ++ "seedPending={" ++ text ++ "}
",iterations,owners,O.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_finished(prefix:String,iterations:U32,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> String:
  match result:
    case (frame,Tx.Returned{world,outcome}):seed_pending(prefix ++ "seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={" ++ Render.frame(frame) ++ "}
",iterations,owners,O.world(world))
def seed_reserved(prefix:String,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> String:
  match result:
    case F.Reserved{tx,reservations}:seed_finished(prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
def seed_registered(prefix:String,+count:U32,iterations:U32,observed:Program.View & String) -> String:
  match observed:
    case (Program.View{world,owners,_,_,_},text):seed_reserved(prefix ++ "registered={" ++ text ++ "}
",count,iterations,owners,F.seed_rows(U32.to_nat(count),0,F.Reserved{Tx.begin(~F.World(),~E.event_type(),world),[]}))
def failure_local(kind:String,world:F.World() & String,capture:Array<U32> & String) -> String:
  (world,sw)=world
  (capture,sc)=capture
  kind ++ ";world={" ++ sw ++ "};capture=" ++ sc ++ "
"
def failure_two(kind:String,world:F.World() & String,owner:S.Instance() & String,capture:Array<U32> & String) -> String:
  (world,sw)=world
  (owner,so)=owner
  (capture,sc)=capture
  kind ++ ";world={" ++ sw ++ "};prior={" ++ so ++ "};capture=" ++ sc ++ "
"
def failure_three(world:F.World() & String,a:S.Instance() & String,b:S.Instance() & String,capture:Array<U32> & String) -> String:
  (world,sw)=world
  (a,sa)=a
  (b,sb)=b
  (capture,sc)=capture
  "DisposeRegistrationRejected;world={" ++ sw ++ "};spawn={" ++ sa ++ "};update={" ++ sb ++ "};capture=" ++ sc ++ "
"
def local_rejected(world:F.World(),owners:Registration.FailedLocals) -> String:
  match owners:
    case Registration.First{capture}:failure_local("SpawnRegistrationRejected",O.world(world),Dump.u32_array(capture))
    case Registration.Second{spawn,capture}:failure_two("UpdateRegistrationRejected",O.world(world),Render.local(spawn),Dump.u32_array(capture))
    case Registration.Third{spawn,update,capture}:failure_three(O.world(world),Render.local(spawn),Render.local(update),Dump.u32_array(capture))
def optional_text(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"None"
    case Some{text}:"Some{" ++ text ++ "}"
def definition_text(context:Family.Context() & String,provider:Maybe<&2,String>,+access:List<&2,String>) -> String:
  match context:
    case (_,text):"context={" ++ text ++ "};provider=" ++ optional_text(provider) ++ ";parameter=" ++ List.show(&2,String,x=>x,access)
def rejected_registered(context:Family.Context() & String,provider:Reader.Provider() & String) -> String:
  (context,sc)=context
  (provider,sp)=provider
  "context={" ++ sc ++ "};provider={" ++ sp ++ "}"
def rejected_disposal(access:List<&2,String>,context:Family.Context() & String,provider:Reader.Provider() & String) -> String:
  (provider,text)=provider
  definition_text(context,Some{text},access)
def rejected_definition(result:Reader.Definition()) -> String:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:rejected_registered(RO.context(context),RO.provider(provider))
    case Ordinary.DefinitionRejected{context,RP.Param{access},_}:definition_text(RO.context(context),None{},access)
    case Ordinary.DefinitionDisposalRejected{context,provider,RP.Param{access}}:rejected_disposal(access,RO.context(context),RO.provider(provider))
def reader_registration_rejected(label:String,a:S.Instance() & String,b:S.Instance() & String,c:S.Instance() & String,fast:String,result:Reader.Definition()) -> String:
  (a,sa)=a
  (b,sb)=b
  (c,sc)=c
  label ++ ";spawn={" ++ sa ++ "};update={" ++ sb ++ "};dispose={" ++ sc ++ "};fast={" ++ fast ++ "};rejected={" ++ rejected_definition(result) ++ "}
"
def slow_registration_rejected(a:S.Instance() & String,b:S.Instance() & String,c:S.Instance() & String,fast:Reader.Provider() & String,result:Reader.Definition()) -> String:
  match fast:
    case (_,text):reader_registration_rejected("SlowRegistrationRejected",a,b,c,text,result)
def registered_named(prefix:String,count:U32,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> String:
  match observed:
    case (world,namespace):seed_registered(prefix,count,iterations,Render.view(Program.View{world,owners,namespace,[],Program.Complete{}}))
def registered(prefix:String,count:U32,iterations:U32,result:Registration.Returned) -> String:
  match result:
    case Registration.Ready{world,owners}:registered_named(prefix,count,iterations,owners,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Registration.LocalRejected{world,owners}:prefix ++ local_rejected(world,owners)
    case Registration.FastRejected{spawn,update,dispose,result}:prefix ++ reader_registration_rejected("FastRegistrationRejected",Render.local(spawn),Render.local(update),Render.local(dispose),"unregistered",result)
    case Registration.SlowRejected{spawn,update,dispose,fast,result}:prefix ++ slow_registration_rejected(Render.local(spawn),Render.local(update),Render.local(dispose),RO.provider(fast),result)
def program(+count:U32,+iterations:U32,world:F.World()) -> String:registered("ReadersRuntime Health
count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "
",count,iterations,Registration.run(world,count))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (_,text):"WorldCreationRefused|resource={" ++ text ++ "}
"
