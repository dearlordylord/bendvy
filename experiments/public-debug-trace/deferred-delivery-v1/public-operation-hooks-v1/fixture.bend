import Base
import ../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../src/ecs/ordinary-machine-initialization-marker.bend as Marker
import ../../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../../src/ecs/ordinary-owned-event-binding.bend as EventBinding
import ../../../../src/ecs/ordinary-owned-event-family-write.bend as EventWrite
import ../../../../src/ecs/ordinary-owned-event-declaration.bend as Events
import ../../../../src/ecs/ordinary-owned-event-family-publisher.bend as Publisher
import ../../../../src/ecs/ordinary-app-owned-event-publisher.bend as AppPublisher
import ../../../../src/ecs/owned-event-journal.bend as EventStage
import ../../../../src/ecs/owned-event-key-route.bend as EventRoute
import ../../../../src/ecs/relation-failure-reader.bend as RelationDecl
import ../../../../src/ecs/relation-providers.bend as RelationOps
import ../../../../src/ecs/ordinary-app-relation.bend as AppRelation
import ../../../../src/ecs/machine-handlers.bend as Handlers
import ../../../../src/ecs/relation-commands.bend as Relations
import ../../../../src/ecs/relation-types.bend as Graph
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/machine.bend as Machine
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/commands.bend as Commands
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/resource-field-binding.bend as Binding
import ../../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../../src/ecs/ordinary-app-resource-field-declaration.bend as Decl
import ../../../../src/ecs/ordinary-app-resource-field.bend as AppField
import ../../../../src/ecs/ordinary-app-resource-field-observation.bend as Leaves
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Records
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-registration-run.bend as Transport
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP

import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/ordinary-component-binding.bend as ComponentBinding
import ../../../../src/ecs/ordinary-query-observable.bend as Query
import ../../../../src/ecs/ordinary-app-component.bend as AppComponent
import ../../../../src/ecs/ordinary-system.bend as ComponentSystem
import ../../../../src/ecs/ordinary-app-observation.bend as ComponentLeaves
import ../../../../src/ecs/ordinary-app-execution-run.bend as ExecutionRun
import ../../../../src/ecs/execution-context.bend as Context
import ../../../../src/ecs/trace-facts.bend as Facts
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/inspector-query.bend as IQ

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Mode is Data:Mode{}
def BaseResources() -> Type:Product.Owner<Array<U32>,Array<U32>>
def MachineState(~S:Data) -> Data:Init.State<S,Mode,U32>
def UserResources(~S:Data) -> Type:Product.Owner<BaseResources(),MachineState(~S)>
def Notice(~S:Data) -> Data:Relations.Notice<S,Nat>
def Resources(~S:Data) -> Type:Product.Owner<UserResources(~S),Log.Log<Array<U32>>>
def Store(~S:Data) -> Type:Relations.Store<S,Col.Column<S,Array<U32>>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Resources(~S),Notice(~S)>
def counter(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Counter")
def sibling(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Sibling")
def BaseIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>
def base_schema(~S:Data) -> Binding.Built<S,BaseResources(),BaseIndex(~S)>:Binding.joined(~S,~Array<U32>,~Array<U32>,~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,Binding.leaf(~S,~Array<U32>,counter(~S)),Binding.leaf(~S,~Array<U32>,sibling(~S)))
def UserIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,BaseResources(),BaseIndex(~S)>,Binding.Built<S,MachineState(~S),Unit>>
def user_schema(~S:Data) -> Binding.Built<S,UserResources(~S),UserIndex(~S)>:Binding.joined(~S,~BaseResources(),~MachineState(~S),~BaseIndex(~S),~Unit,base_schema(~S),Binding.Built{[],Unit{}})
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,UserResources(~S),UserIndex(~S)>,Binding.Built<S,Log.Log<Array<U32>>,Unit>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:Binding.joined(~S,~UserResources(~S),~Log.Log<Array<U32>>,~UserIndex(~S),~Unit,user_schema(~S),Binding.Built{[],Unit{}})
def user_lens(~S:Data) -> Product.Lens<Resources(~S),UserResources(~S),Unit & Log.Log<Array<U32>>>:Binding.left_lens(~Resources(~S),~UserResources(~S),~Log.Log<Array<U32>>,~Unit,~Binding.whole(~Resources(~S)))
def user_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),UserResources(~S),Unit & Log.Log<Array<U32>>,UserIndex(~S),user_lens(~S)>:Binding.left(~S,~Resources(~S),~UserResources(~S),~Log.Log<Array<U32>>,~Unit,~UserIndex(~S),~Unit,~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def base_lens(~S:Data) -> Product.Lens<Resources(~S),BaseResources(),(Unit & Log.Log<Array<U32>>) & MachineState(~S)>:Binding.left_lens(~Resources(~S),~BaseResources(),~MachineState(~S),~(Unit & Log.Log<Array<U32>>),~user_lens(~S))
def base_cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),BaseResources(),(Unit & Log.Log<Array<U32>>) & MachineState(~S),BaseIndex(~S),base_lens(~S)>:Binding.left(~S,~Resources(~S),~BaseResources(),~MachineState(~S),~(Unit & Log.Log<Array<U32>>),~BaseIndex(~S),~Unit,~user_lens(~S),user_cursor(~S))
def CounterRest(~S:Data) -> Type:((Unit & Log.Log<Array<U32>>) & MachineState(~S)) & Array<U32>
def lens(~S:Data) -> Product.Lens<Resources(~S),Array<U32>,CounterRest(~S)>:Binding.left_lens(~Resources(~S),~Array<U32>,~Array<U32>,~((Unit & Log.Log<Array<U32>>) & MachineState(~S)),~base_lens(~S))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Array<U32>,CounterRest(~S),Schema.Resource<S,Array<U32>>,lens(~S)>:Binding.left(~S,~Resources(~S),~Array<U32>,~Array<U32>,~((Unit & Log.Log<Array<U32>>) & MachineState(~S)),~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,~base_lens(~S),base_cursor(~S))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Array<U32>,CounterRest(~S),lens(~S),counter(~S)>:Binding.bind(~S,~Resources(~S),~Array<U32>,~CounterRest(~S),~lens(~S),~cursor(~S))
def viewed(result:Array<U32> & U32) -> Array<U32> & U32:result
def view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def Ops(~S:Data) -> Type -> Type:Decl.write_ops(~S,~Array<U32>,~counter(~S),~U32)
def declaration(~S:Data) -> Decl.Declaration<S,Store(~S),Resources(~S),Notice(~S),Ops(~S),U32>:Decl.write(~S,~Store(~S),~Resources(~S),~Notice(~S),~Array<U32>,~CounterRest(~S),~U32,~lens(~S),~counter(~S),~binding(~S),~view,~U32.show)
def raw(~S:Data) -> Field.Declaration<S,T.Tx<World(~S),Notice(~S)>,Ops(~S)(T.Tx<World(~S),Notice(~S)>)>:Decl.ordinary(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~U32,declaration(~S))
def outcome(fail:Bool) -> T.Outcome<String>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{"expected-body-failure"}
def changed(~S:Data,~H:Type,~caps:Ops(~S)(H),fail:Bool,result:H & U32) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,+value):(Field.set(~S,~Array<U32>,~counter(~S),~H,~U32,~caps,owner,ANode{ALeaf{(value+1:U32)},ALeaf{(value+2:U32)}}),(outcome(fail),Unit{}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),fail:Bool,owner:H) -> H & (T.Outcome<String> & Unit):changed(~S,~H,~caps,fail,Field.get(~S,~Array<U32>,~counter(~S),~H,~U32,~caps,owner))
def runner(~S:Data) -> World(~S) -> Bool -> Sys.Outcome<World(~S),String,Unit>:Field.runner(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~Bool,~String,~Unit,~raw(~S),~body(~S))
def Registry(~S:Data) -> Type:Sys.Registry<S,Store(~S),Resources(~S),Notice(~S),Bool,String,Unit,runner(~S)>
def Owner(~S:Data) -> Type:Leaf.Record<S,Records.Token<Registry(~S)>>
def Owners0() -> Type:Unit
def Rows0() -> Data:Unit
def observe0(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows0()>:Build.empty_observe(~World(~S))
def fold0(~S:Data) -> Unit -> Unit & List<&2,Records.Fields<S>>:Leaf.empty(~S)
def Owners1(~S:Data) -> Type:Unit & Owner(~S)
def Rows1() -> Data:DTO.Product<Rows0(),U32>
def observe1(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows1()>:Tree.observe_pair(~World(~S),~Rows0(),~U32,~observe0(~S),~Leaves.resource_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~U32,~declaration(~S)))
def fold1(~S:Data) -> Owners1(~S) -> Owners1(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~fold0(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Owners2(~S:Data) -> Type:Owners1(~S) & Owner(~S)
def Rows2() -> Data:DTO.Product<Rows1(),U32>
def observe2(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows2()>:Tree.observe_pair(~World(~S),~Rows1(),~U32,~observe1(~S),~Leaves.resource_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~U32,~declaration(~S)))
def fold2(~S:Data) -> Owners2(~S) -> Owners2(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners1(~S),~Owner(~S),~fold1(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Owners3(~S:Data) -> Type:Owners2(~S) & Owner(~S)
def Rows3() -> Data:DTO.Product<Rows2(),U32>
def observe3(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows3()>:Tree.observe_pair(~World(~S),~Rows2(),~U32,~observe2(~S),~Leaves.resource_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~U32,~declaration(~S)))
def fold3(~S:Data) -> Owners3(~S) -> Owners3(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners2(~S),~Owner(~S),~fold2(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Registered0(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Rows0(),observe0(~S),fold0(~S)>
def Registered1(~S:Data) -> Type:Build.Registered<S,World(~S),Owners1(~S),Rows1(),observe1(~S),fold1(~S)>
def Registered2(~S:Data) -> Type:Build.Registered<S,World(~S),Owners2(~S),Rows2(),observe2(~S),fold2(~S)>
def Registered3(~S:Data) -> Type:Build.Registered<S,World(~S),Owners3(~S),Rows3(),observe3(~S),fold3(~S)>
def payload(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Payload")
def component_take(~S:Data,store:Store(~S)) -> Graph.Graph<S> & Col.Column<S,Array<U32>>:
  match store:
    case Relations.Store{column,graph}:(graph,column)
def component_put(~S:Data,graph:Graph.Graph<S>,column:Col.Column<S,Array<U32>>) -> Store(~S):Relations.Store{column,graph}
def component_binding(~S:Data) -> ComponentBinding.Binding<S,Store(~S),Graph.Graph<S>,Array<U32>,U32,Unit,component_take(~S),component_put(~S),view>:ComponentBinding.bind(~S,~Store(~S),~Graph.Graph<S>,~Array<U32>,~U32,~Unit,~component_take(~S),~component_put(~S),~view,payload(~S))
def ComponentOps(H:Type) -> Type:Cap.Write<H,Array<U32>,U32>
def component_query(~S:Data) -> Query.Declaration<S,Q.Frame<S,Store(~S),Resources(~S),Notice(~S)>,ComponentOps(Q.Frame<S,Store(~S),Resources(~S),Notice(~S)>),I.Frame<S,Store(~S),Resources(~S),Notice(~S)>,Cmp.Access<U32>>:Query.write_displayed(~S,~Store(~S),~Graph.Graph<S>,~Array<U32>,~U32,~Unit,~component_take(~S),~component_put(~S),~view,~Resources(~S),~Notice(~S),~U32.show,~component_binding(~S))
def component_value(~H:Type,~caps:ComponentOps(H),fail:Bool,result:H & Cmp.Access<U32>) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,Cmp.Found{+value}):(Cap.set(~H,~Array<U32>,~U32,~caps,owner,ANode{ALeaf{(value+1:U32)},ALeaf{(value+2:U32)}}),(outcome(fail),Unit{}))
    case (owner,_):(owner,(T.Failure{"missing-component"},Unit{}))
def component_body(~H:Type,~caps:ComponentOps(H),fail:Bool,owner:H) -> H & (T.Outcome<String> & Unit):component_value(~H,~caps,fail,Cap.get(~H,~Array<U32>,~U32,~caps,owner))
def component_render(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.Found{value}:"Found(" ++ U32.show(value) ++ ")"
    case Cmp.ComponentAbsent{}:"Absent"
    case Cmp.MissingEntity{}:"MissingEntity"
def component_runner(~S:Data) -> World(~S) -> (Bool & U32) -> Sys.Outcome<World(~S),Q.Error<String>,List<&2,Unit>>:ComponentSystem.observable_runner(~S,~Store(~S),~Resources(~S),~Notice(~S),~ComponentOps,~Bool,~String,~Unit,~Cmp.Access<U32>,~component_query(~S),~component_body)
def ComponentRegistry(~S:Data) -> Type:Sys.Registry<S,Store(~S),Resources(~S),Notice(~S),Bool & U32,Q.Error<String>,List<&2,Unit>,component_runner(~S)>
def ComponentOwner(~S:Data) -> Type:Leaf.Record<S,Records.Token<ComponentRegistry(~S)>>
def Owners4(~S:Data) -> Type:Owners3(~S) & ComponentOwner(~S)
def ComponentRows(~S:Data) -> Data:DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,Cmp.Access<U32>>>>
def Rows4(~S:Data) -> Data:DTO.Product<Rows3(),ComponentRows(~S)>
def observe4(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows4(~S)>:Tree.observe_pair(~World(~S),~Rows3(),~ComponentRows(~S),~observe3(~S),~ComponentLeaves.component_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~ComponentOps,~Cmp.Access<U32>,~component_query(~S),~component_render))
def fold4(~S:Data) -> Owners4(~S) -> Owners4(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners3(~S),~ComponentOwner(~S),~fold3(~S),~Leaf.observed(~S,~Records.Token<ComponentRegistry(~S)>))
def Registered4(~S:Data) -> Type:Build.Registered<S,World(~S),Owners4(~S),Rows4(~S),observe4(~S),fold4(~S)>

def registered4(~S:Data,app:Registered4(~S)) -> Maybe<&1,Registered4(~S)>:Some{app}
def failed3(~S:Data,_:Registered3(~S)) -> Maybe<&1,Registered4(~S)>:None{}
def registered3(~S:Data,app:Registered3(~S)) -> Maybe<&1,Registered4(~S)>:AppComponent.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners3(~S),~Rows3(),~observe3(~S),~fold3(~S),~ComponentOps,~Bool,~String,~Unit,~Cmp.Access<U32>,~component_query(~S),~component_render,~component_body,~Maybe<&1,Registered4(~S)>,registered4(~S),failed3(~S),app,"component","Payload")

def failed2(~S:Data,_:Registered2(~S)) -> Maybe<&1,Registered4(~S)>:None{}
def registered2(~S:Data,app:Registered2(~S)) -> Maybe<&1,Registered4(~S)>:AppField.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners2(~S),~Rows2(),~observe2(~S),~fold2(~S),~Ops(~S),~Bool,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Registered4(~S)>,registered3(~S),failed2(~S),app,"failure","Counter")
def failed1(~S:Data,_:Registered1(~S)) -> Maybe<&1,Registered4(~S)>:None{}
def registered1(~S:Data,app:Registered1(~S)) -> Maybe<&1,Registered4(~S)>:AppField.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners1(~S),~Rows1(),~observe1(~S),~fold1(~S),~Ops(~S),~Bool,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Registered4(~S)>,registered2(~S),failed1(~S),app,"skip","Counter")
def failed0(~S:Data,_:Registered0(~S)) -> Maybe<&1,Registered4(~S)>:None{}
def registered0(~S:Data,app:Registered0(~S)) -> Maybe<&1,Registered4(~S)>:AppField.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Unit,~Rows0(),~observe0(~S),~fold0(~S),~Ops(~S),~Bool,~String,~Unit,~U32,~declaration(~S),~body(~S),~Maybe<&1,Registered4(~S)>,registered1(~S),failed0(~S),app,"success","Counter")
def register_base(~S:Data,world:World(~S)) -> Maybe<&1,Registered4(~S)>:registered0(~S,Build.empty(~S,~World(~S),world))
def transport_returned(~S:Data,result:Transport.TransportResult<S,Context.Context<World(~S)>,Bool,String,Unit,Records.Token<Registry(~S)>>) -> Owner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:(Leaf.Record{token,fields},outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,"registration-refused"})
def call(~S:Data,owner:Owner(~S),world:Context.Context<World(~S)>,fail:Bool) -> Owner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match owner:
    case Leaf.Record{token,fields}:transport_returned(~S,ExecutionRun.resource_field(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~Bool,~String,~Unit,~U32,~declaration(~S),~body(~S),token,fields,world,fail))
def first_returned(~S:Data,second:Owner(~S),third:Owner(~S),value:Owner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>) -> Owners3(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match value:
    case (first,outcome):((((Unit{},first),second),third),outcome)
def second_returned(~S:Data,first:Owner(~S),third:Owner(~S),value:Owner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>) -> Owners3(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match value:
    case (second,outcome):((((Unit{},first),second),third),outcome)
def third_returned(~S:Data,first:Owner(~S),second:Owner(~S),value:Owner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>) -> Owners3(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match value:
    case (third,outcome):((((Unit{},first),second),third),outcome)
def dispatch3(~S:Data,owners:Owners3(~S),world:Context.Context<World(~S)>,id:U32) -> Owners3(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match owners id:
    case (((Unit{},first),second),third) 1:first_returned(~S,second,third,call(~S,first,world,False{}))
    case (((Unit{},first),second),third) 2:second_returned(~S,first,third,call(~S,second,world,False{}))
    case (((Unit{},first),second),third) 3:third_returned(~S,first,second,call(~S,third,world,True{}))
    case owners _:(owners,Sys.Failed{world,"unknown-system"})
def component_error(error:Q.Error<String>) -> String:
  match error:
    case Q.UserError{error}:error
    case Q.AccessError{error}:Cmp.trace_error(error)
def component_outcome(~S:Data,result:Sys.Outcome<Context.Context<World(~S)>,Q.Error<String>,List<&2,Unit>>) -> Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match result:
    case Sys.Succeeded{world,_}:Sys.Succeeded{world,Unit{}}
    case Sys.Failed{world,error}:Sys.Failed{world,component_error(error)}
def component_returned(~S:Data,result:Transport.TransportResult<S,Context.Context<World(~S)>,Bool & U32,Q.Error<String>,List<&2,Unit>,Records.Token<ComponentRegistry(~S)>>) -> ComponentOwner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:(Leaf.Record{token,fields},component_outcome(~S,outcome))
    case Transport.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,"registration-refused"})
def component_call(~S:Data,owner:ComponentOwner(~S),world:Context.Context<World(~S)>) -> ComponentOwner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match owner:
    case Leaf.Record{token,fields}:component_returned(~S,ExecutionRun.component(~S,~Store(~S),~Resources(~S),~Notice(~S),~ComponentOps,~Bool,~String,~Unit,~Cmp.Access<U32>,~component_query(~S),~component_body,token,fields,world,False{}))
def dispatch_component_done(~S:Data,owners:Owners3(~S),result:ComponentOwner(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>) -> Owners4(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match result:
    case (owner,outcome):((owners,owner),outcome)
def dispatch_resource_done(~S:Data,component:ComponentOwner(~S),result:Owners3(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>) -> Owners4(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match result:
    case (owners,outcome):((owners,component),outcome)
def dispatch4(~S:Data,owners:Owners4(~S),world:Context.Context<World(~S)>,id:U32) -> Owners4(~S) & Sys.Outcome<Context.Context<World(~S)>,String,Unit>:
  match owners id:
    case (owners,component) 4:dispatch_component_done(~S,owners,component_call(~S,component,world))
    case (owners,component) id:dispatch_resource_done(~S,component,dispatch3(~S,owners,world,id))
def condition(~S:Data,world:World(~S),slot:U32) -> World(~S) & Bool:
  match slot:
    case 1:(world,False{})
    case _:(world,True{})
def provision(~S:Data,world:World(~S)) -> World(~S) & List<&2,SP.Requirement<S>>:(world,[])
def empty(~S:Data,_:Unit) -> Store(~S):Relations.empty(~S,~Col.Column<S,Array<U32>>,Col.empty_indexed(~S,~Array<U32>))
def resources(~S:Data) -> Resources(~S):Product.Owner{Product.Owner{Product.Owner{ANode{ALeaf{10},ALeaf{11}},ANode{ALeaf{900},ALeaf{901}}},Init.empty(~S,~Mode,~U32)},Log.empty(~Array<U32>)}
def command_returned(~S:Data,value:World(~S) & U32) -> World(~S):
  match value:
    case (world,_):world
def command(~S:Data,world:World(~S)) -> World(~S):command_returned(~S,W.advance_clock(~S,~Store(~S),~Resources(~S),~Notice(~S),world))
def queued(~S:Data,world:World(~S)) -> World(~S):W.enqueue(~S,~Store(~S),~Resources(~S),~Notice(~S),world,command(~S))
type Collector is Type:Collector{calls:U32,events:List<&2,Trace.TraceEvent<String>>,owned:Array<U32>}
def step_returned(calls:U32,events:List<&2,Trace.TraceEvent<String>>,event:Trace.TraceEvent<String>,value:Array<U32> & U32) -> Collector:
  match value:
    case (owned,n):Collector{(calls+1:U32),List.append(&2,Trace.TraceEvent<String>,events,[event]),Array.set(U32,owned,0,(n+1:U32))}
def step(state:Collector,event:Trace.TraceEvent<String>) -> Collector:
  match state:
    case Collector{calls,events,owned}:step_returned(calls,events,event,Array.get(U32,owned,0))
def Subscriber() -> Type:Trace.Subscriber<Collector,String,step>
def collector(first:U32,second:U32) -> Collector:Collector{0,[],ANode{ALeaf{first},ALeaf{second}}}

type SeedEvidence<S:Data> is Type:
  SeedEvidence{reservation:W.Reservation<S>,activation:W.Status,write:W.Status,recovered:Maybe<&1,Array<U32>>}
def seed_finished(~S:Data,reservation:W.Reservation<S>,activation:W.Status,write:W.Status,recovered:Maybe<&1,Array<U32>>,result:T.Returned<World(~S),String>) -> World(~S) & SeedEvidence<S>:
  match result:
    case T.Returned{world,_}:(world,SeedEvidence{reservation,activation,write,recovered})
def seed_written(~S:Data,reservation:W.Reservation<S>,activation:W.Status,result:Cmp.SetResult<T.Tx<World(~S),Notice(~S)>,Array<U32>>) -> World(~S) & SeedEvidence<S>:
  match result:
    case Cmp.Written{tx}:seed_finished(~S,reservation,activation,W.Accepted{},None{},T.finish(~World(~S),~Notice(~S),~String,~Commands.enqueue(~S,~Store(~S),~Resources(~S),~Notice(~S)),~Commands.publish(~S,~Store(~S),~Resources(~S),~Notice(~S)),tx,T.Success{}))
    case Cmp.WriteRejected{tx,incoming,+error}:seed_finished(~S,reservation,activation,W.Rejected{error},Some{incoming},T.finish(~World(~S),~Notice(~S),~String,~Commands.enqueue(~S,~Store(~S),~Resources(~S),~Notice(~S)),~Commands.publish(~S,~Store(~S),~Resources(~S),~Notice(~S)),tx,T.Failure{Cmp.trace_error(error)}))
    case Cmp.WriteFailure{tx,+error}:seed_finished(~S,reservation,activation,W.Rejected{error},None{},T.finish(~World(~S),~Notice(~S),~String,~Commands.enqueue(~S,~Store(~S),~Resources(~S),~Notice(~S)),~Commands.publish(~S,~Store(~S),~Resources(~S),~Notice(~S)),tx,T.Failure{Cmp.trace_error(error)}))
def seed_activated(~S:Data,+reservation:W.Reservation<S>,+handle:W.Handle<S>,result:World(~S) & W.Status) -> World(~S) & SeedEvidence<S>:
  match result:
    case (world,W.Rejected{+error}):(world,SeedEvidence{reservation,W.Rejected{error},W.Rejected{error},None{}})
    case (world,W.Accepted{}):seed_written(~S,reservation,W.Accepted{},Cmp.tx_set(~S,~Store(~S),~Resources(~S),~Notice(~S),~Graph.Graph<S>,~Array<U32>,~U32,~Unit,~component_take(~S),~component_put(~S),~view,ComponentBinding.family(~S,~Store(~S),~Graph.Graph<S>,~Array<U32>,~U32,~Unit,~component_take(~S),~component_put(~S),~view,component_binding(~S)),T.begin(~World(~S),~Notice(~S),world),handle,ANode{ALeaf{20},ALeaf{21}}))
def seed_reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> World(~S) & SeedEvidence<S>:
  match result:
    case (world,W.ReservationRejected{+error}):(world,SeedEvidence{W.ReservationRejected{error},W.Rejected{error},W.Rejected{error},None{}})
    case (world,W.Reserved{+handle}):seed_activated(~S,W.Reserved{handle},handle,W.activate(~S,~Store(~S),~Resources(~S),~Notice(~S),world,handle))
def setup(~S:Data,world:World(~S)) -> World(~S) & SeedEvidence<S>:seed_reserved(~S,W.reserve_id(~S,~Store(~S),~Resources(~S),~Notice(~S),world))

def take_state(~S:Data,resource:Resources(~S)) -> Resources(~S) & MachineState(~S):
  match resource:
    case Product.Owner{Product.Owner{base,+state},log}:(Product.Owner{Product.Owner{base,state},log},state)
def put_state(~S:Data,resource:Resources(~S),state:MachineState(~S)) -> Resources(~S):
  match resource:
    case Product.Owner{Product.Owner{base,_},log}:Product.Owner{Product.Owner{base,state},log}
def take_slot(~S:Data) -> Resources(~S) -> Resources(~S) & Machine.Slot<S,Mode,U32>:Init.take_slot(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S))
def put_slot(~S:Data) -> Resources(~S) -> Machine.Slot<S,Mode,U32> -> Resources(~S):Init.put_slot(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~U32.is_eq)
def machine(~S:Data) -> MD.Declaration<S,Mode,U32,Resources(~S),take_slot(~S)>:Init.declared(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),"Mode",[0,1,2,3,4])
def machine_declaration(~S:Data) -> Decl.Declaration<S,Store(~S),Resources(~S),Notice(~S),Decl.machine_ops(~S,~Mode,~U32),Machine.CurrentView<S,Mode,U32>>:Decl.machine_write(~S,~Mode,~U32,~Store(~S),~Resources(~S),~Notice(~S),~take_slot(~S),~put_slot(~S),~U32.is_eq,~machine(~S),~U32.show)
def machine_changed(~S:Data,~H:Type,~caps:Decl.machine_ops(~S,~Mode,~U32)(H),result:H & Machine.CurrentView<S,Mode,U32>) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,Machine.Current{value}):(Cap.value_set(~H,~Machine.QueueInput<U32>,~Machine.CurrentView<S,Mode,U32>,~caps,owner,Machine.Set{(value+1:U32),False{}}),(T.Success{},Unit{}))
    case (owner,Machine.Unavailable{}):(owner,(T.Failure{"MissingMode"},Unit{}))
def machine_body(~S:Data,~H:Type,~caps:Decl.machine_ops(~S,~Mode,~U32)(H),_:Unit,owner:H) -> H & (T.Outcome<String> & Unit):machine_changed(~S,~H,~caps,Cap.value_get(~H,~Machine.QueueInput<U32>,~Machine.CurrentView<S,Mode,U32>,~caps,owner))
def relation(~S:Data) -> RelationDecl.Declaration<S>:RelationDecl.relation(~S,Graph.Descriptor{17,"Follows","FollowedBy",Graph.Ordinary{}})
def relation_declaration(~S:Data) -> Decl.Declaration<S,Store(~S),Resources(~S),Notice(~S),Decl.relation_ops(~S),AppRelation.View<S>>:Decl.relation_write(~S,~Col.Column<S,Array<U32>>,~Resources(~S),~Nat,~relation(~S))
type RelationArgs<S:Data> is Data:RelationArgs{source:W.Handle<S>,target:W.Handle<S>,clear:Bool}
def relation_changed(~H:Type,result:H & Relations.QueueStatus) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,_):(owner,(T.Success{},Unit{}))
def relation_body(~S:Data,~H:Type,~caps:Decl.relation_ops(~S)(H),args:RelationArgs<S>,owner:H) -> H & (T.Outcome<String> & Unit):
  match args:
    case RelationArgs{source,target,False{}}:relation_changed(~H,RelationOps.relate(~H,~S,~caps,owner,RelationOps.Targets{source,target}))
    case RelationArgs{source,_,True{}}:relation_changed(~H,RelationOps.unrelate(~H,~S,~caps,owner,source))
def event_domain(~S:Data) -> Pub.Domain<S,Array<U32>>:Pub.domain(~S,~Array<U32>,"Cargo")
def event_path(~S:Data) -> Product.Lens<Resources(~S),Log.Log<Array<U32>>,UserResources(~S) & Unit>:EventBinding.right_path(~UserResources(~S),~Log.Log<Array<U32>>,~Array<U32>,~Unit,~EventBinding.identity_lens(~Log.Log<Array<U32>>))
def event_inject(~S:Data) -> Nat -> Notice(~S):EventBinding.notice_inject(~S,~Nat,~EventRoute.inject_leaf)
def event_select(~S:Data) -> List<&2,Notice(~S)> -> List<&2,Nat>:EventBinding.notice_select(~S,~Nat,~EventRoute.select_leaf)
def event_binding(~S:Data) -> EventBinding.Binding<S,Resources(~S),Array<U32>,UserResources(~S) & Unit,Notice(~S),event_path(~S),event_inject(~S),event_select(~S),event_domain(~S)>:EventBinding.under_notice(~S,~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Nat,~event_path(~S),~EventRoute.inject_leaf,~EventRoute.select_leaf,~event_domain(~S),EventBinding.under_resource(~S,~UserResources(~S),~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~EventBinding.identity_lens(~Log.Log<Array<U32>>),~EventRoute.inject_leaf,~EventRoute.select_leaf,~event_domain(~S),EventBinding.leaf(~S,~Array<U32>,~event_domain(~S))))
def EventOps(~S:Data) -> Type -> Type:EventWrite.Ops(~S,~Array<U32>,~event_domain(~S))
type PublishArgs is Type:PublishArgs{payload:Array<U32>,fail:Bool}
def publish_outcome(fail:Bool) -> T.Outcome<String>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{"ExpectedPublicationFailure"}
def publish_body(~S:Data,~H:Type,~caps:EventOps(~S)(H),args:PublishArgs,owner:H) -> H & (T.Outcome<String> & Unit):
  match args:
    case PublishArgs{payload,fail}:(Pub.emit(~S,~Array<U32>,~event_domain(~S),~H,~caps,owner,payload),(publish_outcome(fail),Unit{}))
def event_declaration(~S:Data) -> Events.Declaration<S,World(~S),List<Array<U32>>,EventOps(~S),EventWrite.grant(~S,~Store(~S),~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Notice(~S),~event_path(~S),~event_inject(~S),~event_domain(~S))>:EventWrite.declaration(~S,~Store(~S),~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Notice(~S),~event_path(~S),~event_inject(~S),~event_select(~S),~event_domain(~S),~event_binding(~S))
def handler_failure(value:Handlers.Invocation<U32>) -> Bool:
  match value:
    case Handlers.Invocation{Handlers.Transition{},_,_,to}:U32.is_eq(to,3)
    case _:False{}
def handler_changed(~S:Data,~H:Type,~caps:Ops(~S)(H),fail:Bool,result:H & U32) -> H & (T.Outcome<String> & Unit):
  match result:
    case (owner,+value):(Field.set(~S,~Array<U32>,~counter(~S),~H,~U32,~caps,owner,ANode{ALeaf{(value+1:U32)},ALeaf{(value+2:U32)}}),(outcome(fail),Unit{}))
def handler_body(~S:Data,~H:Type,~caps:Ops(~S)(H),invocation:Handlers.Invocation<U32>,owner:H) -> H & (T.Outcome<String> & Unit):handler_changed(~S,~H,~caps,handler_failure(invocation),Field.get(~S,~Array<U32>,~counter(~S),~H,~U32,~caps,owner))
def handler_runner(~S:Data) -> World(~S) -> Handlers.Invocation<U32> -> Sys.Outcome<World(~S),String,Unit>:Field.runner(~S,~Store(~S),~Resources(~S),~Notice(~S),~Ops(~S),~Handlers.Invocation<U32>,~String,~Unit,~raw(~S),~handler_body(~S))
def HandlerOwners(~S:Data) -> Type:Handlers.Owners<S,Store(~S),Resources(~S),Notice(~S),U32,handler_runner(~S)>
def marker_publish(~S:Data) -> World(~S) -> Machine.Transition<U32> -> World(~S):Marker.publish(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Store(~S),~Notice(~S))
def inserted(~S:Data,world:World(~S)) -> World(~S):Init.insert_state(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Store(~S),~Notice(~S),~machine(~S),world,0)

def MachineRegistry(~S:Data) -> Type:Sys.Registry<S,Store(~S),Resources(~S),Notice(~S),Unit,String,Unit,Field.runner(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.machine_ops(~S,~Mode,~U32),~Unit,~String,~Unit,~Decl.ordinary(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.machine_ops(~S,~Mode,~U32),~Machine.CurrentView<S,Mode,U32>,machine_declaration(~S)),~machine_body(~S))>
def MachineOwner(~S:Data) -> Type:Leaf.Record<S,Records.Token<MachineRegistry(~S)>>
def Owners5(~S:Data) -> Type:Owners4(~S) & MachineOwner(~S)
def Rows5(~S:Data) -> Data:DTO.Product<Rows4(~S),Machine.CurrentView<S,Mode,U32>>
def observe5(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows5(~S)>:Tree.observe_pair(~World(~S),~Rows4(~S),~Machine.CurrentView<S,Mode,U32>,~observe4(~S),~Leaves.resource_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.machine_ops(~S,~Mode,~U32),~Machine.CurrentView<S,Mode,U32>,~machine_declaration(~S)))
def fold5(~S:Data) -> Owners5(~S) -> Owners5(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners4(~S),~MachineOwner(~S),~fold4(~S),~Leaf.observed(~S,~Records.Token<MachineRegistry(~S)>))
def Registered5(~S:Data) -> Type:Build.Registered<S,World(~S),Owners5(~S),Rows5(~S),observe5(~S),fold5(~S)>

def RelationRegistry(~S:Data) -> Type:Sys.Registry<S,Store(~S),Resources(~S),Notice(~S),RelationArgs<S>,String,Unit,Field.runner(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.relation_ops(~S),~RelationArgs<S>,~String,~Unit,~Decl.ordinary(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.relation_ops(~S),~AppRelation.View<S>,relation_declaration(~S)),~relation_body(~S))>
def RelationOwner(~S:Data) -> Type:Leaf.Record<S,Records.Token<RelationRegistry(~S)>>
def Owners6(~S:Data) -> Type:Owners5(~S) & RelationOwner(~S)
def Rows6(~S:Data) -> Data:DTO.Product<Rows5(~S),AppRelation.View<S>>
def observe6(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows6(~S)>:Tree.observe_pair(~World(~S),~Rows5(~S),~AppRelation.View<S>,~observe5(~S),~Leaves.resource_observe(~S,~Store(~S),~Resources(~S),~Notice(~S),~Decl.relation_ops(~S),~AppRelation.View<S>,~relation_declaration(~S)))
def fold6(~S:Data) -> Owners6(~S) -> Owners6(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners5(~S),~RelationOwner(~S),~fold5(~S),~Leaf.observed(~S,~Records.Token<RelationRegistry(~S)>))
def Registered6(~S:Data) -> Type:Build.Registered<S,World(~S),Owners6(~S),Rows6(~S),observe6(~S),fold6(~S)>
def PublisherRegistry(~S:Data) -> Type:Publisher.Registry(~S,~Store(~S),~Resources(~S),~Notice(~S),~List<Array<U32>>,~EventOps(~S),~EventWrite.grant(~S,~Store(~S),~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Notice(~S),~event_path(~S),~event_inject(~S),~event_domain(~S)),~event_declaration(~S),~PublishArgs,~String,~Unit,~publish_body(~S))
def PublisherOwner(~S:Data) -> Type:Leaf.Record<S,Records.Token<PublisherRegistry(~S)>>
def Owners7(~S:Data) -> Type:Owners6(~S) & PublisherOwner(~S)
def Rows7(~S:Data) -> Data:Rows6(~S)
def observe7(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows7(~S)>:observe6(~S)
def fold7(~S:Data) -> Owners7(~S) -> Owners7(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Owners6(~S),~PublisherOwner(~S),~fold6(~S),~Leaf.observed(~S,~Records.Token<PublisherRegistry(~S)>))
def Registered7(~S:Data) -> Type:Build.Registered<S,World(~S),Owners7(~S),Rows7(~S),observe7(~S),fold7(~S)>
type Held<S:Data> is Type:
  Held{source:W.Handle<S>,target:W.Handle<S>,incoming:List<Array<U32>>,retry:List<Array<U32>>,publicationCalls:U32,relationCalls:U32,outcomes:List<&2,T.Outcome<String>>}
def Owners(~S:Data) -> Type:Owners7(~S) & Held<S>
def Rows(~S:Data) -> Data:Rows7(~S)
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows(~S)>:observe7(~S)
def held_folded(~S:Data,held:Held<S>,result:Owners7(~S) & List<&2,Records.Fields<S>>) -> Owners(~S) & List<&2,Records.Fields<S>>:
  match result:
    case (owners,fields):((owners,held),fields)
def fold(~S:Data,owners:Owners(~S)) -> Owners(~S) & List<&2,Records.Fields<S>>:
  match owners:
    case (owners,held):held_folded(~S,held,fold7(~S)(owners))
def Application(~S:Data) -> Type:Single.Application<S,Store(~S),Resources(~S),Notice(~S),Owners(~S),Rows(~S),observe(~S),fold(~S)>

def publisher_registered(~S:Data,result:AppPublisher.Appended<Registered6(~S),Registered7(~S)>) -> Maybe<&1,Registered7(~S)>:
  match result:
    case AppPublisher.Appended{app}:Some{app}
    case AppPublisher.AppendRejected{_}:None{}
def register7(~S:Data,app:Registered6(~S)) -> Maybe<&1,Registered7(~S)>:publisher_registered(~S,AppPublisher.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~List<Array<U32>>,~EventOps(~S),~EventWrite.grant(~S,~Store(~S),~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Notice(~S),~event_path(~S),~event_inject(~S),~event_domain(~S)),~event_declaration(~S),~PublishArgs,~String,~Unit,~publish_body(~S),~Owners6(~S),~Rows6(~S),~observe6(~S),~fold6(~S),app,"publisher"))
def refused5(~S:Data,_:Registered5(~S)) -> Maybe<&1,Registered7(~S)>:None{}
def register6(~S:Data,app:Registered5(~S)) -> Maybe<&1,Registered7(~S)>:AppField.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners5(~S),~Rows5(~S),~observe5(~S),~fold5(~S),~Decl.relation_ops(~S),~RelationArgs<S>,~String,~Unit,~AppRelation.View<S>,~relation_declaration(~S),~relation_body(~S),~Maybe<&1,Registered7(~S)>,register7(~S),refused5(~S),app,"relation","Follows")
def refused4(~S:Data,_:Registered4(~S)) -> Maybe<&1,Registered7(~S)>:None{}
def register5(~S:Data,app:Registered4(~S)) -> Maybe<&1,Registered7(~S)>:AppField.register(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners4(~S),~Rows4(~S),~observe4(~S),~fold4(~S),~Decl.machine_ops(~S,~Mode,~U32),~Unit,~String,~Unit,~Machine.CurrentView<S,Mode,U32>,~machine_declaration(~S),~machine_body(~S),~Maybe<&1,Registered7(~S)>,register6(~S),refused4(~S),app,"machine-queue","Mode")
def base_registered(~S:Data,result:Maybe<&1,Registered4(~S)>) -> Maybe<&1,Registered7(~S)>:
  match result:
    case None{}:None{}
    case Some{app}:register5(~S,app)
def register(~S:Data,world:World(~S)) -> Maybe<&1,Registered7(~S)>:base_registered(~S,register_base(~S,world))
def app_schema(~S:Data) -> Schema.Schema<S,Store(~S),Resources(~S)>:Schema.Schema{List.append(&2,Fragment.Entry<S>,Binding.entries(~S,~Resources(~S),~Index(~S),schema(~S)),List.append(&2,Fragment.Entry<S>,Schema.entries(~S,~Col.Column<S,Array<U32>>,~Unit,Schema.component(~S,~Array<U32>,payload(~S))),List.append(&2,Fragment.Entry<S>,Decl.relation_entries(~S,relation(~S)),AppPublisher.entries(~S,Events.description(~S,~World(~S),~List<Array<U32>>,~EventOps(~S),~EventWrite.grant(~S,~Store(~S),~Resources(~S),~Array<U32>,~(UserResources(~S) & Unit),~Notice(~S),~event_path(~S),~event_inject(~S),~event_domain(~S)),event_declaration(~S))))))}
def planned(~S:Data,steps:List<&2,Sch.Step>) -> SP.Plan<S>:
  match steps:
    case []:SP.Empty{}
    case step <> rest:SP.Sequence{SP.Entry{step,[]},planned(~S,rest)}
def full_plan(~S:Data) -> SP.Plan<S>:planned(~S,[Sch.Phase{"operations"},Sch.System{4,0},Sch.System{7,0},Sch.System{8,0},Sch.System{9,0},Sch.System{10,0},Sch.Barrier{},Sch.System{5,1},Sch.System{6,0},Sch.Barrier{}])
def attached(~S:Data,result:Single.Attachment<App.Application<S,Store(~S),Resources(~S),Notice(~S),Owners(~S),Rows(~S),observe(~S),fold(~S)>,Application(~S)>) -> Maybe<&1,Application(~S)>:
  match result:
    case Single.Attached{app}:Some{app}
    case Single.Invalid{_}:None{}
def attach_inputs(~S:Data,app:Registered7(~S),held:Held<S>) -> Maybe<&1,Application(~S)>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:attached(~S,Single.attach(~S,~Store(~S),~Resources(~S),~Notice(~S),~Owners(~S),~Rows(~S),~observe(~S),~fold(~S),App.Application{app_schema(~S),Build.Registered{world,(owners,held),recipe,debug}},"full-operation-trace",full_plan(~S)))
def held(~S:Data,source:W.Handle<S>,target:W.Handle<S>) -> Held<S>:Held{source,target,[ANode{ALeaf{70},ALeaf{71}},ANode{ALeaf{80},ALeaf{81}},ANode{ALeaf{90},ALeaf{91}}],[],0,0,[]}
