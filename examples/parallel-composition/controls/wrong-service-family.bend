import Base
import ../schema.bend as Schema
import ../../../src/ecs/execution-composer-service.bend as Service

def wrong(world:Schema.World(),incoming:Array<U32>) -> Service.Provision<Schema.World(),Array<U32>>:
  Service.provide(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Array<U32>,~Schema.resources(),~Schema.host_route(),~{==},~{==},~{==},world,incoming)
