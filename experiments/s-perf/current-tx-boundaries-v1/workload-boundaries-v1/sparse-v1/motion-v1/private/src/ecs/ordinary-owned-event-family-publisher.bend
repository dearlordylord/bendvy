import Base
import trace-facts.bend as Facts
import world.bend as W
import system.bend as Sys
import transaction.bend as T
import owned-event-journal.bend as Journal
import ordinary-owned-event-declaration.bend as D
# Standalone publisher runs once, including worlds without entities. Actual log
# owners enter the world only after success; failure returns the typed receipt.
type Reply<Error:Data,Out:Type,Recovery:Type> is Type:
  Reply{outcome:T.Outcome<Error>,output:Out,recovered:Recovery}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Error:Data,~Out:Type,outcome:T.Outcome<Error>,output:Out,result:W.World<S,C,R,E> & Recovery) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>>:
  match result:
    case (world,recovered):Sys.Succeeded{world,Reply{outcome,output,recovered}}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Error:Data,~Out:Type,world:W.World<S,C,R,E>,recovery:Recovery,result:Journal.Stage<W.World<S,C,R,E>,Recovery> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>>:
  match result:
    case (stage,(T.Success{},output)):finished(~S,~C,~R,~E,~Recovery,~Error,~Out,T.Success{},output,Journal.finish(~W.World<S,C,R,E>,~Recovery,stage,True{},world,recovery))
    case (stage,(T.Failure{error},output)):finished(~S,~C,~R,~E,~Recovery,~Error,~Out,T.Failure{error},output,Journal.finish(~W.World<S,C,R,E>,~Recovery,stage,False{},world,recovery))
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:Ops(J) -> Args -> J -> J & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>>:
  returned(~S,~C,~R,~E,~Recovery,~Error,~Out,world,D.empty(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder,declaration)(Unit{}),body(Journal.Stage<W.World<S,C,R,E>,Recovery>,D.root_grant(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder),args,Journal.empty(~W.World<S,C,R,E>,~Recovery)))
def Registry(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:Ops(J) -> Args -> J -> J & (T.Outcome<Error> & Out)) -> Type:Sys.Registry<S,C,R,E,Args,Unit,Reply<Error,Out,Recovery>,runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:Ops(J) -> Args -> J -> J & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,name:String) -> Sys.RegistrationResult<S,C,R,E,Args,Unit,Reply<Error,Out,Recovery>,runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>:
  Sys.register(~S,~C,~R,~E,~Args,~Unit,~Reply<Error,Out,Recovery>,~runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body),world,name,D.access(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder,declaration))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:Ops(J) -> Args -> J -> J & (T.Outcome<Error> & Out),registry:Sys.Registry<S,C,R,E,Args,Unit,Reply<Error,Out,Recovery>,runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>,world:W.World<S,C,R,E>,args:Args) -> Sys.RunResult<S,C,R,E,Args,Unit,Reply<Error,Out,Recovery>,runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>:
  Sys.run(~S,~C,~R,~E,~Args,~Unit,~Reply<Error,Out,Recovery>,~runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body),registry,world,args)

def finished_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Error:Data,~Out:Type,outcome:T.Outcome<Error>,output:Out,result:(W.World<S,C,R,E> & Recovery) & Facts.State) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>> & Facts.State:
  match result:
    case ((world,recovered),trace):(Sys.Succeeded{world,Reply{outcome,output,recovered}},trace)
def returned_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Error:Data,~Out:Type,world:W.World<S,C,R,E>,recovery:Recovery,result:Journal.Stage<W.World<S,C,R,E>,Recovery> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>> & Facts.State:
  match result:
    case (stage,(T.Success{},output)):finished_observed(~S,~C,~R,~E,~Recovery,~Error,~Out,T.Success{},output,Journal.finish_observed(~W.World<S,C,R,E>,~Recovery,stage,True{},world,recovery))
    case (stage,(T.Failure{error},output)):finished_observed(~S,~C,~R,~E,~Recovery,~Error,~Out,T.Failure{error},output,Journal.finish_observed(~W.World<S,C,R,E>,~Recovery,stage,False{},world,recovery))
def runner_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-J:Type -> @-caps:Ops(J) -> Args -> J -> J & (T.Outcome<Error> & Out),trace:Facts.State,world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Out,Recovery>> & Facts.State:
  returned_observed(~S,~C,~R,~E,~Recovery,~Error,~Out,world,D.empty(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder,declaration)(Unit{}),body(Journal.Stage<W.World<S,C,R,E>,Recovery>,D.root_grant(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder),args,Journal.with_trace(~W.World<S,C,R,E>,~Recovery,trace)))
