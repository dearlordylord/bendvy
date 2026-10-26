import Base
import ../schema.bend as Schema
import ../feature-labels.bend as Labels
import ../../../src/ecs/execution-composer-service.bend as Service
import ../../../src/ecs/world.bend as W

type Other is Data:Other{}
def wrong(world:Schema.World(),incoming:Labels.Host) -> Service.Provision<W.World<Other,Schema.Store(),Schema.Resources(),Unit>,Labels.Host>:
  Service.provide(~Other,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Host,~Schema.resources(),~Schema.host_route(),~{==},~{==},~{==},world,incoming)
