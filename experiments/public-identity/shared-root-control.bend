import Base
import ../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}

def empty(_: Unit) -> Unit:
  Unit{}

def observed(result: W.World<Schema,Unit,Unit,U32> & Bool) -> IO(Unit):
  match result:
    case (_,True{}): IO.print("shared-root control: foreign handle accepted\n")
    case (_,False{}): IO.print("shared-root control: foreign handle rejected\n")

def receiver_activated(result: W.World<Schema,Unit,Unit,U32> & W.Status,foreign: W.Handle<Schema>) -> IO(Unit):
  match result:
    case (world,W.Accepted{}): observed(W.valid(~Schema,~Unit,~Unit,~U32,world,foreign))
    case (_,W.Rejected{_}): IO.print("receiver activation refused\n")

def receiver_reserved(result: W.World<Schema,Unit,Unit,U32> & W.Reservation<Schema>,foreign: W.Handle<Schema>) -> IO(Unit):
  match result:
    case (world,W.Reserved{local}): receiver_activated(W.activate(~Schema,~Unit,~Unit,~U32,world,local),foreign)
    case (_,W.ReservationRejected{_}): IO.print("receiver reservation refused\n")

def receiver_created(created: W.Creation<Schema,Unit,Unit,U32>,foreign: W.Handle<Schema>) -> IO(Unit):
  match created:
    case W.Created{_,world}: receiver_reserved(W.reserve_id(~Schema,~Unit,~Unit,~U32,world),foreign)
    case W.CreateRejected{_,_}: IO.print("receiver creation refused\n")

def sender_activated(result: W.World<Schema,Unit,Unit,U32> & W.Status,foreign: W.Handle<Schema>,factory: W.Factory) -> IO(Unit):
  match result:
    case (_,W.Accepted{}): receiver_created(W.create(~Schema,~Unit,~Unit,~U32,~empty,factory,Unit{}),foreign)
    case (_,W.Rejected{_}): IO.print("sender activation refused\n")

def sender_reserved(result: W.World<Schema,Unit,Unit,U32> & W.Reservation<Schema>,factory: W.Factory) -> IO(Unit):
  match result:
    case (world,W.Reserved{+foreign}): sender_activated(W.activate(~Schema,~Unit,~Unit,~U32,world,foreign),foreign,factory)
    case (_,W.ReservationRejected{_}): IO.print("sender reservation refused\n")

def sender_created(created: W.Creation<Schema,Unit,Unit,U32>) -> IO(Unit):
  match created:
    case W.Created{factory,world}: sender_reserved(W.reserve_id(~Schema,~Unit,~Unit,~U32,world),factory)
    case W.CreateRejected{_,_}: IO.print("sender creation refused\n")

def main() -> IO(Unit):
  sender_created(W.create(~Schema,~Unit,~Unit,~U32,~empty,W.factory(),Unit{}))
