import Base
import ./plain-transient-application.bend as Plain
import ./declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def misuse() -> Cap.Write<Q.Frame<Plain.Schema,Plain.Plain,Unit,Unit>,Plain.Payload,U32>:
  Query.grant(~Plain.Schema,~Q.Frame<Plain.Schema,Plain.Plain,Unit,Unit>,~Cap.Read<Q.Frame<Plain.Schema,Plain.Plain,Unit,Unit>,U32>,Plain.plain_read())
