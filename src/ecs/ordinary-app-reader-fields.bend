import Base
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as Tx
import ./commands.bend as Cmd
import ./capabilities.bend as Cap
import ./reader-parameter.bend as RP
import ./event-notice-runtime.bend as Mixed
import ./event-family-routing.bend as Route
import ./relation-commands.bend as Notice
import ./internal/relation-failures/domains.bend as D
import ./ordinary-reader-system.bend as Ordinary
import ./ordinary-app-reader-parameter.bend as Parameter
import ./ordinary-app-registration-fields.bend as Fields

import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Pair
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO

# Retained declaration facts belong to the provider's existing Declaration owner.
# The ordinary definition receives the same generated parameter and facts together.
def define_mixed(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~Reader:Type,~View:Data,~Delta:Type,~Args:Type,~Failure:Data,~Output:Type,
  ~validateFn:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> -> Reader -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Reader & Bool),
  ~prepareFn:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> -> @+cursor:U32 -> Reader -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Reader & (View & Delta)),
  ~commitFn:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> -> Reader -> Delta -> @+cursor:U32 -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & Reader,~releaseFn:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> -> Reader -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,
  ~Ops:Type -> Type,
  ~body:@-K:Type -> @-caps:Ops(K) -> (View & Args) -> K -> K & (Tx.Outcome<Failure> & Output),
  ~grant:Ops(Tx.Tx<W.World<S,C,R,Notice.Notice<S,P>>,Notice.Notice<S,P>>),
  ~sync:F -> Nat -> List<&2,P> -> F,
  ~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,
  ~initialize:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> -> RP.RegistrationFacts -> Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Reader & RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>),
  descriptor:Parameter.Declared<S,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>>,
  context:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,name:String) -> Ordinary.Definition<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Ordinary.Provider<Sys.Registry<S,C,R,Notice.Notice<S,P>,Ordinary.Invocation<(Mixed.State<S,P,F,H> & Nat),Reader,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,List<&2,Fields.DeclaredUse>,Args>,Empty,Ordinary.Envelope<(Mixed.State<S,P,F,H> & Nat),Reader,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,List<&2,Fields.DeclaredUse>,Failure,Output>,Ordinary.shared_runner(~S,~C,~R,~P,~F,~H,~Reader,~View,~Delta,~Args,~List<&2,Fields.DeclaredUse>,~Failure,~Output,~validateFn,~prepareFn,~commitFn,~releaseFn,~Ops,~body,~grant,~sync,~classify)>,Reader,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,List<&2,Fields.DeclaredUse>>,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Reader,View,Delta,validateFn,prepareFn,commitFn,releaseFn>,List<&2,Fields.DeclaredUse>>:
  match descriptor:
    case Parameter.Declared{parameter,uses}:Ordinary.define_mixed(~S,~C,~R,~P,~F,~H,~Reader,~View,~Delta,~Args,~List<&2,Fields.DeclaredUse>,~Failure,~Output,~validateFn,~prepareFn,~commitFn,~releaseFn,~Ops,~body,~grant,~sync,~classify,~initialize,parameter,uses,context,name)

# One registration produces one Binding, even when its parameters span categories.
def fold(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,value:Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>) -> Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>> & List<&2,Fields.Fields<S>>:
  match value:
    case Ordinary.Provider{Sys.Registry{+namespace,+id,+name,+access,+cursor},reader,parameter,+uses}:(Ordinary.Provider{Sys.Registry{namespace,id,name,access,cursor},reader,parameter,uses},[Fields.Fields{namespace,id,name,access,cursor,name,[],Fields.MixedKind{uses}}])

def sources(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,value:Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>) -> Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>> & List<&2,Fields.DeclaredUse>:
  match value:
    case Ordinary.Provider{registry,reader,parameter,+uses}:(Ordinary.Provider{registry,reader,parameter,uses},uses)

def fold_meta_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,~Meta:Type,meta:Meta,result:Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>> & List<&2,Fields.Fields<S>>) -> (Meta & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>) & List<&2,Fields.Fields<S>>:
  match result:
    case (provider,fields):((meta,provider),fields)
def fold_meta(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,~Meta:Type,value:Meta & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>) -> (Meta & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>) & List<&2,Fields.Fields<S>>:
  match value:
    case (meta,provider):fold_meta_returned(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~Reader,~Param,~Meta,meta,fold(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~Reader,~Param,provider))
# Operational runtime metadata remains affine in H, beside the actual provider.
# The library composes the fold; application setup supplies no debug adapter.
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,~Meta:Type,~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,world:W.World<S,C,R,E>,previous:Previous,meta:Meta,provider:Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool) -> Build.Registered<S,W.World<S,C,R,E>,Previous & (Meta & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>),Rows,observe,Pair.fold_pair(~S,~Previous,~(Meta & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>),~previousFold,~fold_meta(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~Reader,~Param,~Meta))>:
  Build.Registered{world,(previous,(meta,provider)),recipe,debug}

# Registration refusal recovers the generated descriptor. If disposal itself
# refuses, its sole provider still owns the initialized readers and declaration.
type Recovered<-S:Data,-Context:Type,-Provider:Type,-Param:Data> is Type:
  Registered{context:Context,provider:Provider}
  Rejected{context:Context,descriptor:Parameter.Declared<S,Param>}
  DisposalRejected{context:Context,provider:Provider,descriptor:Parameter.Declared<S,Param>}
def disposal_recovered(~S:Data,~Context:Type,~Registry:Type,~Reader:Type,~Param:Data,context:Context,parameter:Param,provider:Ordinary.Provider<Registry,Reader,Param,List<&2,Fields.DeclaredUse>>) -> Recovered<S,Context,Ordinary.Provider<Registry,Reader,Param,List<&2,Fields.DeclaredUse>>,Param>:
  match provider:
    case Ordinary.Provider{registry,reader,initialized,+uses}:DisposalRejected{context,Ordinary.Provider{registry,reader,initialized,uses},Parameter.Declared{parameter,uses}}
def recover(~S:Data,~Context:Type,~Registry:Type,~Reader:Type,~Param:Data,result:Ordinary.Definition<Context,Ordinary.Provider<Registry,Reader,Param,List<&2,Fields.DeclaredUse>>,Param,List<&2,Fields.DeclaredUse>>) -> Recovered<S,Context,Ordinary.Provider<Registry,Reader,Param,List<&2,Fields.DeclaredUse>>,Param>:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:Registered{context,provider}
    case Ordinary.DefinitionRejected{context,parameter,uses}:Rejected{context,Parameter.Declared{parameter,uses}}
    case Ordinary.DefinitionDisposalRejected{context,provider,parameter}:disposal_recovered(~S,~Context,~Registry,~Reader,~Param,context,parameter,provider)

# A routed application already owns its sole World inside Context.
def attach_context(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Reader:Type,~Param:Type,~Context:Type,~Previous:Type,~Rows:Data,~observe:Context -> Context & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,context:Context,previous:Previous,provider:Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>,recipe:Tree.Recipe<Context,Rows,observe>,debug:Bool) -> Build.Registered<S,Context,Previous & Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>,Rows,observe,Pair.fold_pair(~S,~Previous,~Ordinary.Provider<Sys.Registry<S,C,R,E,Args,Error,Output,runner>,Reader,Param,List<&2,Fields.DeclaredUse>>,~previousFold,~fold(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~Reader,~Param))>:
  Build.Registered{context,(previous,provider),recipe,debug}
