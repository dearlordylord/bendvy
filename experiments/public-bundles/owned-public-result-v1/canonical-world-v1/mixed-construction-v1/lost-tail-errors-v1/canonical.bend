import Base
import candidate-head.bend as Head
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as Pack
type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
type Custom is Data:Blocked{}
type Tag is Data:Tag{}
type Incoming is Type:Incoming{owned:Array<U32>,wire:D.Raw,fail:Bool}
type Payload is Type:Payload{owned:Array<U32>,number:U32}
type Tail is Type:Tail{owned:Array<U32>,tag:Bool,scalar:U32}
def Extras() -> Type:Pack.Pack<Tag,Pack.Pack<U32,Unit>>
def Side() -> Type:Pack.Pack<Tail,Extras()>
def Raw() -> Type:Pack.Pack<Incoming,Side()>
def Cooked() -> Type:Pack.Pack<Payload,Side()>
def identity(~S:Data) -> Identity.Declaration<S,Payload>:Identity.component(~S,~Payload,"constructed-array")
def project(owner:Payload) -> Payload & D.Raw:
  match owner:
    case Payload{owned,+number}:(Payload{owned,number},D.Number{number})
def incoming(owner:Incoming) -> Incoming & D.Raw:
  match owner:
    case Incoming{owned,+wire,fail}:(Incoming{owned,wire,fail},wire)
def undo(wire:D.Raw,fail:Bool,owner:Payload) -> Incoming:
  match owner:
    case Payload{owned,_}:Incoming{owned,wire,fail}
def built(allowed:Bool,+wire:D.Raw,+fail:Bool,owned:Array<U32>,number:U32) -> Build.Construction<Incoming,Payload,Custom>:
  match allowed:
    case True{}:Build.Constructed{Payload{owned,number},p => undo(wire,fail,p)}
    case False{}:Build.Invalid{Incoming{owned,wire,fail},Blocked{}}
def decoded(owner:Incoming,canonical:D.Raw) -> Build.Construction<Incoming,Payload,Custom>:
  match owner canonical:
    case Incoming{owned,wire,+fail} D.Number{number}:built(Bool.not(fail),wire,fail,owned,number)
    case owner _:Build.Invalid{owner,Blocked{}}
def Factory(~S:Data) -> Type:Constructor.FallibleFactory<S,Incoming,Payload,Custom,identity(~S),project,incoming,decoded>
def tail_identity(~S:Data) -> Identity.Declaration<S,Tail>:Identity.component(~S,~Tail,"canonical-tail")
def tail_project(owner:Tail) -> Tail & D.Raw:
  match owner:
    case Tail{owned,tag,+scalar}:(Tail{owned,tag,scalar},D.Number{scalar})
def tail_checked(rejected:Bool,owner:Tail) -> Build.Construction<Tail,Tail,Custom>:
  match rejected:
    case True{}:Build.Invalid{owner,Blocked{}}
    case False{}:Build.Constructed{owner,x => x}
def tail_decoded(owner:Tail,canonical:D.Raw) -> Build.Construction<Tail,Tail,Custom>:
  match owner canonical:
    case Tail{owned,tag,+scalar} D.Number{number}:tail_checked(U32.is_eq(scalar,31),Tail{owned,tag,scalar})
    case owner _:Build.Invalid{owner,Blocked{}}
def TailFactory(~S:Data) -> Type:Constructor.FallibleFactory<S,Tail,Tail,Custom,tail_identity(~S),tail_project,tail_project,tail_decoded>
type Context<S:Data> is Type:Context{factory:Factory(~S),tailFactory:TailFactory(~S),rest:Array<Array<U32>>,trail:List<&2,String>}
type Rest<S:Data> is Type:Rest{tailFactory:TailFactory(~S),owned:Array<Array<U32>>,trail:List<&2,String>}
def take(~S:Data,context:Context<S>) -> Factory(~S) & Rest<S>:
  match context:
    case Context{factory,tailFactory,owned,trail}:(factory,Rest{tailFactory,owned,trail})
def put(~S:Data,factory:Factory(~S),rest:Rest<S>) -> Context<S>:
  match rest:
    case Rest{tailFactory,owned,trail}:Context{factory,tailFactory,owned,trail}
type TailRest<S:Data> is Type:TailRest{factory:Factory(~S),owned:Array<Array<U32>>,trail:List<&2,String>}
def take_tail(~S:Data,context:Context<S>) -> TailFactory(~S) & TailRest<S>:
  match context:
    case Context{factory,tailFactory,owned,trail}:(tailFactory,TailRest{factory,owned,trail})
def put_tail(~S:Data,tailFactory:TailFactory(~S),rest:TailRest<S>) -> Context<S>:
  match rest:
    case TailRest{factory,owned,trail}:Context{factory,tailFactory,owned,List.append(&2,String,trail,["tail"])}
def extra(~S:Data,context:Context<S>,owner:Extras()) -> Build.Staged<Context<S>,Extras(),Extras(),Constructor.Error<Custom>>:Build.Valid{context,owner,x => x,[None{},None{}]}
def side(~S:Data,context:Context<S>,owner:Side()) -> Build.Staged<Context<S>,Side(),Side(),Constructor.Error<Custom>>:Head.canonical_stage(~S,~Context<S>,~TailRest<S>,~Tail,~Tail,~Extras(),~Extras(),~Custom,~tail_identity(~S),~tail_project,~tail_project,~tail_decoded,~take_tail(~S),~put_tail(~S),~extra(~S),context,owner)
def stage(~S:Data,context:Context<S>,raw:Raw()) -> Build.Staged<Context<S>,Raw(),Cooked(),Constructor.Error<Custom>>:Head.canonical_stage(~S,~Context<S>,~Rest<S>,~Incoming,~Payload,~Side(),~Side(),~Custom,~identity(~S),~project,~incoming,~decoded,~take(~S),~put(~S),~side(~S),context,raw)
def context(~S:Data) -> Context<S>:Context{Constructor.fallible_factory(~S,~Incoming,~Payload,~Custom,~identity(~S),~project,~incoming,~decoded,Decl.constructed(~S,~Payload,~identity(~S),~project,D.FiniteNumber{})),Constructor.fallible_factory(~S,~Tail,~Tail,~Custom,~tail_identity(~S),~tail_project,~tail_project,~tail_decoded,Decl.constructed(~S,~Tail,~tail_identity(~S),~tail_project,D.FiniteNumber{})),ANode{ALeaf{ANode{ALeaf{70},ALeaf{71}}},ALeaf{ALeaf{72}}},[]}
def tree_join(left:Array<U32> & String,right:Array<U32> & String) -> Array<U32> & String:
  match left right:
    case (a,x),(b,y):(ANode{a,b},"N(" ++ x ++ "," ++ y ++ ")")
def tree(owner:Array<U32>) -> Array<U32> & String:
  match owner:
    case ALeaf{+value}:(ALeaf{value},"L(" ++ U32.show(value) ++ ")")
    case ANode{a,b}:tree_join(tree(a),tree(b))
def outer_join(left:Array<Array<U32>> & String,right:Array<Array<U32>> & String) -> Array<Array<U32>> & String:
  match left right:
    case (a,x),(b,y):(ANode{a,b},"N(" ++ x ++ "," ++ y ++ ")")
def outer_leaf(observed:Array<U32> & String) -> Array<Array<U32>> & String:
  (owner,text)=observed
  (ALeaf{owner},"L(" ++ text ++ ")")
def outer(owner:Array<Array<U32>>) -> Array<Array<U32>> & String:
  match owner:
    case ALeaf{owned}:outer_leaf(tree(owned))
    case ANode{a,b}:outer_join(outer(a),outer(b))
def wire(raw:D.Raw) -> String:
  match raw:
    case D.Number{n}:"Number(" ++ U32.show(n) ++ ")"
    case D.Text{x}:"Text(" ++ x ++ ")"
    case _:"unexpected"
def error(value:Constructor.Error<Custom>) -> String:
  match value:
    case Constructor.Constructor{Blocked{}}:"Constructor(Blocked)"
    case Constructor.Validation{D.Invalid{path,expected,actual}}:"Validation(" ++ path ++ "," ++ expected ++ "," ++ wire(actual) ++ ")"
    case Constructor.Validation{D.FuelExhausted{path}}:"FuelExhausted(" ++ path ++ ")"
def position(value:Maybe<&2,Constructor.Error<Custom>>) -> String:
  match value:
    case None{}:"None"
    case Some{x}:error(x)
def tail_shown(+tag:Bool,+scalar:U32,observed:Array<U32> & String) -> Tail & String:
  (owned,text)=observed
  (Tail{owned,tag,scalar},text ++ "/tag=" ++ Bool.show(tag) ++ "/scalar=" ++ U32.show(scalar))
def tail_observe(owner:Tail) -> Tail & String:
  match owner:
    case Tail{owned,tag,scalar}:tail_shown(tag,scalar,tree(owned))
def incoming_shown(+raw:D.Raw,+fail:Bool,observed:Array<U32> & String) -> Incoming & String:
  (owned,text)=observed
  (Incoming{owned,raw,fail},text ++ "/wire=" ++ wire(raw) ++ "/fail=" ++ Bool.show(fail))
def incoming_observe(owner:Incoming) -> Incoming & String:
  match owner:
    case Incoming{owned,raw,fail}:incoming_shown(raw,fail,tree(owned))
def tag_observe(owner:Tag) -> Tag & String:(owner,"Tag")
def data_observe(owner:U32) -> U32 & String:
  +copy=owner
  (copy,U32.show(copy))
def side_join(+tag:Tag,+data:U32,observed:Tail & String) -> Side() & String:
  match observed:
    case (tail,text):(Pack.Pack{tail,Pack.Pack{tag,Pack.Pack{data,Unit{}}}},text ++ "/tag-component=Tag/data-component=" ++ U32.show(data))
def side_observe(owner:Side()) -> Side() & String:
  match owner:
    case Pack.Pack{tail,Pack.Pack{tag,Pack.Pack{data,unit}}}:side_join(tag,data,tail_observe(tail))
def raw_join(head:Incoming & String,tail:Side() & String) -> Raw() & String:
  match head tail:
    case (a,x),(b,y):(Pack.Pack{a,b},x ++ "/tail=" ++ y)
def raw_observe(raw:Raw()) -> Raw() & String:
  match raw:
    case Pack.Pack{head,tail}:raw_join(incoming_observe(head),side_observe(tail))
def codec(value:D.Codec) -> String:
  match value:
    case D.FiniteNumber{}:"FiniteNumber"
    case D.Integer{}:"Integer"
    case D.StringValue{}:"StringValue"
    case D.BoolValue{}:"BoolValue"
    case _:"unexpected-codec"
def factory_observe(~S:Data,factory:Factory(~S)) -> Factory(~S) & String:
  match factory:
    case Constructor.FallibleFactory{+declaration,+inputCodec}:(Constructor.FallibleFactory{declaration,inputCodec},"identity=" ++ Identity.key(~S,~Payload,identity(~S)) ++ "/decl=" ++ codec(Decl.codec(~S,~Payload,~identity(~S),~project,declaration)) ++ "/input=" ++ codec(inputCodec))
def tail_factory_observe(~S:Data,factory:TailFactory(~S)) -> TailFactory(~S) & String:
  match factory:
    case Constructor.FallibleFactory{+declaration,+inputCodec}:(Constructor.FallibleFactory{declaration,inputCodec},"identity=" ++ Identity.key(~S,~Tail,tail_identity(~S)) ++ "/decl=" ++ codec(Decl.codec(~S,~Tail,~tail_identity(~S),~tail_project,declaration)) ++ "/input=" ++ codec(inputCodec))
def context_shown(~S:Data,factory:Factory(~S) & String,tailFactory:TailFactory(~S) & String,+trail:List<&2,String>,observed:Array<Array<U32>> & String) -> Context<S> & String:
  match factory tailFactory observed:
    case (f,description),(t,tailDescription),(rest,text):(Context{f,t,rest,trail},"factory=" ++ description ++ "/tailFactory=" ++ tailDescription ++ "/rest=" ++ text ++ "/trail=" ++ List.show(&2,String,x => x,trail))
def context_observe(~S:Data,context:Context<S>) -> Context<S> & String:
  match context:
    case Context{factory,tailFactory,rest,trail}:context_shown(~S,factory_observe(~S,factory),tail_factory_observe(~S,tailFactory),trail,outer(rest))
def fixed(owner:Incoming) -> Incoming:
  match owner:
    case Incoming{owned,_,_}:Incoming{owned,D.Number{9},False{}}
def repaired(raw:Raw()) -> Raw():
  match raw:
    case Pack.Pack{head,Pack.Pack{Tail{owned,tag,scalar},extras}}:Pack.Pack{fixed(head),Pack.Pack{Tail{owned,tag,32},extras}}
def payload_shown(+number:U32,observed:Array<U32> & String) -> Payload & String:
  (owned,text)=observed
  (Payload{owned,number},text ++ "/number=" ++ U32.show(number))
def payload_observe(owner:Payload) -> Payload & String:
  match owner:
    case Payload{owned,number}:payload_shown(number,tree(owned))

def invalid_again(raw:Raw()) -> Raw():
  match raw:
    case Pack.Pack{Incoming{owned,wire,fail},tail}:Pack.Pack{Incoming{owned,D.Text{"bad"},fail},tail}
