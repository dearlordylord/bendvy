import Base
import ./world.bend as W
import ./system.bend as Sys
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./world-resource-owner.bend as WR
import ./recovery-journal.bend as Journal
import ./recoverable-array.bend as A
import ./recoverable-array-owner.bend as ArrayOwner
import ./transaction.bend as T
# The ordinary constructor derives both lenses. Gameplay only sees opaque H.
type Frame<State:Type,Recovery:Type> is Type:
  Frame{state:State,journal:List<Journal.Action(~State,~Recovery)>}
type Attempt<H:Type,P:Type> is Type:
  Applied{owner:H}
  Refused{owner:H,replacement:P}
type Write<-S:Data,-P:Type,-identity:Schema.Resource<S,Array<P>>,-H:Type> is Type:
  Write{replace:H -> Array<P> -> H,swap:H -> U32 -> P -> Attempt<H,P>}
def replace_field(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,~H:Type,cap:Write<S,P,identity,H>) -> H -> Array<P> -> H:
  match cap:
    case Write{f,_}:f
def swap_field(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,~H:Type,cap:Write<S,P,identity,H>) -> H -> U32 -> P -> Attempt<H,P>:
  match cap:
    case Write{_,f}:f
def replace(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,~H:Type,~cap:Write<S,P,identity,H>,owner:H,value:Array<P>) -> H:
  replace_field(~S,~P,~identity,~H,cap)(owner,value)
def swap(~S:Data,~P:Type,~identity:Schema.Resource<S,Array<P>>,~H:Type,~cap:Write<S,P,identity,H>,owner:H,index:U32,value:P) -> Attempt<H,P>:
  swap_field(~S,~P,~identity,~H,cap)(owner,index,value)
def release_take(~P:Type,values:List<A.Record<P>>) -> Unit & List<A.Record<P>>:(Unit{},values)
def release_put(~P:Type,unit:Unit,values:List<A.Record<P>>) -> List<A.Record<P>>:values
def release(~P:Type) -> Product.Lens<List<A.Record<P>>,List<A.Record<P>>,Unit>:
  Product.Lens{release_take(~P),release_put(~P)}
def replaced(~S:Data,~C:Type,~P:Type,~E:Data,result:W.World<S,C,Array<P>,E> & List<Journal.Action(~W.World<S,C,Array<P>,E>,~List<A.Record<P>>)>) -> Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>:
  match result:
    case (world,journal):Frame{world,journal}
def frame_replace(~S:Data,~C:Type,~P:Type,~E:Data,owner:Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>,replacement:Array<P>) -> Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>:
  match owner:
    case Frame{world,journal}:replaced(~S,~C,~P,~E,ArrayOwner.replace(~W.World<S,C,Array<P>,E>,~P,~WR.Rest<S,C,Array<P>,E>,~WR.lens(~S,~C,~Array<P>,~E),~List<A.Record<P>>,~Unit,~release(~P),world,journal,replacement))
def swapped(~S:Data,~C:Type,~P:Type,~E:Data,result:ArrayOwner.Attempt<W.World<S,C,Array<P>,E>,List<A.Record<P>>,P>) -> Attempt<Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>,P>:
  match result:
    case ArrayOwner.Applied{world,journal}:Applied{Frame{world,journal}}
    case ArrayOwner.Refused{world,journal,replacement}:Refused{Frame{world,journal},replacement}
def frame_swap(~S:Data,~C:Type,~P:Type,~E:Data,owner:Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>,index:U32,replacement:P) -> Attempt<Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>,P>:
  match owner:
    case Frame{world,journal}:swapped(~S,~C,~P,~E,ArrayOwner.swap(~W.World<S,C,Array<P>,E>,~P,~WR.Rest<S,C,Array<P>,E>,~WR.lens(~S,~C,~Array<P>,~E),~List<A.Record<P>>,~Unit,~release(~P),world,journal,index,replacement))
def grant(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>) -> Write<S,P,identity,Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>>:
  Write{frame_replace(~S,~C,~P,~E),frame_swap(~S,~C,~P,~E)}
def succeeded(~Error:Data,outcome:T.Outcome<Error>) -> Bool:
  match outcome:
    case T.Success{}:True{}
    case T.Failure{_}:False{}
type Reply<Error:Data,Out:Type,P:Type> is Type:
  Reply{outcome:T.Outcome<Error>,output:Out,recovered:List<A.Record<P>>}
def finished(~S:Data,~C:Type,~P:Type,~E:Data,~Error:Data,~Out:Type,outcome:T.Outcome<Error>,output:Out,result:W.World<S,C,Array<P>,E> & List<A.Record<P>>) -> Sys.Outcome<W.World<S,C,Array<P>,E>,Unit,Reply<Error,Out,P>>:
  match result:
    case (world,recovered):Sys.Succeeded{world,Reply{outcome,output,recovered}}
def completing(~S:Data,~C:Type,~P:Type,~E:Data,~Error:Data,~Out:Type,world:W.World<S,C,Array<P>,E>,journal:List<Journal.Action(~W.World<S,C,Array<P>,E>,~List<A.Record<P>>)>,result:T.Outcome<Error> & Out) -> Sys.Outcome<W.World<S,C,Array<P>,E>,Unit,Reply<Error,Out,P>>:
  match result:
    case (+outcome,output):finished(~S,~C,~P,~E,~Error,~Out,outcome,output,Journal.finish(~W.World<S,C,Array<P>,E>,~List<A.Record<P>>,journal,succeeded(~Error,outcome),world,[]))
def returned(~S:Data,~C:Type,~P:Type,~E:Data,~Error:Data,~Out:Type,result:Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,Array<P>,E>,Unit,Reply<Error,Out,P>>:
  match result:
    case (Frame{world,journal},output):completing(~S,~C,~P,~E,~Error,~Out,world,journal,output)
def runner(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,Array<P>,E>,args:Args) -> Sys.Outcome<W.World<S,C,Array<P>,E>,Unit,Reply<Error,Out,P>>:
  returned(~S,~C,~P,~E,~Error,~Out,body(Frame<W.World<S,C,Array<P>,E>,List<A.Record<P>>>,grant(~S,~C,~P,~E,~identity),args,Frame{world,[]}))
def Registry(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out)) -> Type:
  Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>
def define(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,Array<P>,E>,name:String) -> Sys.RegistrationResult<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>:
  Sys.register(~S,~C,~Array<P>,~E,~Args,~Unit,~Reply<Error,Out,P>,~runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body),world,name,[Schema.resource_key(~S,~Array<P>,identity)])
type Run<World:Type,Registry:Type,Args:Type,Error:Data,Out:Type,P:Type> is Type:
  Completed{world:World,registry:Registry,outcome:T.Outcome<Error>,output:Out,recovered:List<A.Record<P>>}
  RegistrationRejected{world:World,registry:Registry,args:Args}
  TransportFailed{world:World,registry:Registry}
def done(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),outcome:T.Outcome<Error>,output:Out,recovered:List<A.Record<P>>,updated:W.World<S,C,Array<P>,E> & Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>) -> Run<W.World<S,C,Array<P>,E>,Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>,Args,Error,Out,P>:
  match updated:
    case (world,registry):Completed{world,registry,outcome,output,recovered}
def completed(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),result:Sys.RunResult<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>) -> Run<W.World<S,C,Array<P>,E>,Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>,Args,Error,Out,P>:
  match result:
    case Sys.RegistrationRejected{registry,world,args}:RegistrationRejected{world,registry,args}
    case Sys.Completed{registry,Sys.Succeeded{world,Reply{+outcome,output,recovered}}}:done(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body,outcome,output,recovered,(world,registry))
    case Sys.Completed{registry,Sys.Failed{world,_}}:TransportFailed{world,registry}
def run(~S:Data,~C:Type,~P:Type,~E:Data,~identity:Schema.Resource<S,Array<P>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),registry:Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>,world:W.World<S,C,Array<P>,E>,args:Args) -> Run<W.World<S,C,Array<P>,E>,Sys.Registry<S,C,Array<P>,E,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body)>,Args,Error,Out,P>:
  completed(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body,Sys.run(~S,~C,~Array<P>,~E,~Args,~Unit,~Reply<Error,Out,P>,~runner(~S,~C,~P,~E,~identity,~Args,~Error,~Out,~body),registry,world,args))
