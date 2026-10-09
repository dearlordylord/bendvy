import Base
import ../../../../../src/ecs/inspector-query.bend as Q
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/check.bend as K
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/inspector-query.bend as Errors

type InspectOwner<S:Data,Store:Type,R:Type,E:Data> is Type:
  InspectOwner{frame:I.Frame<S,Store,R,E>}
  InspectOwnerLink{next:InspectOwner<S,Store,R,E>}
def inspect_unpack(~S:Data,~Store:Type,~R:Type,~E:Data,owner:InspectOwner<S,Store,R,E>) -> I.Frame<S,Store,R,E>:
  match owner:
    case InspectOwner{frame}:frame
    case InspectOwnerLink{next}:inspect_unpack(~S,~Store,~R,~E,next)
def inspect_packed(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:I.Frame<S,Store,R,E> & V) -> InspectOwner<S,Store,R,E> & V:
  (frame,value)=observed
  (InspectOwner{frame},value)
def inspect_unpacked(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:InspectOwner<S,Store,R,E> & V) -> I.Frame<S,Store,R,E> & V:
  (owner,value)=observed
  (inspect_unpack(~S,~Store,~R,~E,owner),value)
def inspect_target(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~operation:I.Frame<S,Store,R,E> -> W.Handle<S> -> I.Frame<S,Store,R,E> & V,owner:InspectOwner<S,Store,R,E>,target:W.Handle<S>) -> InspectOwner<S,Store,R,E> & V:
  inspect_packed(~S,~Store,~R,~E,~V,operation(inspect_unpack(~S,~Store,~R,~E,owner),target))
def inspect_predicate(~S:Data,~Store:Type,~R:Type,~E:Data,~predicate:D.Predicate<I.Frame<S,Store,R,E>,S>) -> D.Predicate<InspectOwner<S,Store,R,E>,S>:
  D.Predicate{inspect_target(~S,~Store,~R,~E,~Bool,~D.predicate_field(~I.Frame<S,Store,R,E>,~S,predicate))}
def inspect_all(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~operation:I.Frame<S,Store,R,E> -> I.Frame<S,Store,R,E> & V,owner:InspectOwner<S,Store,R,E>) -> InspectOwner<S,Store,R,E> & V:
  inspect_packed(~S,~Store,~R,~E,~V,operation(inspect_unpack(~S,~Store,~R,~E,owner)))
def inspect_selection(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:D.DeclaredSelection<I.Frame<S,Store,R,E>,S,V>) -> D.DeclaredSelection<InspectOwner<S,Store,R,E>,S,V>:
  D.DeclaredSelection{inspect_target(~S,~Store,~R,~E,~Bool,~D.matches_field(~I.Frame<S,Store,R,E>,~S,~V,selection)),inspect_target(~S,~Store,~R,~E,~V,~D.project_field(~I.Frame<S,Store,R,E>,~S,~V,selection))}
def inspect_world(~S:Data,~Store:Type,~R:Type,~E:Data,~world:Q.WorldRead<I.Frame<S,Store,R,E>,S>) -> Q.WorldRead<InspectOwner<S,Store,R,E>,S>:
  Q.WorldRead{inspect_all(~S,~Store,~R,~E,~List<&2,W.Handle<S>>,~Q.composed_handles_field(~I.Frame<S,Store,R,E>,~S,world)),inspect_target(~S,~Store,~R,~E,~Bool,~Q.composed_valid_field(~I.Frame<S,Store,R,E>,~S,world))}
def inspect_each(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<InspectOwner<S,Store,R,E>,S,V>,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & List<&2,Q.ProjectedRow<S,V>>:
  inspect_unpacked(~S,~Store,~R,~E,~List<&2,Q.ProjectedRow<S,V>>,Q.each_composed(~InspectOwner<S,Store,R,E>,~S,~V,~cap,InspectOwner{frame}))
def inspect_get(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<InspectOwner<S,Store,R,E>,S,V>,frame:I.Frame<S,Store,R,E>,target:W.Handle<S>) -> I.Frame<S,Store,R,E> & Result<&2,&2,Errors.LookupError,Q.ProjectedRow<S,V>>:
  inspect_unpacked(~S,~Store,~R,~E,~Result<&2,&2,Errors.LookupError,Q.ProjectedRow<S,V>>,Q.get_composed(~InspectOwner<S,Store,R,E>,~S,~V,~cap,InspectOwner{frame},target))
def inspect_granted(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<InspectOwner<S,Store,R,E>,S,V>) -> Q.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  Q.ComposedReadQuery{inspect_each(~S,~Store,~R,~E,~V,~cap),inspect_get(~S,~Store,~R,~E,~V,~cap)}
def inspect_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:D.DeclaredSelection<InspectOwner<S,Store,R,E>,S,V>,~world:Q.WorldRead<I.Frame<S,Store,R,E>,S>) -> Q.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  inspect_granted(~S,~Store,~R,~E,~V,~Q.grant_composed(~InspectOwner<S,Store,R,E>,~S,~V,~selection,~inspect_world(~S,~Store,~R,~E,~world)))

type CheckOwner<S:Data,Store:Type,R:Type,E:Data> is Type:
  CheckOwner{frame:K.Frame<S,Store,R,E>}
  CheckOwnerLink{next:CheckOwner<S,Store,R,E>}
def check_unpack(~S:Data,~Store:Type,~R:Type,~E:Data,owner:CheckOwner<S,Store,R,E>) -> K.Frame<S,Store,R,E>:
  match owner:
    case CheckOwner{frame}:frame
    case CheckOwnerLink{next}:check_unpack(~S,~Store,~R,~E,next)
def check_packed(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:K.Frame<S,Store,R,E> & V) -> CheckOwner<S,Store,R,E> & V:
  (frame,value)=observed
  (CheckOwner{frame},value)
def check_unpacked(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:CheckOwner<S,Store,R,E> & V) -> K.Frame<S,Store,R,E> & V:
  (owner,value)=observed
  (check_unpack(~S,~Store,~R,~E,owner),value)
def check_target(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~operation:K.Frame<S,Store,R,E> -> W.Handle<S> -> K.Frame<S,Store,R,E> & V,owner:CheckOwner<S,Store,R,E>,target:W.Handle<S>) -> CheckOwner<S,Store,R,E> & V:
  check_packed(~S,~Store,~R,~E,~V,operation(check_unpack(~S,~Store,~R,~E,owner),target))
def check_predicate(~S:Data,~Store:Type,~R:Type,~E:Data,~predicate:D.Predicate<K.Frame<S,Store,R,E>,S>) -> D.Predicate<CheckOwner<S,Store,R,E>,S>:
  D.Predicate{check_target(~S,~Store,~R,~E,~Bool,~D.predicate_field(~K.Frame<S,Store,R,E>,~S,predicate))}
def check_all(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~operation:K.Frame<S,Store,R,E> -> K.Frame<S,Store,R,E> & V,owner:CheckOwner<S,Store,R,E>) -> CheckOwner<S,Store,R,E> & V:
  check_packed(~S,~Store,~R,~E,~V,operation(check_unpack(~S,~Store,~R,~E,owner)))
def check_selection(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:D.DeclaredSelection<K.Frame<S,Store,R,E>,S,V>) -> D.DeclaredSelection<CheckOwner<S,Store,R,E>,S,V>:
  D.DeclaredSelection{check_target(~S,~Store,~R,~E,~Bool,~D.matches_field(~K.Frame<S,Store,R,E>,~S,~V,selection)),check_target(~S,~Store,~R,~E,~V,~D.project_field(~K.Frame<S,Store,R,E>,~S,~V,selection))}
def check_world(~S:Data,~Store:Type,~R:Type,~E:Data,~world:Q.WorldRead<K.Frame<S,Store,R,E>,S>) -> Q.WorldRead<CheckOwner<S,Store,R,E>,S>:
  Q.WorldRead{check_all(~S,~Store,~R,~E,~List<&2,W.Handle<S>>,~Q.composed_handles_field(~K.Frame<S,Store,R,E>,~S,world)),check_target(~S,~Store,~R,~E,~Bool,~Q.composed_valid_field(~K.Frame<S,Store,R,E>,~S,world))}
def check_each(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<CheckOwner<S,Store,R,E>,S,V>,frame:K.Frame<S,Store,R,E>) -> K.Frame<S,Store,R,E> & List<&2,Q.ProjectedRow<S,V>>:
  check_unpacked(~S,~Store,~R,~E,~List<&2,Q.ProjectedRow<S,V>>,Q.each_composed(~CheckOwner<S,Store,R,E>,~S,~V,~cap,CheckOwner{frame}))
def check_get(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<CheckOwner<S,Store,R,E>,S,V>,frame:K.Frame<S,Store,R,E>,target:W.Handle<S>) -> K.Frame<S,Store,R,E> & Result<&2,&2,Errors.LookupError,Q.ProjectedRow<S,V>>:
  check_unpacked(~S,~Store,~R,~E,~Result<&2,&2,Errors.LookupError,Q.ProjectedRow<S,V>>,Q.get_composed(~CheckOwner<S,Store,R,E>,~S,~V,~cap,CheckOwner{frame},target))
def check_granted(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~cap:Q.ComposedReadQuery<CheckOwner<S,Store,R,E>,S,V>) -> Q.ComposedReadQuery<K.Frame<S,Store,R,E>,S,V>:
  Q.ComposedReadQuery{check_each(~S,~Store,~R,~E,~V,~cap),check_get(~S,~Store,~R,~E,~V,~cap)}
def check_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:D.DeclaredSelection<CheckOwner<S,Store,R,E>,S,V>,~world:Q.WorldRead<K.Frame<S,Store,R,E>,S>) -> Q.ComposedReadQuery<K.Frame<S,Store,R,E>,S,V>:
  check_granted(~S,~Store,~R,~E,~V,~Q.grant_composed(~CheckOwner<S,Store,R,E>,~S,~V,~selection,~check_world(~S,~Store,~R,~E,~world)))
