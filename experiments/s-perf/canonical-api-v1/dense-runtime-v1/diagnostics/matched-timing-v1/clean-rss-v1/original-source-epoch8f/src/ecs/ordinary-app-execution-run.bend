import Base
import ./machine-handler-context.bend as HandlerContext
import ./machine-handler-engine.bend as HandlerEngine
import ./machine-handlers.bend as Handlers
import ./machine.bend as Machine
import ./machine-world.bend as MachineWorld
import ./ordinary-machine-declaration.bend as MachineDecl
import ./ordinary-owned-event-family-publisher.bend as Publisher
import ./ordinary-owned-event-declaration.bend as Events
import ./execution-context.bend as Ctx
import ./trace-facts.bend as Facts
import ./system.bend as Sys
import ./world.bend as W
import ./ordinary-app-registration-run.bend as Run
import ./transaction.bend as T
import ./ordinary-resource-field-system.bend as Field
import ./ordinary-app-resource-field-declaration.bend as D
import ./ordinary-system.bend as Component
import ./ordinary-query-observable.bend as O
import ./compose.bend as Q
import ./inspector.bend as I
import ./ordinary-app-registration-fields.bend as Records
def outcome(~World:Type,~Error:Data,~Out:Type,trace:Facts.State,result:Sys.Outcome<World,Error,Out>) -> Sys.Outcome<Ctx.Context<World>,Error,Out>:
  match result:
    case Sys.Succeeded{world,output}:Sys.Succeeded{Ctx.Context{world,trace},output}
    case Sys.Failed{world,error}:Sys.Failed{Ctx.Context{world,trace},error}
def returned(~S:Data,~World:Type,~Args:Type,~Error:Data,~Out:Type,~Token:Type,result:Run.TransportResult<S,World,Args,Error,Out,Token> & Facts.State) -> Run.TransportResult<S,Ctx.Context<World>,Args,Error,Out,Token>:
  match result:
    case (Run.Completed{token,fields,value},trace):Run.Completed{token,fields,outcome(~World,~Error,~Out,trace,value)}
    case (Run.RegistrationRejected{token,fields,world,args},trace):Run.RegistrationRejected{token,fields,Ctx.Context{world,trace},args}

# Fact-producing runner and normal Registry share the same declaration/body.
def resource_transport(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),token:Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>>,fields:Records.Fields<S>,trace:Facts.State,world:W.World<S,C,R,E>,args:Args) -> Run.TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>>> & Facts.State:
  Run.run_observed(~S,~C,~R,~E,~Args,~Error,~Out,~Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Field.runner_observed(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),token,fields,trace,world,args)
def component_transport(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~Value:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),token:Records.Token<Sys.Registry<S,C,R,E,Args & U32,Q.Error<Error>,List<&2,Out>,Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body)>>,fields:Records.Fields<S>,trace:Facts.State,world:W.World<S,C,R,E>,args:Args) -> Run.TransportResult<S,W.World<S,C,R,E>,Args & U32,Q.Error<Error>,List<&2,Out>,Records.Token<Sys.Registry<S,C,R,E,Args & U32,Q.Error<Error>,List<&2,Out>,Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body)>>> & Facts.State:
  match fields:
    case Records.Fields{namespace,id,name,access,+cursor,slot,clauses,kind}:Run.run_observed(~S,~C,~R,~E,~(Args & U32),~Q.Error<Error>,~List<&2,Out>,~Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body),~Component.observable_runner_observed(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body),token,Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind},trace,world,(args,cursor))

def resource_field(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),token:Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>>,fields:Records.Fields<S>,context:Ctx.Context<W.World<S,C,R,E>>,args:Args) -> Run.TransportResult<S,Ctx.Context<W.World<S,C,R,E>>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>>>:
  match context:
    case Ctx.Context{world,trace}:returned(~S,~W.World<S,C,R,E>,~Args,~Error,~Out,~Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,Field.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>>,resource_transport(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~declaration,~body,token,fields,trace,world,args))

def component(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~Value:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),token:Records.Token<Sys.Registry<S,C,R,E,Args & U32,Q.Error<Error>,List<&2,Out>,Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body)>>,fields:Records.Fields<S>,context:Ctx.Context<W.World<S,C,R,E>>,args:Args) -> Run.TransportResult<S,Ctx.Context<W.World<S,C,R,E>>,Args & U32,Q.Error<Error>,List<&2,Out>,Records.Token<Sys.Registry<S,C,R,E,Args & U32,Q.Error<Error>,List<&2,Out>,Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body)>>>:
  match context:
    case Ctx.Context{world,trace}:returned(~S,~W.World<S,C,R,E>,~(Args & U32),~Q.Error<Error>,~List<&2,Out>,~Records.Token<Sys.Registry<S,C,R,E,Args & U32,Q.Error<Error>,List<&2,Out>,Component.observable_runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body)>>,component_transport(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~Value,~query,~body,token,fields,trace,world,args))

def publisher(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~EventOps:Type -> Type,~builder:Events.Builder(~W.World<S,C,R,E>,~Recovery,~EventOps),~declaration:Events.Declaration<S,W.World<S,C,R,E>,Recovery,EventOps,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:EventOps(J) -> Args -> J -> J & (T.Outcome<Error> & Out),token:Records.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~EventOps,~builder,~declaration,~Args,~Error,~Out,~body)>,fields:Records.Fields<S>,context:Ctx.Context<W.World<S,C,R,E>>,args:Args) -> Run.TransportResult<S,Ctx.Context<W.World<S,C,R,E>>,Args,Unit,Publisher.Reply<Error,Out,Recovery>,Records.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~EventOps,~builder,~declaration,~Args,~Error,~Out,~body)>>:
  match context:
    case Ctx.Context{world,trace}:returned(~S,~W.World<S,C,R,E>,~Args,~Unit,~Publisher.Reply<Error,Out,Recovery>,~Records.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~EventOps,~builder,~declaration,~Args,~Error,~Out,~body)>,Run.run_observed(~S,~C,~R,~E,~Args,~Unit,~Publisher.Reply<Error,Out,Recovery>,~Publisher.runner(~S,~C,~R,~E,~Recovery,~EventOps,~builder,~declaration,~Args,~Error,~Out,~body),~Publisher.runner_observed(~S,~C,~R,~E,~Recovery,~EventOps,~builder,~declaration,~Args,~Error,~Out,~body),token,fields,trace,world,args))

def handlers_resource_field(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~K:Data,~MachineV:Data,~take:R -> R & Machine.Slot<S,K,MachineV>,~put:R -> Machine.Slot<S,K,MachineV> -> R,~machine:MachineDecl.Declaration<S,K,MachineV,R,take>,~same:MachineV -> MachineV -> Bool,~publish:W.World<S,C,R,E> -> Machine.Transition<MachineV> -> W.World<S,C,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> Handlers.Invocation<MachineV> -> H -> H & (T.Outcome<String> & Unit),owners:Handlers.Owners<S,C,R,E,MachineV,Field.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,context:Ctx.Context<W.World<S,C,R,E>>,captured:Machine.Snapshot<MachineV>) -> HandlerEngine.HandlerResult<Ctx.Context<W.World<S,C,R,E>>,Handlers.Entry<S,C,R,E,MachineV,Field.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,Handlers.Phase>:
  HandlerContext.run(~S,~C,~R,~E,~MachineV,~Field.runner(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Field.runner_observed(~S,~C,~R,~E,~Ops,~Handlers.Invocation<MachineV>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~K,~MachineWorld.take(~S,~K,~MachineV,~C,~R,~E,~take),~MachineWorld.put(~S,~K,~MachineV,~C,~R,~E,~put),~publish,~same,~MachineDecl.name(~S,~K,~MachineV,~R,~take,machine),owners,context,captured)
