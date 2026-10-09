import Base
import ./declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import ../capability.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

type Defined<World:Type,Owner:Type> is Type:
  Defined{world:World,owner:Owner}
  Rejected{world:World}
type Args<S:Data,A:Type> is Type:
  Args{target:W.Handle<S>,input:A}
type Invocation<S:Data,A:Type,D:Data> is Type:
  Invocation{args:Args<S,A>,declaration:D}
type Owner<S:Data,Registry:Type,D:Data> is Type:
  Owner{ordinary:Ordinary.Owner<S,Registry>,declaration:D}
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~U:Type,result:Public.Frame<S,(W.World<S,C,R,E> & W.Handle<S>),P,identity,project> & U) -> Sys.Outcome<W.World<S,C,R,E>,Unit,U>:
  match result:
    case (Public.Frame{(world,_),_},value):Sys.Succeeded{world,value}
# Non-failing body only; operation refusals stay owned outputs.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Public.Input<S,P>,Public.Output<S,P,O>> -> A -> H -> H & U,world:W.World<S,C,R,E>,invocation:Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>) -> Sys.Outcome<W.World<S,C,R,E>,Unit,U>:
  match invocation:
    case Invocation{Args{target,input},declaration}:completed(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~U,Public.invoke(~S,~(W.World<S,C,R,E> & W.Handle<S>),~P,~O,~A,~U,~identity,~project,~admit,~body,Decl.constructed(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,declaration),(world,target),input))
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Public.Input<S,P>,Public.Output<S,P,O>> -> A -> H -> H & U,+declaration:Decl.Declaration<S,C,R,E,P,O,identity,project,admit>,slot:String,result:Sys.RegistrationResult<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>) -> Defined<W.World<S,C,R,E>,Owner<S,Sys.Registry<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{Ordinary.Owner{registry,slot,Decl.clauses(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,declaration)},declaration}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Public.Input<S,P>,Public.Output<S,P,O>> -> A -> H -> H & U,+declaration:Decl.Declaration<S,C,R,E,P,O,identity,project,admit>,world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<W.World<S,C,R,E>,Owner<S,Sys.Registry<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>>:
  registered(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body,declaration,slot,Sys.register(~S,~C,~R,~E,~Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,~Unit,~U,~runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body),world,name,Decl.access(~S,Decl.clauses(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,declaration))))
type Returned<Owner:Type,World:Type,A:Type,U:Type> is Type:
  Completed{owner:Owner,outcome:Sys.Outcome<World,Unit,U>}
  RegistrationRejected{owner:Owner,world:World,args:A}
def run_result(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Public.Input<S,P>,Public.Output<S,P,O>> -> A -> H -> H & U,slot:String,clauses:List<&2,Query.Clause<S>>,+declaration:Decl.Declaration<S,C,R,E,P,O,identity,project,admit>,result:Sys.RunResult<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>) -> Returned<Owner<S,Sys.Registry<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,W.World<S,C,R,E>,Args<S,A>,U>:
  match result:
    case Sys.Completed{registry,outcome}:Completed{Owner{Ordinary.Owner{registry,slot,clauses},declaration},outcome}
    case Sys.RegistrationRejected{registry,world,Invocation{args,_}}:RegistrationRejected{Owner{Ordinary.Owner{registry,slot,clauses},declaration},world,args}
def run(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,~A:Type,~U:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Public.Input<S,P>,Public.Output<S,P,O>> -> A -> H -> H & U,owner:Owner<S,Sys.Registry<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,world:W.World<S,C,R,E>,args:Args<S,A>) -> Returned<Owner<S,Sys.Registry<S,C,R,E,Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,Unit,U,runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body)>,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,W.World<S,C,R,E>,Args<S,A>,U>:
  match owner:
    case Owner{Ordinary.Owner{registry,slot,clauses},+declaration}:run_result(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body,slot,clauses,declaration,Sys.run(~S,~C,~R,~E,~Invocation<S,A,Decl.Declaration<S,C,R,E,P,O,identity,project,admit>>,~Unit,~U,~runner(~S,~C,~R,~E,~P,~O,~identity,~project,~admit,~A,~U,~body),registry,world,Invocation{args,declaration}))
