import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ./request.bend as Deferred
import ../application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl

# This application explicitly chooses recovery Local. No library default policy.
type History<S:Data> is Type:
  History{declaration:Decl.Constructed<S,Input.Owner,App.identity(~S),Input.project>,operations:List<Deferred.Output<S,Input.Owner>>,packets:List<Deferred.Packet<Input.Owner>>}
def body(~S:Data,-H:Type,cap:Cap.ValueRead<H,D.Raw>,input:Deferred.Input<S,Input.Owner>,ctx:H) -> H & Deferred.Output<S,Input.Owner>:
  match cap:
    case Cap.OwnedRequest{run}:run(ctx,input)
# Abort fixture never applies queued deliveries. Keep an explicit refusal adapter
# rather than pretending this fixture qualifies successful component installation.
def attempt(~S:Data,world:App.World(~S),target:W.Handle<S>,packet:Deferred.Packet<Input.Owner>) -> Delivery.Delivery<App.World(~S),Deferred.Packet<Input.Owner>>:
  Delivery.Undelivered{world,packet,W.MissingEntity{}}
# If this application's queue were committed, its explicit recovery destination
# would be the resource; no such success is admitted by this abort-only fixture.
def recovered(~S:Data,result:App.World(~S) & Input.Owner) -> App.World(~S):
  match result:
    case (world,old):world
def recover(~S:Data,world:App.World(~S),packet:Deferred.Packet<Input.Owner>,error:W.WorldError) -> App.World(~S):
  match packet:
    case Deferred.Packet{owner,_}:recovered(~S,W.replace_resource(~S,~App.Store(~S),~Input.Owner,~Unit,world,owner))
def finished(~S:Data,declaration:Decl.Constructed<S,Input.Owner,App.identity(~S),Input.project>,operations:List<Deferred.Output<S,Input.Owner>>,packets:List<Deferred.Packet<Input.Owner>>,output:Deferred.Output<S,Input.Owner>,result:Batch.Finished<S,App.Store(~S),Input.Owner,Unit,Deferred.Packet<Input.Owner>,String>) -> Local.Outcome<App.World(~S),History<S>,String,Unit>:
  match result:
    case Batch.Failed{world,returned,error}:Local.Failed{world,History{declaration,output <> operations,List.append(&1,Deferred.Packet<Input.Owner>,packets,returned)},error}
    case Batch.Committed{world}:Local.Succeeded{world,History{declaration,output <> operations,packets},Unit{}}
def invoked(~S:Data,declaration:Decl.Constructed<S,Input.Owner,App.identity(~S),Input.project>,operations:List<Deferred.Output<S,Input.Owner>>,packets:List<Deferred.Packet<Input.Owner>>,result:Deferred.Owner<S,App.Store(~S),Input.Owner,Unit,Input.Owner,App.identity(~S),Input.project> & Deferred.Output<S,Input.Owner>) -> Local.Outcome<App.World(~S),History<S>,String,Unit>:
  match result:
    case (owner,output):finished(~S,declaration,operations,packets,output,Deferred.finish(~S,~App.Store(~S),~Input.Owner,~Unit,~Input.Owner,~String,~App.identity(~S),~Input.project,~attempt(~S),~recover(~S),owner,T.Failure{"abort-after-request"}))
def runner(~S:Data,world:App.World(~S),history:History<S>,input:Deferred.Input<S,Input.Owner>) -> Local.Outcome<App.World(~S),History<S>,String,Unit>:
  match history:
    case History{+declaration,operations,packets}:invoked(~S,declaration,operations,packets,Deferred.invoke(~S,~App.Store(~S),~Input.Owner,~Unit,~Input.Owner,~Deferred.Input<S,Input.Owner>,~Deferred.Output<S,Input.Owner>,~App.identity(~S),~Input.project,~(H => cap => input => ctx => body(~S,H,cap,input,ctx)),Deferred.Owner{Batch.begin(~S,~App.Store(~S),~Input.Owner,~Unit,~Deferred.Packet<Input.Owner>,T.begin(~App.World(~S),~Unit,world)),declaration},input))

type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
def register(~S:Data,world:App.World(~S),codec:D.Codec) -> Local.Registered<S,App.Store(~S),Input.Owner,Unit,History<S>,Deferred.Input<S,Input.Owner>,String,Unit,runner(~S)>:
  Local.register(~S,~App.Store(~S),~Input.Owner,~Unit,~History<S>,~Deferred.Input<S,Input.Owner>,~String,~Unit,~runner(~S),world,"DecodeAbort",[Identity.key(~S,~Input.Owner,App.identity(~S))],History{Decl.constructed(~S,~Input.Owner,~App.identity(~S),~Input.project,codec),[],[]})
def registered(~S:Data,result:Local.Registered<S,App.Store(~S),Input.Owner,Unit,History<S>,Deferred.Input<S,Input.Owner>,String,Unit,runner(~S)>) -> Maybe<&1,Local.Run<S,App.Store(~S),Input.Owner,Unit,History<S>,Deferred.Input<S,Input.Owner>,String,Unit,runner(~S)>>:
  match result:
    case Local.RegistrationRejected{world,local}:None{}
    case Local.Registered{world,instance}:Some{Local.run(~S,~App.Store(~S),~Input.Owner,~Unit,~History<S>,~Deferred.Input<S,Input.Owner>,~String,~Unit,~runner(~S),instance,world,Deferred.Input{Commands.Spawn{},Input.Owner{D.Number{7},ANode{ALeaf{111},ALeaf{222}}}})}
def empty(~S:Data,unit:Unit) -> App.Store(~S):Col.empty(~S,~Input.Owner)
def created(~S:Data,result:W.Creation<S,App.Store(~S),Input.Owner,Unit>) -> Maybe<&1,Local.Run<S,App.Store(~S),Input.Owner,Unit,History<S>,Deferred.Input<S,Input.Owner>,String,Unit,runner(~S)>>:
  match result:
    case W.Created{factory,world}:registered(~S,register(~S,world,D.Integer{}))
    case W.CreateRejected{factory,resource}:None{}
def run(~S:Data) -> Maybe<&1,Local.Run<S,App.Store(~S),Input.Owner,Unit,History<S>,Deferred.Input<S,Input.Owner>,String,Unit,runner(~S)>>:
  created(~S,W.create(~S,~App.Store(~S),~Input.Owner,~Unit,~empty(~S),W.factory(),Input.Owner{D.Number{9},ALeaf{333}}))
def main() -> Maybe<&1,Local.Run<Schema,App.Store(~Schema),Input.Owner,Unit,History<Schema>,Deferred.Input<Schema,Input.Owner>,String,Unit,runner(~Schema)>> & Maybe<&1,Local.Run<OtherSchema,App.Store(~OtherSchema),Input.Owner,Unit,History<OtherSchema>,Deferred.Input<OtherSchema,Input.Owner>,String,Unit,runner(~OtherSchema)>>:
  (run(~Schema),run(~OtherSchema))
