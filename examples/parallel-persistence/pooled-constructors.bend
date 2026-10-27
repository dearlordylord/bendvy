import Base
import ./declarations.bend as O
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/decode-construction.bend as Constructor
import ../../src/ecs/bundle-construction.bend as Build
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/restore-leaf.bend as Leaf
import ../../src/ecs/restore-data.bend as R

# A real caller-owned allocation budget: successful construction takes one actual
# Array from the pool. Exhaustion is a domain failure after codec admission.
# The allocation budget and its reversible buffer ownership are Bend-specific
# application policy; no Bevy correspondence is asserted for this constructor.
type Input is Type:Input{raw:D.Raw,buffer:Maybe<&1,Array<U32>>}
type Error is Data:NoBuffer{} Malformed{}
def observed(+raw:D.Raw,buffer:Maybe<&1,Array<U32>>) -> Input & D.Raw:(Input{raw,buffer},raw)
def incoming(input:Input) -> Input & D.Raw:
  match input:
    case Input{raw,buffer}:observed(raw,buffer)
def undo(~S:Data,raw:D.Raw,original:U32,owner:O.Actor<S>) -> Input:
  match owner:
    case O.Actor{_,buffer}:Input{raw,Some{Array.set(U32,buffer,0,original)}}
def buffered(~S:Data,raw:D.Raw,name:String,energy:U32,result:Array<U32> & U32) -> Build.Construction<Input,O.Actor<S>,Error>:
  match result:
    case (buffer,original):Build.Constructed{O.Actor{name,Array.set(U32,buffer,0,energy)},owner => undo(~S,raw,original,owner)}
def values(~S:Data,input:Input,name:D.Raw,energy:D.Raw) -> Build.Construction<Input,O.Actor<S>,Error>:
  match input name energy:
    case Input{raw,Some{buffer}} D.BendvyText{name} D.Number{energy}:buffered(~S,raw,name,energy,Array.get(U32,buffer,0))
    case Input{raw,None{}} _ _:Build.Invalid{Input{raw,None{}},NoBuffer{}}
    case input _ _:Build.Invalid{input,Malformed{}}
def build(~S:Data,input:Input,canonical:D.Raw) -> Build.Construction<Input,O.Actor<S>,Error>:
  match canonical:
    case D.Object{+fields}:values(~S,input,D.field("name",fields),D.field("energy",fields))
    case _:Build.Invalid{input,Malformed{}}
def Factory(~S:Data) -> Data:Constructor.FallibleFactory<S,Input,O.Actor<S>,Error,Plan.identity(~S,~O.Actor<S>,"actor"),O.actor_project(~S),incoming,build(~S)>
def factory(~S:Data,declaration:Decl.Constructed<S,O.Actor<S>,Plan.identity(~S,~O.Actor<S>,"actor"),O.actor_project(~S)>) -> Factory(~S):Constructor.fallible_factory(~S,~Input,~O.Actor<S>,~Error,~Plan.identity(~S,~O.Actor<S>,"actor"),~O.actor_project(~S),~incoming,~build(~S),declaration)
type Context<-S:Data> is Type:Context{factory:Factory(~S),available:List<Array<U32>>}
def State(~S:Data) -> Type:Leaf.State<Context<S>,Input,O.Actor<S>>
def supplied(~S:Data,context:Context<S>,raw:D.Raw) -> Context<S> & Input:
  match context:
    case Context{factory,[]}: (Context{factory,[]},Input{raw,None{}})
    case Context{factory,buffer <> rest}:(Context{factory,rest},Input{raw,Some{buffer}})
def constructed(~S:Data,position:R.Position,records:List<Leaf.Record<Input,O.Actor<S>>>,returned:List<Input>,removed:List<O.Actor<S>>,applied:List<Leaf.Applied<Input,O.Actor<S>>>,result:Context<S> & Input) -> State(~S) & R.Dispatch<Error>:
  match result:
    case (Context{+factory,available},input):Leaf.constructed(~Context<S>,~Input,~O.Actor<S>,~Error,position,records,returned,removed,applied,Context{factory,available},Constructor.fallible_construct(~S,~Input,~O.Actor<S>,~Error,~Plan.identity(~S,~O.Actor<S>,"actor"),~O.actor_project(~S),~incoming,~build(~S),factory,input))
def actor(~S:Data,state:State(~S),position:R.Position,raw:D.Raw) -> State(~S) & R.Dispatch<Error>:
  match state:
    case Leaf.State{context,records,returned,removed,applied}:constructed(~S,position,records,returned,removed,applied,supplied(~S,context,raw))
def field(~S:Data,state:State(~S),position:R.Position,field:D.Field) -> State(~S) & R.Dispatch<Error>:
  match position field:
    case R.Component{key} D.Field{"actor",raw}:actor(~S,state,R.Component{key},raw)
    case _ _:(state,R.Unhandled{})
def release(~S:Data,state:State(~S)) -> State(~S):Leaf.release(~Context<S>,~Input,~O.Actor<S>,state)
def empty(~S:Data,declaration:Decl.Constructed<S,O.Actor<S>,Plan.identity(~S,~O.Actor<S>,"actor"),O.actor_project(~S)>,buffers:List<Array<U32>>) -> State(~S):Leaf.empty(~Context<S>,~Input,~O.Actor<S>,Context{factory(~S,declaration),buffers})
