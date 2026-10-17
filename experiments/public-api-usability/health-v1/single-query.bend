import Base
import ../../../src/ecs/ordinary-system.bend as O
import ../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/schedule.bend as Sch

# Prototype for ONE registered query system, not a general App replacement.
type ExecutionError<Error:Data> is Data:
  BodyError{error:Q.Error<Error>}
  RegistrationRejected{}
type State<S:Data,C:Type,R:Type,E:Data,-Ops:Type -> Type,A:Data,Error:Data,Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out)> is Type:
  State{owner:O.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<Error>,List<&2,Out>,O.runner(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body)>>,args:A,rows:List<&2,Out>}
type Application<S:Data,C:Type,R:Type,E:Data,-Ops:Type -> Type,A:Data,Error:Data,Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out)> is Type:
  Application{world:W.World<S,C,R,E>,schedule:Sch.Schedule<S,C,R,E,State<S,C,R,E,Ops,A,Error,Out,query,body>>}
type Installation<S:Data,C:Type,R:Type,E:Data,-Ops:Type -> Type,A:Data,Error:Data,Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out)> is Type:
  Installed{app:Application<S,C,R,E,Ops,A,Error,Out,query,body>}
  Refused{world:W.World<S,C,R,E>,owner:Maybe<&1,State<S,C,R,E,Ops,A,Error,Out,query,body>>}
type ExecutionResult<S:Data,C:Type,R:Type,E:Data,-Ops:Type -> Type,A:Data,Error:Data,Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out)> is Type:
  Finished{app:Application<S,C,R,E,Ops,A,Error,Out,query,body>,rows:List<&2,Out>}
  Failed{app:Application<S,C,R,E,Ops,A,Error,Out,query,body>,error:ExecutionError<Error>}
  Rejected{app:Application<S,C,R,E,Ops,A,Error,Out,query,body>}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),args:A,value:Sys.RunResult<S,C,R,E,A & U32,Q.Error<Error>,List<&2,Out>,O.runner(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body)> & (String & List<&2,Decl.Clause<S>>)) -> State<S,C,R,E,Ops,A,Error,Out,query,body> & Sys.Outcome<W.World<S,C,R,E>,ExecutionError<Error>,Unit>:
  match value:
    case (Sys.Completed{registry,Sys.Succeeded{world,+rows}},(slot,clauses)):(State{O.Owner{registry,slot,clauses},args,rows},Sys.Succeeded{world,Unit{}})
    case (Sys.Completed{registry,Sys.Failed{world,error}},(slot,clauses)):(State{O.Owner{registry,slot,clauses},args,[]},Sys.Failed{world,BodyError{error}})
    case (Sys.RegistrationRejected{registry,world,(args,_)},(slot,clauses)):(State{O.Owner{registry,slot,clauses},args,[]},Sys.Failed{world,RegistrationRejected{}})
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),state:State<S,C,R,E,Ops,A,Error,Out,query,body>,world:W.World<S,C,R,E>,_:U32) -> State<S,C,R,E,Ops,A,Error,Out,query,body> & Sys.Outcome<W.World<S,C,R,E>,ExecutionError<Error>,Unit>:
  match state:
    case State{owner,+args,_}:returned(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,args,O.run(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,owner,world,args))
def condition(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,_:U32) -> W.World<S,C,R,E> & Bool:(world,True{})
def plan(barrier:Bool,id:U32) -> List<&2,Sch.Step>:
  match barrier:
    case False{}:[Sch.System{id,0}]
    case True{}:[Sch.Barrier{},Sch.System{id,0}]
def built(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,value:Sch.Build<S,C,R,E,State<S,C,R,E,Ops,A,Error,Out,query,body>>) -> Installation<S,C,R,E,Ops,A,Error,Out,query,body>:
  match value:
    case Sch.Built{schedule}:Installed{Application{world,schedule}}
    case Sch.Invalid{owner}:Refused{world,Some{owner}}
def assemble(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),barrier:Bool,world:W.World<S,C,R,E>,args:A,owner:O.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<Error>,List<&2,Out>,O.runner(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body)>>) -> Installation<S,C,R,E,Ops,A,Error,Out,query,body>:
  match owner:
    case O.Owner{Sys.Registry{+ns,+id,+name,+access,+cursor},+slot,+clauses}:built(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,world,Sch.build(~S,~C,~R,~E,~State<S,C,R,E,Ops,A,Error,Out,query,body>,ns,name,plan(barrier,id),[id],State{O.Owner{Sys.Registry{ns,id,name,access,cursor},slot,clauses},args,[]}))
def defined(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),barrier:Bool,args:A,value:O.Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,A & U32,Q.Error<Error>,List<&2,Out>,O.runner(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body)>>) -> Installation<S,C,R,E,Ops,A,Error,Out,query,body>:
  match value:
    case O.Defined{world,owner}:assemble(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,barrier,world,args,owner)
    case O.Rejected{world}:Refused{world,None{}}
def install(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,args:A,name:String,slot:String,barrier:Bool) -> Installation<S,C,R,E,Ops,A,Error,Out,query,body>:
  defined(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,barrier,args,O.define(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,world,name,slot))
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),value:Sch.RunResult<S,C,R,E,State<S,C,R,E,Ops,A,Error,Out,query,body>,ExecutionError<Error>>) -> ExecutionResult<S,C,R,E,Ops,A,Error,Out,query,body>:
  match value:
    case Sch.Finished{Sch.Schedule{ns,name,steps,State{owner,args,+rows}},world,_}:Finished{Application{world,Sch.Schedule{ns,name,steps,State{owner,args,rows}}},rows}
    case Sch.Failed{schedule,world,error,_}:Failed{Application{world,schedule},error}
    case Sch.Rejected{schedule,world}:Rejected{Application{world,schedule}}
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),value:Application<S,C,R,E,Ops,A,Error,Out,query,body>) -> ExecutionResult<S,C,R,E,Ops,A,Error,Out,query,body>:
  match value:
    case Application{world,schedule}:completed(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,Sch.run(~S,~C,~R,~E,~State<S,C,R,E,Ops,A,Error,Out,query,body>,~ExecutionError<Error>,~dispatch(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body),~condition(~S,~C,~R,~E),schedule,world))
def replan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<Error> & Out),value:Application<S,C,R,E,Ops,A,Error,Out,query,body>,barrier:Bool) -> Installation<S,C,R,E,Ops,A,Error,Out,query,body>:
  match value:
    case Application{world,Sch.Schedule{_,_,_,State{owner,args,_}}}:assemble(~S,~C,~R,~E,~Ops,~A,~Error,~Out,~query,~body,barrier,world,args,owner)
