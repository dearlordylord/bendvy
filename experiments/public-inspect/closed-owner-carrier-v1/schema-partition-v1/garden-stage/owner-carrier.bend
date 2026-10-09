import Base
import query.bend as Q
import selection.bend as D
import schema-families.bend as Families
import runtime-owners.bend as Owners
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/check.bend as K
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector-query.bend as Errors

type InspectOwner<S:Data> is Type:
  InspectOwner{frame:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>}
def inspect_unpack(~S:Data,owner:InspectOwner<S>) -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>:
  match owner:
    case InspectOwner{frame}:frame
def inspect_packed(~S:Data,~V:Data,observed:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V) -> InspectOwner<S> & V:
  (frame,value)=observed
  (InspectOwner{frame},value)
def inspect_unpacked(~S:Data,~V:Data,observed:InspectOwner<S> & V) -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V:
  (owner,value)=observed
  (inspect_unpack(~S,owner),value)
def inspect_target(~S:Data,~V:Data,~operation:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> -> W.Handle<S> -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V,owner:InspectOwner<S>,target:W.Handle<S>) -> InspectOwner<S> & V:
  inspect_packed(~S,~V,operation(inspect_unpack(~S,owner),target))
def inspect_all(~S:Data,~V:Data,~operation:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V,owner:InspectOwner<S>) -> InspectOwner<S> & V:
  inspect_packed(~S,~V,operation(inspect_unpack(~S,owner)))
def inspect_selection(~S:Data,~V:Data,~selection:D.Selection<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>) -> D.Selection<InspectOwner<S>,S,V>:
  D.Selection{inspect_target(~S,~Bool,~D.matches_field(~I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,~V,selection)),inspect_target(~S,~V,~D.project_field(~I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,~V,selection))}
def inspect_world(~S:Data,~world:Q.WorldRead<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S>) -> Q.WorldRead<InspectOwner<S>,S>:
  Q.WorldRead{inspect_all(~S,~List<&2,W.Handle<S>>,~Q.handles_field(~I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,world)),inspect_target(~S,~Bool,~Q.valid_field(~I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,world))}
def inspect_each(~S:Data,~V:Data,~cap:Q.ReadQuery<InspectOwner<S>,S,V>,frame:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>) -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & List<&2,Q.Row<S,V>>:
  inspect_unpacked(~S,~List<&2,Q.Row<S,V>>,Q.each(~InspectOwner<S>,~S,~V,~cap,InspectOwner{frame}))
def inspect_get(~S:Data,~V:Data,~cap:Q.ReadQuery<InspectOwner<S>,S,V>,frame:I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,target:W.Handle<S>) -> I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>:
  inspect_unpacked(~S,~Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,Q.get(~InspectOwner<S>,~S,~V,~cap,InspectOwner{frame},target))
def inspect_granted(~S:Data,~V:Data,~cap:Q.ReadQuery<InspectOwner<S>,S,V>) -> Q.ReadQuery<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>:
  Q.ReadQuery{inspect_each(~S,~V,~cap),inspect_get(~S,~V,~cap)}
def inspect_grant(~S:Data,~V:Data,~selection:D.Selection<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>,~world:Q.WorldRead<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S>) -> Q.ReadQuery<I.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>:
  inspect_granted(~S,~V,~Q.grant(~InspectOwner<S>,~S,~V,~inspect_selection(~S,~V,~selection),~inspect_world(~S,~world)))

type CheckOwner<S:Data> is Type:
  CheckOwner{frame:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>}
def check_unpack(~S:Data,owner:CheckOwner<S>) -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>:
  match owner:
    case CheckOwner{frame}:frame
def check_packed(~S:Data,~V:Data,observed:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V) -> CheckOwner<S> & V:
  (frame,value)=observed
  (CheckOwner{frame},value)
def check_unpacked(~S:Data,~V:Data,observed:CheckOwner<S> & V) -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V:
  (owner,value)=observed
  (check_unpack(~S,owner),value)
def check_target(~S:Data,~V:Data,~operation:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> -> W.Handle<S> -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V,owner:CheckOwner<S>,target:W.Handle<S>) -> CheckOwner<S> & V:
  check_packed(~S,~V,operation(check_unpack(~S,owner),target))
def check_all(~S:Data,~V:Data,~operation:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & V,owner:CheckOwner<S>) -> CheckOwner<S> & V:
  check_packed(~S,~V,operation(check_unpack(~S,owner)))
def check_selection(~S:Data,~V:Data,~selection:D.Selection<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>) -> D.Selection<CheckOwner<S>,S,V>:
  D.Selection{check_target(~S,~Bool,~D.matches_field(~K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,~V,selection)),check_target(~S,~V,~D.project_field(~K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,~V,selection))}
def check_world(~S:Data,~world:Q.WorldRead<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S>) -> Q.WorldRead<CheckOwner<S>,S>:
  Q.WorldRead{check_all(~S,~List<&2,W.Handle<S>>,~Q.handles_field(~K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,world)),check_target(~S,~Bool,~Q.valid_field(~K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,~S,world))}
def check_each(~S:Data,~V:Data,~cap:Q.ReadQuery<CheckOwner<S>,S,V>,frame:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>) -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & List<&2,Q.Row<S,V>>:
  check_unpacked(~S,~List<&2,Q.Row<S,V>>,Q.each(~CheckOwner<S>,~S,~V,~cap,CheckOwner{frame}))
def check_get(~S:Data,~V:Data,~cap:Q.ReadQuery<CheckOwner<S>,S,V>,frame:K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,target:W.Handle<S>) -> K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32> & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>:
  check_unpacked(~S,~Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,Q.get(~CheckOwner<S>,~S,~V,~cap,CheckOwner{frame},target))
def check_granted(~S:Data,~V:Data,~cap:Q.ReadQuery<CheckOwner<S>,S,V>) -> Q.ReadQuery<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>:
  Q.ReadQuery{check_each(~S,~V,~cap),check_get(~S,~V,~cap)}
def check_grant(~S:Data,~V:Data,~selection:D.Selection<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>,~world:Q.WorldRead<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S>) -> Q.ReadQuery<K.Frame<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>:
  check_granted(~S,~V,~Q.grant(~CheckOwner<S>,~S,~V,~check_selection(~S,~V,~selection),~check_world(~S,~world)))
