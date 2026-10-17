import Base
import ../../../src/ecs/entity-key.bend as K
import ../../../src/ecs/entity-allocator.bend as Alloc
import ../generational-reuse-v1/observe.bend as Gen
import ../generational-reuse-v1/fixture.bend as Identity
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/relation-cleanup.bend as Clean

type Payload is Type:
  Payload{first:Array<U32>,second:Array<U32>}
type Components is Type:
  Components{slots:Array<Maybe<&1,Payload>>,removed:List<Payload>}
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Parent","Children",G.Hierarchy{}}
def descriptors(~S:Data) -> List<&2,G.Descriptor<S>>:
  [link(~S),parent(~S)]
def payload(+id:U32) -> Payload:
  Payload{ALeaf{id},ANode{ALeaf{U32.add(id,10)},ALeaf{U32.add(id,20)}}}
def clear_found(~S:Data,id:K.Key,observed:Array<Maybe<&1,Payload>> & Maybe<&1,Payload>,removed:List<Payload>) -> Components & List<&2,A.Notice<S,U32>>:
  match observed:
    case (slots,None{}):(Components{slots,removed},[])
    case (slots,Some{payload}):(Components{slots,payload <> removed},[A.ComponentRemoved{id}])
def clear(~S:Data,components:Components,handle:W.Handle<S>) -> Components & List<&2,A.Notice<S,U32>>:
  match components handle:
    case Components{slots,removed} W.Handle{_,+id}:clear_found(~S,id,Array.swap(Maybe<&1,Payload>,slots,K.index(id),None{}),removed)
def record(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}:A.Original{K.index(id)}
# Complete physical owner observations return every affine input.
def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"L(" ++ text ++ ")")
def tree_right(~T:Type,a:Array<T>,text:String,observed:Array<T> & String) -> Array<T> & String:
  (b,other)=observed
  (ANode{a,b},"N(" ++ text ++ "," ++ other ++ ")")
def tree_left(~T:Type,b:Array<T> & String,observed:Array<T> & String) -> Array<T> & String:
  (a,text)=observed
  tree_right(~T,a,text,b)
def tree(~T:Type,~show:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,show(value))
    case ANode{a,b}:tree_left(~T,tree(~T,~show,b),tree(~T,~show,a))
def number_value(+value:U32) -> U32 & String:
  (value,U32.show(value))
def number(value:U32) -> U32 & String:
  number_value(value)
def boolean_value(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def boolean(value:Bool) -> Bool & String:
  boolean_value(value)
def payload_second(first:Array<U32>,text:String,observed:Array<U32> & String) -> Payload & String:
  (second,other)=observed
  (Payload{first,second},"P(" ++ text ++ "," ++ other ++ ")")
def payload_first(second:Array<U32>,observed:Array<U32> & String) -> Payload & String:
  (first,text)=observed
  payload_second(first,text,tree(~U32,~number,second))
def show_payload(payload:Payload) -> Payload & String:
  match payload:
    case Payload{first,second}:payload_first(second,tree(~U32,~number,first))
def some_payload(observed:Payload & String) -> Maybe<&1,Payload> & String:
  (payload,text)=observed
  (Some{payload},text)
def show_slot(slot:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match slot:
    case None{}:(None{},"absent")
    case Some{payload}:some_payload(show_payload(payload))
def removed_finish(payload:Payload,text:String,observed:List<Payload> & String) -> List<Payload> & String:
  (removed,other)=observed
  (payload <> removed,text ++ ";" ++ other)
def removed_join(first:Payload & String,rest:List<Payload> & String) -> List<Payload> & String:
  (payload,text)=first
  removed_finish(payload,text,rest)
def show_removed(removed:List<Payload>) -> List<Payload> & String:
  match removed:
    case []:([],"")
    case payload <> rest:removed_join(show_payload(payload),show_removed(rest))
def components_removed(slots:Array<Maybe<&1,Payload>>,text:String,observed:List<Payload> & String) -> Components & String:
  (removed,other)=observed
  (Components{slots,removed},text ++ "/removed=" ++ other)
def components_slots(removed:List<Payload>,observed:Array<Maybe<&1,Payload>> & String) -> Components & String:
  (slots,text)=observed
  components_removed(slots,text,show_removed(removed))
def show_components(components:Components) -> Components & String:
  match components:
    case Components{slots,removed}:components_slots(removed,tree(~Maybe<&1,Payload>,~show_slot,slots))
def show_kind(kind:G.RelationKind) -> String:
  match kind:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def show_descriptor(~S:Data,descriptor:G.Descriptor<S>) -> String:
  match descriptor:
    case G.Descriptor{key,name,inverse,kind}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ show_kind(kind)
def show_edge(~S:Data,edge:G.Edge<S>) -> String:
  match edge:
    case G.Edge{descriptor,source,target}:show_descriptor(~S,descriptor) ++ ":" ++ Identity.key_text(source) ++ ">" ++ Identity.key_text(target)
def show_inverse(~S:Data,inverse:G.Inverse<S>) -> String:
  match inverse:
    case G.Inverse{descriptor,target,sources}:show_descriptor(~S,descriptor) ++ ":" ++ Identity.key_text(target) ++ ":" ++ List.show(&2,K.Key,Identity.key_text,sources)
def show_graph(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{edges,inverses}:List.show(&2,G.Edge<S>,show_edge(~S),edges) ++ "/" ++ List.show(&2,G.Inverse<S>,show_inverse(~S),inverses)
def show_member(member:Sc.Member) -> String:
  match member:
    case Sc.Member{name,id}:name ++ ":" ++ Identity.key_text(id)
def store_components(~S:Data,+members:List<&2,Sc.Member>,+graph:G.Graph<S>,observed:Components & String) -> A.Store<S,Sc.Store<S,Components>> & String:
  (components,text)=observed
  (A.Store{Sc.Store{components,members},graph},text ++ "/graph=" ++ show_graph(~S,graph) ++ "/scopes=" ++ List.show(&2,Sc.Member,show_member,members))
def show_store(~S:Data,store:A.Store<S,Sc.Store<S,Components>>) -> A.Store<S,Sc.Store<S,Components>> & String:
  match store:
    case A.Store{Sc.Store{components,members},graph}:store_components(~S,members,graph,show_components(components))
def show_notice(~S:Data,notice:A.Notice<S,U32>) -> String:
  match notice:
    case A.Original{value}:"original:" ++ U32.show(value)
    case A.ComponentRemoved{id}:"removed:" ++ Identity.key_text(id)
    case A.RelationFailed{failure}:"failure"
    case A.CleanupPaused{frames}:"paused"
def show_registration(registration:W.RegistrationMeta) -> String:
  match registration:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value => value,access)
def allocator_done(~S:Data,+namespace:U32,store:A.Store<S,Sc.Store<S,Components>>,resource:Array<U32>,+events:List<&2,A.Notice<S,U32>>,pending:List<(W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,pendingCount:U32,storeText:String,resourceText:String,observed:Alloc.Allocator & String) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  (allocator,text)=observed
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},"world=" ++ U32.show(namespace) ++ ",allocator={" ++ text ++ "}/" ++ storeText ++ "/resource=" ++ resourceText ++ "/events=" ++ List.show(&2,A.Notice<S,U32>,show_notice(~S),events) ++ "/pending=" ++ U32.show(pendingCount) ++ "/regs=" ++ List.show(&2,W.RegistrationMeta,show_registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystemId) ++ "/clock=" ++ U32.show(clock))
def live_observe(~S:Data,pendingCount:U32,storeText:String,resourceText:String,world:W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:allocator_done(~S,namespace,store,resource,events,pending,registrations,nextSystemId,clock,pendingCount,storeText,resourceText,Gen.allocator(allocator))
def resource_observed(~S:Data,pendingCount:U32,storeText:String,observed:W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,text)=observed
  live_observe(~S,pendingCount,storeText,text,world)
def store_observed(~S:Data,pendingCount:U32,observed:W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,text)=observed
  resource_observed(~S,pendingCount,text,W.observe_resource(~S,~A.Store<S,Sc.Store<S,Components>>,~Array<U32>,~A.Notice<S,U32>,~String,~tree(~U32,~number),world))
def pending_observed(~S:Data,observed:W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,count)=observed
  store_observed(~S,count,W.with_store(~S,~A.Store<S,Sc.Store<S,Components>>,~Array<U32>,~A.Notice<S,U32>,~String,show_store(~S),world))
def observe(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Components>>,Array<U32>,A.Notice<S,U32>> & String:
  pending_observed(~S,W.pending_count(~S,~A.Store<S,Sc.Store<S,Components>>,~Array<U32>,~A.Notice<S,U32>,world))
