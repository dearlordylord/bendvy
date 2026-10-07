import Base
import prototype.bend as B
import constructor-stage.bend as S
import read-provider.bend as R
import ../../src/ecs/component.bend as C

type Tag is Data:
  Tag{}
type QueueOwner is Type:
  QueueOwner{front:Array<U32>,back:Array<U32>,queued:List<Array<U32>>}
type Raw<Owner:Type> is Type:
  Raw{valid:Bool,owner:Owner}
type Cooked<Owner:Type> is Type:
  Cooked{owner:Owner}
type Context is Type:
  Context{calls:Array<U32>,order:List<&2,U32>}
def bump_seen(+slot:U32,+order:List<&2,U32>,seen:Array<U32> & U32) -> Context:
  match seen:
    case (calls,+count): Context{Array.set(U32,calls,slot,(count+1:U32)),List.append(&2,U32,order,[slot])}
def bump(ctx:Context,+slot:U32) -> Context:
  match ctx:
    case Context{calls,+order}: bump_seen(slot,order,Array.get(U32,calls,slot))
def undo(~Owner:Type,cooked:Cooked<Owner>) -> Raw<Owner>:
  match cooked:
    case Cooked{owner}: Raw{True{},owner}
def validated(~Owner:Type,ctx:Context,valid:Bool,owner:Owner,error:String) -> Context & S.Construction<Raw<Owner>,Cooked<Owner>,String>:
  match valid:
    case True{}: (ctx,S.Constructed{Cooked{owner},c => undo(~Owner,c)})
    case False{}: (ctx,S.Invalid{Raw{False{},owner},error})
def construct(~Owner:Type,+slot:U32,+error:String,ctx:Context,raw:Raw<Owner>) -> Context & S.Construction<Raw<Owner>,Cooked<Owner>,String>:
  match raw:
    case Raw{valid,owner}: validated(~Owner,bump(ctx,slot),valid,owner,error)
# Nontrivial reversible actual-array transform; saved originals are Data,
# NEVER a second affine Array. Actual returned owners flow through all calls.
def array_restore(+old0:U32,+old1:U32,owner:Array<U32>) -> Array<U32>:
  Array.set(U32,Array.set(U32,owner,0,old0),1,old1)
def array_changed(+old0:U32,seen:Array<U32> & U32) -> Array<U32> & (Array<U32> -> Array<U32>):
  match seen:
    case (owner,+old1): (Array.set(U32,Array.set(U32,owner,0,(old0+1000:U32)),1,(old1+1000:U32)),a => array_restore(old0,old1,a))
def array_seen(seen:Array<U32> & U32) -> Array<U32> & (Array<U32> -> Array<U32>):
  match seen:
    case (owner,+old0): array_changed(old0,Array.get(U32,owner,1))
def array_change(owner:Array<U32>) -> Array<U32> & (Array<U32> -> Array<U32>):
  array_seen(Array.get(U32,owner,0))
def array_undone(restore:Array<U32> -> Array<U32>,cooked:Cooked<Array<U32>>) -> Raw<Array<U32>>:
  match cooked:
    case Cooked{owner}: Raw{True{},restore(owner)}
def array_constructed(ctx:Context,changed:Array<U32> & (Array<U32> -> Array<U32>)) -> Context & S.Construction<Raw<Array<U32>>,Cooked<Array<U32>>,String>:
  match changed:
    case (owner,restore): (ctx,S.Constructed{Cooked{owner},c => array_undone(restore,c)})
def array_valid(ctx:Context,valid:Bool,owner:Array<U32>) -> Context & S.Construction<Raw<Array<U32>>,Cooked<Array<U32>>,String>:
  match valid:
    case True{}: array_constructed(ctx,array_change(owner))
    case False{}: (ctx,S.Invalid{Raw{False{},owner},"bad-0"})
def array_construct(ctx:Context,raw:Raw<Array<U32>>) -> Context & S.Construction<Raw<Array<U32>>,Cooked<Array<U32>>,String>:
  match raw:
    case Raw{valid,owner}: array_valid(bump(ctx,0),valid,owner)
def queue_restore(front:Array<U32> -> Array<U32>,back:Array<U32> -> Array<U32>,cooked:Cooked<QueueOwner>) -> Raw<QueueOwner>:
  match cooked:
    case Cooked{QueueOwner{a,b,queued}}: Raw{True{},QueueOwner{front(a),back(b),queued}}
def queue_changed(ctx:Context,front:Array<U32> & (Array<U32> -> Array<U32>),back:Array<U32> & (Array<U32> -> Array<U32>),queued:List<Array<U32>>) -> Context & S.Construction<Raw<QueueOwner>,Cooked<QueueOwner>,String>:
  match front back:
    case (a,restoreA), (b,restoreB): (ctx,S.Constructed{Cooked{QueueOwner{a,b,queued}},c => queue_restore(restoreA,restoreB,c)})
def queue_valid(ctx:Context,valid:Bool,owner:QueueOwner) -> Context & S.Construction<Raw<QueueOwner>,Cooked<QueueOwner>,String>:
  match valid owner:
    case True{} QueueOwner{front,back,queued}: queue_changed(ctx,array_change(front),array_change(back),queued)
    case False{} owner: (ctx,S.Invalid{Raw{False{},owner},"bad-3"})
def queue_construct(ctx:Context,raw:Raw<QueueOwner>) -> Context & S.Construction<Raw<QueueOwner>,Cooked<QueueOwner>,String>:
  match raw:
    case Raw{valid,owner}: queue_valid(bump(ctx,3),valid,owner)
def stage_4(ctx:Context,raw:Unit) -> S.Staged<Context,Unit,Unit,String>:
  S.terminal(~Context,~String,ctx,raw)
def constructor_3(ctx:Context,raw:Raw<QueueOwner>) -> Context & S.Construction<Raw<QueueOwner>,Cooked<QueueOwner>,String>:
  queue_construct(ctx,raw)
def stage_3(ctx:Context,raw:B.Pack<Raw<QueueOwner>,Unit>) -> S.Staged<Context,B.Pack<Raw<QueueOwner>,Unit>,B.Pack<Cooked<QueueOwner>,Unit>,String>:
  S.stage(~Context,~Raw<QueueOwner>,~Cooked<QueueOwner>,~Unit,~Unit,~String,~constructor_3,~stage_4,ctx,raw)
def constructor_2(ctx:Context,raw:Raw<Tag>) -> Context & S.Construction<Raw<Tag>,Cooked<Tag>,String>:
  construct(~Tag,2,"bad-2",ctx,raw)
def stage_2(ctx:Context,raw:B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>) -> S.Staged<Context,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>,String>:
  S.stage(~Context,~Raw<Tag>,~Cooked<Tag>,~B.Pack<Raw<QueueOwner>,Unit>,~B.Pack<Cooked<QueueOwner>,Unit>,~String,~constructor_2,~stage_3,ctx,raw)
def constructor_1(ctx:Context,raw:Raw<U32>) -> Context & S.Construction<Raw<U32>,Cooked<U32>,String>:
  construct(~U32,1,"bad-1",ctx,raw)
def stage_1(ctx:Context,raw:B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>) -> S.Staged<Context,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>,String>:
  S.stage(~Context,~Raw<U32>,~Cooked<U32>,~B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>,~B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>,~String,~constructor_1,~stage_2,ctx,raw)
def constructor_0(ctx:Context,raw:Raw<Array<U32>>) -> Context & S.Construction<Raw<Array<U32>>,Cooked<Array<U32>>,String>:
  array_construct(ctx,raw)
def stage_0(ctx:Context,raw:B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>) -> S.Staged<Context,B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>,B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>>,String>:
  S.stage(~Context,~Raw<Array<U32>>,~Cooked<Array<U32>>,~B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>,~B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>,~String,~constructor_0,~stage_1,ctx,raw)
def input(+ok1:Bool,+ok3:Bool) -> B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>:
  B.Pack{Raw{True{},ANode{ALeaf{11},ALeaf{12}}},B.Pack{Raw{ok1,17},B.Pack{Raw{True{},Tag{}},B.Pack{Raw{ok3,QueueOwner{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{41},ALeaf{42}},[ANode{ALeaf{51},ALeaf{52}}]}},Unit{}}}}}
def context() -> Context:
  Context{ANode{ANode{ALeaf{0},ALeaf{0}},ANode{ALeaf{0},ALeaf{0}}},[]}
def cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,cells(left),cells(right))
def array_view(owner:Array<U32>) -> String:
  List.show(&2,U32,U32.show,cells(owner))
def queue_items(items:List<Array<U32>>) -> List<&2,String>:
  match items:
    case []: []
    case head <> tail: array_view(head) <> queue_items(tail)
def string_identity(text:String) -> String:
  text
def queue_view(owner:QueueOwner) -> String:
  match owner:
    case QueueOwner{front,back,queued}: array_view(front) ++ ":" ++ array_view(back) ++ ":" ++ List.show(&2,String,string_identity,queue_items(queued))
def tag_view(owner:Tag) -> String:
  "tag"
def error_view(error:Maybe<&2,String>) -> String:
  match error:
    case None{}: "null"
    case Some{error}: error
def raw_4(raw:Unit) -> String:
  "end"
def raw_3(raw:B.Pack<Raw<QueueOwner>,Unit>) -> String:
  match raw:
    case B.Pack{Raw{valid,owner},tail}: Bool.show(valid) ++ ":" ++ queue_view(owner) ++ "/" ++ raw_4(tail)
def raw_2(raw:B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>) -> String:
  match raw:
    case B.Pack{Raw{valid,owner},tail}: Bool.show(valid) ++ ":" ++ tag_view(owner) ++ "/" ++ raw_3(tail)
def raw_1(raw:B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>) -> String:
  match raw:
    case B.Pack{Raw{valid,owner},tail}: Bool.show(valid) ++ ":" ++ U32.show(owner) ++ "/" ++ raw_2(tail)
def raw_0(raw:B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>) -> String:
  match raw:
    case B.Pack{Raw{valid,owner},tail}: Bool.show(valid) ++ ":" ++ array_view(owner) ++ "/" ++ raw_1(tail)
def snapshot(ctx:Context,raw:B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>,positions:List<&2,Maybe<&2,String>>) -> String:
  match ctx:
    case Context{calls,order}: "calls=" ++ array_view(calls) ++ "|order=" ++ List.show(&2,U32,U32.show,order) ++ "|errors=" ++ List.show(&2,Maybe<&2,String>,error_view,positions) ++ "|raw=" ++ raw_0(raw)
def array_read_second(+first:U32,seen:Array<U32> & U32) -> Array<U32> & String:
  match seen:
    case (owner,second): (owner,List.show(&2,U32,U32.show,[first,second]))
def array_read_first(seen:Array<U32> & U32) -> Array<U32> & String:
  match seen:
    case (owner,first): array_read_second(first,Array.get(U32,owner,1))
def array_read(owner:Array<U32>) -> Array<U32> & String:
  array_read_first(Array.get(U32,owner,0))
def list_read_join(head:Array<U32> & String,tail:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & List<&2,String>:
  match head tail:
    case (owner,text), (owners,texts): (owner <> owners,text <> texts)
def list_read(owners:List<Array<U32>>) -> List<Array<U32>> & List<&2,String>:
  match owners:
    case []: ([],[])
    case head <> tail: list_read_join(array_read(head),list_read(tail))
def queue_read_join(front:Array<U32> & String,back:Array<U32> & String,queued:List<Array<U32>> & List<&2,String>) -> QueueOwner & String:
  match front back queued:
    case (a,ta), (b,tb), (q,tq): (QueueOwner{a,b,q},ta ++ ":" ++ tb ++ ":" ++ List.show(&2,String,string_identity,tq))
def queue_read(owner:QueueOwner) -> QueueOwner & String:
  match owner:
    case QueueOwner{front,back,queued}: queue_read_join(array_read(front),array_read(back),list_read(queued))
def tag_read(owner:Tag) -> Tag & String:
  (owner,"tag")
def value_read(owner:U32) -> U32 & String:
  +value=owner
  (value,U32.show(value))
def cooked_read_4(cooked:Unit) -> Unit & String:
  (cooked,"end")
def cooked_read_join_3(head:QueueOwner & String,tail:Unit & String) -> B.Pack<Cooked<QueueOwner>,Unit> & String:
  match head tail:
    case (owner,text), (rest,texts): (B.Pack{Cooked{owner},rest},text ++ "/" ++ texts)
def cooked_read_3(cooked:B.Pack<Cooked<QueueOwner>,Unit>) -> B.Pack<Cooked<QueueOwner>,Unit> & String:
  match cooked:
    case B.Pack{Cooked{owner},rest}: cooked_read_join_3(queue_read(owner),cooked_read_4(rest))
def cooked_read_join_2(head:Tag & String,tail:B.Pack<Cooked<QueueOwner>,Unit> & String) -> B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>> & String:
  match head tail:
    case (owner,text), (rest,texts): (B.Pack{Cooked{owner},rest},text ++ "/" ++ texts)
def cooked_read_2(cooked:B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>) -> B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>> & String:
  match cooked:
    case B.Pack{Cooked{owner},rest}: cooked_read_join_2(tag_read(owner),cooked_read_3(rest))
def cooked_read_join_1(head:U32 & String,tail:B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>> & String) -> B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>> & String:
  match head tail:
    case (owner,text), (rest,texts): (B.Pack{Cooked{owner},rest},text ++ "/" ++ texts)
def cooked_read_1(cooked:B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>) -> B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>> & String:
  match cooked:
    case B.Pack{Cooked{owner},rest}: cooked_read_join_1(value_read(owner),cooked_read_2(rest))
def cooked_read_join_0(head:Array<U32> & String,tail:B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>> & String) -> B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & String:
  match head tail:
    case (owner,text), (rest,texts): (B.Pack{Cooked{owner},rest},text ++ "/" ++ texts)
def cooked_read_0(cooked:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>>) -> B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & String:
  match cooked:
    case B.Pack{Cooked{owner},rest}: cooked_read_join_0(array_read(owner),cooked_read_1(rest))
def valid_seen(ctx:Context,undo:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> -> B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>,positions:List<&2,Maybe<&2,String>>,seen:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & String) -> String:
  match seen:
    case (cooked,view): "valid|cooked=" ++ view ++ "|" ++ snapshot(ctx,undo(cooked),positions)
def found_view(observed:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & String) -> B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & C.Access<String>:
  match observed:
    case (owner,text): (owner,C.Found{text})
def getter(owner:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>>) -> B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & C.Access<String>:
  found_view(cooked_read_0(owner))
def read_returned(ctx:Context,undo:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> -> B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>,positions:List<&2,Maybe<&2,String>>,observed:B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>> & Unit) -> String:
  match observed:
    case (owner,_): valid_seen(ctx,undo,positions,cooked_read_0(owner))
def result(result:S.Staged<Context,B.Pack<Raw<Array<U32>>,B.Pack<Raw<U32>,B.Pack<Raw<Tag>,B.Pack<Raw<QueueOwner>,Unit>>>>,B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>>,String>) -> String:
  match result:
    case S.Failed{ctx,raw,positions}: "failed|" ++ snapshot(ctx,raw,positions)
    case S.Valid{ctx,cooked,undo,positions}: read_returned(ctx,undo,positions,R.provide(~B.Pack<Cooked<Array<U32>>,B.Pack<Cooked<U32>,B.Pack<Cooked<Tag>,B.Pack<Cooked<QueueOwner>,Unit>>>>,~String,~getter,~R.legitimate,cooked))
def main() -> IO(Unit):
  IO.print(result(stage_0(context(),input(False{},False{}))) ++ "\n" ++ result(stage_0(context(),input(True{},True{}))))
