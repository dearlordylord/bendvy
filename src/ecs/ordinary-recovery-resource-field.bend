import Base
import ./recovery-use.bend as Use
import ./resource-field-binding.bend as Binding
import ./world.bend as W
import ./owner-product.bend as Product
import ./ordinary-recovery-declaration.bend as D
import ./ordinary-recoverable-array-resource.bend as F
import ./recoverable-array.bend as A
import ./recoverable-array-owner.bend as AO
import ./recovery-journal.bend as Journal
import ./world-resource-owner.bend as WR
import ./ordinary-schema.bend as Schema
# Canonical selected resource field with generated recovery path; no caller inverse.
# Binding supplies the same identity/path pair as ordinary resource-field grants.
# Advanced capability-shape projection for identity-indexed recoverable Array<P>
# replacement and checked element swap, with opaque execution owner H.
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,H:Type) -> Type:F.Write<S,P,identity,H>
# Trusted recovery lens into World resources while threading actual capture and
# all other World fields. This is setup plumbing, not a gameplay World accessor.
def resource_target(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type) -> Product.Lens<Product.Owner<W.World<S,C,R,E>,Capture>,R,Capture & WR.Rest<S,C,R,E>>:
  Product.compose(~Product.Owner<W.World<S,C,R,E>,Capture>,~W.World<S,C,R,E>,~Capture,~R,~WR.Rest<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Capture,~Product.Left{}),~WR.lens(~S,~C,~R,~E))
# Trusted composition of World-resource and selected Array-field lenses.
# Canonical binding supplies the identity/path pair; siblings/capture stay owned.
def target(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>) -> Product.Lens<Product.Owner<W.World<S,C,R,E>,Capture>,Array<P>,(Capture & WR.Rest<S,C,R,E>) & FieldRest>:
  Product.compose(~Product.Owner<W.World<S,C,R,E>,Capture>,~R,~(Capture & WR.Rest<S,C,R,E>),~Array<P>,~FieldRest,~resource_target(~S,~C,~R,~E,~Capture),~fieldLens)
def empty(~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,unit:Unit) -> List<A.Record<P>>:[]
def replaced(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:Product.Owner<W.World<S,C,R,E>,Capture> & List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Capture>,~All)>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>:
  match result:
    case (state,journal):F.Frame{state,journal}
# Advanced recoverable replacement: consume incoming Array<P>, install it in
# the selected field and journal the displaced array in the shared recovery path.
# Commit returns displaced owners; rollback restores originals and returns displaced
# replacements through the declaration recovery result, not a duplicate live owner.
def replace(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,incoming:Array<P>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>:
  match frame:
    case F.Frame{state,journal}:replaced(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path,AO.replace(~Product.Owner<W.World<S,C,R,E>,Capture>,~P,~((Capture & WR.Rest<S,C,R,E>) & FieldRest),~target(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens),~All,~Rest,~path,state,journal,incoming))
def swapped(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:AO.Attempt<Product.Owner<W.World<S,C,R,E>,Capture>,All,P>) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match result:
    case AO.Applied{state,journal}:F.Applied{F.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:F.Refused{F.Frame{state,journal},incoming}
# Advanced bounds-checked element replacement consuming P. Applied journals old P;
# Refused returns actual incoming P with state/journal preserved when index is out
# of bounds. Recovery follows shared journal order; unlike raw Array access this
# does not wrap an invalid index into another slot.
def swap(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,index:U32,incoming:P) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match frame:
    case F.Frame{state,journal}:swapped(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path,AO.swap(~Product.Owner<W.World<S,C,R,E>,Capture>,~P,~((Capture & WR.Rest<S,C,R,E>) & FieldRest),~target(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens),~All,~Rest,~path,state,journal,index,incoming))
# Advanced canonical grant builder hiding resource lens and journal plumbing
# behind the identity-indexed recoverable write operations. Does not execute them.
def grant(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~identity:Schema.Resource<S,Array<P>>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,unit:Unit) -> F.Write<S,P,identity,F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>>:
  F.Write{replace(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path),swap(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path)}
# Derive the recoverable selected Array resource declaration from its canonical
# Binding. Initializes empty recovery records and publishes known Write-use metadata
# for this resource key. Shared recovery composition controls finish/undo order;
# there is no caller-authored inverse or automatic external-effect rollback.
# See docs/parity/recovery.md for explicit owned recovery boundaries.
def declaration(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~identity:Schema.Resource<S,Array<P>>,~binding:Binding.Binding<S,R,Array<P>,FieldRest,fieldLens,identity>) -> D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,List<A.Record<P>>,Ops(~S,~P,~identity),grant(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~identity)>:
  D.Described{empty(~Capture,~R,~P,~FieldRest,~fieldLens),[Schema.resource_key(~S,~Array<P>,identity)],Use.known([Use.Use{Use.Resource{Schema.resource_key(~S,~Array<P>,identity)},Use.Write{}}])}
