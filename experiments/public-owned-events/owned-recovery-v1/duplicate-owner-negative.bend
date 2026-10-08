import Base
import controls.bend as Controls
import staging.bend as Stage

def duplicate(outcome:Controls.Outcome) -> List<Controls.Payload> & List<Controls.Payload>:
  match outcome:
    case Controls.Aborted{Stage.Aborted{owners}}: (owners,owners)
    case _: ([],[])
def reached() -> List<Controls.Payload> & List<Controls.Payload>:
  duplicate(Controls.aborted())
