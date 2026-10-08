import Base
import ./registered-consumer.bend as Observe
import ./world-snapshot.bend as Snapshot
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import ../state-metadata.bend as State
import ../render-fixture.bend as R
import ./owner-observation.bend as Owner
import ./registered-v2.bend as Registered
import ./definition-v2.bend as Definition
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
import ./fixture.bend as Fixture
import ./render.bend as Render
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Schedule

def empty_store(args:Unit) -> Array<U32>:
  ANode{ALeaf{19},ALeaf{23}}
def owner() -> Owner.Owner:
  Owner.Owner{Some{ALeaf{7}},None{},None{},None{},Machine.Missing{},Machine.Present{State.NumberBits{0,1073217536,"1.5"},Machine.Queued{State.NumberBits{0,0,"0"},False{}},Some{State.NumberBits{0,2147483648,"0"}},True{}},7}
def output(name:String,description:String) -> String:
  String.join(["{\"name\":",R.quote(name),",\"description\":",description,"}"],"")
def need(value:Provision.Requirement<Owner.Schema>) -> String:
  match value:
    case Provision.Component{id}:"component:"++U32.show(id)
    case Provision.Resource{id}:"resource:"++U32.show(id)
    case Provision.Service{id}:"service:"++U32.show(id)
def needs(values:List<&2,Provision.Requirement<Owner.Schema>>) -> String:
  match values:
    case []:""
    case head<>tail:need(head)++";"++needs(tail)
def final_namespace(actual:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & U32,schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry>,description:String,before:String,after:String,view:Registered.View,again:Registered.View) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match actual view again:
    case (world,+worldNamespace), Registered.View{_,_,+requirements,valid,+ns,+id,cursor} Registered.View{_,_,againRequirements,validAgain,nsAgain,idAgain,cursorAgain}:(world,schedule,description++"\nownerBefore="++before++"\nownerAfter="++after++"\nregistration="++U32.show(id)++":"++U32.show(cursor)++":"++U32.show(cursorAgain)++":"++Render.boolean(Bool.and(valid,validAgain))++":"++Render.boolean(Bool.and(Bool.and(U32.is_eq(ns,nsAgain),U32.is_eq(ns,worldNamespace)),U32.is_eq(id,idAgain)))++"\nrequirements="++needs(requirements))
def final(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry>,description:String,before:String,after:String,view:Registered.View,again:Registered.View) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  final_namespace(W.namespace(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,world),schedule,description,before,after,view,again)
def final_view(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,description:String,before:String,after:String,view:Registered.View,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & Registered.View) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match result:
    case (schedule,again):final(world,schedule,description,before,after,view,again)
def after(schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry>,description:String,before:String,view:Registered.View,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match result:
    case (world,after):final_view(world,description,before,after,view,Registered.view(schedule))
def read_join(schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry>,before:String,+view:Registered.View,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match view result:
    case Registered.View{description,system,requirements,valid,namespace,id,cursor}, (world,observation):after(schedule,output("allCategories",Render.description(Fixture.all(observation,system,description))),before,view,Snapshot.project(world))
def before(schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry>,view:Registered.View,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match result:
    case (world,value):read_join(schedule,value,view,Observe.read(world))
def observed(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & Registered.View) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String:
  match result:
    case (schedule,view):before(schedule,view,Snapshot.project(world))
def finished(result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Registry> & String) -> String:
  match result:
    case (world,schedule,text):text
def prepared(result:Registered.Prepared) -> String:
  match result:
    case Registered.Prepared{world,schedule}:finished(observed(world,Registered.view(schedule)))
    case other:"registration-or-schedule-refused"
def identity(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  world
def configured(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,system,clock}:W.World{ns,next,high,live,capacity,depth,store,resource,[17],[identity,identity],regs,system,41}
# Full owners retained through projections and final consumer result. Closed IO
# ends their lifetime here, without a framework disposal/recovery policy.
def created(result:WIO.Creation<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> String:
  match result:
    case WIO.Created{world}:prepared(Registered.prepare(configured(world),Definition.inspect()))
    case WIO.Refused{resource}:"creation-refused"
def print_all(value:String) -> IO(Unit):
  IO.print(output("empty",Render.description(Fixture.empty()))++"\n"++value)
def main() -> IO(Unit):
  IO.bind(WIO.Creation<Owner.Schema,Array<U32>,Owner.Owner,U32>,Unit,WIO.create(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~empty_store,owner()),value => print_all(created(value)))
