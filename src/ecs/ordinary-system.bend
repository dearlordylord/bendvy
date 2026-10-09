import Base
import ./ordinary-query-declaration.bend as Query
import ./compose.bend as Q
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./ordinary-query-observable.bend as O
import ./inspector.bend as I

# Retain clauses from the same declaration used to execute the registered body.
# This is ordinary registration state, not a caller-supplied debug description.
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

# The same ordinary declaration also retains detached inspection lowering.
# The Registry runner index retains this declaration; execution projects only
# its operational part. Registered inspection awaits the existing foreign-world
# association/refusal decision; no debug refusal policy is selected here.
def observable_plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out)) -> Q.Plan<S,C,R,E,Ops>:
  Q.Plan{Query.grant(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query)),Query.selector(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query))}
def observable_runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,args:A & U32) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):completed(~S,~C,~R,~E,~U,~Out,Q.each_since(~S,~C,~R,~E,~Ops,~A,~U,~Out,~observable_plan(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),~body,args,world,cursor))
def observable_registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,slot,clauses}}
def observable_define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>:
  observable_registered(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,slot,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query)),Sys.register(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),world,name,access(~S,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query)))))
def observable_run_cursor(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,observed:Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & U32,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match observed:
    case (registry,cursor):(Sys.run_tracked(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),registry,world,(args,cursor)),(slot,clauses))
def observable_run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),owner:Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match owner:
    case Owner{registry,slot,clauses}:observable_run_cursor(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,slot,clauses,Sys.cursor(~S,~C,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),registry),world,args)
