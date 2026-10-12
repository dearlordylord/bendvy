import Base
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-records.bend as Leaf
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-system.bend as Ordinary
import ./world.bend as W
import ./system.bend as Sys
import ./check.bend as K
import ./ordinary-query-declaration.bend as Query
# Run the actual newest retained Registry. Registration refusal remains distinct
# from the existing runner error; no replacement error or transaction is added.
type Status<Out:Data> is Data:
  Succeeded{output:Out}
  Failed{error:K.Error}
  RegistrationRejected{}
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Data,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,result:Sys.RunResult<S,C,R,E,Args,K.Error,Out,runner>) -> W.World<S,C,R,E> & (Sys.Registry<S,C,R,E,Args,K.Error,Out,runner> & Status<Out>):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,output}}:(world,(registry,Succeeded{output}))
    case Sys.Completed{registry,Sys.Failed{world,error}}:(world,(registry,Failed{error}))
    case Sys.RegistrationRejected{registry,world,_}:(world,(registry,RegistrationRejected{}))
def repacked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Data,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>> -> (Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>) & List<&2,Records.Fields<S>>,world:W.World<S,C,R,E>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,status:Status<Out>,result:Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>> & Records.Fields<S>) -> Build.Registered<S,W.World<S,C,R,E>,Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>,Rows,observe,fold> & Status<Out>:
  match result:
    case (token,fields):(Build.Registered{world,(owners,Leaf.Record{token,fields}),recipe,debug},status)
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Data,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>> -> (Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>) & List<&2,Records.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,slot:String,clauses:List<&2,Query.Clause<S>>,result:W.World<S,C,R,E> & (Sys.Registry<S,C,R,E,Args,K.Error,Out,runner> & Status<Out>)) -> Build.Registered<S,W.World<S,C,R,E>,Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>,Rows,observe,fold> & Status<Out>:
  match result:
    case (world,(registry,status)):repacked(~S,~C,~R,~E,~Args,~Out,~runner,~Owners,~Rows,~observe,~fold,world,owners,recipe,debug,status,Records.field_registry(~S,~C,~R,~E,~Args,~K.Error,~Out,~runner,slot,clauses,registry))
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Data,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>> -> (Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>) & List<&2,Records.Fields<S>>,world:W.World<S,C,R,E>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,args:Args,result:Ordinary.Owner<S,Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>) -> Build.Registered<S,W.World<S,C,R,E>,Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>,Rows,observe,fold> & Status<Out>:
  match result:
    case Ordinary.Owner{registry,slot,clauses}:returned(~S,~C,~R,~E,~Args,~Out,~runner,~Owners,~Rows,~observe,~fold,owners,recipe,debug,slot,clauses,completed(~S,~C,~R,~E,~Args,~Out,~runner,Sys.run_tracked(~S,~C,~R,~E,~Args,~K.Error,~Out,~runner,registry,world,args)))
def run_latest(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,~Out:Data,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>> -> (Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>) & List<&2,Records.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>,Rows,observe,fold>,args:Args) -> Build.Registered<S,W.World<S,C,R,E>,Owners & Leaf.Record<S,Records.Token<Sys.Registry<S,C,R,E,Args,K.Error,Out,runner>>>,Rows,observe,fold> & Status<Out>:
  match app:
    case Build.Registered{world,(owners,Leaf.Record{token,fields}),recipe,debug}:restored(~S,~C,~R,~E,~Args,~Out,~runner,~Owners,~Rows,~observe,~fold,world,owners,recipe,debug,args,Records.restore_component(~S,~C,~R,~E,~Args,~K.Error,~Out,~runner,token,fields))
