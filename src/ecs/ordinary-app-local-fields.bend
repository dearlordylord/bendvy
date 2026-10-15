import Base
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Pair
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./local.bend as Local
import ./world.bend as W
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-query-declaration.bend as Query
import ./ordinary-resource-system.bend as P
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./capabilities.bend as Cap
# One ordinary declaration indexes the runner and registration owner. Local is
# returned separately from body Out on both transaction success and failure.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Error:Data,~Out:Type,local:L,output:Out,result:T.Returned<W.World<S,C,R,E>,Error>) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case T.Returned{world,T.Success{}}:Local.Succeeded{world,local,output}
    case T.Returned{world,T.Failure{error}}:Local.Failed{world,local,error}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Error:Data,~Out:Type,result:T.Tx<W.World<S,C,R,E>,E> & (L & (T.Outcome<Error> & Out))) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case (tx,(local,(outcome,output))):returned(~S,~C,~R,~E,~L,~Error,~Out,local,output,Cmd.tx_finish(~S,~C,~R,~E,~Error,tx,outcome))
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),world:W.World<S,C,R,E>,local:L,args:Args) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  finished(~S,~C,~R,~E,~L,~Error,~Out,body(T.Tx<W.World<S,C,R,E>,E>,P.grant(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),local,args,T.begin(~W.World<S,C,R,E>,~E,world)))
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Args:Type,-Error:Data,-Out:Type,-Ops:Type -> Type,-declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))> is Type:
  Owner{instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>}
type Registration<-World:Type,-Owned:Type,-L:Type> is Type:
  Registered{world:World,owner:Owned}
  Rejected{world:World,local:L}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),result:Local.Registered<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>:
  match result:
    case Local.Registered{world,instance}:Registered{world,Owner{instance}}
    case Local.RegistrationRejected{world,local}:Rejected{world,local}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),world:W.World<S,C,R,E>,name:String,local:L) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>:
  registered(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,Local.register(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body),world,name,P.access(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)),local))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,world:W.World<S,C,R,E>,args:Args) -> Local.Run<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>:
  match value:
    case Owner{instance}:Local.run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body),instance,world,args)
def field_values(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>,clause:Query.Clause<S>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>:
  match instance clause:
    case Local.Instance{+namespace,+id,+name,+access,local} Query.Clause{+slot,+mode}:(Owner{Local.Instance{namespace,id,name,access,local}},Fields.Fields{namespace,id,name,access,0,slot,[Query.Clause{slot,mode}],Fields.ResourceKind{mode}})
# Local has no tracked reader cursor: 0 is a nonreader projection convention.
def fields(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>:
  match value:
    case Owner{instance}:field_values(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,instance,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration))
def fields_list_returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),result:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  match result:
    case (value,field):(value,[field])
def fold(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  fields_list_returned(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,value))
type Appended<-Before:Type,-After:Type,-L:Type> is Type:
  Appended{app:After}
  AppendRejected{app:Before,local:L}
# Ordinary registration composes the derived fold itself; application authors
# provide only operational declaration/body and Local, never metadata adapters.
def appended(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,previous:Previous,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,result:Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))>,L>:
  match result:
    case Rejected{world,local}:AppendRejected{Build.Registered{world,previous,recipe,debug},local}
    case Registered{world,owner}:Appended{Build.Registered{world,(previous,owner),recipe,debug}}
def register(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,name:String,local:L) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))>,L>:
  match app:
    case Build.Registered{world,previous,recipe,debug}:appended(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,~Previous,~Rows,~observe,~previousFold,previous,recipe,debug,define(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,world,name,local))
