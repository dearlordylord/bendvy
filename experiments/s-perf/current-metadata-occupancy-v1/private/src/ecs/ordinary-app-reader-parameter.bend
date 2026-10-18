import Base
import ./reader-parameter.bend as RP
import ./ordinary-query-observable.bend as Observable
import ./ordinary-query-declaration.bend as Query
import ./compose.bend as FrameQuery
import ./inspector.bend as Inspector
import ./inspector-query.bend as InspectQuery
import ./world.bend as W
import ./relation-commands.bend as Notice
import ./event-notice-runtime.bend as Mixed
import ./event-family-routing.bend as Route
import ./event-runtime.bend as Ev
import ./event-stream.bend as Stream
import ./event-family-runtime.bend as Family
import ./ordinary-event-declaration.bend as Event
import ./relation-failure-reader.bend as KDecl
import ./relation-failure-runtime.bend as K
import ./relation-failure-disposal.bend as KDispose
import ./internal/relation-failures/domains.bend as KD
import ./internal/relation-failures/readings.bend as KRead
import ./ordinary-removal-provision.bend as Provision
import ./ordinary-declaration.bend as Identity
import ./removals.bend as Rm
import ./ordinary-reader-query-parameter.bend as QParam
import ./ordinary-reader-stream-parameter.bend as SParam
import ./ordinary-app-registration-fields.bend as Fields
import ./relation-types.bend as Relations

# Constructors bind retained facts to the same operational declaration and parameter.
# Applications never pass a parallel clause list to registration.
type Declared<S:Data,Parameter:Data> is Data:
  Declared{parameter:Parameter,uses:List<&2,Fields.DeclaredUse>}
def query_uses(~S:Data,clauses:List<&2,Query.Clause<S>>) -> List<&2,Fields.DeclaredUse>:
  match clauses:
    case []:[]
    case Query.Clause{key,mode} <> rest:Fields.DeclaredUse{Fields.ComponentUse{},Fields.QuerySource{},key,mode} <> query_uses(~S,rest)
def event_mode(mode:Event.Mode) -> Query.Mode:
  match mode:
    case Event.Read{}:Query.Read{}
    case Event.Write{}:Query.Write{}
def event_uses(~S:Data,~E:Data,declaration:Event.Declaration<S,E>) -> List<&2,Fields.DeclaredUse>:
  match declaration:
    case Event.Declaration{Event.Domain{key},mode}:[Fields.DeclaredUse{Fields.EventUse{},Fields.MessageSource{},key,event_mode(mode)}]
def relation_uses(~S:Data,declarations:List<&2,KDecl.Declaration<S>>) -> List<&2,Fields.DeclaredUse>:
  match declarations:
    case []:[]
    case KDecl.Declaration{Relations.Descriptor{_,key,_,_}} <> rest:Fields.DeclaredUse{Fields.EventUse{},Fields.RelationFailureSource{},key,Query.Read{}} <> relation_uses(~S,rest)

def from_observable(~S:Data,~Store:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Ops:Type,~V:Data,~declaration:Observable.Declaration<S,FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,Ops,Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,V>) -> Declared<S,RP.Param<Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Unit,QParam.Rows<S,V>,Unit,QParam.validate_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),QParam.prepare_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),QParam.commit_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>),QParam.release_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>)>>:
  Declared{QParam.from_observable(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),query_uses(~S,Query.clauses(~S,~FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,~Ops,Observable.operational(~S,~FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,~Ops,~Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,~V,declaration)))}

def event_param(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~H:Type,
  ~take:F -> F & Stream.Stream<S,E>,
  ~put:F -> Stream.Stream<S,E> -> F,
  ~declaration:Event.Declaration<S,E>) -> Declared<S,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,SParam.EventOwner<S,C,R,P,E,F,H,take,put>,SParam.EventView<S,E>,Nat,
  SParam.validate_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),SParam.prepare_event(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),SParam.commit_event(~S,~C,~R,~P,~E,~F,~H,~take,~put),SParam.release_event(~S,~C,~R,~P,~E,~F,~H,~take,~put)>>:
  Declared{SParam.event_param(~S,~C,~R,~P,~E,~F,~H,~take,~put,~declaration),event_uses(~S,~E,declaration)}

def removal_param(~S:Data,~C:Type,~R:Type,~P:Data,~Payload:Type,~F:Type,~H:Type,
  ~inject:Identity.Declaration<S,Payload> -> W.Handle<S> -> Notice.Notice<S,P>,
  ~select:Notice.Notice<S,P> -> Maybe<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>,
  ~selection:Provision.Selection<S,Payload,Notice.Notice<S,P>,inject,select>) -> Declared<S,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,SParam.RemovalOwner<S,Payload,Notice.Notice<S,P>,select>,SParam.RemovalView<S,Payload>,Nat,
  SParam.validate_removal(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection),SParam.prepare_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),SParam.commit_removal(~S,~C,~R,~P,~Payload,~F,~H,~select),SParam.release_removal(~S,~C,~R,~P,~Payload,~F,~H,~select)>>:
  Declared{SParam.removal_param(~S,~C,~R,~P,~Payload,~F,~H,~inject,~select,~selection),[Fields.DeclaredUse{Fields.EventUse{},Fields.RemovalSource{},SParam.removal_name(~S,~Payload,~Notice.Notice<S,P>,~inject,~select,selection),Query.Read{}}]}

def relation_param(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,
  ~declarations:List<&2,KDecl.Declaration<S>>) -> Declared<S,RP.Param<Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,SParam.RelationOwner<S,P>,SParam.RelationView<S,P>,SParam.RelationDelta,
  SParam.validate_relation(~S,~C,~R,~P,~F,~H,~declarations),SParam.prepare_relation(~S,~C,~R,~P,~F,~H,~declarations),SParam.commit_relation(~S,~C,~R,~P,~F,~H),SParam.release_relation(~S,~C,~R,~P,~F,~H)>>:
  Declared{SParam.relation_param(~S,~C,~R,~P,~F,~H,~declarations),relation_uses(~S,declarations)}

def pair(~S:Data,~W:Type,~OwnerA:Type,~ViewA:Data,~DeltaA:Type,~validateA:W -> OwnerA -> W & (OwnerA & Bool),~prepareA:W -> @+cursor:U32 -> OwnerA -> W & (OwnerA & (ViewA & DeltaA)),~commitA:W -> OwnerA -> DeltaA -> @+cursor:U32 -> W & OwnerA,~releaseA:W -> OwnerA -> W,~OwnerB:Type,~ViewB:Data,~DeltaB:Type,~validateB:W -> OwnerB -> W & (OwnerB & Bool),~prepareB:W -> @+cursor:U32 -> OwnerB -> W & (OwnerB & (ViewB & DeltaB)),~commitB:W -> OwnerB -> DeltaB -> @+cursor:U32 -> W & OwnerB,~releaseB:W -> OwnerB -> W,left:Declared<S,RP.Param<W,OwnerA,ViewA,DeltaA,validateA,prepareA,commitA,releaseA>>,right:Declared<S,RP.Param<W,OwnerB,ViewB,DeltaB,validateB,prepareB,commitB,releaseB>>) -> Declared<S,RP.Param<W,OwnerA & OwnerB,RP.ViewPair<ViewA,ViewB>,DeltaA & DeltaB,RP.pair_validate_fn(~W,~OwnerA,~OwnerB,~validateA,~validateB),RP.pair_prepare_fn(~W,~OwnerA,~OwnerB,~ViewA,~ViewB,~DeltaA,~DeltaB,~prepareA,~prepareB),RP.pair_commit_fn(~W,~OwnerA,~OwnerB,~DeltaA,~DeltaB,~commitA,~commitB),RP.pair_release_fn(~W,~OwnerA,~OwnerB,~releaseA,~releaseB)>>:
  match left right:
    case Declared{left,leftUses} Declared{right,rightUses}:Declared{RP.pair(~W,~OwnerA,~ViewA,~DeltaA,~validateA,~prepareA,~commitA,~releaseA,~OwnerB,~ViewB,~DeltaB,~validateB,~prepareB,~commitB,~releaseB,left,right),List.append(&2,Fields.DeclaredUse,leftUses,rightUses)}
