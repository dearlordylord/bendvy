import Base
import ../../../../../src/ecs/world.bend as W

# Trusted closed declarations; runtime H is consumed and returned, never copied.
# This composition kernel grants no Frame, family, lifecycle, write or command.
type Selection<-H:Type,-S:Data,-V:Data> is Type:
  Selection{matches:H -> W.Handle<S> -> H & Bool,project:H -> W.Handle<S> -> H & V}
type Product<A:Data,B:Data> is Data:
  Product{left:A,right:B}
type Predicate<-H:Type,-S:Data> is Type:
  Predicate{matches:H -> W.Handle<S> -> H & Bool}
def predicate_field(~H:Type,~S:Data,value:Predicate<H,S>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case Predicate{matches}:matches
def matches_field(~H:Type,~S:Data,~V:Data,value:Selection<H,S,V>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case Selection{matches,_}:matches
def project_field(~H:Type,~S:Data,~V:Data,value:Selection<H,S,V>) -> H -> W.Handle<S> -> H & V:
  match value:
    case Selection{_,project}:project
def yes(~H:Type,~S:Data,owner:H,target:W.Handle<S>) -> H & Bool:
  (owner,True{})
def empty_value(~H:Type,~S:Data,owner:H,target:W.Handle<S>) -> H & Unit:
  (owner,Unit{})
def empty(~H:Type,~S:Data) -> Selection<H,S,Unit>:
  Selection{yes(~H,~S),empty_value(~H,~S)}
def matched_right(~H:Type,~S:Data,~B:Data,~right:Selection<H,S,B>,target:W.Handle<S>,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):matches_field(~H,~S,~B,right)(owner,target)
def pair_matches_target(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>,owner:H,+target:W.Handle<S>) -> H & Bool:
  matched_right(~H,~S,~B,~right,target,matches_field(~H,~S,~A,left)(owner,target))
def pair_matches(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>,owner:H,target:W.Handle<S>) -> H & Bool:
  pair_matches_target(~H,~S,~A,~B,~left,~right,owner,target)
def projected_right(~H:Type,~A:Data,~B:Data,left:A,observed:H & B) -> H & Product<A,B>:
  (owner,right)=observed
  (owner,Product{left,right})
def projected_left(~H:Type,~S:Data,~A:Data,~B:Data,~right:Selection<H,S,B>,target:W.Handle<S>,observed:H & A) -> H & Product<A,B>:
  (owner,left)=observed
  projected_right(~H,~A,~B,left,project_field(~H,~S,~B,right)(owner,target))
def pair_project_target(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>,owner:H,+target:W.Handle<S>) -> H & Product<A,B>:
  projected_left(~H,~S,~A,~B,~right,target,project_field(~H,~S,~A,left)(owner,target))
def pair_project(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>,owner:H,target:W.Handle<S>) -> H & Product<A,B>:
  pair_project_target(~H,~S,~A,~B,~left,~right,owner,target)
def pair(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>) -> Selection<H,S,Product<A,B>>:
  Selection{pair_matches(~H,~S,~A,~B,~left,~right),pair_project(~H,~S,~A,~B,~left,~right)}
def true_predicate(~H:Type,~S:Data) -> Predicate<H,S>:
  Predicate{yes(~H,~S)}
def predicate_right(~H:Type,~S:Data,~right:Predicate<H,S>,target:W.Handle<S>,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):predicate_field(~H,~S,right)(owner,target)
def predicate_both_target(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>,owner:H,+target:W.Handle<S>) -> H & Bool:
  predicate_right(~H,~S,~right,target,predicate_field(~H,~S,left)(owner,target))
def predicate_both(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>,owner:H,target:W.Handle<S>) -> H & Bool:
  predicate_both_target(~H,~S,~left,~right,owner,target)
def both(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>) -> Predicate<H,S>:
  Predicate{predicate_both(~H,~S,~left,~right)}
def constrained_target(~H:Type,~S:Data,~V:Data,~source:Selection<H,S,V>,~predicate:Predicate<H,S>,owner:H,+target:W.Handle<S>) -> H & Bool:
  predicate_right(~H,~S,~predicate,target,matches_field(~H,~S,~V,source)(owner,target))
def constrained(~H:Type,~S:Data,~V:Data,~source:Selection<H,S,V>,~predicate:Predicate<H,S>,owner:H,target:W.Handle<S>) -> H & Bool:
  constrained_target(~H,~S,~V,~source,~predicate,owner,target)
def constrain(~H:Type,~S:Data,~V:Data,~source:Selection<H,S,V>,~predicate:Predicate<H,S>) -> Selection<H,S,V>:
  Selection{constrained(~H,~S,~V,~source,~predicate),project_field(~H,~S,~V,source)}
def mapped(~H:Type,~A:Data,~B:Data,~name:A -> B,observed:H & A) -> H & B:
  (owner,value)=observed
  (owner,name(value))
def map_project(~H:Type,~S:Data,~A:Data,~B:Data,~source:Selection<H,S,A>,~name:A -> B,owner:H,target:W.Handle<S>) -> H & B:
  mapped(~H,~A,~B,~name,project_field(~H,~S,~A,source)(owner,target))
def map(~H:Type,~S:Data,~A:Data,~B:Data,~source:Selection<H,S,A>,~name:A -> B) -> Selection<H,S,B>:
  Selection{matches_field(~H,~S,~A,source),map_project(~H,~S,~A,~B,~source,~name)}

# Feasibility boundary only: no unchecked enumeration/lookup acceptance claim.
type Read<-H:Type,-S:Data,-V:Data> is Type:
  Read{project:H -> W.Handle<S> -> H & V}
def read_field(~H:Type,~S:Data,~V:Data,value:Read<H,S,V>) -> H -> W.Handle<S> -> H & V:
  match value:
    case Read{project}:project
def read(~H:Type,~S:Data,~V:Data,~cap:Read<H,S,V>,owner:H,target:W.Handle<S>) -> H & V:
  read_field(~H,~S,~V,cap)(owner,target)
def internal_projection_grant(~H:Type,~S:Data,~V:Data,~selection:Selection<H,S,V>) -> Read<H,S,V>:
  Read{project_field(~H,~S,~V,selection)}
def invoke(~H:Type,~S:Data,~V:Data,~selection:Selection<H,S,V>,~body:@-Owner:Type -> @-cap:Read<Owner,S,V> -> W.Handle<S> -> Owner -> Owner & V,target:W.Handle<S>,owner:H) -> H & V:
  body(H,internal_projection_grant(~H,~S,~V,~selection),target,owner)
