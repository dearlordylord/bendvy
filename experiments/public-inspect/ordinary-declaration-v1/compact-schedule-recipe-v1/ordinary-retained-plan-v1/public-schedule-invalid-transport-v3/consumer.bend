import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/frontend.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-retained-plan-v1/public-schedule-app-transport-v3/consumer.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def finished(~S:Data,before:String,after:String,result:F.Application(~S) & String) -> String:
  match result:
    case (app,disabled):"Before{" ++ before ++ "}\nInvalidRecovered{" ++ after ++ "}\nDisabledRecovered{" ++ disabled ++ "}\n"
def observed(~S:Data,before:String,result:F.Application(~S) & String) -> String:
  match result:
    case (app,after):finished(~S,before,after,F.snapshot(~S,False{},app))
def attached(~S:Data,before:String,result:Scheduled.Attachment<F.Application(~S),Ordinary.Application(~S)>) -> String:
  match result:
    case Scheduled.Invalid{app}:observed(~S,before,F.snapshot(~S,True{},app))
    case Scheduled.Attached{app}:"UNEXPECTED_ATTACHED"
def before_observed(~S:Data,result:F.Application(~S) & String) -> String:
  match result:
    case (app,before):attached(~S,before,Scheduled.attach(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),app,"InvalidMissingRegistration",SP.Entry{Sch.System{999,1},[SP.Resource{7}]}))
def registered(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,result:Front.SetupResult<S>) -> String:
  match result:
    case Front.Ready{app}:before_observed(~S,F.snapshot(~S,True{},App.attached(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Front.rows(~S),~Front.observe(~S),~Front.fold(~S),schema,app)))
    case _:"REGISTRATION_REJECTED"
def created(~S:Data,count:Nat,result:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> String:
  match result:
    case (schema,W.Created{_,world}):registered(~S,schema,Front.register(~S,W.enqueue(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,F.entities(~S,count,True{},world),F.pending(~S))))
    case _:"CREATE_REJECTED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,App.create(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~F.empty_store(~S),Setup.schema(~S,~Array<U32>,~Array<U32>,Front.declarations(~S)),W.factory(),Product.Owner{Unit{},Array.new(U32,0n,10)}))
