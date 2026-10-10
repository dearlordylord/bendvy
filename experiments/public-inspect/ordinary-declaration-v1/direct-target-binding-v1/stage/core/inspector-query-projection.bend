import Base
import inspector.bend as I
import world.bend as W
import component.bend as C
import column.bend as Col
import capabilities.bend as Cap

type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,value:I.Value<V>}
type Selection is Data:
  Required{}
  Optional{}
  Added{}
  Changed{}

def present(~V:Data,value:C.Access<V>) -> Bool:
  match value:
    case C.Found{_}:True{}
    case _:False{}
def accepts(~V:Data,selection:Selection,value:I.Value<V>) -> Bool:
  match selection value:
    case Optional{} _:True{}
    case Required{} I.Value{access,_,_}:present(~V,access)
    case Added{} I.Value{access,added,_}:Bool.and(present(~V,access),added)
    case Changed{} I.Value{access,_,changed}:Bool.and(present(~V,access),changed)
def included(~S:Data,~V:Data,include:Bool,row:Row<S,V>,rows:List<&2,Row<S,V>>) -> List<&2,Row<S,V>>:
  match include:
    case True{}:row <> rows
    case False{}:rows

def read_row(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:Selection,target:W.Handle<S>,rows:List<&2,Row<S,V>>,continue:I.Frame<S,Store,R,E> -> List<&2,Row<S,V>> -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>,observed:I.Frame<S,Store,R,E> & I.Value<V>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  (frame,+value)=observed
  continue(frame,included(~S,~V,accepts(~V,selection,value),Row{target,value},rows))

def read_rows(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,handles:List<&2,W.Handle<S>>,frame:I.Frame<S,Store,R,E>,rows:List<&2,Row<S,V>>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match handles:
    case []:(frame,List.reverse(&2,Row<S,V>,rows))
    case +target <> rest:read_row(~S,~Store,~R,~E,~V,~selection,target,rows,(frame => rows => read_rows(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,rest,frame,rows)),I.family_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame,target))

def scanned(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,cursor:U32,observed:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  (world,handles)=observed
  read_rows(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,handles,I.Frame{world,cursor},[])
def scan(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & List<&2,Row<S,V>>:
  match frame:
    case I.Frame{world,cursor}:scanned(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,cursor,W.handles(~S,~Store,~R,~E,world))
def read_query(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,~selection:Selection) -> Cap.ValueRead<I.Frame<S,Store,R,E>,List<&2,Row<S,V>>>:
  Cap.ValueRead{frame => scan(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~selection,frame)}

# Trusted closed declarations; runtime H is consumed and returned, never copied.
# This composition kernel grants no Frame, family, lifecycle, write or command.
type DeclaredSelection<-H:Type,-S:Data,-V:Data> is Type:
  DeclaredSelection{matches:H -> W.Handle<S> -> H & Bool,project:H -> W.Handle<S> -> H & V}
type Product<A:Data,B:Data> is Data:
  Product{left:A,right:B}
type Predicate<-H:Type,-S:Data> is Type:
  Predicate{matches:H -> W.Handle<S> -> H & Bool}
def predicate_field(~H:Type,~S:Data,value:Predicate<H,S>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case Predicate{matches}:matches
def matches_field(~H:Type,~S:Data,~V:Data,value:DeclaredSelection<H,S,V>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case DeclaredSelection{matches,_}:matches
def project_field(~H:Type,~S:Data,~V:Data,value:DeclaredSelection<H,S,V>) -> H -> W.Handle<S> -> H & V:
  match value:
    case DeclaredSelection{_,project}:project
def yes(~H:Type,~S:Data,owner:H,target:W.Handle<S>) -> H & Bool:
  (owner,True{})
def empty_value(~H:Type,~S:Data,owner:H,target:W.Handle<S>) -> H & Unit:
  (owner,Unit{})
def empty(~H:Type,~S:Data) -> DeclaredSelection<H,S,Unit>:
  DeclaredSelection{yes(~H,~S),empty_value(~H,~S)}
# Private recursive runtime matching representation; public declaration shape unchanged.
type MatchTree<-H:Type,-S:Data> is Type:
  MatchLeaf{operation:H -> W.Handle<S> -> H & Bool}
  MatchBoth{left:MatchTree<H,S>,right:MatchTree<H,S>}
def tree_matched(~H:Type,continue:H -> H & Bool,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):continue(owner)
def tree_matches(~H:Type,~S:Data,tree:MatchTree<H,S>,owner:H,+target:W.Handle<S>) -> H & Bool:
  match tree:
    case MatchLeaf{operation}:operation(owner,target)
    case MatchBoth{left,right}:tree_matched(~H,(next => tree_matches(~H,~S,right,next,target)),tree_matches(~H,~S,left,owner,target))
def matched_right(~H:Type,~S:Data,~B:Data,~right:DeclaredSelection<H,S,B>,target:W.Handle<S>,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):matches_field(~H,~S,~B,right)(owner,target)
def pair_matches_target(~H:Type,~S:Data,~A:Data,~B:Data,~left:DeclaredSelection<H,S,A>,~right:DeclaredSelection<H,S,B>,owner:H,+target:W.Handle<S>) -> H & Bool:
  tree_matches(~H,~S,MatchBoth{MatchLeaf{matches_field(~H,~S,~A,left)},MatchLeaf{matches_field(~H,~S,~B,right)}},owner,target)
def pair_matches(~H:Type,~S:Data,~A:Data,~B:Data,~left:DeclaredSelection<H,S,A>,~right:DeclaredSelection<H,S,B>,owner:H,target:W.Handle<S>) -> H & Bool:
  pair_matches_target(~H,~S,~A,~B,~left,~right,owner,target)
def projected_right(~H:Type,~A:Data,~B:Data,left:A,observed:H & B) -> H & Product<A,B>:
  (owner,right)=observed
  (owner,Product{left,right})
def projected_left(~H:Type,~S:Data,~A:Data,~B:Data,right:H -> W.Handle<S> -> H & B,target:W.Handle<S>,observed:H & A) -> H & Product<A,B>:
  (owner,left)=observed
  projected_right(~H,~A,~B,left,right(owner,target))
def pair_project_target(~H:Type,~S:Data,~A:Data,~B:Data,~left:DeclaredSelection<H,S,A>,~right:DeclaredSelection<H,S,B>,owner:H,+target:W.Handle<S>) -> H & Product<A,B>:
  projected_left(~H,~S,~A,~B,project_field(~H,~S,~B,right),target,project_field(~H,~S,~A,left)(owner,target))
def pair_project(~H:Type,~S:Data,~A:Data,~B:Data,~left:DeclaredSelection<H,S,A>,~right:DeclaredSelection<H,S,B>,owner:H,target:W.Handle<S>) -> H & Product<A,B>:
  pair_project_target(~H,~S,~A,~B,~left,~right,owner,target)
def pair(~H:Type,~S:Data,~A:Data,~B:Data,~left:DeclaredSelection<H,S,A>,~right:DeclaredSelection<H,S,B>) -> DeclaredSelection<H,S,Product<A,B>>:
  DeclaredSelection{owner => target => pair_matches_target(~H,~S,~A,~B,~left,~right,owner,target),owner => target => pair_project_target(~H,~S,~A,~B,~left,~right,owner,target)}
def true_predicate(~H:Type,~S:Data) -> Predicate<H,S>:
  Predicate{yes(~H,~S)}
def predicate_right(~H:Type,~S:Data,~right:Predicate<H,S>,target:W.Handle<S>,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):predicate_field(~H,~S,right)(owner,target)
def predicate_both_target(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>,owner:H,+target:W.Handle<S>) -> H & Bool:
  tree_matches(~H,~S,MatchBoth{MatchLeaf{predicate_field(~H,~S,left)},MatchLeaf{predicate_field(~H,~S,right)}},owner,target)
def predicate_both(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>,owner:H,target:W.Handle<S>) -> H & Bool:
  predicate_both_target(~H,~S,~left,~right,owner,target)
def both(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>) -> Predicate<H,S>:
  Predicate{predicate_both(~H,~S,~left,~right)}
def constrained_target(~H:Type,~S:Data,~V:Data,~source:DeclaredSelection<H,S,V>,~predicate:Predicate<H,S>,owner:H,+target:W.Handle<S>) -> H & Bool:
  tree_matches(~H,~S,MatchBoth{MatchLeaf{matches_field(~H,~S,~V,source)},MatchLeaf{predicate_field(~H,~S,predicate)}},owner,target)
def constrained(~H:Type,~S:Data,~V:Data,~source:DeclaredSelection<H,S,V>,~predicate:Predicate<H,S>,owner:H,target:W.Handle<S>) -> H & Bool:
  constrained_target(~H,~S,~V,~source,~predicate,owner,target)
def constrain(~H:Type,~S:Data,~V:Data,~source:DeclaredSelection<H,S,V>,~predicate:Predicate<H,S>) -> DeclaredSelection<H,S,V>:
  DeclaredSelection{constrained(~H,~S,~V,~source,~predicate),project_field(~H,~S,~V,source)}
def mapped(~H:Type,~A:Data,~B:Data,~name:A -> B,observed:H & A) -> H & B:
  (owner,value)=observed
  (owner,name(value))
def map_project(~H:Type,~S:Data,~A:Data,~B:Data,~source:DeclaredSelection<H,S,A>,~name:A -> B,owner:H,target:W.Handle<S>) -> H & B:
  mapped(~H,~A,~B,~name,project_field(~H,~S,~A,source)(owner,target))
def map(~H:Type,~S:Data,~A:Data,~B:Data,~source:DeclaredSelection<H,S,A>,~name:A -> B) -> DeclaredSelection<H,S,B>:
  DeclaredSelection{matches_field(~H,~S,~A,source),map_project(~H,~S,~A,~B,~source,~name)}
