import Base
import ./world.bend as W
import ./owner-product.bend as Product
import ./ordinary-recovery-declaration.bend as D
import ./ordinary-recoverable-array-resource.bend as F
import ./ordinary-recoverable-component-capture.bend as Existing
import ./recoverable-array.bend as A
import ./recoverable-array-owner.bend as AO
import ./recovery-journal.bend as Journal
# Canonical capture target and generated recovery path; no caller inverse.
def Ops(~Q:Type,H:Type) -> Type:Existing.CaptureWrite<Q,H>
def empty(~Q:Type,unit:Unit) -> List<A.Record<Q>>:[]
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,result:Product.Owner<W.World<S,C,R,E>,Array<Q>> & List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~All)>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>:
  match result:
    case (state,journal):F.Frame{state,journal}
def replace(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,incoming:Array<Q>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>:
  match frame:
    case F.Frame{state,journal}:replaced(~S,~C,~R,~E,~Q,~All,~Rest,~path,AO.replace(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~Q,~W.World<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Array<Q>,~Product.Right{}),~All,~Rest,~path,state,journal,incoming))
def swapped(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,result:AO.Attempt<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All,Q>) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,Q>:
  match result:
    case AO.Applied{state,journal}:F.Applied{F.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:F.Refused{F.Frame{state,journal},incoming}
def swap(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,index:U32,incoming:Q) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,Q>:
  match frame:
    case F.Frame{state,journal}:swapped(~S,~C,~R,~E,~Q,~All,~Rest,~path,AO.swap(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~Q,~W.World<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Array<Q>,~Product.Right{}),~All,~Rest,~path,state,journal,index,incoming))
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,unit:Unit) -> Existing.CaptureWrite<Q,F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>>:Existing.CaptureWrite{replace(~S,~C,~R,~E,~Q,~All,~Rest,~path),swap(~S,~C,~R,~E,~Q,~All,~Rest,~path)}
def declaration(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type) -> D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Array<Q>>,List<A.Record<Q>>,Ops(~Q),grant(~S,~C,~R,~E,~Q)>:D.Declaration{empty(~Q),[]}
