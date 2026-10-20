import Base
import ./change-tick.bend as Tick
import ./trace-facts.bend as TraceFacts
import ./ordinary-query-declaration.bend as Query
import ./compose.bend as Q
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./ordinary-query-observable.bend as O
import ./inspector.bend as I

# Retain clauses from the same declaration used to execute the registered body.
# This is ordinary registration state, not a caller-supplied debug description.
# Registered ordinary-query system owner retaining its actual Registry,
# authored slot and clauses derived from the operational declaration.
# Contains registration metadata, not a second user-authored debug schema.
type Owner<-S:Data,-Registry:Type> is Type:
  Owner{registry:Registry,slot:String,clauses:List<&2,Query.Clause<S>>}
# Defined returns World and ordinary registration owner; Rejected returns
# World on registration refusal. No system body is executed by definition.
type Defined<-S:Data,-World:Type,-Registry:Type> is Type:
  Defined{world:World,owner:Owner<S,Registry>}
  Rejected{world:World}
# Project ordered component names from declaration clauses as registration
# access metadata. Does not validate runtime identity or grant payload access.
def access(~S:Data,clauses:List<&2,Query.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Query.Clause{name,_} <> rest:name <> access(~S,rest)

def plan_parts(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>) -> Q.Plan<S,C,R,E,Ops>:
  match declaration:
    case Query.Declaration{grant,select,_}:Q.Plan{grant,select}
# Lower a closed ordinary declaration into its operational query plan.
# Grant and row predicate come from that declaration; this performs no scan.
# Trusted setup must keep the declaration consistent with the body Ops.
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out)) -> Q.Plan<S,C,R,E,Ops>:
  plan_parts(~S,~C,~R,~E,~Ops,query)
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,result:Q.Executed<W.World<S,C,R,E>,Q.Error<U>,Out>) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match result:
    case Q.Executed{world,T.Success{},values}:Sys.Succeeded{world,values}
    case Q.Executed{world,T.Failure{error},_}:Sys.Failed{world,error}
# Lower-level query execution with Data arguments and explicit lifecycle
# cursor. Runs the enclosing Compose transaction over selected rows; failure
# reports query error and discards row outputs. This bypasses Registry checks;
# use define/run or App registration for ordinary runtime-bound execution.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,args:A & Maybe<&2,Tick.Tick>) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):completed(~S,~C,~R,~E,~U,~Out,Q.each_since(~S,~C,~R,~E,~Ops,~A,~U,~Out,~plan(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),~body,args,world,cursor))
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,slot,clauses}}
# Register an ordinary query body with access derived from query clauses.
# Returns Defined with World/owner, or Rejected with World. Does not execute
# body or flush deferred commands. Schema/query/body indices must agree.
# Application starting point: examples/scheduled-health/registration.bend.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  registered(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,slot,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Sys.register(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),world,name,access(~S,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query))))
def run_cursor(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,observed:Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & Maybe<&2,Tick.Tick>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match observed:
    case (registry,cursor):(Sys.run(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),registry,world,(args,cursor)),(slot,clauses))
# Execute the registered query using its retained lifecycle cursor.
# Returns System.RunResult plus retained slot/clauses; Registry is inside
# the RunResult and can be rewrapped as Owner. Success advances cursor to
# the captured execution tick; completed failure consumes it too. Row transaction
# rollback and deferred visibility follow Compose/explicit barriers.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),owner:Owner<S,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match owner:
    case Owner{registry,slot,clauses}:run_cursor(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,slot,clauses,Sys.cursor(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body),registry),world,args)

# The same ordinary declaration also retains detached inspection lowering.
# The Registry runner index retains this declaration; execution projects only
# its operational part. Runtime-bound registered inspection is supplied by
# the separate checked Inspector entry points, not this execution adapter.
# Lower only the operational half of an observable query declaration.
# Detached inspection remains separate; writes do not enter Inspector grants.
def observable_plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out)) -> Q.Plan<S,C,R,E,Ops>:
  plan_parts(~S,~C,~R,~E,~Ops,O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query))
# Lower-level observable-declaration query runner with explicit cursor.
# Executes operational grants in the Compose transaction; runtime registration
# validation belongs to observable_run or the derived App dispatch path.
def observable_runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,args:A & Maybe<&2,Tick.Tick>) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):completed(~S,~C,~R,~E,~U,~Out,Q.each_since(~S,~C,~R,~E,~Ops,~A,~U,~Out,~observable_plan(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),~body,args,world,cursor))
def observable_registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,slot,clauses}}
# Register from one observable declaration, deriving operational access
# and retaining its typed runner. Returns Defined or Rejected with World.
# Inspection is a separate read-only route; defining a system reads no rows.
def observable_define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>:
  observable_registered(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,slot,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query)),Sys.register(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),world,name,access(~S,Query.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),O.operational(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),~I.Frame<S,C,R,E>,~V,query)))))
def observable_run_cursor(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Query.Clause<S>>,observed:Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & Maybe<&2,Tick.Tick>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match observed:
    case (registry,cursor):(Sys.run(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),registry,world,(args,cursor)),(slot,clauses))
# Execute the runtime-bound observable query system and retain Registry
# plus slot/clauses in the result. Uses its real cursor, advancing only on
# success. Registration refusal returns unconsumed (args,cursor) with World.
def observable_run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),owner:Owner<S,Sys.Registry<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)>>,world:W.World<S,C,R,E>,args:A) -> Sys.RunResult<S,C,R,E,A & Maybe<&2,Tick.Tick>,Q.Error<U>,List<&2,Out>,observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body)> & (String & List<&2,Query.Clause<S>>):
  match owner:
    case Owner{registry,slot,clauses}:observable_run_cursor(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body,slot,clauses,Sys.cursor(~S,~C,~R,~E,~(A & Maybe<&2,Tick.Tick>),~Q.Error<U>,~List<&2,Out>,~observable_runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),registry),world,args)

def completed_observed(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,result:Q.Executed<W.World<S,C,R,E>,Q.Error<U>,Out> & TraceFacts.State) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>> & TraceFacts.State:
  match result:
    case (executed,trace):(completed(~S,~C,~R,~E,~U,~Out,executed),trace)

# Trusted traced adapter for the same operational query/body and cursor.
# Returns runner outcome with actual transaction facts; does not register
# another system or consume detached Inspector visibility.
def observable_runner_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),trace:TraceFacts.State,world:W.World<S,C,R,E>,args:A & Maybe<&2,Tick.Tick>) -> Sys.Outcome<W.World<S,C,R,E>,Q.Error<U>,List<&2,Out>> & TraceFacts.State:
  match args:
    case (args,cursor):completed_observed(~S,~C,~R,~E,~U,~Out,Q.each_since_observed(~S,~C,~R,~E,~Ops,~A,~U,~Out,~observable_plan(~S,~C,~R,~E,~Ops,~A,~U,~Out,~V,~query,~body),~body,trace,args,world,cursor))
