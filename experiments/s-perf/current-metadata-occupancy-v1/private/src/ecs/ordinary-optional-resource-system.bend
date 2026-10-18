import Base
import ./ordinary-optional-resource-declaration.bend as D
import ./ordinary-resource-field-system.bend as Field
import ./world.bend as W
import ./transaction.bend as T
import ./check.bend as K
import ./system.bend as Sys
import ./ordinary-query-declaration.bend as Q
# Existing transaction body is reached only after the declared slot preflight.
def preflighted(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~Out:Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<K.Error> & Out),args:Args,result:W.World<S,C,R,E> & List<&2,String>) -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>:
  match result:
    case (world,[]):Field.runner(~S,~C,~R,~E,~Ops,~Args,~K.Error,~Out,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body,world,args)
    case (world,missing):Sys.Failed{world,K.MissingRuntimeRequirements{missing}}
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~Out:Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<K.Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>:
  preflighted(~S,~C,~R,~E,~Ops,~Args,~Out,~Value,~declaration,~body,args,D.preflight(~S,~C,~R,~E,~Ops,~Value,declaration,world))
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Type,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,~clauses:List<&2,Q.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,Args,K.Error,Out,run>) -> Field.Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,K.Error,Out,run>,clauses>:
  match result:
    case Sys.RegistrationFailed{world}:Field.Rejected{world}
    case Sys.Registered{world,registry}:Field.Defined{world,Field.Owner{registry}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~Out:Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<K.Error> & Out),world:W.World<S,C,R,E>,name:String) -> Field.Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,K.Error,Out,runner(~S,~C,~R,~E,~Ops,~Args,~Out,~Value,~declaration,~body)>,Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration))>:
  registered(~S,~C,~R,~E,~Args,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Out,~Value,~declaration,~body),~Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration)),Sys.register(~S,~C,~R,~E,~Args,~K.Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Out,~Value,~declaration,~body),world,name,Field.access(~S,Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration)))))
