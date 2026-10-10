import Base
import ./frontend.bend as Front
import ./consumer.bend as Full
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import ./owner-observer.bend as Observer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
# Trusted setup reaches the existing system-ID exhaustion outcome, not a new policy.
def limit(~S:Data,value:Full.World(~S)) -> Full.World(~S):
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,_,clock}:W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,4294967294,clock}
def first_world(~S:Data,owners:Unit & Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,flag:Bool,fields:String,result:Full.World(~S) & String) -> Front.FirstApp(~S) & String:
  match result:
    case (world,text):(Build.Registered{world,owners,Tree.Recipe{},flag},"ResourceRejected|world{" ++ text ++ "}|owners=[" ++ fields ++ "]")
def first_observed(~S:Data,value:Front.FirstApp(~S)) -> Front.FirstApp(~S) & String:
  match value:
    case Build.Registered{world,(rest,Leaf.Record{token,+fields}),_,flag}:first_world(~S,(rest,Leaf.Record{token,fields}),flag,Full.record(~S,fields),Observer.mixed_world(~S,~Array<U32>,~Setup.resources(~Array<U32>),~U32,~Observer.u32_array,~Observer.mixed_resource,~U32.show,world))
def observed_text(~S:Data,result:Front.FirstApp(~S) & String) -> String:
  match result:
    case (_,text):text
def refused(~S:Data,result:Front.SetupResult<S>) -> String:
  match result:
    case Front.ResourceRejected{app}:observed_text(~S,first_observed(~S,app))
    case _ :"WRONG_REFUSAL_BOUNDARY"
def created(~S:Data,result:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)> & W.Creation<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> String:
  match result:
    case (_,W.Created{_,world}):refused(~S,Front.register(~S,limit(~S,W.enqueue(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,Full.entities(~S,2n,True{},world),Full.pending(~S)))))
    case _ :"CREATE_REJECTED"
type ApplicationSchema is Data:
  ApplicationSchema{}
def main() -> String:
  created(~ApplicationSchema,App.create(~ApplicationSchema,~Setup.store(~ApplicationSchema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Full.empty_store(~ApplicationSchema),Setup.schema(~ApplicationSchema,~Array<U32>,~Array<U32>,Front.declarations(~ApplicationSchema)),W.factory(),Product.Owner{Unit{},Array.new(U32,0n,10)}))
