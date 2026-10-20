import Base
import entity-key.bend as Key
import ./persistence-declaration.bend as Persist
import ./decode-data.bend as D
import ./ordinary-component-binding.bend as Binding
import ./ordinary-declaration.bend as Identity
import ./column.bend as Col
import ./world.bend as W
import ./ordinary-schema.bend as Schema
import ./schema-fragments.bend as Fragment
import ./ordinary-schema-provision.bend as Ordinary
import ./ordinary-schema-dump.bend as Dump
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
# Trusted storage presence adapter using the operational column lenses.
# Returns store and Bool for a slot index, without World/handle validation.
# Ordinary callers provide live handles through the population/dump route.
def has(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,store:C,id:U32) -> C & Bool:has_taken(~S,~C,~Rest,~P,~put,id,take(store))
def count_loop(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,handles:List<&2,W.Handle<S>>,store:C,total:U32) -> C & U32:
  match handles:
    case []:(store,total)
    case W.Handle{_,Key.EntityKey{id,_}} <> rest:counted(~C,total,store=>total=>count_loop(~S,~C,~Rest,~P,~take,~put,rest,store,total),has(~S,~C,~Rest,~P,~take,~put,store,id))
def count_returned(~C:Type,result:C & U32) -> C & List<&2,Maybe<&2,U32>>:
  match result:
    case (store,total):(store,[Some{total}])
# Trusted population callback counting this bound component among supplied
# handles and returning the retained store with one Some count slot.
# Does not validate namespaces/generations; use the matching ordinary traversal.
def count(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,store:C,handles:List<&2,W.Handle<S>>) -> C & List<&2,Maybe<&2,U32>>:count_returned(~C,count_loop(~S,~C,~Rest,~P,~take,~put,handles,store,0))
def rendered(~P:Type,~V:Data,~render:V -> String,result:P & V) -> P & String:
  match result:
    case (owner,value):(owner,render(value))
# Thread a component payload through view and render its detached Data V.
# view must return P; render owns no affine payload. Does not access a World.
def present(~P:Type,~V:Data,~view:P -> P & V,~render:V -> String,owner:P) -> P & String:rendered(~P,~V,~render,view(owner))
def view_returned(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,rest:Rest,result:Col.Column<S,P> & Maybe<&2,String>) -> C & List<&2,Maybe<&2,String>>:
  match result:
    case (column,value):(put(rest,column),[value])
def view_taken(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,id:U32,result:Rest & Col.Column<S,P>) -> C & List<&2,Maybe<&2,String>>:
  match result:
    case (rest,column):view_returned(~S,~C,~Rest,~P,~put,rest,Col.view(~S,~P,~String,~present(~P,~V,~view,~render),column,id))
# Trusted component-display callback for a raw slot index, returning store
# and one optional rendered-value slot. Missing component remains None;
# handle validity is established by the enclosing World dump traversal.
def values(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,store:C,id:U32) -> C & List<&2,Maybe<&2,String>>:view_taken(~S,~C,~Rest,~P,~V,~put,~view,~render,id,take(store))
def no_resource(value:Unit) -> Unit & List<&2,Maybe<&2,String>>:(value,[None{}])
# Build dump/population provisioning from the SAME operational binding.
# Identity, lenses and view are not repeated as debug metadata. render handles
# detached V; payload/store ownership stays threaded through trusted callbacks.
# Does not read a World or validate arbitrary lens laws during construction.
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
# Append two component provisions over the same aggregate store owner.
# Combines their entry/count/display order without constructing a storage
# product. Supplied bindings must consistently refer to that same owner shape.
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
# Advanced resource-display callback composing prior Unit resource slots
# with an owner-preserving renderer for R. Returns R and ordered optional text
# slots; arbitrary render effects are trusted, not a World transaction.
def resources(~R:Type,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,owner:R) -> R & List<&2,Maybe<&2,String>>:resource_prefix(~R,~show,owner,before(Unit{}))
# Extend component provisioning with one ordinary resource declaration and
# owner-preserving renderer. Adds None component/count slots for that resource;
# it is not counted as a component. Does not construct R or inspect World.
def with_resource(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,resource:Schema.Resource<S,R>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:
  match resource base:
    case Schema.Resource{+key} Dump.Provision{Ordinary.Provision{Schema.Schema{entries}}}:Dump.Provision{Ordinary.Provision{Schema.Schema{List.append(&2,Fragment.Entry<S>,entries,[Fragment.Entry{Fragment.Resource{},key,key}])}}}

# Rebase existing operational schema entries onto the SAME aggregate owner.
# Trusted advanced adapter rebasing a schema onto matching aggregate
# storage/display callbacks. Caller must preserve entry/slot consistency;
# metadata alone does not prove lens identity or create component authority.
def component_schema(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,~empty:Unit -> C,schema:Schema.Schema<S,Col.Column<S,P>,Unit>) -> Dump.Provision<S,C,Unit,empty,count(~S,~C,~Rest,~P,~take,~put),values(~S,~C,~Rest,~P,~V,~take,~put,~view,~render),no_resource>:
  match schema:
    case Schema.Schema{entries}:Dump.Provision{Ordinary.Provision{Schema.Schema{entries}}}
# Build component provisioning with plain classification from the same
# operational binding and identity-bound persistence extension. Derives count
# and display routes; classification does not itself execute codecs or snapshots.
def component_plain(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,~empty:Unit -> C,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,extension:Persist.Plain<S,P,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding)>) -> Dump.Provision<S,C,Unit,empty,count(~S,~C,~Rest,~P,~take,~put),values(~S,~C,~Rest,~P,~V,~take,~put,~view,~render),no_resource>:component_schema(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,~render,~empty,Schema.component_plain(~S,~P,~Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),extension))
# Build component provisioning with transient classification from the same
# operational binding and identity-bound persistence extension. Derives count
# and display routes; classification does not itself execute codecs or snapshots.
def component_transient(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,~empty:Unit -> C,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,extension:Persist.Transient<S,P,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding)>) -> Dump.Provision<S,C,Unit,empty,count(~S,~C,~Rest,~P,~take,~put),values(~S,~C,~Rest,~P,~V,~take,~put,~view,~render),no_resource>:component_schema(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,~render,~empty,Schema.component_transient(~S,~P,~Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),extension))
# Build component provisioning with constructed classification from the same
# operational binding and identity-bound persistence extension. Derives count
# and display routes; classification does not itself execute codecs or snapshots.
def component_constructed(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~render:V -> String,~empty:Unit -> C,~binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>,~project:P -> P & D.Raw,extension:Persist.Constructed<S,P,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),project>) -> Dump.Provision<S,C,Unit,empty,count(~S,~C,~Rest,~P,~take,~put),values(~S,~C,~Rest,~P,~V,~take,~put,~view,~render),no_resource>:component_schema(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,~render,~empty,Schema.component_constructed(~S,~P,~Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),~project,extension))
# Trusted advanced adapter appending resource schema entries to an existing
# dump provision with matching resource/count/display callbacks. Does not
# validate forged callback/entry relationships or create resource payloads.
def resource_schema(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,schema:Schema.Schema<S,Unit,R>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:
  match schema base:
    case Schema.Schema{added} Dump.Provision{Ordinary.Provision{Schema.Schema{entries}}}:Dump.Provision{Ordinary.Provision{Schema.Schema{List.append(&2,Fragment.Entry<S>,entries,added)}}}
# Extend dump provisioning with a constructed resource declaration and its
# owner-preserving presentation. Uses the identity-bound persistence extension;
# creates metadata/slots, not a resource payload or a saved value.
def with_resource_constructed(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,~identity:Identity.Declaration<S,R>,~project:R -> R & D.Raw,extension:Persist.Constructed<S,R,identity,project>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:resource_schema(~S,~C,~R,~empty,~count,~read,~before,~show,Schema.resource_constructed(~S,~R,~identity,~project,extension),base)
# Extend dump provisioning with a plain resource declaration and its
# owner-preserving presentation. Uses the identity-bound persistence extension;
# creates metadata/slots, not a resource payload or a saved value.
def with_resource_plain(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,~identity:Identity.Declaration<S,R>,extension:Persist.Plain<S,R,identity>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:resource_schema(~S,~C,~R,~empty,~count,~read,~before,~show,Schema.resource_plain(~S,~R,~identity,extension),base)
# Extend dump provisioning with a transient resource declaration and its
# owner-preserving presentation. Uses the identity-bound persistence extension;
# creates metadata/slots, not a resource payload or a saved value.
def with_resource_transient(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~read:C -> U32 -> C & List<&2,Maybe<&2,String>>,~before:Unit -> Unit & List<&2,Maybe<&2,String>>,~show:R -> R & String,~identity:Identity.Declaration<S,R>,extension:Persist.Transient<S,R,identity>,base:Dump.Provision<S,C,Unit,empty,count,read,before>) -> Dump.Provision<S,C,R,empty,resource_count(~S,~C,~count),resource_values(~C,~read),resources(~R,~before,~show)>:resource_schema(~S,~C,~R,~empty,~count,~read,~before,~show,Schema.resource_transient(~S,~R,~identity,extension),base)
