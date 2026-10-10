import Base
import ./observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import ../automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
# All descriptions and resource observations are generated at ordinary registration.
# Resource observation borrows only the App-owned World; it never starts a Tx.
def value_previous(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,~render:V -> String,key:String,previous:App.Observation<Rows>,world:W.World<S,C,R,E>,+value:V) -> W.World<S,C,R,E> & App.Observation<App.Product<Rows,V>>:
  match previous:
    case App.Observation{rows,rendered}:(world,App.Observation{App.Product{rows,value},List.append(&2,String,rendered,[key ++ "=" ++ render(value)])})
def value_joined(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,~render:V -> String,key:String,previous:App.Observation<Rows>,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & App.Observation<App.Product<Rows,V>>:
  match result:
    case (world,value):value_previous(~S,~C,~R,~E,~Rows,~V,~render,key,previous,world,value)
def previous_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,~render:V -> String,~key:String,result:W.World<S,C,R,E> & App.Observation<Rows>) -> W.World<S,C,R,E> & App.Observation<App.Product<Rows,V>>:
  match result:
    case (world,previous):value_joined(~S,~C,~R,~E,~Rows,~V,~render,key,previous,observe(world))
def append_fold(~S:Data,~C:Type,~R:Type,~E:Data,~Rows:Data,~V:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,~render:V -> String,~key:String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & App.Observation<App.Product<Rows,V>>:
  previous_observed(~S,~C,~R,~E,~Rows,~V,~observe,~render,~key,fold(world))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,result:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & List<&2,Query.Clause<S>>) -> P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & App.Binding<S>:
  match result:
    case (P.Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor},+slot},clauses):(P.Owner{Sys.Registry{namespace,id,name,access,cursor},slot},App.Binding{namespace,id,name,access,cursor,slot,clauses})
def actual_description(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,owner:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & App.Binding<S>:
  described(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,P.describe(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,owner))
def description_tail(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,previous:H,values:List<&2,App.Binding<S>>,result:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & App.Binding<S>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>:
  match result:
    case (owner,value):((previous,owner),List.append(&2,App.Binding<S>,values,[value]))
def description_previous(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,owner:P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,result:H & List<&2,App.Binding<S>>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>:
  match result:
    case (previous,values):description_tail(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,~H,previous,values,actual_description(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,owner))
def append_description(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,~describe:H -> H & List<&2,App.Binding<S>>,owners:H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>:
  match owners:
    case (previous,owner):description_previous(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,~H,owner,describe(previous))
# Exact transport of the already-existing operational discriminants.
type RunResult<-Application:Type,-Args:Type,-Error:Data,-Out:Type> is Type:
  Completed{app:Application,outcome:Sys.Outcome<Unit,Error,Out>}
  RegistrationRejected{app:Application,args:Args}
def outcome_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~describe:(H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>,owners:H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,debug:Bool,result:Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> RunResult<App.ApplicationType<S,C,R,E,H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,Rows,fold,describe>,Args,Error,Out>:
  match result:
    case Sys.Succeeded{world,output}:Completed{App.Application{world,owners,debug},Sys.Succeeded{Unit{},output}}
    case Sys.Failed{world,error}:Completed{App.Application{world,owners,debug},Sys.Failed{Unit{},error}}
def run_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~describe:(H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>,previous:H,debug:Bool,result:Sys.RunResult<S,C,R,E,Args,Error,Out,runner> & String) -> RunResult<App.ApplicationType<S,C,R,E,H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,Rows,fold,describe>,Args,Error,Out>:
  match result:
    case (Sys.Completed{registry,outcome},slot):outcome_returned(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,~H,~Rows,~fold,~describe,(previous,P.Owner{registry,slot}),debug,outcome)
    case (Sys.RegistrationRejected{registry,world,args},slot):RegistrationRejected{App.Application{world,(previous,P.Owner{registry,slot}),debug},args}
def run_latest_resource(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~describe:(H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> (H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) & List<&2,App.Binding<S>>,app:App.ApplicationType<S,C,R,E,H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,Rows,fold,describe>,args:Args) -> RunResult<App.ApplicationType<S,C,R,E,H & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,Rows,fold,describe>,Args,Error,Out>:
  match app:
    case App.Application{world,(previous,owner),debug}:run_returned(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,~H,~Rows,~fold,~describe,previous,debug,P.run(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,owner,world,args))
def registered_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~V:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,~render:V -> String,~key:String,~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<S>>,~Output:Type,~done:@-Previous:Type -> @-Observed:Data -> @-mode:Query.Mode -> @-run:(W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> @-fold:(W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Observed>) -> @-describe:((Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>) -> (Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>) & List<&2,App.Binding<S>>) -> App.ApplicationType<S,C,R,E,Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>,Observed,fold,describe> -> Output,~failed:App.ApplicationType<S,C,R,E,H,Rows,fold,describe> -> Output,owners:H,debug:Bool,result:P.Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> Output:
  match result:
    case P.Rejected{world}:failed(App.Application{world,owners,debug})
    case P.Defined{world,owner}:done(H,App.Product<Rows,V>,kind,runner,append_fold(~S,~C,~R,~E,~Rows,~V,~fold,~observe,~render,~key),append_description(~S,~C,~R,~E,~Args,~Error,~Out,~kind,~runner,~H,~describe),App.Application{world,(owners,owner),debug})
def register_resource_with(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,~body:@-Context:Type -> @-caps:Ops(Context) -> Args -> Context -> Context & (T.Outcome<Error> & Out),~H:Type,~Rows:Data,~fold:W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<S>>,~Output:Type,~done:@-Previous:Type -> @-Observed:Data -> @-mode:Query.Mode -> @-run:(W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> @-fold:(W.World<S,C,R,E> -> W.World<S,C,R,E> & App.Observation<Observed>) -> @-describe:((Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>) -> (Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>) & List<&2,App.Binding<S>>) -> App.ApplicationType<S,C,R,E,Previous & P.Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,mode>,Observed,fold,describe> -> Output,~failed:App.ApplicationType<S,C,R,E,H,Rows,fold,describe> -> Output,app:App.ApplicationType<S,C,R,E,H,Rows,fold,describe>,name:String,slot:String) -> Output:
  match app:
    case App.Application{world,owners,debug}:registered_with(~S,~C,~R,~E,~Args,~Error,~Out,~P.mode(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),D.ordinary(~S,~C,~R,~E,~Ops,~V,declaration)),~P.runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~V,declaration),~body),~V,~D.observer(~S,~C,~R,~E,~Ops,~V,declaration),~D.presenter(~S,~C,~R,~E,~Ops,~V,declaration),~D.name(~S,~C,~R,~E,~Ops,~V,declaration),~H,~Rows,~fold,~describe,~Output,~done,~failed,owners,debug,P.define(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~V,declaration),~body,world,name,slot))
