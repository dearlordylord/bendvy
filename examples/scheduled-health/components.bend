import Base

# Independent components; entities may have either or both.
type Health is Data: Health{value: F32}
type HealthDecay is Data: HealthDecay{factor: F32}
# Application-authored spawn payload, not a new framework bundle API.
type EntitySeed is Data: EntitySeed{health: Health,decay: Maybe<&2,HealthDecay>}
