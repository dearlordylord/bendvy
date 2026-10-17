import Base
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/resource-field-binding.bend as Binding
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../../src/ecs/ordinary-app-resource-field-declaration.bend as D
import ../../../../src/ecs/ordinary-app-machine-handler-field.bend as Factory
import ../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../src/ecs/ordinary-machine-schedule.bend as Ordinary
import ../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-world.bend as MW
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../src/ecs/ordinary-machine-initialization-marker.bend as Marker
import ../../../../src/ecs/ordinary-machine-operations.bend as MachineOps
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/system.bend as Sys

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Mode is Data:Mode{}
type Need is Data:ModeRequired{}
def Resources(~S:Data) -> Type:Product.Owner<Array<U32>,Init.State<S,Mode,U32>>
def World(~S:Data) -> Type:W.World<S,Unit,Resources(~S),Unit>
def counter(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"Counter")
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Binding.Built<S,Init.State<S,Mode,U32>,Unit>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:Binding.joined(~S,~Array<U32>,~Init.State<S,Mode,U32>,~Schema.Resource<S,Array<U32>>,~Unit,Binding.leaf(~S,~Array<U32>,counter(~S)),Binding.Built{[],Unit{}})
def Rest(~S:Data) -> Type:Unit & Init.State<S,Mode,U32>
def lens(~S:Data) -> Product.Lens<Resources(~S),Array<U32>,Rest(~S)>:Binding.left_lens(~Resources(~S),~Array<U32>,~Init.State<S,Mode,U32>,~Unit,~Binding.whole(~Resources(~S)))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Array<U32>,Rest(~S),Schema.Resource<S,Array<U32>>,lens(~S)>:Binding.left(~S,~Resources(~S),~Array<U32>,~Init.State<S,Mode,U32>,~Unit,~Schema.Resource<S,Array<U32>>,~Unit,~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Array<U32>,Rest(~S),lens(~S),counter(~S)>:Binding.bind(~S,~Resources(~S),~Array<U32>,~Rest(~S),~lens(~S),~cursor(~S))
def view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def Ops(~S:Data) -> Type -> Type:D.write_ops(~S,~Array<U32>,~counter(~S),~U32)
def declaration(~S:Data) -> D.Declaration<S,Unit,Resources(~S),Unit,Ops(~S),U32>:D.write(~S,~Unit,~Resources(~S),~Unit,~Array<U32>,~Rest(~S),~U32,~lens(~S),~counter(~S),~binding(~S),~view,~U32.show)
def body_outcome(fail:Bool) -> T.Outcome<String>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{"expected-transition-failure"}
def changed(~S:Data,~Owner:Type,~caps:Ops(~S)(Owner),+ordinal:U32,fail:Bool,result:Owner & U32) -> Owner & (T.Outcome<String> & Unit):
  match result:
    case (owner,value):(Field.set(~S,~Array<U32>,~counter(~S),~Owner,~U32,~caps,owner,ANode{ALeaf{U32.add(value,ordinal)},ALeaf{ordinal}}),(body_outcome(fail),Unit{}))
def body(~S:Data,~Owner:Type,~caps:Ops(~S)(Owner),input:H.Invocation<U32>,owner:Owner) -> Owner & (T.Outcome<String> & Unit):
  match input:
    case H.Invocation{_,+ordinal,_,to}:changed(~S,~Owner,~caps,ordinal,Bool.and(U32.is_eq(to,2),U32.is_eq(ordinal,5)),Field.get(~S,~Array<U32>,~counter(~S),~Owner,~U32,~caps,owner))
    case H.InitialEnter{ordinal,_}:changed(~S,~Owner,~caps,ordinal,False{},Field.get(~S,~Array<U32>,~counter(~S),~Owner,~U32,~caps,owner))
def take_state(~S:Data,resources:Resources(~S)) -> Resources(~S) & Init.State<S,Mode,U32>:
  match resources:
    case Product.Owner{counter,+state}:(Product.Owner{counter,state},state)
def put_state(~S:Data,resources:Resources(~S),state:Init.State<S,Mode,U32>) -> Resources(~S):
  match resources:
    case Product.Owner{counter,_}:Product.Owner{counter,state}
def take_slot(~S:Data) -> Resources(~S) -> Resources(~S) & M.Slot<S,Mode,U32>:Init.take_slot(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S))
def put_slot(~S:Data) -> Resources(~S) -> M.Slot<S,Mode,U32> -> Resources(~S):Init.put_slot(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~U32.is_eq)
def machine(~S:Data) -> MD.Declaration<S,Mode,U32,Resources(~S),take_slot(~S)>:Init.declared(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),"Mode",[0,1,2])
def empty(~S:Data,_:Unit) -> Unit:Unit{}
def resources(~S:Data) -> Resources(~S):Product.Owner{ANode{ALeaf{10},ALeaf{11}},Init.empty(~S,~Mode,~U32)}
def requirement_same(first:Need,second:Need) -> Bool:True{}
def available(result:List<&2,String>) -> Bool:
  match result:
    case []:True{}
    case _:False{}
def required_returned(~S:Data,result:World(~S) & List<&2,String>) -> World(~S) & Bool:
  match result:
    case (world,missing):(world,available(missing))
def has(~S:Data,world:World(~S),_:Need) -> World(~S) & Bool:required_returned(~S,MD.required(~S,~Mode,~U32,~Unit,~Resources(~S),~Unit,~take_slot(~S),~machine(~S),world))
def frame(~S:Data,world:World(~S)) -> World(~S):world
def publish(~S:Data) -> World(~S) -> M.Transition<U32> -> World(~S):Marker.publish(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Unit,~Unit)
def Application(~S:Data) -> Type:Factory.Application(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S),~Array<U32>)
def Entry(~S:Data) -> Type:Factory.Entry(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S))
def Bundle(~S:Data) -> Type:Factory.Bundle(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S))
def runner(~S:Data) -> World(~S) -> H.Invocation<U32> -> Sys.Outcome<World(~S),String,Unit>:Field.runner(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~H.Invocation<U32>,~String,~Unit,~D.ordinary(~S,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,declaration(~S)),~body(~S))
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):App.enabled(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~runner(~S),~Array<U32>,app,flag)
def run(~S:Data,app:Application(~S)) -> App.RunResult<S,Mode,U32,Need,Unit,Resources(~S),Unit,runner(~S),Array<U32>> & Trace.Batch<String>:Factory.run(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S),~take_slot(~S),~put_slot(~S),~machine(~S),~publish(~S),~U32.is_eq,~requirement_same,~has(~S),~frame(~S),~Array<U32>,app)
def resume(~S:Data,value:App.RunResult<S,Mode,U32,Need,Unit,Resources(~S),Unit,runner(~S),Array<U32>>) -> Application(~S) & B.Status<Need>:Factory.resume(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~runner(~S),~Array<U32>,value)
type Plan<S:Data> is Data:Plan{selector:B.Selector<S,Mode,U32>,ordinal:U32,name:String}
def plans(~S:Data) -> List<&2,Plan<S>>:[Plan{B.ExitFrom{0},1,"exit-zero"},Plan{B.TransitionPair{0,1},2,"zero-one"},Plan{B.EnterTo{1},3,"enter-one"},Plan{B.ExitFrom{1},4,"exit-one"},Plan{B.TransitionPair{1,2},5,"one-two-fails"},Plan{B.EnterTo{2},6,"enter-two"}]
def tree(~S:Data,entries:List<Entry(~S)>) -> B.Tree<S,Mode,U32,Need,Unit,Resources(~S),Unit,runner(~S)>:
  match entries:
    case []:B.Empty{}
    case first <> rest:B.Join{B.Single{first},tree(~S,rest)}
type Setup<S:Data> is Type:
  Ready{app:Application(~S)}
  Rejected{world:World(~S),entries:List<Entry(~S)>,plans:List<&2,Plan<S>>}
def bound(~S:Data,entries:List<Entry(~S)>,result:World(~S) & U32) -> Setup<S>:
  match result:
    case (world,namespace):Ready{Factory.bind(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S),~Array<U32>,world,B.bundle(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~runner(~S),namespace,tree(~S,entries)),Ordinary.declare(~S,"selector-phases"),ANode{ALeaf{600},ALeaf{601}})}
def next_registered(~S:Data,entries:List<Entry(~S)>,rest:List<&2,Plan<S>>,result:Factory.Registration<S,Mode,U32,Need,Unit,Resources(~S),Unit,runner(~S)>,next:World(~S) -> List<Entry(~S)> -> Setup<S>) -> Setup<S>:
  match result:
    case Factory.Registered{world,entry}:next(world,List.append(&1,Entry(~S),entries,[entry]))
    case Factory.Rejected{world,selector,_,ordinal,name}:Rejected{world,entries,Plan{selector,ordinal,name} <> rest}
def register(~S:Data,plans:List<&2,Plan<S>>,world:World(~S),entries:List<Entry(~S)>) -> Setup<S>:
  match plans:
    case []:bound(~S,entries,W.namespace(~S,~Unit,~Resources(~S),~Unit,world))
    case Plan{selector,ordinal,name} <> +rest:next_registered(~S,entries,rest,Factory.register(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S),~body(~S),world,selector,[ModeRequired{}],ordinal,name),w => es => register(~S,rest,w,es))
def clocked(~S:Data,result:World(~S) & U32) -> World(~S):
  match result:
    case (world,_):world
def advance(~S:Data,world:World(~S)) -> World(~S):clocked(~S,W.advance_clock(~S,~Unit,~Resources(~S),~Unit,world))
def setup(~S:Data,world:World(~S)) -> Setup<S>:register(~S,plans(~S),W.enqueue(~S,~Unit,~Resources(~S),~Unit,world,advance(~S)),[])
def insert_world(~S:Data,world:World(~S)) -> World(~S):Init.insert_state(~S,~Mode,~U32,~Resources(~S),~take_state(~S),~put_state(~S),~Unit,~Unit,~machine(~S),world,0)
def insert(~S:Data,app:Application(~S)) -> Application(~S):
  match app:
    case App.Application{world,bundle,declaration,extra,debug}:App.Application{insert_world(~S,world),bundle,declaration,extra,debug}
    case app:app
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,App.Description<S,Mode,U32,Need>>:App.snapshot(~S,~Mode,~U32,~Need,~Unit,~Resources(~S),~Unit,~runner(~S),~Array<U32>,app)
def queue_returned(~S:Data,bundle:Bundle(~S),declaration:Ordinary.Declaration<S>,extra:Array<U32>,debug:Bool,result:T.Returned<World(~S),String>) -> Application(~S) & T.Outcome<String>:
  match result:
    case T.Returned{world,outcome}:(App.Application{world,bundle,declaration,extra,debug},outcome)
def queue(~S:Data,app:Application(~S),value:U32,skipSame:Bool) -> Application(~S) & T.Outcome<String>:
  match app:
    case App.Application{world,bundle,declaration,extra,debug}:queue_returned(~S,bundle,declaration,extra,debug,Cmd.tx_finish(~S,~Unit,~Resources(~S),~Unit,~String,MachineOps.set(~S,~Mode,~U32,~Unit,~Resources(~S),~Unit,~take_slot(~S),~put_slot(~S),~U32.is_eq,~machine(~S),T.begin(~World(~S),~Unit,world),M.Set{value,skipSame}),T.Success{}))
    case app:(app,T.Failure{"fixture-recovering"})
type Collector is Type:Collector{calls:U32,events:List<&2,Trace.TraceEvent<String>>,owned:Array<U32>}
def step_returned(calls:U32,events:List<&2,Trace.TraceEvent<String>>,event:Trace.TraceEvent<String>,value:Array<U32> & U32) -> Collector:
  match value:
    case (owned,n):Collector{(calls+1:U32),List.append(&2,Trace.TraceEvent<String>,events,[event]),Array.set(U32,owned,0,(n+1:U32))}
def step(state:Collector,event:Trace.TraceEvent<String>) -> Collector:
  match state:
    case Collector{calls,events,owned}:step_returned(calls,events,event,Array.get(U32,owned,0))
def Subscriber() -> Type:Trace.Subscriber<Collector,String,step>
def collector(first:U32,second:U32) -> Collector:Collector{0,[],ANode{ALeaf{first},ALeaf{second}}}
