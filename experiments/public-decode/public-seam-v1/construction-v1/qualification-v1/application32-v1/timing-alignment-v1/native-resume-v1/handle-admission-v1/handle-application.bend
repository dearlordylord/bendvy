import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-resource.bend as ResourceConstruction
import /workspace/formal-proofs/bendvy/src/ecs/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type First is Data: First{}
type Second is Data: Second{}
type Token is Data: Token{}

type Payload<S:Data> is Type:
  Payload{cells:Array<U32>,name:String,target:Maybe<&2,W.Handle<S>>}

def array_join(left:Array<U32> & List<&2,D.Raw>,right:Array<U32> & List<&2,D.Raw>) -> Array<U32> & List<&2,D.Raw>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,D.Raw,a,b))
def array_project(cells:Array<U32>) -> Array<U32> & List<&2,D.Raw>:
  match cells:
    case ALeaf{+value}:(ALeaf{value},[D.Number{value}])
    case ANode{left,right}:array_join(array_project(left),array_project(right))
def project_target(~S:Data,+name:String,cells:Array<U32>,items:List<&2,D.Raw>,target:Maybe<&2,W.Handle<S>>) -> Payload<S> & D.Raw:
  match target:
    case None{}:(Payload{cells,name,None{}},D.Object{[D.Field{"cells",D.Array{items}},D.Field{"name",D.Text{name}},D.Field{"target",D.Null{}}]})
    case Some{W.Handle{+namespace,+id}}:(Payload{cells,name,Some{W.Handle{namespace,id}}},D.Object{[D.Field{"cells",D.Array{items}},D.Field{"name",D.Text{name}},D.Field{"target",D.Handle{namespace,id}}]})
def project_join(~S:Data,name:String,target:Maybe<&2,W.Handle<S>>,observed:Array<U32> & List<&2,D.Raw>) -> Payload<S> & D.Raw:
  match observed:
    case (cells,items):project_target(~S,name,cells,items,target)
def project(~S:Data,payload:Payload<S>) -> Payload<S> & D.Raw:
  match payload:
    case Payload{cells,+name,target}:project_join(~S,name,target,array_project(cells))

def codec(namespace:U32) -> D.Codec:
  D.Struct{[D.NamedCodec{"cells",D.ArrayValue{D.Integer{}}},D.NamedCodec{"name",D.StringValue{}},D.NamedCodec{"target",D.Nullable{D.HandleValue{namespace}}}]}
def incoming(~S:Data,payload:Payload<S>) -> Payload<S> & D.Raw:project(~S,payload)
def identity(~S:Data) -> Identity.Declaration<S,Payload<S>>:Identity.component(~S,~Payload<S>,"HandlePayload")
def resource_identity(~S:Data) -> Identity.Declaration<S,Payload<S>>:Identity.component(~S,~Payload<S>,"HandlePayloadResource")
def reverse(~S:Data,payload:Payload<S>) -> Payload<S>:payload
def build(~S:Data,payload:Payload<S>,canonical:D.Raw) -> Build.Construction<Payload<S>,Payload<S>,D.Error>:
  Build.Constructed{payload,reverse(~S)}
def component_declaration(~S:Data,namespace:U32) -> Decl.Constructed<S,Payload<S>,identity(~S),project(~S)>:
  Decl.constructed(~S,~Payload<S>,~identity(~S),~project(~S),codec(namespace))
def resource_declaration(~S:Data,namespace:U32) -> Decl.Constructed<S,Payload<S>,resource_identity(~S),project(~S)>:
  Decl.constructed(~S,~Payload<S>,~resource_identity(~S),~project(~S),codec(namespace))
def component_factory(~S:Data,namespace:U32) -> Constructor.Factory<S,Payload<S>,Payload<S>,identity(~S),project(~S),incoming(~S),build(~S)>:
  Constructor.factory(~S,~Payload<S>,~Payload<S>,~identity(~S),~project(~S),~incoming(~S),~build(~S),component_declaration(~S,namespace))
def resource_factory(~S:Data,namespace:U32) -> Constructor.Factory<S,Payload<S>,Payload<S>,resource_identity(~S),project(~S),incoming(~S),build(~S)>:
  Constructor.factory(~S,~Payload<S>,~Payload<S>,~resource_identity(~S),~project(~S),~incoming(~S),~build(~S),resource_declaration(~S,namespace))

def Store(~S:Data) -> Type:Col.Column<S,Payload<S>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Payload<S>,U32>
def Frame(~S:Data) -> Type:F.Frame<S,Store(~S),Payload<S>,U32,Payload<S>,Unit,identity(~S),project(~S)>
def take(~S:Data,column:Store(~S)) -> Unit & Store(~S):(Unit{},column)
def put(~S:Data,unit:Unit,column:Store(~S)) -> Store(~S):column
def family(~S:Data) -> Cmp.Family<S,Store(~S),Unit,Payload<S>,D.Raw,Token,take(~S),put(~S),project(~S)>:
  Cmp.Family{"HandlePayload"}
def empty(~S:Data,unit:Unit) -> Store(~S):Col.empty(~S,~Payload<S>)
def namespace(~S:Data,world:World(~S)) -> World(~S) & U32:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},namespace)

def populated(~S:Data,result:Cmp.Replacement<World(~S),Payload<S>>) -> World(~S):
  match result:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:world
def populate(~S:Data,world:World(~S),+target:W.Handle<S>,payload:Payload<S>) -> World(~S):
  populated(~S,Cmp.replace(~S,~Store(~S),~Payload<S>,~U32,~Unit,~Payload<S>,~D.Raw,~Token,~take(~S),~put(~S),~project(~S),family(~S),world,target,Some{payload}))
def replacement_result(~S:Data,original:D.Raw,canonical:D.Raw,result:Cmp.Replacement<World(~S),Payload<S>>) -> Delivery.Delivery<World(~S),Request.Packet<Payload<S>>>:
  match result:
    case Cmp.Replaced{world,_}:Delivery.Delivered{world}
    case Cmp.ReplaceRejected{world,incoming,error}:Delivery.Undelivered{world,Request.Packet{incoming,original,canonical},error}
def attempt(~S:Data,world:World(~S),target:W.Handle<S>,packet:Request.Packet<Payload<S>>) -> Delivery.Delivery<World(~S),Request.Packet<Payload<S>>>:
  match packet:
    case Request.Packet{owner,original,canonical}:
      replacement_result(~S,original,canonical,Cmp.replace(~S,~Store(~S),~Payload<S>,~U32,~Unit,~Payload<S>,~D.Raw,~Token,~take(~S),~put(~S),~project(~S),family(~S),world,target,owner))
def recover(~S:Data,world:World(~S),packet:Request.Packet<Payload<S>>,error:W.WorldError) -> World(~S):world

def component_grant(~S:Data) -> Cap.OwnedRequest<Frame(~S),Constructed.Input<S,Payload<S>>,Constructed.Output<S,Payload<S>,Payload<S>>>:
  Constructed.grant(~S,~Payload<S>,~Payload<S>,~identity(~S),~project(~S),~incoming(~S),~build(~S),~component_factory(~S,1),~Frame(~S),~F.request_grant(~S,~Store(~S),~Payload<S>,~U32,~Payload<S>,~Unit,~identity(~S),~project(~S)) )
def resource_grant(~S:Data) -> Cap.OwnedRequest<Frame(~S),Payload<S>,ResourceConstruction.Output<Payload<S>,Payload<S>>>:
  ResourceConstruction.grant(~S,~Payload<S>,~Payload<S>,~resource_identity(~S),~project(~S),~incoming(~S),~build(~S),~resource_factory(~S,1),~Frame(~S),~Resource.grant(~S,~Store(~S),~Payload<S>,~U32,~Payload<S>,~Unit,~identity(~S),~project(~S),~resource_identity(~S),~project(~S),~resource_declaration(~S,1)))
def frame_at(~S:Data,namespace:U32,world:World(~S)) -> Frame(~S):
  Completion.begin_frame(~S,~Store(~S),~Payload<S>,~U32,~Payload<S>,~Unit,~identity(~S),~project(~S),world,component_declaration(~S,namespace))

type Outcome<S:Data> is Type:
  Outcome{world:World(~S),incoming:Maybe<&1,Payload<S>>,checked:D.Checked,host:Maybe<&2,W.Status>}
def component_entity_error(~S:Data,world:World(~S),error:W.WorldError,projected:Payload<S> & D.Raw) -> Outcome<S>:
  match projected:
    case (payload,canonical):Outcome{world,Some{payload},D.Accepted{canonical},Some{W.Rejected{error}}}
def component_entity_refused(~S:Data,world:World(~S),owner:Maybe<&1,Payload<S>>,error:W.WorldError) -> Outcome<S>:
  match owner:
    case None{}:Outcome{world,None{},D.Accepted{D.Null{}},Some{W.Rejected{error}}}
    case Some{payload}:component_entity_error(~S,world,error,project(~S,payload))
def component_output_done(~S:Data,world:World(~S),output:Constructed.Output<S,Payload<S>,Payload<S>>) -> Outcome<S>:
  match output:
    case Constructed.Accepted{_,_,canonical,_}:Outcome{world,None{},D.Accepted{canonical},Some{W.Accepted{}}}
    case Constructed.Refused{owner,Request.Validation{error}}:Outcome{world,owner,D.Rejected{error},None{}}
    case Constructed.Refused{owner,Request.Entity{error}}:component_entity_refused(~S,world,owner,error)
def component_done(~S:Data,output:Constructed.Output<S,Payload<S>,Payload<S>>,finished:Batch.Finished<S,Store(~S),Payload<S>,U32,Request.Packet<Payload<S>>,Unit>) -> Outcome<S>:
  match finished:
    case Batch.Committed{world}:component_output_done(~S,world,output)
    case Batch.Failed{world,_,_}:Outcome{world,None{},D.Accepted{D.Null{}},None{}}
def component_result(~S:Data,result:Frame(~S) & Constructed.Output<S,Payload<S>,Payload<S>>) -> Outcome<S>:
  match result:
    case (F.Frame{owner,_,_,_,_,_},output):component_done(~S,output,Request.finish(~S,~Store(~S),~Payload<S>,~U32,~Payload<S>,~Unit,~identity(~S),~project(~S),~attempt(~S),~recover(~S),owner,T.Success{}))
def component_request_at(~S:Data,namespace:U32,world:World(~S),operation:Commands.Operation<S>,payload:Payload<S>) -> Outcome<S>:
  component_result(~S,Cap.owned_request(~Frame(~S),~Constructed.Input<S,Payload<S>>,~Constructed.Output<S,Payload<S>,Payload<S>>,~component_grant(~S),frame_at(~S,namespace,world),Constructed.Input{operation,payload}))
def request_component_in_world(~S:Data,operation:Commands.Operation<S>,payload:Payload<S>,observed:World(~S) & U32) -> Outcome<S>:
  match observed:
    case (world,namespace):component_request_at(~S,namespace,world,operation,payload)
def component_request(~S:Data,world:World(~S),operation:Commands.Operation<S>,payload:Payload<S>) -> Outcome<S>:
  request_component_in_world(~S,operation,payload,namespace(~S,world))

def resource_output_done(~S:Data,world:World(~S),output:ResourceConstruction.Output<Payload<S>,Payload<S>>) -> Outcome<S>:
  match output:
    case ResourceConstruction.Replaced{canonical,_}:Outcome{world,None{},D.Accepted{canonical},Some{W.Accepted{}}}
    case ResourceConstruction.Refused{owner,error}:Outcome{world,Some{owner},D.Rejected{error},None{}}
def resource_done(~S:Data,output:ResourceConstruction.Output<Payload<S>,Payload<S>>,finished:Batch.Finished<S,Store(~S),Payload<S>,U32,Request.Packet<Payload<S>>,Unit>) -> Outcome<S>:
  match finished:
    case Batch.Committed{world}:resource_output_done(~S,world,output)
    case Batch.Failed{world,_,_}:Outcome{world,None{},D.Accepted{D.Null{}},None{}}
def resource_result(~S:Data,result:Frame(~S) & ResourceConstruction.Output<Payload<S>,Payload<S>>) -> Outcome<S>:
  match result:
    case (F.Frame{owner,_,_,_,_,_},output):resource_done(~S,output,Request.finish(~S,~Store(~S),~Payload<S>,~U32,~Payload<S>,~Unit,~identity(~S),~project(~S),~attempt(~S),~recover(~S),owner,T.Success{}))
def resource_request_at(~S:Data,namespace:U32,world:World(~S),payload:Payload<S>) -> Outcome<S>:
  resource_result(~S,Cap.owned_request(~Frame(~S),~Payload<S>,~ResourceConstruction.Output<Payload<S>,Payload<S>>,~resource_grant(~S),frame_at(~S,namespace,world),payload))
def request_resource_in_world(~S:Data,payload:Payload<S>,observed:World(~S) & U32) -> Outcome<S>:
  match observed:
    case (world,namespace):resource_request_at(~S,namespace,world,payload)
def resource_request(~S:Data,world:World(~S),payload:Payload<S>) -> Outcome<S>:
  request_resource_in_world(~S,payload,namespace(~S,world))

def admit(~S:Data,which:U32,world:World(~S),target:W.Handle<S>,payload:Payload<S>) -> Outcome<S>:
  match which:
    case 0:component_request(~S,world,Commands.Spawn{},payload)
    case 1:component_request(~S,world,Commands.Insert{target},payload)
    case 2:resource_request(~S,world,payload)
    case 3:component_request(~S,world,Commands.Spawn{},payload)
    case 4:component_request(~S,world,Commands.Insert{target},payload)
    case 5:resource_request(~S,world,payload)
    case 6:component_request(~S,world,Commands.Spawn{},payload)
    case 7:component_request(~S,world,Commands.Insert{target},payload)
    case 8:resource_request(~S,world,payload)
    case 9:component_request(~S,world,Commands.Insert{target},payload)
    case _:resource_request(~S,world,payload)
