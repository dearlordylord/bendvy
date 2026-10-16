import Base
import ./world.bend as W
import ./column.bend as Col
import ./system.bend as Sys
import ./transaction.bend as T
import ./ordinary-declaration.bend as Declaration
import ./owner-product.bend as Product
import ./capabilities.bend as Cap
import ./ordinary-recoverable-array-resource.bend as O
import ./recoverable-array.bend as A
import ./recoverable-array-owner.bend as AO
import ./recoverable-owner.bend as RO
import ./recoverable-component.bend as RC
import ./recovery-journal.bend as Journal
# Explicit opt-in recovery for captures. The normal #50 entry is unchanged.
type ComponentAttempt<H:Type,P:Type> is Type:
  ComponentApplied{owner:H}
  ComponentRefused{owner:H,incoming:Maybe<P>,error:W.WorldError}
type ComponentWrite<-S:Data,-P:Type,-identity:Declaration.Declaration<S,P>,-H:Type> is Type:
  ComponentWrite{replace:H -> W.Handle<S> -> Maybe<P> -> ComponentAttempt<H,P>}
type CaptureWrite<-Q:Type,-H:Type> is Type:
  CaptureWrite{replace:H -> Array<Q> -> H,swap:H -> U32 -> Q -> O.Attempt<H,Q>}
def component_function(~S:Data,~P:Type,~identity:Declaration.Declaration<S,P>,~H:Type,value:ComponentWrite<S,P,identity,H>) -> H -> W.Handle<S> -> Maybe<P> -> ComponentAttempt<H,P>:
  match value:
    case ComponentWrite{f}:f
def component_replace(~S:Data,~P:Type,~identity:Declaration.Declaration<S,P>,~H:Type,~cap:ComponentWrite<S,P,identity,H>,owner:H,handle:W.Handle<S>,incoming:Maybe<P>) -> ComponentAttempt<H,P>:
  component_function(~S,~P,~identity,~H,cap)(owner,handle,incoming)
def capture_replace_function(~Q:Type,~H:Type,value:CaptureWrite<Q,H>) -> H -> Array<Q> -> H:
  match value:
    case CaptureWrite{f,_}:f
def capture_swap_function(~Q:Type,~H:Type,value:CaptureWrite<Q,H>) -> H -> U32 -> Q -> O.Attempt<H,Q>:
  match value:
    case CaptureWrite{_,f}:f
def capture_replace(~Q:Type,~H:Type,~cap:CaptureWrite<Q,H>,owner:H,incoming:Array<Q>) -> H:
  capture_replace_function(~Q,~H,cap)(owner,incoming)
def capture_swap(~Q:Type,~H:Type,~cap:CaptureWrite<Q,H>,owner:H,index:U32,incoming:Q) -> O.Attempt<H,Q>:
  capture_swap_function(~Q,~H,cap)(owner,index,incoming)
def Recovery(~S:Data,~P:Type,~Q:Type) -> Type:Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>
def Ops(~S:Data,~P:Type,~Q:Type,~identity:Declaration.Declaration<S,P>,H:Type) -> Type:
  Cap.Bundle<ComponentWrite<S,P,identity,H>,CaptureWrite<Q,H>>
def component_released(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,capture:Array<Q>,recovery:Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,result:W.World<S,Col.Column<S,P>,R,E> & RC.Record<S,P>) -> Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>> & Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>:
  match recovery result:
    case Product.Owner{components,captures},(world,record):(Product.Owner{world,capture},Product.Owner{record <> components,captures})
def component_inverse(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,old:RC.Record<S,P>,success:Bool,state:Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,recovery:Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>) -> Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>> & Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>:
  match success state recovery:
    case True{} state Product.Owner{components,captures}:(state,Product.Owner{old <> components,captures})
    case False{} Product.Owner{world,capture} recovery:component_released(~S,~P,~Q,~R,~E,capture,recovery,RC.undo(~S,~P,~R,~E,old,world))
def component_changed(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,capture:Array<Q>,journal:List<Journal.Action(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>)>,result:RC.Replacement<W.World<S,Col.Column<S,P>,R,E>,S,P>) -> ComponentAttempt<O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,P>:
  match result:
    case RC.Applied{world,old}:ComponentApplied{O.Frame{Product.Owner{world,capture},(success => s => r => component_inverse(~S,~P,~Q,~R,~E,old,success,s,r)) <> journal}}
    case RC.Refused{world,incoming,error}:ComponentRefused{O.Frame{Product.Owner{world,capture},journal},incoming,error}
def frame_component(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,owner:O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,handle:W.Handle<S>,incoming:Maybe<P>) -> ComponentAttempt<O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,P>:
  match owner:
    case O.Frame{Product.Owner{world,capture},journal}:component_changed(~S,~P,~Q,~R,~E,capture,journal,RC.replace(~S,~P,~R,~E,Declaration.key(~S,~P,identity),world,handle,incoming))
def frame_replaced(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,result:Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>> & List<Journal.Action(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>)>) -> O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>:
  match result:
    case (state,journal):O.Frame{state,journal}
def frame_capture_replace(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,owner:O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,incoming:Array<Q>) -> O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>:
  match owner:
    case O.Frame{state,journal}:frame_replaced(~S,~P,~Q,~R,~E,AO.replace(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Q,~W.World<S,Col.Column<S,P>,R,E>,~Product.lens(~W.World<S,Col.Column<S,P>,R,E>,~Array<Q>,~Product.Right{}),~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,~List<RC.Record<S,P>>,~Product.lens(~List<RC.Record<S,P>>,~List<A.Record<Q>>,~Product.Right{}),state,journal,incoming))
def frame_swapped(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,result:AO.Attempt<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,Q>) -> O.Attempt<O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,Q>:
  match result:
    case AO.Applied{state,journal}:O.Applied{O.Frame{state,journal}}
    case AO.Refused{state,journal,incoming}:O.Refused{O.Frame{state,journal},incoming}
def frame_capture_swap(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,owner:O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,index:U32,incoming:Q) -> O.Attempt<O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,Q>:
  match owner:
    case O.Frame{state,journal}:frame_swapped(~S,~P,~Q,~R,~E,AO.swap(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Q,~W.World<S,Col.Column<S,P>,R,E>,~Product.lens(~W.World<S,Col.Column<S,P>,R,E>,~Array<Q>,~Product.Right{}),~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,~List<RC.Record<S,P>>,~Product.lens(~List<RC.Record<S,P>>,~List<A.Record<Q>>,~Product.Right{}),state,journal,index,incoming))
def grant(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>) -> Ops(~S,~P,~Q,~identity,O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>):
  Cap.Bundle{ComponentWrite{frame_component(~S,~P,~Q,~R,~E,~identity)},CaptureWrite{frame_capture_replace(~S,~P,~Q,~R,~E),frame_capture_swap(~S,~P,~Q,~R,~E)}}
type Request<Args:Type,Q:Type> is Type:Request{args:Args,capture:Array<Q>}
type Reply<S:Data,P:Type,Q:Type,Error:Data,Out:Type> is Type:
  Reply{outcome:T.Outcome<Error>,output:Out,capture:Array<Q>,recovery:Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>}
def finished(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,outcome:T.Outcome<Error>,output:Out,result:Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>> & Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>) -> Sys.Outcome<W.World<S,Col.Column<S,P>,R,E>,Unit,Reply<S,P,Q,Error,Out>>:
  match result:
    case (Product.Owner{world,capture},recovery):Sys.Succeeded{world,Reply{outcome,output,capture,recovery}}
def completing(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,state:Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,journal:List<Journal.Action(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>)>,result:T.Outcome<Error> & Out) -> Sys.Outcome<W.World<S,Col.Column<S,P>,R,E>,Unit,Reply<S,P,Q,Error,Out>>:
  match result:
    case (+outcome,output):finished(~S,~P,~Q,~R,~E,~Error,~Out,outcome,output,Journal.finish(~Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,~Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,journal,O.succeeded(~Error,outcome),state,Product.Owner{[],[]}))
def returned(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,result:O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,Col.Column<S,P>,R,E>,Unit,Reply<S,P,Q,Error,Out>>:
  match result:
    case (O.Frame{state,journal},output):completing(~S,~P,~Q,~R,~E,~Error,~Out,state,journal,output)
def runner(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,Col.Column<S,P>,R,E>,request:Request<Args,Q>) -> Sys.Outcome<W.World<S,Col.Column<S,P>,R,E>,Unit,Reply<S,P,Q,Error,Out>>:
  match request:
    case Request{args,capture}:returned(~S,~P,~Q,~R,~E,~Error,~Out,body(O.Frame<Product.Owner<W.World<S,Col.Column<S,P>,R,E>,Array<Q>>,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>,grant(~S,~P,~Q,~R,~E,~identity),args,O.Frame{Product.Owner{world,capture},[]}))
type Owner<Registry:Type,Q:Type> is Type:Owner{registry:Registry,capture:Array<Q>}
def Owned(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out)) -> Type:Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>
type Defined<World:Type,Owned:Type,Q:Type> is Type:
  Defined{world:World,owner:Owned}
  DefinitionRejected{world:World,capture:Array<Q>}
def registered(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),capture:Array<Q>,result:Sys.RegistrationResult<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>) -> Defined<W.World<S,Col.Column<S,P>,R,E>,Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,Q>:
  match result:
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,capture}}
    case Sys.RegistrationFailed{world}:DefinitionRejected{world,capture}
def define(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,Col.Column<S,P>,R,E>,name:String,capture:Array<Q>) -> Defined<W.World<S,Col.Column<S,P>,R,E>,Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,Q>:
  registered(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body,capture,Sys.register(~S,~Col.Column<S,P>,~R,~E,~Request<Args,Q>,~Unit,~Reply<S,P,Q,Error,Out>,~runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body),world,name,[Declaration.key(~S,~P,identity)]))
type Run<World:Type,Owned:Type,Args:Type,Error:Data,Out:Type,Recovery:Type> is Type:
  Completed{world:World,owner:Owned,outcome:T.Outcome<Error>,output:Out,recovery:Recovery}
  RegistrationRejected{world:World,owner:Owned,args:Args}
  TransportFailed{world:World}
def cursor(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),success:Bool,world:W.World<S,Col.Column<S,P>,R,E>,registry:Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>) -> W.World<S,Col.Column<S,P>,R,E> & Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>:
  match success world registry:
    case False{} world registry:(world,registry)
    case True{} W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,+clock} Sys.Registry{rns,id,name,access,_}:
      (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},Sys.Registry{rns,id,name,access,clock})
def done(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),outcome:T.Outcome<Error>,output:Out,capture:Array<Q>,recovery:Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>,result:W.World<S,Col.Column<S,P>,R,E> & Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>) -> Run<W.World<S,Col.Column<S,P>,R,E>,Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,Args,Error,Out,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>:
  match result:
    case (world,registry):Completed{world,Owner{registry,capture},outcome,output,recovery}
def completed(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),result:Sys.RunResult<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>) -> Run<W.World<S,Col.Column<S,P>,R,E>,Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,Args,Error,Out,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>:
  match result:
    case Sys.RegistrationRejected{registry,world,Request{args,capture}}:RegistrationRejected{world,Owner{registry,capture},args}
    case Sys.Completed{registry,Sys.Succeeded{world,Reply{+outcome,output,capture,recovery}}}:done(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body,outcome,output,capture,recovery,cursor(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body,O.succeeded(~Error,outcome),world,registry))
    case Sys.Completed{_,Sys.Failed{world,_}}:TransportFailed{world}
def run(~S:Data,~P:Type,~Q:Type,~R:Type,~E:Data,~identity:Declaration.Declaration<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(~S,~P,~Q,~identity,H) -> Args -> H -> H & (T.Outcome<Error> & Out),owner:Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,world:W.World<S,Col.Column<S,P>,R,E>,args:Args) -> Run<W.World<S,Col.Column<S,P>,R,E>,Owner<Sys.Registry<S,Col.Column<S,P>,R,E,Request<Args,Q>,Unit,Reply<S,P,Q,Error,Out>,runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body)>,Q>,Args,Error,Out,Product.Owner<List<RC.Record<S,P>>,List<A.Record<Q>>>>:
  match owner:
    case Owner{registry,capture}:completed(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body,Sys.run(~S,~Col.Column<S,P>,~R,~E,~Request<Args,Q>,~Unit,~Reply<S,P,Q,Error,Out>,~runner(~S,~P,~Q,~R,~E,~identity,~Args,~Error,~Out,~body),registry,world,Request{args,capture}))
