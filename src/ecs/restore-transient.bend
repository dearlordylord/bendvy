import Base
import ./change-tick.bend as Tick
import ./restore-data.bend as R
import ./snapshot-leaf.bend as Leaf
import ./ordinary-declaration.bend as Identity
import ./persistence-declaration.bend as Decl
import ./column.bend as Col
import ./world.bend as W
import ./decode-data.bend as D

type State<P:Type> is Type:State{removed:List<P>}
def stage(~State:Type,~Custom:Data,state:State,position:R.Position,field:D.Field) -> State & R.Dispatch<Custom>:
  (state,R.Unhandled{})
def release(~State:Type,state:State) -> State:state
def insert(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,owner:Leaf.TransientComponent<S,P,identity>,unit:Unit,state:State<P>,bindings:List<&2,R.Binding<S>>,tick:Tick.Tick) -> (Leaf.TransientComponent<S,P,identity> & Unit) & State<P>:
  ((owner,unit),state)
def resource_insert(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,unit:Unit,owner:Leaf.TransientResource<S,P,identity>,state:Unit,bindings:List<&2,R.Binding<S>>,tick:Tick.Tick) -> (Unit & Leaf.TransientResource<S,P,identity>) & Unit:
  ((unit,owner),state)
def commit(~P:Type,state:State<P>) -> State<P>:
  State{[]}
def take_recovery(~State:Type,state:State) -> State & Unit:
  (state,Unit{})
