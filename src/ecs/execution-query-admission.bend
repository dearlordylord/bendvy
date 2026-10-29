import Base
import ./execution-query-recipe.bend as Recipe
import ./execution-query-schema.bend as Schema
import ./execution-query-domain.bend as D
import ./execution-query-matches.bend as Match
import ./execution-query-identity.bend as Id
import ./execution-composer-layout.bend as L
import ./world.bend as W
import ./entity-key.bend as K
import ./indexed-lifecycle.bend as Indexed
import ./chunk-partition.bend as Part
import ./chunk-column.bend as Col

type Granted<-S:Data,-WC:Type> is Data:
  Granted{entry:Recipe.Entry,handles:List<&2,W.Handle<S>>}
type Lowering<-S:Data,-WC:Type,-full:L.Layout> is Data:
  Lowered{grants:List<&2,Granted<S,WC>>,book:Schema.Book<S,full>}
  LoweringRefused{}
def info_matches(route:L.Route,info:Schema.Info) -> Bool:
  match info:
    case Schema.Info{at,_,_}:Schema.same_route(route,at)
def info_selected(info:Schema.Info,next:Maybe<&2,Schema.Info>,selected:Bool) -> Maybe<&2,Schema.Info>:
  match selected:
    case False{}:next
    case True{}:Some{info}
def info_at(+route:L.Route,info:List<&2,Schema.Info>) -> Maybe<&2,Schema.Info>:
  match info:
    case []:None{}
    case +head <> rest:info_selected(head,info_at(route,rest),info_matches(route,head))
def present(info:Maybe<&2,Schema.Info>,offset:U32,wanted:Bool) -> Bool:
  match info:
    case None{}:False{}
    case Some{Schema.Info{_,_,domain}}:Bool.not(Bool.xor(D.contains(domain,offset),wanted))
def bound(+info:List<&2,Schema.Info>,selection:Recipe.Bound,+offset:U32) -> Bool:
  match selection:
    case Recipe.AllLive{}:True{}
    case Recipe.Changed{_}:True{}
    case Recipe.With{route}:present(info_at(route,info),offset,True{})
    case Recipe.Without{route}:present(info_at(route,info),offset,False{})
    case Recipe.And{left,right}:Bool.and(bound(info,left,offset),bound(info,right,offset))
    case Recipe.Or{left,right}:Bool.or(bound(info,left,offset),bound(info,right,offset))
def selected_handle(~S:Data,handle:W.Handle<S>,rest:List<&2,W.Handle<S>>,selected:Bool) -> List<&2,W.Handle<S>>:
  match selected:
    case False{}:rest
    case True{}:handle <> rest
def candidate_offset(~S:Data,info:List<&2,Schema.Info>,selection:Recipe.Bound,handle:W.Handle<S>,rest:List<&2,W.Handle<S>>,offset:Maybe<&2,U32>) -> List<&2,W.Handle<S>>:
  match offset:
    case None{}:rest
    case Some{offset}:selected_handle(~S,handle,rest,bound(info,selection,offset))
def candidates(~S:Data,+info:List<&2,Schema.Info>,+selection:Recipe.Bound,handles:List<&2,W.Handle<S>>) -> List<&2,W.Handle<S>>:
  match handles:
    case []:[]
    case +handle <> rest:candidate_offset(~S,info,selection,handle,candidates(~S,info,selection,rest),Id.physical_index(W.handle_index(~S,handle)))
def capacity(info:Maybe<&2,Schema.Info>) -> U32:
  match info:
    case None{}:0
    case Some{Schema.Info{_,capacity,_}}:capacity
def physical_cons(offset:U32,rest:List<&2,U32>,fits:Bool) -> List<&2,U32>:
  match fits:
    case False{}:rest
    case True{}:offset <> rest
# Beyond-storage optional absence remains in Granted.handles. Only physical
# owners/cache cells that actually exist contribute physical cut domains.
def physical_checked(capacity:U32,rest:List<&2,U32>,offset:Maybe<&2,U32>) -> List<&2,U32>:
  match offset:
    case None{}:rest
    case Some{+offset}:physical_cons(offset,rest,U32.is_lt(offset,capacity))
def physical(~S:Data,+capacity:U32,handles:List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []:[]
    case +handle <> rest:physical_checked(capacity,physical(~S,capacity,rest),Id.physical_index(W.handle_index(~S,handle)))
def physical_recipe(kind:Recipe.QueryKind,domain:D.Domain) -> Match.Recipe:
  match kind:
    case Recipe.ReadRows{}:Match.Read{domain}
    case Recipe.WriteRows{}:Match.Write{domain}
def handles_valid(~S:Data,+namespace:U32,handles:List<&2,W.Handle<S>>) -> Bool:
  match handles:
    case []:True{}
    case W.Handle{hn,key} <> rest:Bool.and(U32.is_eq(namespace,hn),Bool.and(Indexed.normal(K.index(key)),handles_valid(~S,namespace,rest)))
def public_indexes(~S:Data,handles:List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []:[]
    case handle <> rest:W.handle_index(~S,handle) <> public_indexes(~S,rest)
def recipe_valid(~S:Data,~WC:Type,~full:L.Layout,recipe:Recipe.Recipe<S,WC>) -> Bool:
  match recipe:
    case Recipe.Recipe{Recipe.Entry{route,_,selection,_}}:Bool.and(L.valid(full,route),Recipe.bound_valid(~full,selection))
def recipes_valid(~S:Data,~WC:Type,~full:L.Layout,recipes:List<&2,Recipe.Recipe<S,WC>>) -> Bool:
  match recipes:
    case []:True{}
    case recipe <> rest:Bool.and(recipe_valid(~S,~WC,~full,recipe),recipes_valid(~S,~WC,~full,rest))
type LoweredEntries<-S:Data,-WC:Type> is Data:
  LoweredEntries{grants:List<&2,Granted<S,WC>>,entries:List<&2,Schema.Entry>}
def bound_entries(~S:Data,+info:List<&2,Schema.Info>,+handles:List<&2,W.Handle<S>>,selection:Recipe.Bound) -> List<&2,Schema.Entry>:
  match selection:
    case Recipe.AllLive{}:[]
    case Recipe.Changed{+route}:[Schema.Entry{route,Match.Read{D.Domain{physical(~S,capacity(info_at(route,info)),handles)}}}]
    case Recipe.With{+route}:[Schema.Entry{route,Match.Read{D.Domain{physical(~S,capacity(info_at(route,info)),handles)}}}]
    case Recipe.Without{+route}:[Schema.Entry{route,Match.Read{D.Domain{physical(~S,capacity(info_at(route,info)),handles)}}}]
    case Recipe.And{left,right}:List.append(&2,Schema.Entry,bound_entries(~S,info,handles,left),bound_entries(~S,info,handles,right))
    case Recipe.Or{left,right}:List.append(&2,Schema.Entry,bound_entries(~S,info,handles,left),bound_entries(~S,info,handles,right))
def lowered_cons(~S:Data,~WC:Type,+route:L.Route,+kind:Recipe.QueryKind,selection:Recipe.Bound,presence:Match.Presence,+handles:List<&2,W.Handle<S>>,capacity:U32,boundReads:List<&2,Schema.Entry>,rest:LoweredEntries<S,WC>) -> LoweredEntries<S,WC>:
  match rest:
    case LoweredEntries{grants,entries}:LoweredEntries{Granted{Recipe.Entry{route,kind,selection,presence},handles} <> grants,Schema.Entry{route,physical_recipe(kind,D.Domain{physical(~S,capacity,handles)})} <> List.append(&2,Schema.Entry,boundReads,entries)}
def lower_entries(~S:Data,~WC:Type,recipes:List<&2,Recipe.Recipe<S,WC>>,+info:List<&2,Schema.Info>,+handles:List<&2,W.Handle<S>>) -> LoweredEntries<S,WC>:
  match recipes:
    case []:LoweredEntries{[],[]}
    case Recipe.Recipe{Recipe.Entry{+route,kind,+selection,presence}} <> rest:lowered_cons(~S,~WC,route,kind,selection,presence,candidates(~S,info,selection,handles),capacity(info_at(route,info)),bound_entries(~S,info,handles,selection),lower_entries(~S,~WC,rest,info,handles))
def lowered(~S:Data,~WC:Type,~full:L.Layout,result:LoweredEntries<S,WC>) -> Lowering<S,WC,full>:
  match result:
    case LoweredEntries{grants,entries}:Lowered{grants,Schema.Book{entries}}
def lower_checked(~S:Data,~WC:Type,~full:L.Layout,recipes:List<&2,Recipe.Recipe<S,WC>>,info:List<&2,Schema.Info>,handles:List<&2,W.Handle<S>>,valid:Bool) -> Lowering<S,WC,full>:
  match valid:
    case False{}:LoweringRefused{}
    case True{}:lowered(~S,~WC,~full,lower_entries(~S,~WC,recipes,info,handles))
def lower(~S:Data,~WC:Type,~full:L.Layout,~same:{WC == L.columns(~S,full) : Type},+recipes:List<&2,Recipe.Recipe<S,WC>>,+info:List<&2,Schema.Info>,namespace:U32,+handles:List<&2,W.Handle<S>>) -> Lowering<S,WC,full>:
  lower_checked(~S,~WC,~full,recipes,info,handles,Bool.and(handles_valid(~S,namespace,handles),Bool.and(Id.unique(~S,handles),Bool.and(Part.inventory_valid(D.validate(U32.add(Col.maximum_capacity(),1),D.Domain{public_indexes(~S,handles)})),recipes_valid(~S,~WC,~full,recipes)))))

def same_kind(left:Recipe.QueryKind,right:Recipe.QueryKind) -> Bool:
  match left right:
    case Recipe.ReadRows{} Recipe.ReadRows{}:True{}
    case Recipe.WriteRows{} Recipe.WriteRows{}:True{}
    case _ _:False{}
def same_presence(left:Match.Presence,right:Match.Presence) -> Bool:
  match left right:
    case Match.Optional{} Match.Optional{}:True{}
    case Match.Required{} Match.Required{}:True{}
    case Match.With{} Match.With{}:True{}
    case Match.Without{} Match.Without{}:True{}
    case _ _:False{}
def same_bound(left:Recipe.Bound,right:Recipe.Bound) -> Bool:
  match left right:
    case Recipe.AllLive{} Recipe.AllLive{}:True{}
    case Recipe.Changed{l} Recipe.Changed{r}:Schema.same_route(l,r)
    case Recipe.With{l} Recipe.With{r}:Schema.same_route(l,r)
    case Recipe.Without{l} Recipe.Without{r}:Schema.same_route(l,r)
    case Recipe.And{ll,lr} Recipe.And{rl,rr}:Bool.and(same_bound(ll,rl),same_bound(lr,rr))
    case Recipe.Or{ll,lr} Recipe.Or{rl,rr}:Bool.and(same_bound(ll,rl),same_bound(lr,rr))
    case _ _:False{}
def same_entry(left:Recipe.Entry,right:Recipe.Entry) -> Bool:
  match left right:
    case Recipe.Entry{lr,lk,lb,lp} Recipe.Entry{rr,rk,rb,rp}:Bool.and(Schema.same_route(lr,rr),Bool.and(same_kind(lk,rk),Bool.and(same_bound(lb,rb),same_presence(lp,rp))))
def grant_selected(~S:Data,handles:List<&2,W.Handle<S>>,next:Maybe<&2,List<&2,W.Handle<S>>>,selected:Bool) -> Maybe<&2,List<&2,W.Handle<S>>>:
  match selected:
    case False{}:next
    case True{}:Some{handles}
def grant_handles(~S:Data,~WC:Type,+entry:Recipe.Entry,grants:List<&2,Granted<S,WC>>) -> Maybe<&2,List<&2,W.Handle<S>>>:
  match grants:
    case []:None{}
    case Granted{at,handles} <> rest:grant_selected(~S,handles,grant_handles(~S,~WC,entry,rest),same_entry(entry,at))
