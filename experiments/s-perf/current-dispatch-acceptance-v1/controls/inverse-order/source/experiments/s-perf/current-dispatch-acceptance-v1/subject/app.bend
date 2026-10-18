import Base
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ./body.bend as B
import ../../canonical-api-v1/dense-runtime-v1/motion-driver.bend as Layout
import ../../canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../../canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/ordinary-app-capture-query-fields.bend as A
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/ordinary-app-records.bend as Records
import ../../../../src/ecs/trace-facts.bend as Trace

def Owners() -> Type:B.Owned() & B.Args
def fields(owner:B.Owned()) -> B.Owned() & Fields.Fields<T.MotionSchema>:A.fields(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~P.Pack,~B.Ops,~B.Args,~Unit,~U32,~B.query(),~B.body,owner)
def fold(owners:Owners()) -> Owners() & List<&2,Fields.Fields<T.MotionSchema>>:Existing.fold(~T.MotionSchema,~B.Owned(),~B.Args,~fields,owners)
def enabled(args:B.Args) -> B.Args & Bool:(args,True{})
def plan(owners:Owners()) -> Owners() & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~B.Owned(),~B.Args,~fields,~enabled,~[],owners)
def provide(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:(world,[])
def returned(+args:B.Args,trace:Trace.State,result:O.Run<F.World(),B.Owned(),B.Args,Q.Error<Unit>,U32>) -> B.Owned() & (B.Args & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match result:
    case O.Completed{world,owner,Done{_}}:(owner,(args,Sys.Succeeded{Ctx.Context{world,trace},Unit{}}))
    case O.Completed{world,owner,Fail{_}}:(owner,(args,Sys.Failed{Ctx.Context{world,trace},Unit{}}))
    case O.Refused{world,owner,_}:(owner,(args,Sys.Failed{Ctx.Context{world,trace},Unit{}}))
def invoke(owner:B.Owned(),args:B.Args,context:Ctx.Context<F.World()>) -> B.Owned() & (B.Args & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match context:
    case Ctx.Context{world,trace}:
      +copy=args
      returned(copy,trace,B.run(owner,world,copy))
def dispatch(owners:Owners(),context:Ctx.Context<F.World()>,id:U32) -> Owners() & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~B.Owned(),~B.Args,~Unit,~fields,~invoke,~Unit{},owners,context,id)
def Application() -> Type:Entry.Application<T.MotionSchema,F.Store(),F.Resources(),Nat,Owners(),Unit,Build.empty_observe(~F.World()),fold,Unit,plan,dispatch,provide>
def Registered() -> Type:Exec.Registered<T.MotionSchema,F.World(),Owners(),Unit,Build.empty_observe(~F.World()),fold,Unit,plan,dispatch,provide>
def create(world:F.World(),owners:Owners()) -> Single.Attachment<Registered(),Application()>:
  Entry.attach(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Owners(),~Unit,~Build.empty_observe(~F.World()),~fold,~Unit,~plan,~dispatch,~provide,Layout.schema(),Existing.registered(~T.MotionSchema,~F.World(),~Owners(),~fold,~Unit,~plan,~dispatch,~provide,world,owners),"current-dispatch",False{})
def run(app:Application()) -> Execute.Run<Application(),T.MotionSchema,Unit>:Entry.run(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Owners(),~Unit,~Build.empty_observe(~F.World()),~fold,~Unit,~plan,~dispatch,~provide,app)
def set_args(owners:Owners(),args:B.Args) -> Owners():
  match owners:
    case (owner,_):(owner,args)
def retry(app:Application()) -> Application():Entry.update_owners(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Owners(),~Unit,~Build.empty_observe(~F.World()),~fold,~Unit,~plan,~dispatch,~provide,~B.Args,~set_args,app,B.Args{999})
