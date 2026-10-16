import Base

type SimulationEvent is Data:
  SimulationHit{id: U32,damage: U32}
  SimulationDeath{id: U32}
