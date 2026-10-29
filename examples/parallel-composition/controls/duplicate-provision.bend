import Base
import ../schema.bend as Schema
import ../feature-labels.bend as Labels
import ../../../src/ecs/execution-composer-service.bend as Service

def duplicate(world:Schema.World(),incoming:Labels.Host) -> Service.Provision<Schema.World(),Labels.Host> & Labels.Host:
  (Service.provide(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Host,~Schema.resources(),~Schema.host_route(),~{==},~{==},~{==},world,incoming),incoming)
