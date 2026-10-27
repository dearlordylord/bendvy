import Base
import ./execution-composer-layout.bend as L
import ./execution-resource-recipe.bend as Recipe
import ./execution-resource-store.bend as Store
import ./execution-query-schema.bend as Routes
import ./owner-product.bend as Product
import ./lifecycle.bend as Life
import ./schema-fragments.bend as Fragment

type StampEntry is Data:
  StampEntry{route:L.Route,stamp:Life.Stamp}
def stamp_selected(stamp:Life.Stamp,next:Life.Stamp,selected:Bool) -> Life.Stamp:
  match selected:
    case True{}:stamp
    case False{}:next
def stamp_at(+route:L.Route,entries:List<&2,StampEntry>) -> Life.Stamp:
  match entries:
    case []:Life.Stamp{None{},None{}}
    case StampEntry{at,stamp} <> rest:stamp_selected(stamp,stamp_at(route,rest),Routes.same_route(route,at))
type Family<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Family{left:Store.Slot<S,P,V,origin>,right:Store.Slot<S,P,V,origin>,rest:Maybe<&1,L.ResourceSlot<S,L.Viewed<P,V>,key,origin>>,stamp:Life.Stamp}
def families(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key}:Family<S,P,V,key,L.LayoutLeaf{P,V,refresh,key}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}:Family<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>
    case L.LayoutPair{left,right}:Product.Owner<families(~S,left),families(~S,right)>
type JoinOwner<-S:Data,-full:L.Layout> is Type:
  JoinOwner{namespace:U32,left:List<&2,Recipe.Entry>,right:List<&2,Recipe.Entry>}
type Cut<-S:Data,-full:L.Layout> is Type:
  Partitioned{families:families(~S,full),join:JoinOwner<S,full>}
  Refused{resources:L.resources(~S,full)}
def cache(-V:Data,view:V,permission:Recipe.Permission) -> Maybe<&2,V>:
  match permission:
    case Recipe.Unused{}:None{}
    case _:Some{view}
def split_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,owner:P,+view:V,+stamp:Life.Stamp,+left:Recipe.Permission,+right:Recipe.Permission) -> Family<S,P,V,key,origin>:
  match left right:
    case Recipe.Writable{} Recipe.Unused{}:Family{Store.Slot{Some{L.Viewed{owner,view}},Some{view},stamp,left},Store.Slot{None{},None{},stamp,right},None{},stamp}
    case Recipe.Unused{} Recipe.Writable{}:Family{Store.Slot{None{},None{},stamp,left},Store.Slot{Some{L.Viewed{owner,view}},Some{view},stamp,right},None{},stamp}
    case left right:Family{Store.Slot{None{},cache(V,view,left),stamp,left},Store.Slot{None{},cache(V,view,right),stamp,right},Some{L.ResourceSlot{L.Viewed{owner,view}}},stamp}
def scatter(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,+stamps:List<&2,StampEntry>,resources:L.resources(~S,layout)) -> families(~S,layout):
  match layout resources:
    case L.EmptyLayout{} Unit{}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key} L.ResourceSlot{L.Viewed{owner,view}}:split_family(S,P,V,key,L.LayoutLeaf{P,V,refresh,key},owner,view,stamp_at(route,stamps),Recipe.at(route,left),Recipe.at(route,right))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind} L.ResourceSlot{L.Viewed{owner,view}}:split_family(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind},owner,view,stamp_at(route,stamps),Recipe.at(route,left),Recipe.at(route,right))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:Product.Owner{scatter(~S,ll,Routes.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,stamps,l),scatter(~S,rr,Routes.append_route(route,L.InRight{L.AtLeaf{}}),left,right,stamps,r)}
def cut_checked(~S:Data,~full:L.Layout,+namespace:U32,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,stamps:List<&2,StampEntry>,resources:L.resources(~S,full),valid:Bool) -> Cut<S,full>:
  match valid:
    case False{}:Refused{resources}
    case True{}:Partitioned{scatter(~S,full,L.AtLeaf{},left,right,stamps,resources),JoinOwner{namespace,left,right}}
# Complete closed recipes are checked before any actual resource is extracted.
def cut(~S:Data,~full:L.Layout,namespace:U32,left:Recipe.Book<S,full>,right:Recipe.Book<S,full>,stamps:List<&2,StampEntry>,resources:L.resources(~S,full)) -> Cut<S,full>:
  match left right:
    case Recipe.Book{+left} Recipe.Book{+right}:cut_checked(~S,~full,namespace,left,right,stamps,resources,Recipe.compatible(~full,left,right))

def present(-A:Type,value:Maybe<&1,A>) -> Maybe<&1,A> & Bool:
  match value:
    case None{}:(None{},False{})
    case Some{owner}:(Some{owner},True{})
def cache_present(-V:Data,value:Maybe<&2,V>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def same_bool(left:Bool,right:Bool) -> Bool:
  Bool.not(Bool.xor(left,right))
def checked_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,+expected:Recipe.Permission,+cache:Maybe<&2,V>,stamp:Life.Stamp,+permission:Recipe.Permission,result:Maybe<&1,L.Viewed<P,V>> & Bool) -> Store.Slot<S,P,V,origin> & Bool:
  match result:
    case (owner,owned):(Store.Slot{owner,cache,stamp,permission},Bool.and(Recipe.same(expected,permission),Bool.and(same_bool(owned,Recipe.writes(expected)),same_bool(cache_present(V,cache),Recipe.uses(expected)))))
def check_slot(-S:Data,-P:Type,-V:Data,-origin:L.Layout,expected:Recipe.Permission,slot:Store.Slot<S,P,V,origin>) -> Store.Slot<S,P,V,origin> & Bool:
  match slot:
    case Store.Slot{owner,cache,stamp,permission}:checked_slot(S,P,V,origin,expected,cache,stamp,permission,present(L.Viewed<P,V>,owner))
def checked_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,+leftExpected:Recipe.Permission,+rightExpected:Recipe.Permission,stamp:Life.Stamp,left:Store.Slot<S,P,V,origin> & Bool,right:Store.Slot<S,P,V,origin> & Bool,rest:Maybe<&1,L.ResourceSlot<S,L.Viewed<P,V>,key,origin>> & Bool) -> Family<S,P,V,key,origin> & Bool:
  match left right rest:
    case (left,lv), (right,rv), (rest,owned):(Family{left,right,rest,stamp},Bool.and(lv,Bool.and(rv,same_bool(owned,Bool.not(Bool.or(Recipe.writes(leftExpected),Recipe.writes(rightExpected)))))))
def check_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,+leftExpected:Recipe.Permission,+rightExpected:Recipe.Permission,family:Family<S,P,V,key,origin>) -> Family<S,P,V,key,origin> & Bool:
  match family:
    case Family{left,right,rest,stamp}:checked_family(S,P,V,key,origin,leftExpected,rightExpected,stamp,check_slot(S,P,V,origin,leftExpected,left),check_slot(S,P,V,origin,rightExpected,right),present(L.ResourceSlot<S,L.Viewed<P,V>,key,origin>,rest))
def checked_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:families(~S,ll) & Bool,right:families(~S,rr) & Bool) -> families(~S,L.LayoutPair{ll,rr}) & Bool:
  match left right:
    case (left,lv), (right,rv):(Product.Owner{left,right},Bool.and(lv,rv))
def inspect(~S:Data,layout:L.Layout,+route:L.Route,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,tree:families(~S,layout)) -> families(~S,layout) & Bool:
  match layout tree:
    case L.EmptyLayout{} Unit{}:(Unit{},True{})
    case L.LayoutLeaf{P,V,refresh,key} family:check_family(S,P,V,key,L.LayoutLeaf{P,V,refresh,key},Recipe.at(route,left),Recipe.at(route,right),family)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind} family:check_family(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind},Recipe.at(route,left),Recipe.at(route,right),family)
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:checked_pair(~S,ll,rr,inspect(~S,ll,Routes.append_route(route,L.InLeft{L.AtLeaf{}}),left,right,l),inspect(~S,rr,Routes.append_route(route,L.InRight{L.AtLeaf{}}),left,right,r))

type Recovery<-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout> is Type:
  Recovered{resource:L.ResourceSlot<S,L.Viewed<P,V>,key,origin>,stamp:Life.Stamp}
  Unrecovered{family:Family<S,P,V,key,origin>}
def recoveries(~S:Data,layout:L.Layout) -> Type:
  match layout:
    case L.EmptyLayout{}:Unit
    case L.LayoutLeaf{P,V,refresh,key}:Recovery<S,P,V,key,L.LayoutLeaf{P,V,refresh,key}>
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}:Recovery<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>
    case L.LayoutPair{left,right}:Product.Owner<recoveries(~S,left),recoveries(~S,right)>
def recover_family(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,family:Family<S,P,V,key,origin>) -> Recovery<S,P,V,key,origin>:
  match family:
    case Family{Store.Slot{Some{owner},_,stamp,Recipe.Writable{}},Store.Slot{None{},_,_,Recipe.Unused{}},None{},_}:Recovered{L.ResourceSlot{owner},stamp}
    case Family{Store.Slot{None{},_,_,Recipe.Unused{}},Store.Slot{Some{owner},_,stamp,Recipe.Writable{}},None{},_}:Recovered{L.ResourceSlot{owner},stamp}
    case Family{Store.Slot{None{},_,_,_},Store.Slot{None{},_,_,_},Some{owner},stamp}:Recovered{owner,stamp}
    case family:Unrecovered{family}
def recover(~S:Data,layout:L.Layout,tree:families(~S,layout)) -> recoveries(~S,layout):
  match layout tree:
    case L.EmptyLayout{} Unit{}:Unit{}
    case L.LayoutLeaf{P,V,refresh,key} family:recover_family(S,P,V,key,L.LayoutLeaf{P,V,refresh,key},family)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind} family:recover_family(S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind},family)
    case L.LayoutPair{ll,rr} Product.Owner{left,right}:Product.Owner{recover(~S,ll,left),recover(~S,rr,right)}
type Stage<-S:Data,-full:L.Layout> is Type:
  Ready{resources:L.resources(~S,full),stamps:List<&2,StampEntry>,restore:L.resources(~S,full) -> recoveries(~S,full)}
  Unready{inventory:recoveries(~S,full)}
def restore_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:L.resources(~S,ll) -> recoveries(~S,ll),right:L.resources(~S,rr) -> recoveries(~S,rr),resources:L.resources(~S,L.LayoutPair{ll,rr})) -> recoveries(~S,L.LayoutPair{ll,rr}):
  match resources:
    case Product.Owner{l,r}:Product.Owner{left(l),right(r)}
def staged_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Stage<S,ll>,right:Stage<S,rr>) -> Stage<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Ready{left,ls,leftRestore} Ready{right,rs,rightRestore}:Ready{Product.Owner{left,right},List.append(&2,StampEntry,ls,rs),(resources => restore_pair(~S,ll,rr,leftRestore,rightRestore,resources))}
    case Ready{left,_,restore} Unready{right}:Unready{Product.Owner{restore(left),right}}
    case Unready{left} Ready{right,_,restore}:Unready{Product.Owner{left,restore(right)}}
    case Unready{left} Unready{right}:Unready{Product.Owner{left,right}}
def stage_plain(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,route:L.Route,recovery:Recovery<S,P,V,key,L.LayoutLeaf{P,V,refresh,key}>) -> Stage<S,L.LayoutLeaf{P,V,refresh,key}>:
  match recovery:
    case Recovered{resource,+stamp}:Ready{resource,[StampEntry{route,stamp}],(resource => Recovered{resource,stamp})}
    case recovery:Unready{recovery}
def stage_classified(-S:Data,-P:Type,-V:Data,-refresh:P -> P & V,-key:String,-kind:Fragment.PersistenceKind,route:L.Route,recovery:Recovery<S,P,V,key,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>) -> Stage<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind}>:
  match recovery:
    case Recovered{resource,+stamp}:Ready{resource,[StampEntry{route,stamp}],(resource => Recovered{resource,stamp})}
    case recovery:Unready{recovery}
def stage(~S:Data,layout:L.Layout,+route:L.Route,inventory:recoveries(~S,layout)) -> Stage<S,layout>:
  match layout inventory:
    case L.EmptyLayout{} Unit{}:Ready{Unit{},[],(owner => Unit{})}
    case L.LayoutLeaf{P,V,refresh,key} recovery:stage_plain(S,P,V,refresh,key,route,recovery)
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind} recovery:stage_classified(S,P,V,refresh,key,kind,route,recovery)
    case L.LayoutPair{ll,rr} Product.Owner{left,right}:staged_pair(~S,ll,rr,stage(~S,ll,Routes.append_route(route,L.InLeft{L.AtLeaf{}}),left),stage(~S,rr,Routes.append_route(route,L.InRight{L.AtLeaf{}}),right))
type Joined<-S:Data,-full:L.Layout> is Type:
  Joined{resources:L.resources(~S,full),stamps:List<&2,StampEntry>}
  JoinRefused{families:families(~S,full),join:JoinOwner<S,full>}
  JoinInventoryRefused{inventory:recoveries(~S,full),join:JoinOwner<S,full>}
def staged(~S:Data,~full:L.Layout,join:JoinOwner<S,full>,result:Stage<S,full>) -> Joined<S,full>:
  match result:
    case Ready{resources,stamps,_}:Joined{resources,stamps}
    case Unready{inventory}:JoinInventoryRefused{inventory,join}
def join_checked(~S:Data,~full:L.Layout,join:JoinOwner<S,full>,result:families(~S,full) & Bool) -> Joined<S,full>:
  match result:
    case (families,False{}):JoinRefused{families,join}
    case (families,True{}):staged(~S,~full,join,stage(~S,full,L.AtLeaf{},recover(~S,full,families)))
def join(~S:Data,~full:L.Layout,families:families(~S,full),join:JoinOwner<S,full>) -> Joined<S,full>:
  match join:
    case JoinOwner{namespace,+left,+right}:join_checked(~S,~full,JoinOwner{namespace,left,right},inspect(~S,full,L.AtLeaf{},left,right,families))
