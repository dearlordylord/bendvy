import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd

type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,value:C.Access<V>,error:Maybe<&2,W.WorldError>}
type Population<S:Data,V:Data> is Data:
  Population{clauses:List<&2,Decl.Clause<S>>,rows:List<&2,Row<S,V>>}
def finished(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,handle:W.Handle<S>,value:C.Access<V>,error:Maybe<&2,W.WorldError>,got:T.Returned<W.World<S,Store,R,E>,Unit>) -> W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>:
  match got:
    case T.Returned{world,_}:(world,Some{Row{handle,value,error}})
def read_done(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,got:Q.Frame<S,Store,R,E> & C.Access<V>) -> W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>:
  match got:
    case (Q.Frame{tx,handle,error,_},value):finished(~S,~Store,~R,~E,~V,handle,value,error,Cmd.tx_finish(~S,~Store,~R,~E,~Unit,tx,T.Failure{Unit{}}))
def empty_finished(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,got:T.Returned<W.World<S,Store,R,E>,Unit>) -> W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>:
  match got:
    case T.Returned{world,_}:(world,None{})
def unselected(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,frame:Q.Frame<S,Store,R,E>) -> W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>:
  match frame:
    case Q.Frame{tx,_,_,_}:empty_finished(~S,~Store,~R,~E,~V,Cmd.tx_finish(~S,~Store,~R,~E,~Unit,tx,T.Failure{Unit{}}))
def selected(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~declaration:Decl.Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>,got:Q.Frame<S,Store,R,E> & Bool) -> W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>:
  match got:
    case (frame,False{}):unselected(~S,~Store,~R,~E,~V,frame)
    case (frame,True{}):read_done(~S,~Store,~R,~E,~V,Decl.execute_read(~S,~Q.Frame<S,Store,R,E>,~V,~declaration,frame))
def append_row(~S:Data,~V:Data,row:Maybe<&2,Row<S,V>>,rows:List<&2,Row<S,V>>) -> List<&2,Row<S,V>>:
  match row:
    case None{}:rows
    case Some{value}:value <> rows
def row_done(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,next:W.World<S,Store,R,E> -> List<&2,Row<S,V>> -> W.World<S,Store,R,E> & List<&2,Row<S,V>>,rows:List<&2,Row<S,V>>,got:W.World<S,Store,R,E> & Maybe<&2,Row<S,V>>) -> W.World<S,Store,R,E> & List<&2,Row<S,V>>:
  match got:
    case (world,row):next(world,append_row(~S,~V,row,rows))
def scan(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~declaration:Decl.Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>,handles:List<&2,W.Handle<S>>,world:W.World<S,Store,R,E>,rows:List<&2,Row<S,V>>) -> W.World<S,Store,R,E> & List<&2,Row<S,V>>:
  match handles:
    case []:(world,List.reverse(&2,Row<S,V>,rows))
    case handle <> rest:row_done(~S,~Store,~R,~E,~V,(world => rows => scan(~S,~Store,~R,~E,~V,~declaration,rest,world,rows)),rows,selected(~S,~Store,~R,~E,~V,~declaration,Decl.selector(~S,~Q.Frame<S,Store,R,E>,~Cap.Read<Q.Frame<S,Store,R,E>,V>,declaration)(Q.Frame{T.begin(~W.World<S,Store,R,E>,~E,world),handle,None{},0})))
def population(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,clauses:List<&2,Decl.Clause<S>>,got:W.World<S,Store,R,E> & List<&2,Row<S,V>>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match got:
    case (world,rows):(world,Some{Population{clauses,rows}})
def named(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~declaration:Decl.Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>,got:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match got:
    case (world,handles):population(~S,~Store,~R,~E,~V,Decl.clauses(~S,~Q.Frame<S,Store,R,E>,~Cap.Read<Q.Frame<S,Store,R,E>,V>,declaration),scan(~S,~Store,~R,~E,~V,~declaration,handles,world,[]))
# Planted defect: run the normal grant/presentation but still claim Disabled None.
def hidden(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,got:W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match got:
    case (world,_):(world,None{})
# Existing ordinary executable read grant is the only component authority.
# Disabled reaches neither declaration projection nor world/payload traversal.
def query(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~declaration:Decl.Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>>,debug:App.Debug,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Maybe<&2,Population<S,V>>:
  match debug:
    case App.Disabled{}:hidden(~S,~Store,~R,~E,~V,named(~S,~Store,~R,~E,~V,~declaration,W.handles(~S,~Store,~R,~E,world)))
    case App.Enabled{}:named(~S,~Store,~R,~E,~V,~declaration,W.handles(~S,~Store,~R,~E,world))
