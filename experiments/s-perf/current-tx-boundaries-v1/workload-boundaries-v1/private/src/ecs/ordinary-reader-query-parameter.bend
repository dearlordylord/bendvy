import Base
import reader-parameter.bend as RP
import ordinary-query-observable.bend as Observable
import ordinary-query-declaration.bend as Query
import compose.bend as FrameQuery
import inspector.bend as Inspector
import inspector-query.bend as InspectQuery
import world.bend as W
import relation-commands.bend as Notice
import event-notice-runtime.bend as Mixed
import event-family-routing.bend as Route

# Query rows are detached Data values; the shared route context retains the
# sole World and its affine event/relation history.
type Rows<S:Data,V:Data> is Data:
  Rows{rows:List<&2,InspectQuery.ProjectedRow<S,V>>}

def rows_observed(~S:Data,~Store:Type,~R:Type,~P:Data,~V:Data,observed:Inspector.Frame<S,Store,R,Notice.Notice<S,P>> & List<&2,InspectQuery.ProjectedRow<S,V>>) -> W.World<S,Store,R,Notice.Notice<S,P>> & (Unit & (Rows<S,V> & Unit)):
  match observed:
    case (Inspector.Frame{world,_},rows):(world,(Unit{},(Rows{rows},Unit{})))

def validate_context(~S:Data,~Store:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Ops:Type,~V:Data,~declaration:Observable.Declaration<S,FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,Ops,Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,V>,context:Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Unit) -> Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Unit & Bool):
  match context:
    case Route.Runtime{world,state,tick}:(Route.Runtime{world,state,tick},(owner,True{}))

def with_query_rows(~S:Data,~Store:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Ops:Type,~V:Data,state:Mixed.State<S,P,F,H>,tick:Nat,observed:W.World<S,Store,R,Notice.Notice<S,P>> & (Unit & (Rows<S,V> & Unit))) -> Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Unit & (Rows<S,V> & Unit)):
  match observed:
    case (world,(owner,(rows,delta))):(Route.Runtime{world,state,tick},(owner,(rows,delta)))

def prepare_context(~S:Data,~Store:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Ops:Type,~V:Data,~declaration:Observable.Declaration<S,FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,Ops,Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,V>,context:Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,+cursor:U32,owner:Unit) -> Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & (Unit & (Rows<S,V> & Unit)):
  match context:
    case Route.Runtime{world,state,tick}:with_query_rows(~S,~Store,~R,~P,~F,~H,~Ops,~V,state,tick,rows_observed(~S,~Store,~R,~P,~V,InspectQuery.each_composed(~Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,~S,~V,Observable.inspect_query(~S,~Store,~R,~Notice.Notice<S,P>,~FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,~Ops,~V,~declaration),Inspector.Frame{world,cursor})))

def commit_context(~Context:Type,context:Context,owner:Unit,delta:Unit,+cursor:U32) -> Context & Unit:
  (context,owner)

# Query projection retains no private cursor or shared-history membership.
# Disposal consumes its Unit owner while preserving the sole affine context.
def release_context(~Context:Type,context:Context,owner:Unit) -> Context:
  context

def access_clauses(~S:Data,clauses:List<&2,Query.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Query.Clause{name,_} <> rest:name <> access_clauses(~S,rest)

def access_of(~S:Data,~Store:Type,~R:Type,~P:Data,~Ops:Type,~V:Data,declaration:Observable.Declaration<S,FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,Ops,Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,V>) -> List<&2,String>:
  access_clauses(~S,Query.clauses(~S,~FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,~Ops,Observable.operational(~S,~FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,~Ops,~Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,~V,declaration)))

def from_observable(~S:Data,~Store:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Ops:Type,~V:Data,~declaration:Observable.Declaration<S,FrameQuery.Frame<S,Store,R,Notice.Notice<S,P>>,Ops,Inspector.Frame<S,Store,R,Notice.Notice<S,P>>,V>) -> RP.Param<Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,Unit,Rows<S,V>,Unit,validate_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),prepare_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),commit_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>),release_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>)>:
  RP.make(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,~Unit,~Rows<S,V>,~Unit,~validate_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),~prepare_context(~S,~Store,~R,~P,~F,~H,~Ops,~V,~declaration),~commit_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>),~release_context(~Route.Runtime<S,Store,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>),access_of(~S,~Store,~R,~P,~Ops,~V,declaration))
