import Base
import ./schema-fragments.bend as Fragment
import ./ordinary-owned-event-declaration.bend as D
import ./ordinary-owned-event-family-publisher.bend as Publisher
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Pair
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-query-declaration.bend as Query
import ./transaction.bend as T
import ./system.bend as Sys
import ./world.bend as W

type Appended<Before:Type,After:Type> is Type:
  Appended{app:After}
  AppendRejected{app:Before}
def uses(keys:List<&2,String>) -> List<&2,Fields.DeclaredUse>:
  match keys:
    case []:[]
    case key <> rest:Fields.DeclaredUse{Fields.EventUse{},Fields.MessageSource{},key,Query.Write{}} <> uses(rest)
def kind(description:D.Description) -> Fields.RegistrationKind:
  match description:
    case D.Description{keys,_}:Fields.MixedKind{uses(keys)}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Previous -> Previous & List<&2,Fields.Fields<S>>,previous:Previous,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,result:Sys.RegistrationResult<S,C,R,E,Args,Unit,Publisher.Reply<Error,Out,Recovery>,Publisher.runner(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,fold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,Rows,observe,Pair.fold_pair(~S,~Previous,~Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,~fold,~Pair.observed(~S,~Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>) )>>:
  match result:
    case Sys.Registered{world,Sys.Registry{namespace,id,name,access,cursor}}:Appended{Build.Registered{world,(previous,Pair.Record{Fields.Token{},Fields.Fields{namespace,id,name,access,cursor,"",[],kind(D.description(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder,declaration))}}),recipe,debug}}
    case Sys.RegistrationFailed{world}:AppendRejected{Build.Registered{world,previous,recipe,debug}}
def admitted(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Previous -> Previous & List<&2,Fields.Fields<S>>,complete:Bool,app:Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,fold>,name:String) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,fold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,Rows,observe,Pair.fold_pair(~S,~Previous,~Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,~fold,~Pair.observed(~S,~Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>) )>>:
  match complete app:
    case False{} app:AppendRejected{app}
    case True{} Build.Registered{world,previous,recipe,debug}:registered(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body,~Previous,~Rows,~observe,~fold,previous,recipe,debug,Publisher.define(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body,world,name))
def register(~S:Data,~C:Type,~R:Type,~E:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~W.World<S,C,R,E>,~Recovery,~Ops),~declaration:D.Declaration<S,W.World<S,C,R,E>,Recovery,Ops,builder>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Previous -> Previous & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,fold>,name:String) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,fold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,Rows,observe,Pair.fold_pair(~S,~Previous,~Pair.Record<S,Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>>,~fold,~Pair.observed(~S,~Fields.Token<Publisher.Registry(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body)>) )>>:
  admitted(~S,~C,~R,~E,~Recovery,~Ops,~builder,~declaration,~Args,~Error,~Out,~body,~Previous,~Rows,~observe,~fold,D.complete(D.description(~S,~W.World<S,C,R,E>,~Recovery,~Ops,~builder,declaration)),app,name)
def event_entries(~S:Data,keys:List<&2,String>) -> List<&2,Fragment.Entry<S>>:
  match keys:
    case []:[]
    case +key <> rest:Fragment.Entry{Fragment.Event{},key,key} <> event_entries(~S,rest)
def entries(~S:Data,description:D.Description) -> List<&2,Fragment.Entry<S>>:
  match description:
    case D.Description{keys,_}:event_entries(~S,keys)
