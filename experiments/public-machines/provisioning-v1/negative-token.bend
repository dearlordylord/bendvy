import Base
import requirements.bend as R
import declared.bend as D
import scene/provider.bend as P

type Undeclared is Data:
  Undeclared{}
def wrong() -> R.Requirements<P.SchemaA,D.Token<P.SchemaA>>:
  R.Requirements{[Undeclared{}]}
def main() -> Unit:
  Unit{}
