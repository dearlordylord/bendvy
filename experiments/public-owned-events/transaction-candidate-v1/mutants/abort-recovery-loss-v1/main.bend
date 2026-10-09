import Base
import controls.bend as F
import observation.bend as O

type Batch is Data: Batch{seeded:O.SeedView,seedRefused:O.SeedView,success:O.RunView,failure:O.RunView,foreign:O.RunView}
def main() -> Batch:
  Batch{O.seed_dto(F.seeded()),O.seed_dto(F.seed_refused()),O.dto(O.success()),O.dto(O.failure()),O.dto(O.foreign())}
