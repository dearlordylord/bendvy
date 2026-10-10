import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Full
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import ../runtime-registration-records-v1/records.bend as Records
import ../runtime-registration-records-v1/run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
# Actual Registry transport, separate from composition-only snapshot witness.
# Invalidate is a trusted-admin fixture operation, not a normal ECS capability.
type Action is Data:
  Observe{}
  Invoke{fail:Bool}
  Skip{}
  Invalidate{}
def kind_text(value:Records.RegistrationKind) -> String:
  match value:
    case Records.ComponentKind{}:"Component"
    case Records.ResourceKind{mode}:"Resource:" ++ Full.mode(mode)
def fields_text(~S:Data,fields:Records.Fields<S>) -> String:
  match fields:
    case Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}:"Registry{" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ "|name=" ++ name ++ "|access=" ++ List.show(&2,String,x=>x,access) ++ "|cursor=" ++ U32.show(cursor) ++ "|slot=" ++ slot ++ "|clauses=" ++ List.show(&2,Query.Clause<S>,Full.clause(~S),clauses) ++ "|kind=" ++ kind_text(kind) ++ "}"
def invalidated(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,_,nextSystemId,clock}:W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,[],nextSystemId,clock}
def observed(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,next:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> -> Records.Fields<S> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> String -> String,token:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>,+fields:Records.Fields<S>,result:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & String) -> String:
  match result:
    case (world,state):next(token,fields,world,fields_text(~S,fields) ++ "|world{" ++ state ++ "}")
def output_observed(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,next:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> -> Records.Fields<S> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> String -> String,token:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>,fields:Records.Fields<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,result:Array<U32> & U32) -> String:
  match result:
    case (_,prior):next(token,fields,world,"Success:" ++ U32.show(prior))
def outcome(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,next:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> -> Records.Fields<S> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> String -> String,token:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>,fields:Records.Fields<S>,result:Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>) -> String:
  match result:
    case Sys.Succeeded{world,RF.Output{values}}:output_observed(~S,~runner,next,token,fields,world,Array.get(U32,values,0))
    case Sys.Failed{world,RF.RolledBack{prior}}:next(token,fields,world,"Failure:" ++ U32.show(prior))
def rejected(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,next:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> -> Records.Fields<S> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> String -> String,token:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>,fields:Records.Fields<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,result:Array<Bool> & Bool) -> String:
  match result:
    case (_,fail):next(token,fields,world,"RejectedArgs:" ++ Bool.show(fail))
def invoked(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,next:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> -> Records.Fields<S> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> String -> String,result:Run.TransportResult<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Input.Args,RF.Error,RF.Output,Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>>) -> String:
  match result:
    case Run.Completed{token,fields,result}:outcome(~S,~runner,next,token,fields,result)
    case Run.RegistrationRejected{token,fields,world,Input.Args{flags}}:rejected(~S,~runner,next,token,fields,world,Array.get(Bool,flags,0))
def drive(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,actions:List<&2,Action>,token:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>>,fields:Records.Fields<S>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,prefix:String) -> String:
  match actions:
    case []:prefix
    case Observe{} <> tail:observed(~S,~runner,token=>fields=>world=>text=>drive(~S,~runner,tail,token,fields,world,prefix ++ text ++ "\n"),token,fields,Dump.world(~S,~Caller.Payload,~Array<U32>,~U32,~Fixture.payload,~Dump.u32_array,~U32.show,world))
    case Invoke{fail} <> tail:invoked(~S,~runner,token=>fields=>world=>text=>drive(~S,~runner,tail,token,fields,world,prefix ++ text ++ "\n"),Run.run(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Input.Args,~RF.Error,~RF.Output,~runner,token,fields,world,Input.Args{Array.new(Bool,0n,fail)}))
    case Skip{} <> tail:drive(~S,~runner,tail,token,fields,world,prefix ++ "Skipped\n")
    case Invalidate{} <> tail:drive(~S,~runner,tail,token,fields,invalidated(~S,world),prefix ++ "TrustedInvalidation\n")
def extracted(~S:Data,~runner:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,RF.Error,RF.Output>,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,result:Records.Token<Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,runner>> & Records.Fields<S>) -> String:
  match result:
    case (token,fields):drive(~S,~runner,[Observe{},Invoke{False{}},Observe{},Invoke{True{}},Observe{},Invoke{False{}},Observe{},Skip{},Observe{},Invalidate{},Observe{},Invoke{True{}},Observe{}],token,fields,world,"")
def defined(~S:Data,result:P.Defined<S,W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,Sys.Registry<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Input.Args,RF.Error,RF.Output,P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body)>,P.mode(~S,~Array<U32>,~T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,~D.write_ops(~Array<U32>,~U32,T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>),D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)))>) -> String:
  match result:
    case P.Rejected{_}:"DEFINE_REJECTED"
    case P.Defined{world,owner}:extracted(~S,~P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body),world,Records.resource(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Input.Args,~RF.Error,~RF.Output,~P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body),~P.mode(~S,~Array<U32>,~T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>,~D.write_ops(~Array<U32>,~U32,T.Tx<W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,U32>),D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S))),owner))
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
    case W.Created{_,world}:defined(~S,P.define(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~D.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~D.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body,Full.entities(~S,count,True{},world),"CounterUpdate","Update"))
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.empty_store(~S),W.factory(),Array.new(U32,0n,10)))
type Report is Data:
  Report{empty:String,populated:String}
