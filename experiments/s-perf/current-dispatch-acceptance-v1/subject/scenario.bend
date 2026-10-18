import Base
import ./body.bend as B
import ./app.bend as A
import ../../canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../../canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../canonical-api-v1/dense-runtime-v1/motion-observe.bend as Obs
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-execution.bend as Exec
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/transaction.bend as Tx

def tree(value:P.Tree) -> String:
  match value:
    case P.Leaf{n}:U32.show(n)
    case P.Node{left,right}:"(" ++ tree(left) ++ "," ++ tree(right) ++ ")"
def pack(value:P.Observation) -> String:
  match value:
    case P.Observation{first,second}:"{" ++ tree(first) ++ ";" ++ tree(second) ++ "}"
def packed(+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,result:P.Pack & P.Observation) -> B.Owned() & String:
  match result:
    case (capture,view):(O.Owner{L.Instance{ns,id,name,access,capture},cursor},"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";capture=" ++ pack(view))
def owner(value:B.Owned()) -> B.Owned() & String:
  match value:
    case O.Owner{L.Instance{ns,id,name,access,capture},cursor}:packed(ns,id,name,access,cursor,P.project(capture))
def with_world(~Out:Type,next:F.World() -> String -> Out,result:F.World() & String) -> Out:
  match result:
    case (world,text):next(world,text)
def with_owner(~Out:Type,next:B.Owned() -> String -> Out,result:B.Owned() & String) -> Out:
  match result:
    case (owner,text):next(owner,text)
def args_text(value:B.Args) -> String:
  match value:
    case B.Args{failAt}:U32.show(failAt)
def snapshot(value:A.Application()) -> A.Application() & String:
  match value:
    case Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owned,+args),recipe,debug}},selected,ns,name,steps,needs},execution}:
      with_world(~(A.Application() & String),world=>wt=>with_owner(~(A.Application() & String),owned=>ot=>(Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owned,args),recipe,debug}},selected,ns,name,steps,needs},execution},wt ++ "|owner={" ++ ot ++ "};failAt=" ++ args_text(args)),owner(owned)),Obs.world(world))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered(" ++ name ++ ")"
    case Sch.Ran{id}:"Ran(" ++ U32.show(id) ++ ")"
    case Sch.Skipped{id}:"Skipped(" ++ U32.show(id) ++ ")"
    case Sch.Applied{}:"Applied"
def completed(value:Single.RunResult<A.Application(),T.MotionSchema,Unit>) -> A.Application() & String:
  match value:
    case Single.Finished{app,observations}:(app,"Finished:" ++ List.show(&2,Sch.Observation,observation,observations))
    case Single.Failed{app,Unit{},observations}:(app,"Failed:Unit:" ++ List.show(&2,Sch.Observation,observation,observations))
    case Single.Rejected{app}:(app,"Rejected")
    case Single.Missing{app,_}:(app,"Missing")
def with_app(~Out:Type,next:A.Application() -> String -> Out,result:A.Application() & String) -> Out:
  match result:
    case (app,text):next(app,text)
def executed(value:Exec.Run<A.Application(),T.MotionSchema,Unit>) -> A.Application() & String:
  match value:
    case Exec.Run{result,Trace.Disabled{}}:completed(result)
    case Exec.Run{result,Trace.Ready{events}}:with_app(~(A.Application() & String),app=>text=>(app,text ++ ":UNEXPECTED_TRACE:" ++ Nat.show(List.length(&2,Trace.TraceEvent<Unit>,events))),completed(result))
def step(label:String,old:String,app:A.Application()) -> A.Application() & String:
  with_app(~(A.Application() & String),app=>result=>with_app(~(A.Application() & String),app=>state=>(app,old ++ label ++ ":" ++ result ++ "|" ++ state ++ "\n"),snapshot(app)),executed(A.run(app)))
def final_text(result:A.Application() & String) -> String:
  match result:
    case (_,text):text
def sequence(app:A.Application()) -> String:
  with_app(~String,app=>initial=>with_app(~String,app=>first=>with_app(~String,app=>second=>final_text(step("repeat",second,app)),step("retry",first,A.retry(app))),step("failure","initial|" ++ initial ++ "\n",app)),snapshot(app))
def attached(value:Single.Attachment<A.Registered(),A.Application()>) -> String:
  match value:
    case Single.Attached{app}:sequence(app)
    case Single.Invalid{_}:"INVALID_APP\n"
def registered(value:O.Registration<F.World(),B.Owned(),P.Pack>) -> String:
  match value:
    case O.Registered{world,owner}:attached(A.create(world,(owner,B.Args{1})))
    case O.Rejected{_,_}:"REGISTRATION_REJECTED\n"
def seeded(value:F.Seeded) -> String:
  match value:
    case F.Seeded{world,_,Tx.Success{}}:registered(B.define(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
    case F.Seeded{_,_,Tx.Failure{_}}:"SEED_FAILURE\n"
def start(world:F.World()) -> String:seeded(F.seed(2,world))
