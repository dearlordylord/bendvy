import Base
import ./recovery-use.bend as Use
import ./owner-product.bend as Product
import ./capabilities.bend as Cap
import ./ordinary-recoverable-array-resource.bend as Frame
# Builder is an erased type index, like a Registry runner. It is specialized
# at the closed recovery product before any executable grant is materialized.
# Advanced erased grant-builder type for canonical recovery declarations.
# Specializes operations to the closed recovery product and an owner-preserving
# lens into that product. Ordinary bodies receive the generated Ops; they do not
# supply runtime journal routes or inverse callbacks themselves.
def Builder(~State:Type,~Recovery:Type,~Ops:Type -> Type) -> Type:
  @-All:Type -> @-Rest:Type -> @-path:Product.Lens<All,Recovery,Rest> -> Unit -> Ops(Frame.Frame<State,All>)
# Static recovery description for State, recovery owner and operation family Ops.
# Canonical component/resource/capture modules supply matching builders, empty
# recovery constructors and typed use descriptions. Arbitrary affine Type
# payloads are supported by those operations; this is not automatic rollback for
# all functions, external IO or arbitrary payload mutation.
# The classic Declaration form has opaque use metadata. Automatic App recovery
# registration requires a complete description and refuses that opaque form;
# the classic runner remains available. See docs/parity/recovery.md for the
# accepted operation domains, owner-return rules and qualified scenarios.
type Declaration<-S:Data,-State:Type,-Recovery:Type,-Ops:Type -> Type,-builder:Builder(~State,~Recovery,~Ops)> is Type:
  Declaration{empty:Unit -> Recovery,access:List<&2,String>}
  Described{empty:Unit -> Recovery,access:List<&2,String>,description:Use.Description}
# Consume a declaration and obtain its fresh recovery-owner constructor.
# This constructs the accumulator used when a recovery runner finishes; it does
# not execute operations, undo a transaction or copy live affine recovery values.
def empty(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> Unit -> Recovery:
  match value:
    case Declaration{empty,_}:empty
    case Described{empty,_,_}:empty
# Consume a declaration and obtain its declared registration access names.
# Order and duplicates are retained. These strings are metadata, not a journal
# route or a replacement for the declaration's typed operation authority.
def access(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> List<&2,String>:
  match value:
    case Declaration{_,access}:access
    case Described{_,access,_}:access
# Consume a declaration and return typed operational-use metadata.
# Legacy Declaration returns an opaque description; Described returns its stored
# description. Automatic App registration uses completeness rather than parsing
# access strings. This projection does not validate an inverse or run recovery.
def description(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops),value:Declaration<S,State,Recovery,Ops,builder>) -> Use.Description:
  match value:
    case Declaration{_,_}:Use.none()
    case Described{_,_,description}:description
# Operation-family alias for a bundle of left and right recovery grants acting
# on the same opaque frame. Keep their order consistent with the paired
# recovery product constructed by both.
def PairOps(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:Cap.Bundle<L(H),R(H)>
def pair_empty(~L:Type,~R:Type,~left:Unit -> L,~right:Unit -> R,unit:Unit) -> Product.Owner<L,R>:Product.Owner{left(Unit{}),right(unit)}
def pair_grant(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~left:Builder(~State,~L,~LOps),~right:Builder(~State,~R,~ROps),~All:Type,~Rest:Type,~path:Product.Lens<All,Product.Owner<L,R>,Rest>,unit:Unit) -> Cap.Bundle<LOps(Frame.Frame<State,All>),ROps(Frame.Frame<State,All>)>:
  Cap.Bundle{left(All,Rest & R,Product.compose(~All,~Product.Owner<L,R>,~Rest,~L,~R,~path,~Product.lens(~L,~R,~Product.Left{})),Unit{}),right(All,Rest & L,Product.compose(~All,~Product.Owner<L,R>,~Rest,~R,~L,~path,~Product.lens(~L,~R,~Product.Right{})),unit)}
# Compose two closed declarations for the same schema and State.
# The body receives Cap.Bundle{left, right}; recovery owners form
# Product.Owner<LeftRecovery, RightRecovery>. Access entries and typed use lists
# are appended left first, preserving duplicates; opacity in either description
# remains opaque. This does not execute either operation or create two journals.
# The recovery runner uses one shared LIFO journal across both grants: commit
# returns displaced originals, rollback restores recorded state and returns
# replacements. Effects outside the declared operations are not made reversible.
# Canonical leaves: ordinary-recovery-component.declaration,
# ordinary-recovery-resource.declaration and ordinary-recovery-capture.declaration;
# ordinary-recovery-system registers/runs the resulting declaration.
def both(~S:Data,~State:Type,~L:Type,~R:Type,~LOps:Type -> Type,~ROps:Type -> Type,~leftBuilder:Builder(~State,~L,~LOps),~rightBuilder:Builder(~State,~R,~ROps),~left:Declaration<S,State,L,LOps,leftBuilder>,~right:Declaration<S,State,R,ROps,rightBuilder>) -> Declaration<S,State,Product.Owner<L,R>,PairOps(~LOps,~ROps),pair_grant(~S,~State,~L,~R,~LOps,~ROps,~leftBuilder,~rightBuilder)>:
  Described{pair_empty(~L,~R,~empty(~S,~State,~L,~LOps,~leftBuilder,left),~empty(~S,~State,~R,~ROps,~rightBuilder,right)),List.append(&2,String,access(~S,~State,~L,~LOps,~leftBuilder,left),access(~S,~State,~R,~ROps,~rightBuilder,right)),Use.pair(description(~S,~State,~L,~LOps,~leftBuilder,left),description(~S,~State,~R,~ROps,~rightBuilder,right))}
def identity_take(~R:Type,value:R) -> Unit & R:(Unit{},value)
def identity_put(~R:Type,unit:Unit,value:R) -> R:value
# Advanced builder lens selecting the complete recovery owner, with Unit rest.
# It threads that owner once; it does not clone it or establish rollback by itself.
def identity(~R:Type) -> Product.Lens<R,R,Unit>:Product.Lens{identity_take(~R),identity_put(~R)}
# Advanced runner projection: instantiate the matching builder at the complete
# recovery owner with its identity lens. Returns operations, not live state;
# registration, journal execution and recovery results belong to
# ordinary-recovery-system. Use canonical declaration constructors for gameplay.
def root_grant(~S:Data,~State:Type,~Recovery:Type,~Ops:Type -> Type,~builder:Builder(~State,~Recovery,~Ops)) -> Ops(Frame.Frame<State,Recovery>):builder(Recovery,Unit,identity(~Recovery),Unit{})
