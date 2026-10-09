import Base
import ./scenario-schema.bend as S
import ./scenario-systems.bend as Systems
import ../../../../../../../src/ecs/ordinary-system.bend as System
import ./app.bend as App

def misuse(owner:System.Owner<S.Schema,Systems.plain_main_registry()>) -> System.Owner<S.Schema,Systems.plain_main_registry()> & System.Owner<S.Schema,Systems.plain_main_registry()>:
  (owner,owner)
