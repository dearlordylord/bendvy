import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import ../public-v1/operations.bend as Operations
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-failure-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
type Other is Data:Other{}
def misuse(runtime:Events.Runtime(),declaration:Decl.Declaration<Other>) -> Reader.Registration<F.S,F.Store(),F.Resources(),Events.Events(),Events.Metadata(),Array<U32>,Reader.OwnerType(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner)>:Reader.register(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,~Events.Metadata(),~Array<U32>,runtime,declaration,"ParentFailures")
def main() -> Unit:Unit{}
