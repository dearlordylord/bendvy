import Base
import ./scenario-schema.bend as S
import ./scenario-systems.bend as Systems
import ../../../../../../../src/ecs/ordinary-system.bend as System
import ./app.bend as App

type Other is Data:
  Other{}
def misuse(owner:System.Owner<S.Schema,Systems.plain_main_registry()>) -> System.Owner<Other,Systems.plain_main_registry()>:
  owner
