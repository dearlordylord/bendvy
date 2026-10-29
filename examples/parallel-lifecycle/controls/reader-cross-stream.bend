import Base
import ../notice-positive-core.bend as Core
import ../../../src/ecs/execution-lifecycle-notices.bend as Notice

def rebrand(reader:Core.Reader(~Core.First)) -> Notice.Reader<Core.First,Core.origin(),Notice.Despawned{}>:reader
