import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type Owner<-S:Data,-Registry:Type> is Type:
  Owner{registry:Registry,slot:String,clauses:List<&2,Query.Clause<S>>}
type Defined<-S:Data,-World:Type,-Registry:Type> is Type:
  Defined{world:World,owner:Owner<S,Registry>}
  Rejected{world:World}
def access(~S:Data,clauses:List<&2,Query.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Query.Clause{name,_} <> rest:name <> access(~S,rest)

def plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out)) -> Q.Plan<S,C,R,E,Ops>:
  Q.Plan{Query.grant(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Query.selector(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query)}
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,result:Q.Executed<W.World<S,C,R,E>,Q.Error<U>,Out>) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match result:
    case Q.Executed{world,T.Success{},values}:Sys.Succeeded{world,values}
    case Q.Executed{world,T.Failure{error},_}:Sys.Failed{world,error}
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,args:A & U32) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):completed(~S,~C,~R,~E,~U,~Out,Q.each_since(~S,~C,~R,~E,~Ops,~A,~U,~Out,~plan(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),~body,args,world,cursor))
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,slot,clauses}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  registered(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,slot,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Sys.register(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),world,name,access(~S,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query))))
def run_cursor(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,observed:Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & U32,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match observed:
    case (registry,cursor):(Sys.run_tracked(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),registry,world,(args,cursor)),(slot,clauses))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),owner:Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match owner:
    case Owner{registry,slot,clauses}:run_cursor(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,slot,clauses,Sys.cursor(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),registry),world,args)

# Experimental typed transport, not a selected Sch.RunResult error policy.
# Refusal has no body outcome and preserves rejected args/owner/world.
type ScheduleDispatch<-S:Data,-World:Type,-Registry:Type,A:Type,Error:Data,Out:Data> is Type:
  Reached{owner:Owner<S,Registry>,outcome:Sys.Outcome<World,Error,Unit>,values:List<&2,Out>}
  RegistrationRefused{owner:Owner<S,Registry>,world:World,args:A}
def schedule_result(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),result:Sys.RunResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & (String & List<&2,Query.Clause<S>>)) -> ScheduleDispatch<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>,A & U32,Q.Error<U>,Out>:
  match result:
    case (Sys.RegistrationRejected{registry,world,args},(slot,clauses)):RegistrationRefused{Owner{registry,slot,clauses},world,args}
    case (Sys.Completed{registry,Sys.Failed{world,error}},(slot,clauses)):Reached{Owner{registry,slot,clauses},Sys.Failed{world,error},[]}
    case (Sys.Completed{registry,Sys.Succeeded{world,values}},(slot,clauses)):Reached{Owner{registry,slot,clauses},Sys.Succeeded{world,Unit{}},values}
def schedule_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),owner:Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>,world:W.World<S,C,R,E>,args:A) -> ScheduleDispatch<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>,A & U32,Q.Error<U>,Out>:
  schedule_result(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,run(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,owner,world,args))
