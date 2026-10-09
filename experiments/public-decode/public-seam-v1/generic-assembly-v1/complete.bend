import Base
import ./public-fixture.bend as Second
import ./first-public-fixture.bend as First
import ./recovery-fixture.bend as Recovery

type Candidate is Data:Candidate{second:Second.Candidate,first:First.Candidate,recovery:Recovery.Candidate}
def main() -> Candidate:Candidate{Second.main(),First.main(),Recovery.main()}
