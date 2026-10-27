import Base
import ./execution-save-data.bend as Saved
import ./restore-data.bend as R
import ./restore-prepare.bend as Prepare
import ./decode-data.bend as D

# Constructor records and their undo functions remain affine in State. A refusal
# runs the closed schema's release operation; it never mutates the receiver.
def persisted(values:List<&2,Saved.Field>) -> List<&2,D.Field>:
  match values:
    case []:[]
    case Saved.Field{key,True{},Saved.Persisted{raw},_} <> rest:D.Field{key,raw} <> persisted(rest)
    case _ <> rest:persisted(rest)
def continued(~State:Type,~Custom:Data,next:State -> Prepare.Walk<State,Custom>,result:Prepare.Walk<State,Custom>) -> Prepare.Walk<State,Custom>:
  match result:
    case Prepare.Working{state}:next(state)
    case Prepare.Stopped{state,error}:Prepare.Stopped{state,error}
def entities(~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,values:List<&2,Saved.Entity>,state:State) -> Prepare.Walk<State,Custom>:
  match values:
    case []:Prepare.Working{state}
    case Saved.Entity{+key,fields} <> rest:continued(~State,~Custom,next => entities(~State,~Custom,~stage,rest,next),Prepare.fields(~State,~Custom,~stage,R.Component{key},persisted(fields),state))
def finished(~S:Data,~State:Type,~Custom:Data,~release:State -> State,input:Saved.Snapshot<S>,result:Prepare.Walk<State,Custom>) -> State & (Saved.Snapshot<S> & Maybe<&2,R.Error<Custom>>):
  match result:
    case Prepare.Working{state}:(state,(input,None{}))
    case Prepare.Stopped{state,error}:(release(state),(input,Some{error}))
# Called only after schema and metadata admission. Raw omission is deliberate:
# Transient values have no constructor invocation and no invented default owner.
def admitted(~S:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,state:State,+input:Saved.Snapshot<S>) -> State & (Saved.Snapshot<S> & Maybe<&2,R.Error<Custom>>):
  match input:
    case Saved.Snapshot{+version,+metadata,+values,+resources}:finished(~S,~State,~Custom,~release,Saved.Snapshot{version,metadata,values,resources},continued(~State,~Custom,next => Prepare.fields(~State,~Custom,~stage,R.Resource{},persisted(resources),next),entities(~State,~Custom,~stage,values,state)))
