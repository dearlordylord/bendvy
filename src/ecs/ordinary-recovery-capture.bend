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
# Canonical capture target and generated recovery path; no caller inverse.
# Recoverable retained Array<Q> capture capability family: whole-array
# replace and bounded element swap. Q may be affine Type; arbitrary capture
# mutation outside these declared operations is not automatically reversible.
def Ops(~Q:Type,H:Type) -> Type:Existing.CaptureWrite<Q,H>
def empty(~Q:Type,unit:Unit) -> List<A.Record<Q>>:[]
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,result:Product.Owner<W.World<S,C,R,E>,Array<Q>> & List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~All)>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>:
  match result:
    case (state,journal):F.Frame{state,journal}
# Replace retained Array<Q> capture, recording its displaced owner in the
# shared recovery journal. Commit returns the displaced array; rollback
# restores it and returns the replacement through the recovery accumulator.
# World remains the retained sibling of capture.
def replace(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,incoming:Array<Q>) -> F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>:
  match frame:
    case F.Frame{state,journal}:replaced(~S,~C,~R,~E,~Q,~All,~Rest,~path,AO.replace(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~Q,~W.World<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Array<Q>,~Product.Right{}),~All,~Rest,~path,state,journal,incoming))
def swapped(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,result:AO.Attempt<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All,Q>) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,Q>:
  match result:
    case AO.Applied{state,journal}:F.Applied{F.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:F.Refused{F.Frame{state,journal},incoming}
# Attempt a bounded capture element replacement. Refused retains frame and
# incoming Q without extending the journal; accepted records the old element
# for commit/rollback recovery. Does not copy either affine element.
def swap(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,index:U32,incoming:Q) -> F.Attempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>,Q>:
  match frame:
    case F.Frame{state,journal}:swapped(~S,~C,~R,~E,~Q,~All,~Rest,~path,AO.swap(~Product.Owner<W.World<S,C,R,E>,Array<Q>>,~Q,~W.World<S,C,R,E>,~Product.lens(~W.World<S,C,R,E>,~Array<Q>,~Product.Right{}),~All,~Rest,~path,state,journal,index,incoming))
# Advanced canonical builder selecting the capture and generated recovery
# path inside the complete product. Raw indices are trusted setup; the body
# sees only its closed replace/swap operations.
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type,~All:Type,~Rest:Type,~path:Product.Lens<All,List<A.Record<Q>>,Rest>,unit:Unit) -> Existing.CaptureWrite<Q,F.Frame<Product.Owner<W.World<S,C,R,E>,Array<Q>>,All>>:Existing.CaptureWrite{replace(~S,~C,~R,~E,~Q,~All,~Rest,~path),swap(~S,~C,~R,~E,~Q,~All,~Rest,~path)}
# Declare canonical Array<Q> capture recovery with complete typed Capture
# use metadata and no fabricated World access key. Compose with component/
# resource declarations through ordinary-recovery-declaration.both. Does not
# execute a body or make host IO reversible; see docs/parity/recovery.md.
def declaration(~S:Data,~C:Type,~R:Type,~E:Data,~Q:Type) -> D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Array<Q>>,List<A.Record<Q>>,Ops(~Q),grant(~S,~C,~R,~E,~Q)>:D.Described{empty(~Q),[],Use.known([Use.Use{Use.Capture{},Use.Write{}}])}
