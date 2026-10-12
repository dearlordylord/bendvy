import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine-value-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
type Other is Data:
  Other{}
def subject(app:C.Application(~Beta)) -> C.Application(~Alpha) & Maybe<&2,Dump.View<Alpha,C.Token,U32>>:
  Dump.snapshot(~Alpha,~C.Token,~U32,~Array<U32>,~C.Resource<Alpha>,~U32,~C.take(~Alpha),~C.put(~Alpha),~U32.is_eq,~C.declaration(~Alpha),~U32.show,~Unit,~Unit,~Build.empty_observe(~C.World(~Alpha)),~Leaf.empty(~Alpha),app)
def main() -> U32:
  0
