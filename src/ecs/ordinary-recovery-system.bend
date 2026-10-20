import Base
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./owner-product.bend as Product
import ./ordinary-recovery-declaration.bend as D
import ./ordinary-recoverable-array-resource.bend as F
import ./recovery-journal.bend as Journal
# Affine invocation input pairing caller Args with the retained capture.
# Admission refusal returns both through the registered request protocol.
type Request<Args:Type,Capture:Type> is Type:Request{args:Args,capture:Capture}
# Semantic outcome plus retained Out, capture and typed recovery receipts.
# Body errors stay inside Reply so transport success does not discard owners.
# Only explicitly journaled recoverable operations participate in restoration.
type Reply<Capture:Type,Recovery:Type,Error:Data,Out:Type> is Type:Reply{outcome:T.Outcome<Error>,output:Out,capture:Capture,recovery:Recovery}
# Affine recoverable-system owner pairing actual Registry and capture.
# Metadata or a printable name cannot substitute for the live registration.
type Owner<Registry:Type,Capture:Type> is Type:Owner{registry:Registry,capture:Capture}
# Completed retains World, owner, semantic outcome, Out and recovery.
# RegistrationRejected returns original Args and owner without running body.
# TransportFailed retains only World and is unreachable through the canonical
# closed runner, which returns semantic errors in Reply.
type Run<World:Type,Owner:Type,Args:Type,Error:Data,Out:Type,Recovery:Type> is Type:
  Completed{world:World,owner:Owner,outcome:T.Outcome<Error>,output:Out,recovery:Recovery}
  RegistrationRejected{world:World,owner:Owner,args:Args}
  TransportFailed{world:World}
# Defined returns World and registered capture owner; DefinitionRejected
# returns World and initial capture, without invoking the body.
type Defined<World:Type,Owner:Type,Capture:Type> is Type:
  Defined{world:World,owner:Owner}
  DefinitionRejected{world:World,capture:Capture}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),outcome:T.Outcome<Error>,output:Out,result:Product.Owner<W.World<S,C,R,E>,Capture> & Recovery) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Capture,Recovery,Error,Out>>:
  match result:
    case (Product.Owner{world,capture},recovery):Sys.Succeeded{world,Reply{outcome,output,capture,recovery}}
def completing(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),state:Product.Owner<W.World<S,C,R,E>,Capture>,journal:List<Journal.Action(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery)>,result:T.Outcome<Error> & Out) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Capture,Recovery,Error,Out>>:
  match result:
    case (+outcome,output):finished(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,outcome,output,Journal.finish(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,journal,F.succeeded(~Error,outcome),state,D.empty(~S,~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops,~builder,declaration)(Unit{})))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),result:F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,Recovery> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Capture,Recovery,Error,Out>>:
  match result:
    case (F.Frame{state,journal},result):completing(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,state,journal,result)
# Advanced recoverable runner over World/capture product and shared journal.
# Canonical declared inverses determine commit/rollback receipts; arbitrary
# external effects or undeclared mutations are not made reversible. Returns
# outer Succeeded with semantic outcome and actual owners in Reply.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,request:Request<Args,Capture>) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Capture,Recovery,Error,Out>>:
  match request:
    case Request{args,capture}:returned(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,body(F.Frame<Product.Owner<W.World<S,C,R,E>,Capture>,Recovery>,D.root_grant(~S,~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops,~builder),args,F.Frame{Product.Owner{world,capture},[]}))
# Advanced type alias for the matching Registry/capture owner.
# Does not create a registration or validate a World by itself.
def Owned(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out)) -> Type:Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),capture:Capture,result:Sys.RegistrationResult<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>) -> Defined<W.World<S,C,R,E>,Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,Capture>:
  match result:
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,capture}}
    case Sys.RegistrationFailed{world}:DefinitionRejected{world,capture}
# Register a recoverable body with access derived from its declaration.
# Consumes capture on success; definition refusal returns it with World.
# No body or inverse operation runs at registration.
# Contract and consumers: docs/parity/recovery.md.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,name:String,capture:Capture) -> Defined<W.World<S,C,R,E>,Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,Capture>:
  registered(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,capture,Sys.register(~S,~C,~R,~E,~Request<Args,Capture>,~Unit,~Reply<Capture,Recovery,Error,Out>,~runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body),world,name,D.access(~S,~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops,~builder,declaration)))
# Completion retains the Registry already advanced to its captured run tick.
# Semantic failure still returns its explicit Reply and recovery owners.
def done(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),outcome:T.Outcome<Error>,output:Out,capture:Capture,recovery:Recovery,result:W.World<S,C,R,E> & Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>) -> Run<W.World<S,C,R,E>,Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,Args,Error,Out,Recovery>:
  match result:
    case (world,registry):Completed{world,Owner{registry,capture},outcome,output,recovery}
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),result:Sys.RunResult<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>) -> Run<W.World<S,C,R,E>,Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,Args,Error,Out,Recovery>:
  match result:
    case Sys.RegistrationRejected{registry,world,Request{args,capture}}:RegistrationRejected{world,Owner{registry,capture},args}
    case Sys.Completed{registry,Sys.Succeeded{world,Reply{+outcome,output,capture,recovery}}}:done(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,outcome,output,capture,recovery,(world,registry))
    # Unreachable through the closed runner, which retains semantic errors in Reply.
    case Sys.Completed{_,Sys.Failed{world,_}}:TransportFailed{world}
# Validate registration and execute with retained capture and affine Args.
# Admission refusal returns original owners/Args. Completed returns semantic
# outcome, Out and typed recovery on both body success and failure; inspect
# outcome instead of assuming outer transport means commit. Every admitted completion consumes its captured lifecycle tick,
# including semantic failure; recovery ownership remains in Reply.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Capture:Type,~Recovery:Type,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~builder:D.Builder(~Product.Owner<W.World<S,C,R,E>,Capture>,~Recovery,~Ops),~declaration:D.Declaration<S,Product.Owner<W.World<S,C,R,E>,Capture>,Recovery,Ops,builder>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),owner:Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,world:W.World<S,C,R,E>,args:Args) -> Run<W.World<S,C,R,E>,Owner<Sys.Registry<S,C,R,E,Request<Args,Capture>,Unit,Reply<Capture,Recovery,Error,Out>,runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body)>,Capture>,Args,Error,Out,Recovery>:
  match owner:
    case Owner{registry,capture}:completed(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body,Sys.run(~S,~C,~R,~E,~Request<Args,Capture>,~Unit,~Reply<Capture,Recovery,Error,Out>,~runner(~S,~C,~R,~E,~Capture,~Recovery,~Ops,~Args,~Error,~Out,~builder,~declaration,~body),registry,world,Request{args,capture}))
