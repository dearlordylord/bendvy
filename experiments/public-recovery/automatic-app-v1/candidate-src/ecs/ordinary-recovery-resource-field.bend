import Base
import ./recovery-use.bend as Use
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import ./ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-array-resource.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array-owner.bend as AO
import /workspace/formal-proofs/bendvy/src/ecs/recovery-journal.bend as Journal
import /workspace/formal-proofs/bendvy/src/ecs/world-resource-owner.bend as WR
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
# Canonical selected resource field with generated recovery path; no caller inverse.
# Binding supplies the same identity/path pair as ordinary resource-field grants.
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,H:Type) -> Type:F.Write<S,P,identity,H>
def resource_target(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type) -> Product.Lens<Product.Owner<W.World<S,C,R,E>,Capture>,R,Capture & WR.Rest<S,C,R,E>>:
  Product.compose(~Product.Owner<W.World<S,C,R,E>,Capture>,~W.World<S,C,R,E>,~Capture,~R,~WR.Rest<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Capture,~Product.Left{}),~WR.lens(~S,~C,~R,~E))
def target(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>) -> Product.Lens<Product.Owner<W.World<S,C,R,E>,Capture>,Array<P>,(Capture & WR.Rest<S,C,R,E>) & FieldRest>:
  Product.compose(~Product.Owner<W.World<S,C,R,E>,Capture>,~R,~(Capture & WR.Rest<S,C,R,E>),~Array<P>,~FieldRest,~resource_target(~S,~C,~R,~E,~Capture),~fieldLens)
def empty(~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,unit:Unit) -> List<A.Record<P>>:[]
def replaced(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:Product.Owner<W.World<S,C,R,E>,Capture> & List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Capture>,~All)>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>:
  match result:
    case (state,journal):F.Frame{state,journal}
def replace(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,incoming:Array<P>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>:
  match frame:
    case F.Frame{state,journal}:replaced(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path,AO.replace(~Product.Owner<W.World<S,C,R,E>,Capture>,~P,~((Capture & WR.Rest<S,C,R,E>) & FieldRest),~target(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens),~All,~Rest,~path,state,journal,incoming))
def swapped(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:AO.Attempt<Product.Owner<W.World<S,C,R,E>,Capture>,All,P>) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match result:
    case AO.Applied{state,journal}:F.Applied{F.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:F.Refused{F.Frame{state,journal},incoming}
def swap(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,index:U32,incoming:P) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match frame:
    case F.Frame{state,journal}:swapped(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path,AO.swap(~Product.Owner<W.World<S,C,R,E>,Capture>,~P,~((Capture & WR.Rest<S,C,R,E>) & FieldRest),~target(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens),~All,~Rest,~path,state,journal,index,incoming))
def grant(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~identity:Schema.Resource<S,Array<P>>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,unit:Unit) -> F.Write<S,P,identity,F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>>:
  F.Write{replace(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path),swap(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~All,~Rest,~path)}
def declaration(~S:Data,~C:Type,~E:Data,~Capture:Type,~R:Type,~P:Type,~FieldRest:Type,~fieldLens:Product.Lens<R,Array<P>,FieldRest>,~identity:Schema.Resource<S,Array<P>>,~binding:Binding.Binding<S,R,Array<P>,FieldRest,fieldLens,identity>) -> D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,List<A.Record<P>>,Ops(~S,~P,~identity),grant(~S,~C,~E,~Capture,~R,~P,~FieldRest,~fieldLens,~identity)>:
  D.Described{empty(~Capture,~R,~P,~FieldRest,~fieldLens),[Schema.resource_key(~S,~Array<P>,identity)],Use.known([Use.Use{Use.Resource{Schema.resource_key(~S,~Array<P>,identity)},Use.Write{}}])}
