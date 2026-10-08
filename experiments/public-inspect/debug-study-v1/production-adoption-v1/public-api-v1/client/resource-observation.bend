import Base
import ../candidate/src/ecs/machine.bend as Machine
import ../candidate/src/ecs/debug-state-metadata.bend as State
# Presence is an actual owner observation, not inferred from a name or payload.
# Some(empty affine Array) remains present. No payload cloning is required.
def presence(~Payload:Type,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & Bool:
  match value:
    case None{}:(None{},False{})
    case Some{owner}:(Some{owner},True{})
def current_value(~S:Data,~Key:Data,value:Machine.CurrentView<S,Key,State.Value>) -> Maybe<&2,State.Value>:
  match value:
    case Machine.Unavailable{}:None{}
    case Machine.Current{value}:Some{value}
# A closed Check.resource_grant provider composes these projections and returns
# its entire Resource owner, including pending/previous/changed machine fields.

def current(~S:Data,~Key:Data,slot:Machine.Slot<S,Key,State.Value>) -> Maybe<&2,State.Value>:
  current_value(~S,~Key,Machine.current_view(~S,~Key,~State.Value,slot))
