import Base
import ./recovery-use.bend as Use
import ./world.bend as W
import ./owner-product.bend as Product
import ./ordinary-recovery-declaration.bend as D
import ./ordinary-recoverable-array-resource.bend as F
import ./ordinary-recoverable-component-capture.bend as Existing
import ./recoverable-array.bend as A
import ./recoverable-array-owner.bend as AO
import ./recovery-journal.bend as Journal
import ./world-resource-owner.bend as WR
import ./ordinary-schema.bend as Schema
# Canonical World resource target and generated recovery path; no caller inverse.
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,H:Type) -> Type:F.Write<S,P,identity,H>
def target(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type) -> Product.Lens<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,Array<P>,Capture & WR.Rest<S,C,Array<P>,E>>:
  Product.compose(~Product.Owner<W.World<S,C,Array<P>,E>,Capture>,~W.World<S,C,Array<P>,E>,~Capture,~Array<P>,~WR.Rest<S,C,Array<P>,E>,~Product.lens(~W.World<S,C,Array<P>,E>,~Capture,~Product.Left{}),~WR.lens(~S,~C,~Array<P>,~E))
def empty(~Capture:Type,~P:Type,unit:Unit) -> List<A.Record<P>>:[]
def replaced(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:Product.Owner<W.World<S,C,Array<P>,E>,Capture> & List<Journal.Action(~Product.Owner<W.World<S,C,Array<P>,E>,Capture>,~All)>) -> F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>:
  match result:
    case (state,journal):F.Frame{state,journal}
def replace(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>,incoming:Array<P>) -> F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>:
  match frame:
    case F.Frame{state,journal}:replaced(~S,~C,~E,~Capture,~P,~All,~Rest,~path,AO.replace(~Product.Owner<W.World<S,C,Array<P>,E>,Capture>,~P,~(Capture & WR.Rest<S,C,Array<P>,E>),~target(~S,~C,~E,~Capture,~P),~All,~Rest,~path,state,journal,incoming))
def swapped(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,result:AO.Attempt<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All,P>) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>,P>:
  match result:
    case AO.Applied{state,journal}:F.Applied{F.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:F.Refused{F.Frame{state,journal},incoming}
def swap(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>,index:U32,incoming:P) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>,P>:
  match frame:
    case F.Frame{state,journal}:swapped(~S,~C,~E,~Capture,~P,~All,~Rest,~path,AO.swap(~Product.Owner<W.World<S,C,Array<P>,E>,Capture>,~P,~(Capture & WR.Rest<S,C,Array<P>,E>),~target(~S,~C,~E,~Capture,~P),~All,~Rest,~path,state,journal,index,incoming))
def grant(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~identity:Schema.Resource<S,Array<P>>,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<P>>,Rest>,unit:Unit) -> F.Write<S,P,identity,F.Frame<Product.Owner<W.World<S,C,Array<P>,E>,Capture>,All>>:
  F.Write{replace(~S,~C,~E,~Capture,~P,~All,~Rest,~path),swap(~S,~C,~E,~Capture,~P,~All,~Rest,~path)}
def declaration(~S:Data,~C:Type,~E:Data,~Capture:Type,~P:Type,~identity:Schema.Resource<S,Array<P>>) -> D.Declaration<S,Product.Owner<W.World<S,C,Array<P>,E>,Capture>,List<A.Record<P>>,Ops(~S,~P,~identity),grant(~S,~C,~E,~Capture,~P,~identity)>:
  D.Described{empty(~Capture,~P),[Schema.resource_key(~S,~Array<P>,identity)],Use.known([Use.Use{Use.Resource{Schema.resource_key(~S,~Array<P>,identity)},Use.Write{}}])}
