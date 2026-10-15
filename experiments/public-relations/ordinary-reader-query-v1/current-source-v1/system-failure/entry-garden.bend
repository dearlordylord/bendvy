import Base
import consumer.bend as C
import fixture.bend as F
def main() -> Maybe<C.Report<F.Garden>>:C.run(~F.Garden)
