import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import ../public-v1/operations.bend as Operations
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-failure-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
def Owner() -> Type:Reader.OwnerType(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner)
def duplicate(owner:Owner()) -> Owner() & Owner():(owner,owner)
def main() -> Unit:Unit{}
