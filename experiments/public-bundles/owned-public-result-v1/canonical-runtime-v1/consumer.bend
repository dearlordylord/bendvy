import Base
import /workspace/formal-proofs/bendvy/experiments/public-bundles/owned-public-result-v1/canonical-constructor-head.bend as Head
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as Pack
type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
type Custom is Data:Blocked{}
type Incoming is Type:Incoming{owned:Array<U32>,wire:D.Raw,fail:Bool}
type Payload is Type:Payload{owned:Array<U32>,number:U32}
type Tail is Type:Tail{owned:Array<U32>,tag:Bool,scalar:U32}
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
type Context<S:Data> is Type:Context{factory:Factory(~S),rest:Array<Array<U32>>,trail:List<&2,String>}
type Rest is Type:Rest{owned:Array<Array<U32>>,trail:List<&2,String>}
def take(~S:Data,context:Context<S>) -> Factory(~S) & Rest:
  match context:
    case Context{factory,owned,trail}:(factory,Rest{owned,trail})
def put(~S:Data,factory:Factory(~S),rest:Rest) -> Context<S>:
  match rest:
    case Rest{owned,trail}:Context{factory,owned,trail}
def tail(~S:Data,context:Context<S>,owner:Tail) -> Build.Staged<Context<S>,Tail,Tail,Constructor.Error<Custom>>:
  match context:
    case Context{factory,rest,trail}:Build.Valid{Context{factory,rest,List.append(&2,String,trail,["tail"])},owner,x => x,[None{}]}
def stage(~S:Data,context:Context<S>,raw:Pack.Pack<Incoming,Tail>) -> Build.Staged<Context<S>,Pack.Pack<Incoming,Tail>,Pack.Pack<Payload,Tail>,Constructor.Error<Custom>>:Head.canonical_stage(~S,~Context<S>,~Rest,~Incoming,~Payload,~Tail,~Tail,~Custom,~identity(~S),~project,~incoming,~decoded,~take(~S),~put(~S),~tail(~S),context,raw)
def context(~S:Data) -> Context<S>:Context{Constructor.fallible_factory(~S,~Incoming,~Payload,~Custom,~identity(~S),~project,~incoming,~decoded,Decl.constructed(~S,~Payload,~identity(~S),~project,D.FiniteNumber{})),ANode{ALeaf{ANode{ALeaf{70},ALeaf{71}}},ALeaf{ALeaf{72}}},[]}
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
def raw_join(head:Incoming & String,tail:Tail & String) -> Pack.Pack<Incoming,Tail> & String:
  match head tail:
    case (a,x),(b,y):(Pack.Pack{a,b},x ++ "/tail=" ++ y)
def raw_observe(raw:Pack.Pack<Incoming,Tail>) -> Pack.Pack<Incoming,Tail> & String:
  match raw:
    case Pack.Pack{head,tail}:raw_join(incoming_observe(head),tail_observe(tail))
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
def context_shown(~S:Data,factory:Factory(~S) & String,+trail:List<&2,String>,observed:Array<Array<U32>> & String) -> Context<S> & String:
  match factory observed:
    case (f,description),(rest,text):(Context{f,rest,trail},"factory=" ++ description ++ "/rest=" ++ text ++ "/trail=" ++ List.show(&2,String,x => x,trail))
def context_observe(~S:Data,context:Context<S>) -> Context<S> & String:
  match context:
    case Context{factory,rest,trail}:context_shown(~S,factory_observe(~S,factory),trail,outer(rest))
def initial_join(~S:Data,context:Context<S> & String,raw:Pack.Pack<Incoming,Tail> & String) -> Context<S> & Pack.Pack<Incoming,Tail> & String:
  match context raw:
    case (ctx,a),(input,b):(ctx,input,"initial:" ++ a ++ "/raw=" ++ b ++ "\n")
def initial(~S:Data,context:Context<S>,raw:Pack.Pack<Incoming,Tail>) -> Context<S> & Pack.Pack<Incoming,Tail> & String:initial_join(~S,context_observe(~S,context),raw_observe(raw))
def fixed(owner:Incoming) -> Incoming:
  match owner:
    case Incoming{owned,_,_}:Incoming{owned,D.Number{9},False{}}
def repaired(raw:Pack.Pack<Incoming,Tail>) -> Pack.Pack<Incoming,Tail>:
  match raw:
    case Pack.Pack{head,tail}:Pack.Pack{fixed(head),tail}
def payload_shown(+number:U32,observed:Array<U32> & String) -> Payload & String:
  (owned,text)=observed
  (Payload{owned,number},text ++ "/number=" ++ U32.show(number))
def payload_observe(owner:Payload) -> Payload & String:
  match owner:
    case Payload{owned,number}:payload_shown(number,tree(owned))
def cooked_join(head:Payload & String,tail:Tail & String) -> Pack.Pack<Payload,Tail> & String:
  match head tail:
    case (a,x),(b,y):(Pack.Pack{a,b},x ++ "/tail=" ++ y)
def cooked_observe(cooked:Pack.Pack<Payload,Tail>) -> Pack.Pack<Payload,Tail> & String:
  match cooked:
    case Pack.Pack{head,tail}:cooked_join(payload_observe(head),tail_observe(tail))
def restored_join(~S:Data,prior:String,context:Context<S> & String,raw:Pack.Pack<Incoming,Tail> & String) -> String:
  match context raw:
    case (_,a),(_,b):prior ++ "restored:" ++ a ++ "/raw=" ++ b ++ "\n"
def complete(~S:Data,prior:String,context:Context<S>,undo:Pack.Pack<Payload,Tail> -> Pack.Pack<Incoming,Tail>,cooked:Pack.Pack<Payload,Tail> & String,+positions:List<&2,Maybe<&2,Constructor.Error<Custom>>>) -> String:
  (owner,text)=cooked
  restored_join(~S,prior ++ "valid:" ++ text ++ "/positions=" ++ List.show(&2,Maybe<&2,Constructor.Error<Custom>>,position,positions) ++ "\n",context_observe(~S,context),raw_observe(undo(owner)))
def retried(~S:Data,prior:String,result:Build.Staged<Context<S>,Pack.Pack<Incoming,Tail>,Pack.Pack<Payload,Tail>,Constructor.Error<Custom>>) -> String:
  match result:
    case Build.Valid{context,cooked,undo,positions}:complete(~S,prior,context,undo,cooked_observe(cooked),positions)
    case Build.Failed{context,raw,positions}:"unexpected-retry-failure"
def refused_join(~S:Data,prior:String,+positions:List<&2,Maybe<&2,Constructor.Error<Custom>>>,context:Context<S> & String,raw:Pack.Pack<Incoming,Tail> & String) -> String:
  match context raw:
    case (ctx,a),(owner,b):retried(~S,prior ++ "refused:" ++ a ++ "/raw=" ++ b ++ "/positions=" ++ List.show(&2,Maybe<&2,Constructor.Error<Custom>>,position,positions) ++ "\n",stage(~S,ctx,repaired(owner)))
def first(~S:Data,prior:String,result:Build.Staged<Context<S>,Pack.Pack<Incoming,Tail>,Pack.Pack<Payload,Tail>,Constructor.Error<Custom>>) -> String:
  match result:
    case Build.Valid{context,cooked,undo,positions}:complete(~S,prior,context,undo,cooked_observe(cooked),positions)
    case Build.Failed{context,raw,positions}:refused_join(~S,prior,positions,context_observe(~S,context),raw_observe(raw))
def prepared(~S:Data,pair:Context<S> & Pack.Pack<Incoming,Tail> & String) -> String:
  (context,raw,prior)=pair
  first(~S,prior,stage(~S,context,raw))
def scenario(~S:Data,raw:D.Raw,fail:Bool) -> String:prepared(~S,initial(~S,context(~S),Pack.Pack{Incoming{ANode{ALeaf{11},ALeaf{12}},raw,fail},Tail{ANode{ALeaf{21},ANode{ALeaf{22},ALeaf{23}}},True{},31}}))
def main() -> String:"validation\n" ++ scenario(~SchemaA,D.Text{"bad"},False{}) ++ "custom\n" ++ scenario(~SchemaA,D.Number{8},True{}) ++ "success\n" ++ scenario(~SchemaA,D.Number{7},False{})
