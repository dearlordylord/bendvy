import Base
import relation-types.bend as G
import relation-graph.bend as Graph
import relation-commands.bend as A
import world.bend as W
import transaction.bend as X
import query.bend as Q
import component.bend as Cmp
import capabilities.bend as Cap

# Relation requirements have arbitrary declaration length. The application C
# remains Type; only immutable relation handles/snapshots are Data.
type End is Data:
  Outgoing{}
  Incoming{}
type Requirement<S:Data> is Data:
  Requirement{key:String,descriptor:G.Descriptor<S>,end:End,mode:Q.Selection,project:Bool}
type Spec<S:Data> is Data:
  Spec{requirements:List<&2,Requirement<S>>}
type Value<S:Data> is Data:
  Missing{}
  Target{handle:W.Handle<S>}
  Sources{handles:List<&2,W.Handle<S>>}
type Cell<S:Data> is Data:
  Cell{key:String,end:End,value:Value<S>}
type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,cells:List<&2,Cell<S>>,component:V}
def read_relation(~S:Data,key:String,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{key,descriptor,Outgoing{},Q.Required{},True{}}
def optional_relation(~S:Data,key:String,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{key,descriptor,Outgoing{},Q.Optional{},True{}}
def read_related(~S:Data,key:String,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{key,descriptor,Incoming{},Q.Required{},True{}}
def optional_related(~S:Data,key:String,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{key,descriptor,Incoming{},Q.Optional{},True{}}
def with_relation(~S:Data,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{"",descriptor,Outgoing{},Q.Present{},False{}}
def without_relation(~S:Data,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{"",descriptor,Outgoing{},Q.Absent{},False{}}
def with_related(~S:Data,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{"",descriptor,Incoming{},Q.Present{},False{}}
def without_related(~S:Data,descriptor:G.Descriptor<S>) -> Requirement<S>:
  Requirement{"",descriptor,Incoming{},Q.Absent{},False{}}
def handles_acc(~S:Data,ids:List<&2,U32>,+namespace:U32,acc:List<&2,W.Handle<S>>) -> List<&2,W.Handle<S>>:
  match ids:
    case []: List.reverse(&2,W.Handle<S>,acc)
    case id <> rest: handles_acc(~S,rest,namespace,W.Handle{namespace,id} <> acc)
def outgoing_value(~S:Data,value:Maybe<&2,U32>,namespace:U32) -> Value<S>:
  match value:
    case None{}: Missing{}
    case Some{id}: Target{W.Handle{namespace,id}}
def incoming_value(~S:Data,ids:List<&2,U32>,namespace:U32) -> Value<S>:
  match ids:
    case []: Missing{}
    case first <> rest: Sources{handles_acc(~S,first <> rest,namespace,[])}
def value(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,end:End,+namespace:U32,id:U32) -> Value<S>:
  match end:
    case Outgoing{}: outgoing_value(~S,Graph.target(~S,graph,descriptor,id),namespace)
    case Incoming{}: incoming_value(~S,Graph.inverse(~S,graph,descriptor,id),namespace)
def presence(~S:Data,value:Value<S>) -> Cmp.Access<Bool>:
  match value:
    case Missing{}: Cmp.ComponentAbsent{}
    case _: Cmp.Found{True{}}
def add_cell(~S:Data,project:Bool,key:String,end:End,value:Value<S>,cells:List<&2,Cell<S>>) -> List<&2,Cell<S>>:
  match project:
    case False{}: cells
    case True{}: Cell{key,end,value} <> cells
def requirements(~S:Data,remaining:List<&2,Requirement<S>>,+graph:G.Graph<S>,+namespace:U32,+id:U32,selected:Bool,acc:List<&2,Cell<S>>) -> Bool & List<&2,Cell<S>>:
  match remaining:
    case []: (selected,List.reverse(&2,Cell<S>,acc))
    case Requirement{key,descriptor,+end,mode,project} <> rest:
      +observed = value(~S,graph,descriptor,end,namespace,id)
      requirements(~S,rest,graph,namespace,id,selected && Q.selection_aux(~Bool,mode,presence(~S,observed)),add_cell(~S,project,key,end,observed,acc))
def spec_rows_result(~S:Data,~V:Data,observed:Bool & List<&2,Cell<S>>,handle:W.Handle<S>,component:V) -> Bool & Row<S,V>:
  (selected,cells) = observed
  (selected,Row{handle,cells,component})
def spec_rows(~S:Data,~V:Data,spec:Spec<S>,graph:G.Graph<S>,handle:W.Handle<S>,component:V) -> Bool & Row<S,V>:
  match spec handle:
    case Spec{items} W.Handle{+namespace,+id}: spec_rows_result(~S,~V,requirements(~S,items,graph,namespace,id,True{},[]),W.Handle{namespace,id},component)
def graph_read(~S:Data,~C:Type,store:A.Store<S,C>) -> A.Store<S,C> & G.Graph<S>:
  match store:
    case A.Store{components,+graph}: (A.Store{components,graph},graph)
def inspect_done(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~spec:Spec<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>,handle:W.Handle<S>,component:V,undo:List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & Row<S,V>):
  (world,graph) = observed
  (X.Tx{world,undo,commands,events},spec_rows(~S,~V,spec,graph,handle,component))
def inspect(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~spec:Spec<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,handle:W.Handle<S>,component:V) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & Row<S,V>):
  match tx:
    case X.Tx{world,undo,commands,events}: inspect_done(~S,~V,~C,~R,~E,~spec,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~G.Graph<S>,graph_read(~S,~C),world),handle,component,undo,commands,events)
def row_get(~S:Data,~V:Data,~H:Type,+row:Row<S,V>,owner:H) -> H & Row<S,V>:
  (owner,row)
def invoke(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,row:Row<S,V>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out:
  body(X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,Cap.ValueRead{row_get(~S,~V,~X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,row)},tx)
def output_prepend(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Data,value:Out,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>:
  (tx,rest) = observed
  (tx,value <> rest)
def output_join(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out,next:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>:
  (tx,value) = observed
  output_prepend(~S,~C,~R,~E,~Out,value,next(tx))
def selected_row(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & Row<S,V>),next:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>:
  match observed:
    case (tx,(False{},_)): next(tx)
    case (tx,(True{},row)): output_join(~S,~V,~C,~R,~E,~Out,invoke(~S,~V,~C,~R,~E,~Out,~body,row,tx),next)
def component_join(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~spec:Spec<S>,~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,handle:W.Handle<S>,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & V),next:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>:
  match observed:
    case (tx,(False{},_)): next(tx)
    case (tx,(True{},component)): selected_row(~S,~V,~C,~R,~E,~Out,~body,inspect(~S,~V,~C,~R,~E,~spec,tx,handle,component),next)
def scan(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~spec:Spec<S>,~component_selected:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> W.Handle<S> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & V),~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,handles:List<&2,W.Handle<S>>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>:
  match handles:
    case []: (tx,[])
    case +handle <> rest: component_join(~S,~V,~C,~R,~E,~Out,~spec,~body,handle,component_selected(tx,handle),tx => scan(~S,~V,~C,~R,~E,~Out,~spec,~component_selected,~body,rest,tx))
def finish(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Data,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & List<&2,Out>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Out>:
  match observed:
    case (X.Tx{world,_,_,_},values): (world,values)
def reserved(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~spec:Spec<S>,~component_selected:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> W.Handle<S> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & V),~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Out>:
  (world,handles) = observed
  finish(~S,~C,~R,~E,~Out,scan(~S,~V,~C,~R,~E,~Out,~spec,~component_selected,~body,handles,X.begin(~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))
def each(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~Out:Data,~spec:Spec<S>,~component_selected:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> -> W.Handle<S> -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & (Bool & V),~body:@-H:Type -> Cap.ValueRead<H,Row<S,V>> -> H -> H & Out,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Out>:
  reserved(~S,~V,~C,~R,~E,~Out,~spec,~component_selected,~body,W.handles(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world))
