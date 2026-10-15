import Base
import fixture.bend as F
import consumer.bend as C
def main() -> Maybe<C.Report<F.Garden>>: C.run(~F.Garden)
