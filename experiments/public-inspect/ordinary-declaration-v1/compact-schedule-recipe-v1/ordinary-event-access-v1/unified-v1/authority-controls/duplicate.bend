import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import ../consumer-public.bend as Consumer
def twice(host:Consumer.Host) -> Consumer.Host & String:
  (first,_) = Consumer.snapshot(host,"first")
  Consumer.snapshot(host,"second")
def main() -> Unit:Unit{}
