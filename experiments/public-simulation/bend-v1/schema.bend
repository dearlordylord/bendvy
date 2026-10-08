import Base
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import ./geometry.bend as Geometry
import ./storage.bend as Storage

def PositionFamily(~S: Data) -> Data:
  C.Family<S,Storage.Store<S>,Storage.PositionRest<S>,Array<U32>,Geometry.Cell,Storage.PositionToken<S>,Storage.take_position(~S),Storage.put_position(~S),Geometry.project>
def VelocityFamily(~S: Data) -> Data:
  C.Family<S,Storage.Store<S>,Storage.VelocityRest<S>,Array<U32>,Geometry.Cell,Storage.VelocityToken<S>,Storage.take_velocity(~S),Storage.put_velocity(~S),Geometry.project>
def HealthFamily(~S: Data) -> Data:
  C.Family<S,Storage.Store<S>,Storage.HealthRest<S>,Array<U32>,Geometry.Cell,Storage.HealthToken<S>,Storage.take_health(~S),Storage.put_health(~S),Geometry.project>
def position(~S: Data) -> PositionFamily(~S): C.Family{"Simulation/Position"}
def velocity(~S: Data) -> VelocityFamily(~S): C.Family{"Simulation/Velocity"}
def health(~S: Data) -> HealthFamily(~S): C.Family{"Simulation/Health"}
