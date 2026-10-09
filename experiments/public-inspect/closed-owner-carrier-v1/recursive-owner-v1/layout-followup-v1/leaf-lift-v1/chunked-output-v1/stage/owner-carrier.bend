import Base
import query.bend as Q
import selection.bend as D
import schema-families.bend as Families
import runtime-owners.bend as Owners
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/check.bend as K
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector-query.bend as Errors

type InspectOwner<S:Data,R:Type> is Type:
  InspectOwner{frame:I.Frame<S,Families.Store<S>,R,U32>}
  InspectOwnerLink{next:InspectOwner<S,R>}
def inspect_unpack(~S:Data,~R:Type,owner:InspectOwner<S,R>) -> I.Frame<S,Families.Store<S>,R,U32>:
  match owner:
    case InspectOwner{frame}:frame
    case InspectOwnerLink{next}:inspect_unpack(~S,~R,next)
def inspect_packed(~S:Data,~R:Type,~V:Data,observed:I.Frame<S,Families.Store<S>,R,U32> & V) -> InspectOwner<S,R> & V:
  (frame,value)=observed
  (InspectOwner{frame},value)
def inspect_unpacked(~S:Data,~R:Type,~V:Data,observed:InspectOwner<S,R> & V) -> I.Frame<S,Families.Store<S>,R,U32> & V:
  (owner,value)=observed
  (inspect_unpack(~S,~R,owner),value)
def inspect_target(~S:Data,~R:Type,~V:Data,~operation:I.Frame<S,Families.Store<S>,R,U32> -> W.Handle<S> -> I.Frame<S,Families.Store<S>,R,U32> & V,owner:InspectOwner<S,R>,target:W.Handle<S>) -> InspectOwner<S,R> & V:
  inspect_packed(~S,~R,~V,operation(inspect_unpack(~S,~R,owner),target))
def inspect_predicate(~S:Data,~R:Type,~predicate:D.Predicate<I.Frame<S,Families.Store<S>,R,U32>,S>) -> D.Predicate<InspectOwner<S,R>,S>:
  D.Predicate{inspect_target(~S,~R,~Bool,~D.predicate_field(~I.Frame<S,Families.Store<S>,R,U32>,~S,predicate))}
def inspect_all(~S:Data,~R:Type,~V:Data,~operation:I.Frame<S,Families.Store<S>,R,U32> -> I.Frame<S,Families.Store<S>,R,U32> & V,owner:InspectOwner<S,R>) -> InspectOwner<S,R> & V:
  inspect_packed(~S,~R,~V,operation(inspect_unpack(~S,~R,owner)))
def inspect_selection(~S:Data,~R:Type,~V:Data,~selection:D.Selection<I.Frame<S,Families.Store<S>,R,U32>,S,V>) -> D.Selection<InspectOwner<S,R>,S,V>:
  D.Selection{inspect_target(~S,~R,~Bool,~D.matches_field(~I.Frame<S,Families.Store<S>,R,U32>,~S,~V,selection)),inspect_target(~S,~R,~V,~D.project_field(~I.Frame<S,Families.Store<S>,R,U32>,~S,~V,selection))}
def inspect_world(~S:Data,~R:Type,~world:Q.WorldRead<I.Frame<S,Families.Store<S>,R,U32>,S>) -> Q.WorldRead<InspectOwner<S,R>,S>:
  Q.WorldRead{inspect_all(~S,~R,~List<&2,W.Handle<S>>,~Q.handles_field(~I.Frame<S,Families.Store<S>,R,U32>,~S,world)),inspect_target(~S,~R,~Bool,~Q.valid_field(~I.Frame<S,Families.Store<S>,R,U32>,~S,world))}
def inspect_each(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<InspectOwner<S,R>,S,V>,frame:I.Frame<S,Families.Store<S>,R,U32>) -> I.Frame<S,Families.Store<S>,R,U32> & List<&2,Q.Row<S,V>>:
  inspect_unpacked(~S,~R,~List<&2,Q.Row<S,V>>,Q.each(~InspectOwner<S,R>,~S,~V,~cap,InspectOwner{frame}))
def inspect_get(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<InspectOwner<S,R>,S,V>,frame:I.Frame<S,Families.Store<S>,R,U32>,target:W.Handle<S>) -> I.Frame<S,Families.Store<S>,R,U32> & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>:
  inspect_unpacked(~S,~R,~Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,Q.get(~InspectOwner<S,R>,~S,~V,~cap,InspectOwner{frame},target))
def inspect_granted(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<InspectOwner<S,R>,S,V>) -> Q.ReadQuery<I.Frame<S,Families.Store<S>,R,U32>,S,V>:
  Q.ReadQuery{inspect_each(~S,~R,~V,~cap),inspect_get(~S,~R,~V,~cap)}
def inspect_grant(~S:Data,~R:Type,~V:Data,~selection:D.Selection<InspectOwner<S,R>,S,V>,~world:Q.WorldRead<I.Frame<S,Families.Store<S>,R,U32>,S>) -> Q.ReadQuery<I.Frame<S,Families.Store<S>,R,U32>,S,V>:
  inspect_granted(~S,~R,~V,~Q.grant(~InspectOwner<S,R>,~S,~V,~selection,~inspect_world(~S,~R,~world)))

type CheckOwner<S:Data,R:Type> is Type:
  CheckOwner{frame:K.Frame<S,Families.Store<S>,R,U32>}
  CheckOwnerLink{next:CheckOwner<S,R>}
def check_unpack(~S:Data,~R:Type,owner:CheckOwner<S,R>) -> K.Frame<S,Families.Store<S>,R,U32>:
  match owner:
    case CheckOwner{frame}:frame
    case CheckOwnerLink{next}:check_unpack(~S,~R,next)
def check_packed(~S:Data,~R:Type,~V:Data,observed:K.Frame<S,Families.Store<S>,R,U32> & V) -> CheckOwner<S,R> & V:
  (frame,value)=observed
  (CheckOwner{frame},value)
def check_unpacked(~S:Data,~R:Type,~V:Data,observed:CheckOwner<S,R> & V) -> K.Frame<S,Families.Store<S>,R,U32> & V:
  (owner,value)=observed
  (check_unpack(~S,~R,owner),value)
def check_target(~S:Data,~R:Type,~V:Data,~operation:K.Frame<S,Families.Store<S>,R,U32> -> W.Handle<S> -> K.Frame<S,Families.Store<S>,R,U32> & V,owner:CheckOwner<S,R>,target:W.Handle<S>) -> CheckOwner<S,R> & V:
  check_packed(~S,~R,~V,operation(check_unpack(~S,~R,owner),target))
def check_predicate(~S:Data,~R:Type,~predicate:D.Predicate<K.Frame<S,Families.Store<S>,R,U32>,S>) -> D.Predicate<CheckOwner<S,R>,S>:
  D.Predicate{check_target(~S,~R,~Bool,~D.predicate_field(~K.Frame<S,Families.Store<S>,R,U32>,~S,predicate))}
def check_all(~S:Data,~R:Type,~V:Data,~operation:K.Frame<S,Families.Store<S>,R,U32> -> K.Frame<S,Families.Store<S>,R,U32> & V,owner:CheckOwner<S,R>) -> CheckOwner<S,R> & V:
  check_packed(~S,~R,~V,operation(check_unpack(~S,~R,owner)))
def check_selection(~S:Data,~R:Type,~V:Data,~selection:D.Selection<K.Frame<S,Families.Store<S>,R,U32>,S,V>) -> D.Selection<CheckOwner<S,R>,S,V>:
  D.Selection{check_target(~S,~R,~Bool,~D.matches_field(~K.Frame<S,Families.Store<S>,R,U32>,~S,~V,selection)),check_target(~S,~R,~V,~D.project_field(~K.Frame<S,Families.Store<S>,R,U32>,~S,~V,selection))}
def check_world(~S:Data,~R:Type,~world:Q.WorldRead<K.Frame<S,Families.Store<S>,R,U32>,S>) -> Q.WorldRead<CheckOwner<S,R>,S>:
  Q.WorldRead{check_all(~S,~R,~List<&2,W.Handle<S>>,~Q.handles_field(~K.Frame<S,Families.Store<S>,R,U32>,~S,world)),check_target(~S,~R,~Bool,~Q.valid_field(~K.Frame<S,Families.Store<S>,R,U32>,~S,world))}
def check_each(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<CheckOwner<S,R>,S,V>,frame:K.Frame<S,Families.Store<S>,R,U32>) -> K.Frame<S,Families.Store<S>,R,U32> & List<&2,Q.Row<S,V>>:
  check_unpacked(~S,~R,~List<&2,Q.Row<S,V>>,Q.each(~CheckOwner<S,R>,~S,~V,~cap,CheckOwner{frame}))
def check_get(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<CheckOwner<S,R>,S,V>,frame:K.Frame<S,Families.Store<S>,R,U32>,target:W.Handle<S>) -> K.Frame<S,Families.Store<S>,R,U32> & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>:
  check_unpacked(~S,~R,~Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,Q.get(~CheckOwner<S,R>,~S,~V,~cap,CheckOwner{frame},target))
def check_granted(~S:Data,~R:Type,~V:Data,~cap:Q.ReadQuery<CheckOwner<S,R>,S,V>) -> Q.ReadQuery<K.Frame<S,Families.Store<S>,R,U32>,S,V>:
  Q.ReadQuery{check_each(~S,~R,~V,~cap),check_get(~S,~R,~V,~cap)}
def check_grant(~S:Data,~R:Type,~V:Data,~selection:D.Selection<CheckOwner<S,R>,S,V>,~world:Q.WorldRead<K.Frame<S,Families.Store<S>,R,U32>,S>) -> Q.ReadQuery<K.Frame<S,Families.Store<S>,R,U32>,S,V>:
  check_granted(~S,~R,~V,~Q.grant(~CheckOwner<S,R>,~S,~V,~selection,~check_world(~S,~R,~world)))
