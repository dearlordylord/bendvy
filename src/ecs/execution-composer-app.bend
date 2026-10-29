import Base
import ./dependency-composer-program.bend as Scoped
import ./dependency-registry-program.bend as Prog
import ./execution-composer-layout.bend as Layout
import ./execution-composer-schema.bend as Schema
import ./world.bend as W
import ./dependency-composer.bend as Compose
import ./dependency-application.bend as DependencyApp
import ./dependency-registration.bend as Reg
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./schema-fragments.bend as Fragment

type Composed<-S:Data,-World:Type,-Owners:Type,-Provisions:Type,-Guards:Type,-Handler:Type,-Error:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),-guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),-handle:Handler -> Error -> Handler & Exec.Handling> is Type:
  Composed{application:DependencyApp.Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>,fragment:Fragment.Fragment<S,Provisions>,invalid:Maybe<&2,Compose.Error>}
type CompositionReport<Error:Data,Out:Data> is Data:
  CompositionRan{report:DependencyApp.Report<Error,Out>}
  CompositionRejected{error:Compose.Error}

def trusted_add_error(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,error:Maybe<&2,Compose.Error>,value:Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  match value:
    case Composed{application,fragment,invalid}:Composed{application,fragment,Compose.first_error(error,invalid)}
def nesting_error(value:Maybe<&2,Scoped.NestError>) -> Maybe<&2,Compose.Error>:
  match value:
    case None{}:None{}
    case Some{error}:Some{Compose.Nesting{error}}
def guard_needs(~S:Data,~World:Type,~Guards:Type,~Error:Data,~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),guards:Reg.ConditionRegistry<World,Guards,Error,guardDispatch>,entries:List<&2,Fragment.Entry<S>>) -> Reg.ConditionRegistry<World,Guards,Error,guardDispatch> & Maybe<&2,Compose.Error>:
  match guards:
    case Reg.ConditionRegistry{Reg.Registry{owners,+nodes},+invalid}:(Reg.ConditionRegistry{Reg.Registry{owners,nodes},invalid},Compose.first_error(Compose.schedule_error(invalid),Compose.schedule_error(Compose.missing(~S,nodes,entries))))
def trusted_build_lowered(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,world:World,provisions:Provisions,handler:Handler,guards:Reg.ConditionRegistry<World,Guards,Error,guardDispatch>,bindings:List<&2,DependencyApp.Binding>,+entries:List<&2,Fragment.Entry<S>>,nested:Scoped.Nesting,registry:Reg.Registry<World,Owners,Error,Out,dispatch>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  match nested registry:
    case Scoped.Nesting{edges,invalid} Reg.Registry{owners,+nodes}:Composed{DependencyApp.trusted_build_checked(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,~Compose.available,world,Reg.Registry{owners,nodes},guards,handler,edges,bindings),Fragment.Fragment{entries,provisions},Compose.first_error(nesting_error(invalid),Compose.first_error(Compose.schema_error(Fragment.validate(~S,entries)),Compose.schedule_error(Compose.missing(~S,nodes,entries))))}
def trusted_build_guarded(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,world:World,provisions:Provisions,handler:Handler,bindings:List<&2,DependencyApp.Binding>,entries:List<&2,Fragment.Entry<S>>,nested:Scoped.Nesting,registry:Reg.Registry<World,Owners,Error,Out,dispatch>,checked:Reg.ConditionRegistry<World,Guards,Error,guardDispatch> & Maybe<&2,Compose.Error>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  match checked:
    case (guards,invalid):trusted_add_error(~S,~World,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,invalid,trusted_build_lowered(~S,~World,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,world,provisions,handler,guards,bindings,entries,nested,registry))
def trusted_build_scoped(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,world:World,provisions:Provisions,handler:Handler,guards:Reg.ConditionRegistry<World,Guards,Error,guardDispatch>,bindings:List<&2,DependencyApp.Binding>,+entries:List<&2,Fragment.Entry<S>>,groups:List<&2,Scoped.Nested>,compiled:Scoped.Compiled<World,Owners,Error,Out,dispatch>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  match compiled:
    case Scoped.Compiled{registry,scope}:trusted_build_guarded(~S,~World,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,world,provisions,handler,bindings,entries,Scoped.nested(groups,scope),registry,guard_needs(~S,~World,~Guards,~Error,~guardDispatch,guards,entries))
def build(~S:Data,~C:Type,~R:Type,~E:Data,~components:Layout.Layout,~resources:Layout.Layout,~sameC:{C == Layout.columns(~S,components) : Type},~sameR:{R == Layout.resources(~S,resources) : Type},~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> W.World<S,C,R,E> -> U32 -> Owners & (W.World<S,C,R,E> & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> W.World<S,C,R,E> -> U32 -> Guards & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,~systemSelection:Prog.Selection(~W.World<S,C,R,E>,~Owners,~Error,~Out,~dispatch),~guardSelection:Prog.Selection(~W.World<S,C,R,E>,~Guards,~Error,~Bool,~guardDispatch),world:W.World<S,C,R,E>,owners:Owners,guards:Guards,handler:Handler,provisions:Provisions,groups:List<&2,Scoped.Nested>,bindings:List<&2,DependencyApp.Binding>) -> Composed<S,W.World<S,C,R,E>,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  trusted_build_scoped(~S,~W.World<S,C,R,E>,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,world,provisions,handler,Prog.compile_conditions(~W.World<S,C,R,E>,~Guards,~Error,~guardDispatch,~guardSelection,guards),bindings,Schema.inventory(~S,~components,~resources),groups,Scoped.compile(~W.World<S,C,R,E>,~Owners,~Error,~Out,~dispatch,~systemSelection,owners))
def run_returned(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,fragment:Fragment.Fragment<S,Provisions>,invalid:Maybe<&2,Compose.Error>,result:DependencyApp.Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & DependencyApp.Report<Error,Out>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & CompositionReport<Error,Out>:
  match result:
    case (application,report):(Composed{application,fragment,invalid},CompositionRan{report})
def run_checked(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,invalid:Maybe<&2,Compose.Error>,application:DependencyApp.Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>,fragment:Fragment.Fragment<S,Provisions>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & CompositionReport<Error,Out>:
  match invalid:
    case Some{+error}:(Composed{application,fragment,Some{error}},CompositionRejected{error})
    case None{}:run_returned(~S,~World,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,fragment,None{},DependencyApp.run(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,application))
def run(~S:Data,~World:Type,~Owners:Type,~Provisions:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,composed:Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>) -> Composed<S,World,Owners,Provisions,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & CompositionReport<Error,Out>:
  match composed:
    case Composed{application,fragment,invalid}:run_checked(~S,~World,~Owners,~Provisions,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,invalid,application,fragment)
