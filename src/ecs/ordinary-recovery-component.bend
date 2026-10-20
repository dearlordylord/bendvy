import Base
import ./recovery-use.bend as Use
import ./world.bend as W
import ./column.bend as Col
import ./owner-product.bend as Product
import ./ordinary-component-binding.bend as B
import ./ordinary-declaration.bend as Identity
import ./ordinary-recovery-declaration.bend as D
import ./ordinary-recoverable-array-resource.bend as F
import ./ordinary-recoverable-component-capture.bend as Existing
import ./recoverable-component.bend as RC
import ./recoverable-component-family.bend as Family
import ./recoverable-owner.bend as RO
import ./recovery-journal.bend as Journal
# Existing schema take/put/view are trusted provisioning, never gameplay inverses.
# Nominal recoverable component replacement capability family. P may be
# affine Type; the grant is bound to its ordinary component identity, not a
# printable access name or a caller-provided inverse.
def Ops(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,H:Type) -> Type:Existing.ComponentWrite<S,P,identity,H>
def empty(~S:Data,~P:Type,unit:Unit) -> List<RC.Record<S,P>>:[]
def released(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>,~All:Type,~ReleasedRest:Type,~path:Product.Lens<All,List<RC.Record<S,P>>,ReleasedRest>,capture:Capture,recovery:All,result:W.World<S,C,R,E> & RC.Record<S,P>) -> Product.Owner<W.World<S,C,R,E>,Capture> & All:
  match result:
    case (world,record):(Product.Owner{world,capture},RO.append(~All,~RC.Record<S,P>,~ReleasedRest,~path,recovery,record))
def inverse(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>,~All:Type,~ReleasedRest:Type,~path:Product.Lens<All,List<RC.Record<S,P>>,ReleasedRest>,old:RC.Record<S,P>,success:Bool,state:Product.Owner<W.World<S,C,R,E>,Capture>,recovery:All) -> Product.Owner<W.World<S,C,R,E>,Capture> & All:
  match success state:
    case True{} state:(state,RO.append(~All,~RC.Record<S,P>,~ReleasedRest,~path,recovery,old))
    case False{} Product.Owner{world,capture}:released(~S,~C,~R,~E,~Capture,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~All,~ReleasedRest,~path,capture,recovery,Family.undo(~S,~C,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),old,world))
def replaced(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>,~All:Type,~ReleasedRest:Type,~path:Product.Lens<All,List<RC.Record<S,P>>,ReleasedRest>,capture:Capture,journal:List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Capture>,~All)>,result:RC.Replacement<W.World<S,C,R,E>,S,P>) -> Existing.ComponentAttempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match result:
    case RC.Applied{world,old}:Existing.ComponentApplied{F.Frame{Product.Owner{world,capture},(success => state => recovery => inverse(~S,~C,~R,~E,~Capture,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~All,~ReleasedRest,~path,old,success,state,recovery)) <> journal}}
    case RC.Refused{world,incoming,error}:Existing.ComponentRefused{F.Frame{Product.Owner{world,capture},journal},incoming,error}
# Replace an optional component owner through the canonical binding.
# Immediate refusal returns frame, incoming owner and error without adding
# an inverse. Accepted records the displaced component receipt; commit returns
# displaced owners, while rollback restores recorded state and recovers
# replacements. Other World/capture owners are retained through the frame.
def replace(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>,~All:Type,~ReleasedRest:Type,~path:Product.Lens<All,List<RC.Record<S,P>>,ReleasedRest>,frame:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,handle:W.Handle<S>,incoming:Maybe<P>) -> Existing.ComponentAttempt<F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>,P>:
  match frame:
    case F.Frame{Product.Owner{world,capture},journal}:replaced(~S,~C,~R,~E,~Capture,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~All,~ReleasedRest,~path,capture,journal,Family.replace(~S,~C,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,B.family(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),world,handle,incoming))
# Advanced canonical grant builder specialized at the complete recovery
# product/path. Raw erased lenses must match the declaration; gameplay
# receives the resulting nominal component operation, not journal callbacks.
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>,~All:Type,~ReleasedRest:Type,~path:Product.Lens<All,List<RC.Record<S,P>>,ReleasedRest>,unit:Unit) -> Existing.ComponentWrite<S,P,B.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding),F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,All>>:Existing.ComponentWrite{replace(~S,~C,~R,~E,~Capture,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~All,~ReleasedRest,~path)}
# Build a complete typed component-recovery declaration from its ordinary
# binding. Derives access/use metadata and the canonical recovery accumulator
# without executing an operation. Compose with other leaves using
# ordinary-recovery-declaration.both; semantics: docs/parity/recovery.md.
def declaration(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,~binding:B.Binding<S,C,Rest,P,V,Token,take,put,view>) -> D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,List<RC.Record<S,P>>,Ops(~S,~P,~B.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding)),grant(~S,~C,~R,~E,~Capture,~Rest,~P,~V,~Token,~take,~put,~view,~binding)>:
  D.Described{empty(~S,~P),[Identity.key(~S,~P,B.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding))],Use.known([Use.Use{Use.Component{Identity.key(~S,~P,B.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding))},Use.Write{}}])}
