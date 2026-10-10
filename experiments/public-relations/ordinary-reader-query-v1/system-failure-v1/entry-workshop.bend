import Base
import consumer.bend as C
import ../mutation-composition-v1/fixture.bend as F
def main() -> Maybe<C.Report<F.Workshop>>:C.run(~F.Workshop)
