import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx

import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup

import types.bend as Types
def signal() -> Event.Domain<Types.Schema,U32>:Event.domain(~Types.Schema,~U32,"Signal")
def reader_declaration() -> Event.Declaration<Types.Schema,U32>:Event.read(~Types.Schema,~U32,signal())
def writer_declaration() -> Event.Declaration<Types.Schema,U32>:Event.write(~Types.Schema,~U32,signal())

def empty(_: Unit) -> Unit: Unit{}
def fail_read(fail: Bool,world: W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,+observation: Types.Observation) -> Sy.Outcome<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error,Types.Observation>:
  match fail:
    case False{}: Sy.Succeeded{world,observation}
    case True{}: Sy.Failed{world,Types.ReadFailed{observation}}

def observed(~H: Type,owner: H,+reader: String,reading: Ev.Reading<U32>) -> H & Types.Observation:
  match reading:
    case Ev.Reading{values,lagged}: (owner,Types.Observation{reader,values,lagged})

def gameplay_observed(~H: Type,+reader: String,returned: H & Ev.Reading<U32>) -> H & Types.Observation:
  (owner,reading) = returned
  observed(~H,owner,reader,reading)

def gameplay(~H: Type,~observe: H -> H & Ev.Reading<U32>,ops: Ev.ReadAccess<H,U32,observe>,owner: H,+reader: String) -> H & Types.Observation:
  gameplay_observed(~H,reader,Ev.all(~H,~U32,~observe,ops,owner))

def read_finished(world: W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,returned: Ev.Input<U32,Types.ReadRequest> & Types.Observation) -> Sy.Outcome<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error,Types.Observation>:
  match returned:
    case (Ev.Input{_,_,Types.ReadRequest{_,fail}},observation): fail_read(fail,world,observation)

def read_runner(world: W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,input: Ev.Input<U32,Types.ReadRequest>) -> Sy.Outcome<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error,Types.Observation>:
  match input:
    case Ev.Input{+values,+lagged,Types.ReadRequest{+reader,+fail}}: read_finished(world,gameplay(~Ev.Input<U32,Types.ReadRequest>,~(input => Ev.input_read(~U32,~Types.ReadRequest,input)),Event.read_grant(~Types.Schema,~U32,~Ev.Input<U32,Types.ReadRequest>,~(input => Ev.input_read(~U32,~Types.ReadRequest,input)),signal()),Ev.Input{values,lagged,Types.ReadRequest{reader,fail}},reader))

def stage_many(remaining: Nat,+value: U32,tx: Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>) -> Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>:
  match remaining:
    case 0n: tx
    case 1n+rest: stage_many(rest,value,Ev.emit(~Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~U32,~(tx => event => Tx.emit(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,tx,event)),Event.write_grant(~Types.Schema,~U32,~Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~(tx => event => Tx.emit(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,tx,event)),signal()),tx,value))

def stage_second(second: Maybe<&2,U32>,tx: Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>) -> Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>:
  match second:
    case None{}: tx
    case Some{value}: Ev.emit(~Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~U32,~(tx => event => Tx.emit(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,tx,event)),Event.write_grant(~Types.Schema,~U32,~Tx.Tx<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,U32>,~(tx => event => Tx.emit(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,tx,event)),signal()),tx,value)

def outcome(fail: Bool) -> Tx.Outcome<Types.Error>:
  match fail:
    case False{}: Tx.Success{}
    case True{}: Tx.Failure{Types.PublishFailed{}}

def queue_none(world: W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,_: List<(W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32> -> W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>)>) -> W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>: world

def published(returned: Tx.Returned<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error>) -> Sy.Outcome<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error,Unit>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}: Sy.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}: Sy.Failed{world,error}

def publish_runner(world: W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,request: Types.PublishRequest) -> Sy.Outcome<W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,Types.Error,Unit>:
  match request:
    case Types.PublishRequest{value,count,second,fail}: published(Tx.finish(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,~Types.Error,~queue_none,~(world => events => W.event_publish(~Types.Schema,~Setup.store(~Types.Schema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,world,events)),stage_second(second,stage_many(U32.to_nat(count),value,Tx.begin(~W.World<Types.Schema,Setup.store(~Types.Schema,~Array<U32>),Setup.resources(~Array<U32>),U32>,~U32,world))),outcome(fail)))
