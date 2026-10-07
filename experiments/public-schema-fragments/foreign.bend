import Base
import application.bend as A
import fragment-left.bend as L
import fragment-right.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col

type Workshop is Data:
  Workshop{}
type Other is Data:
  Other{}

def observed(~S: Data,first: W.World<S,A.Store<S>,U32,U32>,read: W.World<S,A.Store<S>,U32,U32> & C.Access<List<&2,U32>>) -> String:
  (second,access) = read
  A.access_text(access) ++ ":" ++ A.observe(~S,first) ++ "|" ++ A.observe(~S,second)
def populated(~S: Data,first: W.World<S,A.Store<S>,U32,U32>,foreign: W.Handle<S>,second: W.World<S,A.Store<S>,U32,U32>,+own: W.Handle<S>) -> String:
  observed(~S,first,C.get(~S,~A.Store<S>,~U32,~U32,~Col.Column<S,R.Payload>,~L.Payload,~List<&2,U32>,~L.Token,~A.take_left(~S),~A.put_left(~S),~A.project_left,A.left_family(~S),A.right_write(~S,A.left_write(~S,second,own,L.Payload{ANode{ALeaf{20},ALeaf{21}}}),own,R.Payload{ANode{ALeaf{4},ALeaf{5}}}),foreign))
def second_active(~S: Data,first: W.World<S,A.Store<S>,U32,U32>,foreign: W.Handle<S>,active: W.World<S,A.Store<S>,U32,U32> & W.Status,own: W.Handle<S>) -> String:
  (second,_) = active
  populated(~S,first,foreign,second,own)
def second_reserved(~S: Data,first: W.World<S,A.Store<S>,U32,U32>,foreign: W.Handle<S>,reserved: W.World<S,A.Store<S>,U32,U32> & W.Reservation<S>) -> String:
  match reserved:
    case (second,W.Reserved{+own}): second_active(~S,first,foreign,W.activate(~S,~A.Store<S>,~U32,~U32,second,own),own)
    case _: "second-reservation-failed"
def second_created(~S: Data,first: W.World<S,A.Store<S>,U32,U32>,foreign: W.Handle<S>,created: W.Creation<S,A.Store<S>,U32,U32>) -> String:
  match created:
    case W.Created{_,second}: second_reserved(~S,first,foreign,W.reserve_id(~S,~A.Store<S>,~U32,~U32,second))
    case _: "second-create-failed"
def first_active(~S: Data,factory: W.Factory,active: W.World<S,A.Store<S>,U32,U32> & W.Status,+handle: W.Handle<S>) -> String:
  (first,_) = active
  second_created(~S,A.right_write(~S,A.left_write(~S,first,handle,L.Payload{ANode{ALeaf{10},ALeaf{11}}}),handle,R.Payload{ANode{ALeaf{2},ALeaf{3}}}),handle,W.create(~S,~A.Store<S>,~U32,~U32,~A.empty_store(~S),factory,0))
def first_reserved(~S: Data,factory: W.Factory,reserved: W.World<S,A.Store<S>,U32,U32> & W.Reservation<S>) -> String:
  match reserved:
    case (first,W.Reserved{+handle}): first_active(~S,factory,W.activate(~S,~A.Store<S>,~U32,~U32,first,handle),handle)
    case _: "first-reservation-failed"
def first_created(~S: Data,created: W.Creation<S,A.Store<S>,U32,U32>) -> String:
  match created:
    case W.Created{factory,first}: first_reserved(~S,factory,W.reserve_id(~S,~A.Store<S>,~U32,~U32,first))
    case _: "first-create-failed"
def run(~S: Data) -> String:
  first_created(~S,W.create(~S,~A.Store<S>,~U32,~U32,~A.empty_store(~S),W.factory(),0))
def main() -> IO(Unit):
  IO.print(run(~Workshop) ++ "\n" ++ run(~Other))
