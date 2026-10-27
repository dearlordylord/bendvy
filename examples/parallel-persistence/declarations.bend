import Base
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/owner-product.bend as Product

type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
type Actor<-S:Data> is Type:
  Actor{name:String,energy:Array<U32>}
type ActorView is Data:
  ActorView{name:String,energy:U32}
type Config<-S:Data> is Type:
  Config{enabled:Bool,limit:Array<U32>}
type ConfigView is Data:
  ConfigView{enabled:Bool,limit:U32}
type Scratch<-S:Data> is Type:
  Scratch{values:Array<U32>}
def actor_got(~S:Data,+name:String,result:Array<U32> & U32) -> Actor<S> & ActorView:
  match result:
    case (energy,+value):(Actor{name,energy},ActorView{name,value})
def actor_view(~S:Data,owner:Actor<S>) -> Actor<S> & ActorView:
  match owner:
    case Actor{name,energy}:actor_got(~S,name,Array.get(U32,energy,0))
def actor_raw(~S:Data,result:Actor<S> & ActorView) -> Actor<S> & D.Raw:
  match result:
    case (owner,ActorView{name,value}):(owner,D.Object{[D.Field{"name",D.BendvyText{name}},D.Field{"energy",D.Number{value}}]})
def actor_project(~S:Data,owner:Actor<S>) -> Actor<S> & D.Raw:actor_raw(~S,actor_view(~S,owner))
def config_got(~S:Data,+enabled:Bool,result:Array<U32> & U32) -> Config<S> & ConfigView:
  match result:
    case (limit,+value):(Config{enabled,limit},ConfigView{enabled,value})
def config_view(~S:Data,owner:Config<S>) -> Config<S> & ConfigView:
  match owner:
    case Config{enabled,limit}:config_got(~S,enabled,Array.get(U32,limit,0))
def config_raw(~S:Data,result:Config<S> & ConfigView) -> Config<S> & D.Raw:
  match result:
    case (owner,ConfigView{enabled,value}):(owner,D.Object{[D.Field{"enabled",D.Boolean{enabled}},D.Field{"limit",D.Number{value}}]})
def config_project(~S:Data,owner:Config<S>) -> Config<S> & D.Raw:config_raw(~S,config_view(~S,owner))
def scratch_view(~S:Data,owner:Scratch<S>) -> Scratch<S> & Unit:(owner,Unit{})
def components(~S:Data) -> Plan.Plan:
  Plan.Pair{Plan.Constructed{Actor<S>,ActorView,actor_view(~S),"actor",actor_project(~S)},Plan.Transient{Scratch<S>,Unit,scratch_view(~S),"scratch"}}
def resources(~S:Data) -> Plan.Plan:
  Plan.Pair{Plan.Constructed{Config<S>,ConfigView,config_view(~S),"config",config_project(~S)},Plan.Transient{Scratch<S>,Unit,scratch_view(~S),"temporary"}}
def schema(~S:Data) -> Plan.Schema<S,components(~S),resources(~S)>:
  Plan.Schema{Product.Owner{Decl.Constructed{D.Struct{[D.NamedCodec{"name",D.StringValue{}},D.NamedCodec{"energy",D.Integer{}}]}},Decl.Transient{}},Product.Owner{Decl.Constructed{D.Struct{[D.NamedCodec{"enabled",D.BoolValue{}},D.NamedCodec{"limit",D.Integer{}}]}},Decl.Transient{}}}
def initial_resources(~S:Data) -> Layout.resources(~S,Plan.layout(resources(~S))):
  Product.Owner{Layout.ResourceSlot{Layout.Viewed{Config{True{},ALeaf{700}},ConfigView{True{},700}},Layout.unknown_stamp()},Layout.ResourceSlot{Layout.Viewed{Scratch{ALeaf{909}},Unit{}},Layout.unknown_stamp()}}
def empty(~S:Data,_:Unit) -> Layout.columns(~S,Plan.layout(components(~S))):Layout.empty_columns(~S,Plan.layout(components(~S)))
