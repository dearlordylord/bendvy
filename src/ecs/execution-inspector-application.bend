import Base
import ./inspector.bend as I
import ./world.bend as W
import ./dependency-application.bend as State
import ./execution-parallel-root-application.bend as App
import ./dependency-plan.bend as Plan
import ./execution-parallel-registration.bend as Registration
import ./check.bend as Check

# The actual schedule, captures, guard owners and pending-command owners stay
# outside the opaque Inspector frame. Neither bindings list is reconstructed.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Guards:Type,~Handler:Type,~U:Data,~Out:Data,owners:Owners,guards:Guards,handler:Handler,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:App.Deferred,result:I.Observed<S,C,R,E,U,Out>) -> App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & (I.Instance<S> & Result<&2,&2,U,Out>):
  match result:
    case I.Observed{world,instance,result}:(App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred},(instance,result))
def passive(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Guards:Type,~Handler:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:I.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,application:App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>>,instance:I.Instance<S>,args:A) -> App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & (I.Instance<S> & Result<&2,&2,U,Out>):
  match application:
    case App.Scheduled{State.State{world,owners,guards,handler,stateBindings},schedule,bindings,rules,deferred}:returned(~S,~C,~R,~E,~Owners,~Guards,~Handler,~U,~Out,owners,guards,handler,stateBindings,schedule,bindings,rules,deferred,I.passive(~S,~C,~R,~E,~Ops,~A,~U,~Out,~plan,~body,instance,args,world))
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Guards:Type,~Handler:Type,owners:Owners,guards:Guards,handler:Handler,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:App.Deferred,result:Check.Checked<S,C,R,E>) -> App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & Result<&2,&2,Check.Error,Bool>:
  match result:
    case Check.Checked{world,result}:(App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred},result)
def check(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Guards:Type,~Handler:Type,~Ops:Type -> Type,~A:Data,~plan:Check.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,application:App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>>,args:A) -> App.Scheduled<State.State<W.World<S,C,R,E>,Owners,Guards,Handler>> & Result<&2,&2,Check.Error,Bool>:
  match application:
    case App.Scheduled{State.State{world,owners,guards,handler,stateBindings},schedule,bindings,rules,deferred}:checked(~S,~C,~R,~E,~Owners,~Guards,~Handler,owners,guards,handler,stateBindings,schedule,bindings,rules,deferred,Check.run(~S,~C,~R,~E,~Ops,~A,~body,~plan,args,world))
