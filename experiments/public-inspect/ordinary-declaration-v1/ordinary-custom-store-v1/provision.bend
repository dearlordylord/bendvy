import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as Dump
# Consume the SAME operational Binding; no second identity/lens debug input.
# Existing schema-authoring lenses remain trusted, not universal identity proofs.
def counted(~C:Type,total:U32,next:C -> U32 -> C & U32,result:C & Bool) -> C & U32:
  match result:
    case (store,True{}):next(store,U32.add(total,1))
    case (store,False{}):next(store,total)
def has_returned(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,rest:Rest,result:Col.Column<S,P> & Bool) -> C & Bool:
  match result:
    case (column,present):(put(rest,column),present)
def has_taken(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,id:U32,result:Rest & Col.Column<S,P>) -> C & Bool:
  match result:
    case (rest,column):has_returned(~S,~C,~Rest,~P,~put,rest,Col.has(~S,~P,column,id))
def has(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,store:C,id:U32) -> C & Bool:has_taken(~S,~C,~Rest,~P,~put,id,take(store))
def count_loop(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,handles:List<&2,W.Handle<S>>,store:C,total:U32) -> C & U32:
  match handles:
    case []:(store,total)
    case W.Handle{_,id} <> rest:counted(~C,total,store=>total=>count_loop(~S,~C,~Rest,~P,~take,~put,rest,store,total),has(~S,~C,~Rest,~P,~take,~put,store,id))
def count_returned(~C:Type,result:C & U32) -> C & List<&2,Maybe<&2,U32>>:
  match result:
    case (store,total):(store,[Some{total}])
def count(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,store:C,handles:List<&2,W.Handle<S>>) -> C & List<&2,Maybe<&2,U32>>:count_returned(~C,count_loop(~S,~C,~Rest,~P,~take,~put,handles,store,0))
def rendered(~P:Type,~V:Data,~render:V -> String,result:P & V) -> P & String:
  match result:
    case (owner,value):(owner,render(value))
def present(~P:Type,~V:Data,~view:P -> P & V,~render:V -> String,owner:P) -> P & String:rendered(~P,~V,~render,view(owner))
def view_returned(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,rest:Rest,result:Col.Column<S,P> & Maybe<&2,String>) -> C & List<&2,Maybe<&2,String>>:
  match result:
    case (column,value):(put(rest,column),[value])
def view_taken(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,id:U32,result:Rest & Col.Column<S,P>) -> C & List<&2,Maybe<&2,String>>:
  match result:
    case (rest,column):view_returned(~S,~C,~Rest,~P,~put,rest,Col.view(~S,~P,~String,~present(~P,~V,~view,~render),column,id))
def values(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,store:C,id:U32) -> C & List<&2,Maybe<&2,String>>:view_taken(~S,~C,~Rest,~P,~V,~put,~view,~render,id,take(store))
def no_resource(value:Unit) -> Unit & List<&2,Maybe<&2,String>>:(value,[None{}])
def component(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,~empty:Unit -> C,binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>) -> Dump.Provision<S,C,Unit,empty,count(~S,~C,~Rest,~P,~take,~put),values(~S,~C,~Rest,~P,~V,~take,~put,~view,~render),no_resource>:
  match binding:
    case Binding.Binding{+identity,_}:Dump.Provision{Ordinary.Provision{Schema.Schema{[Fragment.Entry{Fragment.Component{},Identity.key(~S,~P,identity),Identity.key(~S,~P,identity)}]}}}
def joined(~C:Type,~V:Data,before:List<&2,Maybe<&2,V>>,result:C & List<&2,Maybe<&2,V>>) -> C & List<&2,Maybe<&2,V>>:
  match result:
    case (store,after):(store,List.append(&2,Maybe<&2,V>,before,after))
def next_count(~S:Data,~C:Type,~right:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,handles:List<&2,W.Handle<S>>,result:C & List<&2,Maybe<&2,U32>>) -> C & List<&2,Maybe<&2,U32>>:
  match result:
    case (store,before):joined(~C,~U32,before,right(store,handles))
def append_count(~S:Data,~C:Type,~left:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~right:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,store:C,handles:List<&2,W.Handle<S>>) -> C & List<&2,Maybe<&2,U32>>:
  +handles=handles
  next_count(~S,~C,~right,handles,left(store,handles))
def next_values(~C:Type,~right:C -> U32 -> C & List<&2,Maybe<&2,String>>,id:U32,result:C & List<&2,Maybe<&2,String>>) -> C & List<&2,Maybe<&2,String>>:
  match result:
    case (store,before):joined(~C,~String,before,right(store,id))
def append_values(~C:Type,~left:C -> U32 -> C & List<&2,Maybe<&2,String>>,~right:C -> U32 -> C & List<&2,Maybe<&2,String>>,store:C,id:U32) -> C & List<&2,Maybe<&2,String>>:
  +id=id
  next_values(~C,~right,id,left(store,id))
def next_resources(~right:Unit -> Unit & List<&2,Maybe<&2,String>>,result:Unit & List<&2,Maybe<&2,String>>) -> Unit & List<&2,Maybe<&2,String>>:
  match result:
    case (owner,before):joined(~Unit,~String,before,right(owner))
def append_resources(~left:Unit -> Unit & List<&2,Maybe<&2,String>>,~right:Unit -> Unit & List<&2,Maybe<&2,String>>,owner:Unit) -> Unit & List<&2,Maybe<&2,String>>:next_resources(~right,left(owner))
def append(~S:Data,~C:Type,~empty:Unit -> C,~lc:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~rc:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~lv:C -> U32 -> C & List<&2,Maybe<&2,String>>,~rv:C -> U32 -> C & List<&2,Maybe<&2,String>>,~lr:Unit -> Unit & List<&2,Maybe<&2,String>>,~rr:Unit -> Unit & List<&2,Maybe<&2,String>>,left:Dump.Provision<S,C,Unit,empty,lc,lv,lr>,right:Dump.Provision<S,C,Unit,empty,rc,rv,rr>) -> Dump.Provision<S,C,Unit,empty,append_count(~S,~C,~lc,~rc),append_values(~C,~lv,~rv),append_resources(~lr,~rr)>:
  match left right:
    case Dump.Provision{Ordinary.Provision{Schema.Schema{left}}} Dump.Provision{Ordinary.Provision{Schema.Schema{right}}}:Dump.Provision{Ordinary.Provision{Schema.Schema{List.append(&2,Fragment.Entry<S>,left,right)}}}
# Resource identity is supplied once through the existing ordinary declaration.
def trailing_none(~C:Type,~V:Data,result:C & List<&2,Maybe<&2,V>>) -> C & List<&2,Maybe<&2,V>>:
  match result:
    case (store,before):(store,List.append(&2,Maybe<&2,V>,before,[None{}]))
def resource_count(~S:Data,~C:Type,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,store:C,handles:List<&2,W.Handle<S>>) -> C & List<&2,Maybe<&2,U32>>:trailing_none(~C,~U32,count(store,handles))
def resource_values(~C:Type,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,store:C,id:U32) -> C & List<&2,Maybe<&2,String>>:trailing_none(~C,~String,read(store,id))
def resource_returned(~R:Type,before:List<&2,Maybe<&2,String>>,result:R & String) -> R & List<&2,Maybe<&2,String>>:
  match result:
    case (owner,text):(owner,List.append(&2,Maybe<&2,String>,before,[Some{text}]))
def resource_prefix(~R:Type,~show:R -> R & String,owner:R,result:Unit & List<&2,Maybe<&2,String>>) -> R & List<&2,Maybe<&2,String>>:
  match result:
    case (_,before):resource_returned(~R,before,show(owner))
def resources(~R:Type,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,owner:R) -> R & List<&2,Maybe<&2,String>>:resource_prefix(~R,~show,owner,before(Unit{}))
def with_resource(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,resource:Schema.Resource<S,R>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:
  match resource base:
    case Schema.Resource{+key} Dump.Provision{Ordinary.Provision{Schema.Schema{entries}}}:Dump.Provision{Ordinary.Provision{Schema.Schema{List.append(&2,Fragment.Entry<S>,entries,[Fragment.Entry{Fragment.Resource{},key,key}])}}}
