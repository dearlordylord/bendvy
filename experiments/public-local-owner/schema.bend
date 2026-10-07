import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/local.bend as L
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/commands.bend as Cmd

type Schema is Data:
  Schema{}
type Owner is Type:
  Owner{array: Array<U32>}
type Args is Type:
  Args{delta: U32,fail: Bool,ticket: Array<U32>}
type Output is Data:
  Output{ticket: List<&2,U32>}

def empty(unit: Unit) -> Unit:
  Unit{}
def list4(a: U32,b: U32,c: U32,d: U32) -> List<&2,U32>:
  [a,b,c,d]
def fourth(a: U32,b: U32,c: U32,result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,d) = result
  (array,[a,b,c,d])
def third(a: U32,b: U32,result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,c) = result
  fourth(a,b,c,Array.get(U32,array,3))
def second(a: U32,result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,b) = result
  third(a,b,Array.get(U32,array,2))
def first(result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,a) = result
  second(a,Array.get(U32,array,1))
def collect4(array: Array<U32>) -> Array<U32> & List<&2,U32>:
  first(Array.get(U32,array,0))
def ticket_second(a: U32,result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,b) = result
  (array,[a,b])
def ticket_first(result: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (array,a) = result
  ticket_second(a,Array.get(U32,array,1))
def collect2(array: Array<U32>) -> Array<U32> & List<&2,U32>:
  ticket_first(Array.get(U32,array,0))
def projected(result: Array<U32> & List<&2,U32>) -> Owner & List<&2,U32>:
  (array,values) = result
  (Owner{array},values)
def project(owner: Owner) -> Owner & List<&2,U32>:
  match owner:
    case Owner{array}: projected(collect4(array))
def owned(a: U32,b: U32,c: U32,d: U32) -> Owner:
  Owner{ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}}
def shown(values: List<&2,U32>) -> String:
  match values:
    case []: ""
    case value <> []: U32.show(value)
    case value <> rest: U32.show(value) ++ "," ++ shown(rest)
def made(values: List<&2,U32>,+delta: U32) -> Owner:
  match values:
    case [a,b,c,d]: owned((a + delta : U32),(b + delta : U32),(c + delta : U32),(d + delta : U32))
    case _: owned(0,0,0,0)
def updated(-H: Type,replace: H -> Owner -> H,+delta: U32,observed: H & List<&2,U32>) -> H & Unit:
  (owner,values) = observed
  (replace(owner,made(values,delta)),Unit{})
def gameplay(-H: Type,ops: L.Ops<H,Owner,List<&2,U32>>,owner: H,delta: U32) -> H & Unit:
  match ops:
    case L.Ops{read,replace}: updated(H,replace,delta,read(owner))
def discarded(result: W.World<Schema,Unit,U32,Unit> & U32) -> W.World<Schema,Unit,U32,Unit>:
  (world,old) = result
  world
def restore(world: W.World<Schema,Unit,U32,Unit>,old: U32) -> W.World<Schema,Unit,U32,Unit>:
  discarded(W.replace_resource(~Schema,~Unit,~U32,~Unit,world,old))
def journal(result: W.World<Schema,Unit,U32,Unit> & U32) -> T.Tx<W.World<Schema,Unit,U32,Unit>,Unit>:
  (world,old) = result
  T.add_undo(~W.World<Schema,Unit,U32,Unit>,~Unit,T.begin(~W.World<Schema,Unit,U32,Unit>,~Unit,world),w => restore(w,old))
def changed_world(world: W.World<Schema,Unit,U32,Unit>,+delta: U32) -> T.Tx<W.World<Schema,Unit,U32,Unit>,Unit>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,+counter,events,pending,regs,sid,clock}: journal(W.replace_resource(~Schema,~Unit,~U32,~Unit,W.World{ns,next,high,live,cap,depth,store,counter,events,pending,regs,sid,clock},(counter + delta : U32)))
def finished(owner: Owner,ticket: List<&2,U32>,returned: T.Returned<W.World<Schema,Unit,U32,Unit>,Unit>) -> L.Outcome<W.World<Schema,Unit,U32,Unit>,Owner,Unit,Output>:
  match returned:
    case T.Returned{world,T.Success{}}: L.Succeeded{world,owner,Output{ticket}}
    case T.Returned{world,T.Failure{error}}: L.Failed{world,owner,error}
def finalized(owner: Owner,ticket: List<&2,U32>,fail: Bool,tx: T.Tx<W.World<Schema,Unit,U32,Unit>,Unit>) -> L.Outcome<W.World<Schema,Unit,U32,Unit>,Owner,Unit,Output>:
  match fail:
    case False{}: finished(owner,ticket,Cmd.tx_finish(~Schema,~Unit,~U32,~Unit,~Unit,tx,T.Success{}))
    case True{}: finished(owner,ticket,Cmd.tx_finish(~Schema,~Unit,~U32,~Unit,~Unit,tx,T.Failure{Unit{}}))
def ticket_observed(owner: Owner,fail: Bool,tx: T.Tx<W.World<Schema,Unit,U32,Unit>,Unit>,ticket: Array<U32> & List<&2,U32>) -> L.Outcome<W.World<Schema,Unit,U32,Unit>,Owner,Unit,Output>:
  (array,values) = ticket
  finalized(owner,values,fail,tx)
def local_updated(world: W.World<Schema,Unit,U32,Unit>,+delta: U32,fail: Bool,ticket: Array<U32>,updated: Owner & Unit) -> L.Outcome<W.World<Schema,Unit,U32,Unit>,Owner,Unit,Output>:
  (owner,unit) = updated
  ticket_observed(owner,fail,changed_world(world,delta),collect2(ticket))

def runner(world: W.World<Schema,Unit,U32,Unit>,owner: Owner,args: Args) -> L.Outcome<W.World<Schema,Unit,U32,Unit>,Owner,Unit,Output>:
  match args:
    case Args{+delta,fail,ticket}: local_updated(world,delta,fail,ticket,L.provide_with(~Owner,~List<&2,U32>,~U32,~Unit,~project,~gameplay,owner,delta))
