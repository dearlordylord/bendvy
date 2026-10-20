import Base
import ./owner-product.bend as Product
import ./capabilities.bend as Cap
import ./owned-event-journal.bend as Frame
# Canonical event declarations compose heterogeneous payload grants with one
# ordered journal. Builder remains erased until the full recovery tree is known.
# Raw constructors/builders are trusted engine administration, not gameplay.
# Advanced erased builder for an owned-event publication grant family.
# Specializes the journal recovery path only after the complete heterogeneous
# recovery product is known. Gameplay receives abstract emission grants rather
# than constructing runtime journal paths or retaining raw payload aliases.
def Builder(~State:Type,~Recovery:Type,~Ops:Type -> Type) -> Type:
  @-All:Type -> @-Rest:Type -> @-path:Product.Lens<All,Recovery,Rest> -> Unit -> Ops(Frame.Stage<State,All>)
# Detached metadata listing owned event-domain names and whether it is opaque.
# Names describe provisioned publication uses; they do not grant access or prove
# that a hand-authored builder targets the named log. Canonical constructors
# supply this metadata together with their typed operational bindings.
type Description is Data:
  Description{events:List<&2,String>,opaque:Bool}
# Combine metadata left first, preserving duplicate names and propagating
# opacity from either side. This does not combine live logs or publish payloads.
def pair_description(left:Description,right:Description) -> Description:
  match left right:
    case Description{left,lo} Description{right,ro}:Description{List.append(&2,String,left,right),Bool.or(lo,ro)}
# Report whether the description is nonopaque. This is the automatic App
# metadata-admission test, not validation of arbitrary builders or runtime log
# existence. Use canonical declarations rather than asserting trusted metadata.
def complete(value:Description) -> Bool:
  match value:
    case Description{_,opaque}:Bool.not(opaque)
# Static publisher declaration carrying a recovery constructor and access names;
# State, Recovery, Ops and builder keep its operational route typed. Canonical
# ordinary-owned-event-family-write.declaration supplies the matching log/recovery
# paths. Payloads may be arbitrary affine Type values; this is not a Data-event
# stream reader and does not duplicate payloads for multiple readers.
# Legacy Declaration has opaque metadata. Described adds operational-domain
# metadata; automatic App publisher registration requires a complete description.
# Classic publisher registration remains available for the legacy form. Raw
# constructors/builders are trusted administration, not a gameplay permission API.
# See docs/parity/affine-events.md for ownership and qualified publication bounds.
type Declaration<-S:Data,-State:Type,-Recovery:Type,-Ops:Type -> Type,-builder:Builder(~State,~Recovery,~Ops)> is Type:
  Declaration{empty:Unit -> Recovery,access:List<&2,String>}
  Described{empty:Unit -> Recovery,access:List<&2,String>,description:Description}
# Consume a declaration and obtain its fresh recovery-owner constructor.
# It initializes the finish-time recovery accumulator; it does not copy payloads,
# publish an event, retire a log entry or execute cleanup.
def empty(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> Unit -> Recovery:
  match value:
    case Declaration{empty,_}:empty
    case Described{empty,_,_}:empty
# Consume a declaration and return its Registry access strings in stored order.
# These are metadata, not a reader cursor, payload owner or substitute for the
# builder's schema-bound publication grant.
def access(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> List<&2,String>:
  match value:
    case Declaration{_,access}:access
    case Described{_,access,_}:access
# Consume a declaration and obtain its detached event-use description.
# Legacy Declaration yields an opaque description; Described yields the supplied
# one. This operation does not read logs, advance readers or publish events.
def description(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> Description:
  match value:
    case Declaration{_,_}:Description{[],True{}}
    case Described{_,_,description}:description
# Operation-family alias for left/right emission grants on the same opaque
# journal stage. Its order matches the recovery product produced by both.
def PairOps(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:Cap.Bundle<L(H),R(H)>
def pair_empty(~L:Type,~R:Type,~left:Unit -> L,~right:Unit -> R,unit:Unit) -> Product.Owner<L,R>:Product.Owner{left(Unit{}),right(unit)}
def pair_grant(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~left:Builder(~State,~L,~LOps),~right:Builder(~State,~R,~ROps),~All:Type,~Rest:Type,~path:Product.Lens<All,Product.Owner<L,R>,Rest>,unit:Unit) -> Cap.Bundle<LOps(Frame.Stage<State,All>),ROps(Frame.Stage<State,All>)>:
  Cap.Bundle{left(All,Rest & R,Product.compose(~All,~Product.Owner<L,R>,~Rest,~L,~R,~path,~Product.lens(~L,~R,~Product.Left{})),Unit{}),right(All,Rest & L,Product.compose(~All,~Product.Owner<L,R>,~Rest,~R,~L,~path,~Product.lens(~L,~R,~Product.Right{})),unit)}
# Compose owned-event declarations for the same schema and staged State.
# The body receives Cap.Bundle{left, right}; recovery is the corresponding
# Product.Owner<LeftRecovery, RightRecovery>. Access/domain lists remain left
# first, with duplicates; opaque metadata on either side remains opaque.
# One shared staged journal preserves actual emission order across families,
# not declaration grouping. The publisher commits payload owners only on success;
# on abort it publishes none and returns staged owners through the typed recovery
# product, preserving each family's order. The declaration itself executes none
# of these actions. No owner restored by another required ECS rollback may also
# be returned as recovered event data, and no automatic IO finalizer is implied.
# Use ordinary-owned-event-family-write.declaration for each canonical leaf and
# ordinary-owned-event-family-publisher for execution. Reader projection,
# retention and retirement use their separate owned-event APIs.
def both(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~leftBuilder:Builder(~State,~L,~LOps),~rightBuilder:Builder(~State,~R,~ROps),~left:Declaration<S,State,L,LOps,leftBuilder>,~right:Declaration<S,State,R,ROps,rightBuilder>) -> Declaration<S,State,Product.Owner<L,R>,PairOps(~LOps,~ROps),pair_grant(~S,~State,~L,~R,~LOps,~ROps,~leftBuilder,~rightBuilder)>:
  Described{pair_empty(~L,~R,~empty(~S,~State,~L,~LOps,~leftBuilder,left),~empty(~S,~State,~R,~ROps,~rightBuilder,right)),List.append(&2,String,access(~S,~State,~L,~LOps,~leftBuilder,left),access(~S,~State,~R,~ROps,~rightBuilder,right)),pair_description(description(~S,~State,~L,~LOps,~leftBuilder,left),description(~S,~State,~R,~ROps,~rightBuilder,right))}
def identity_take(~R:Type,value:R) -> Unit & R:(Unit{},value)
def identity_put(~R:Type,unit:Unit,value:R) -> R:value
# Advanced builder lens selecting the complete recovery owner with Unit rest.
# It threads the owner rather than copying it; it does not publish or abort events.
def identity(~R:Type) -> Product.Lens<R,R,Unit>:Product.Lens{identity_take(~R),identity_put(~R)}
# Advanced publisher projection: instantiate builder at the full recovery owner
# and return its emission operations. The runner supplies the opaque journal
# stage; gameplay does not construct raw paths, expose stored owners or decide
# publication by invoking this projection outside the publisher protocol.
def root_grant(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops)) -> Ops(Frame.Stage<State,Recovery>):builder(Recovery,Unit,identity(~Recovery),Unit{})
