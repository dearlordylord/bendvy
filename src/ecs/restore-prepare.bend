import Base
import ./restore-data.bend as R
import ./snapshot-data.bend as Snapshot
import ./decode-data.bend as D
import ./entity-key.bend as Key
import ./decode-construction.bend as Constructor

type Walk<State:Type,Custom:Data> is Type:
  Working{state:State}
  Stopped{state:State,error:R.Error<Custom>}
def unknown(~Custom:Data,position:R.Position,name:String) -> R.Error<Custom>:
  match position:
    case R.Component{key}:R.UnknownComponent{key,name}
    case R.Resource{}:R.UnknownResource{name}
def invalid(~Custom:Data,position:R.Position,name:String,error:Constructor.Error<Custom>) -> R.Error<Custom>:
  match position:
    case R.Component{key}:R.InvalidComponent{key,name,error}
    case R.Resource{}:R.InvalidResource{name,error}
def dispatched(~State:Type,~Custom:Data,+position:R.Position,+name:String,next:State -> Walk<State,Custom>,observed:State & R.Dispatch<Custom>) -> Walk<State,Custom>:
  match observed:
    case (state,R.Unhandled{}):Stopped{state,unknown(~Custom,position,name)}
    case (state,R.Rejected{error}):Stopped{state,invalid(~Custom,position,name,error)}
    case (state,R.Staged{}):next(state)
def fields(~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,+position:R.Position,values:List<&2,D.Field>,state:State) -> Walk<State,Custom>:
  match values:
    case []:Working{state}
    case D.Field{+name,value} <> rest:dispatched(~State,~Custom,position,name,next => fields(~State,~Custom,~stage,position,rest,next),stage(state,position,D.Field{name,value}))
def seen(+key:Key.Key,keys:List<&2,Key.Key>) -> Bool:
  match keys:
    case []:False{}
    case other <> rest:Bool.or(Key.equal(key,other),seen(key,rest))
def continued(~State:Type,~Custom:Data,next:State -> Walk<State,Custom>,result:Walk<State,Custom>) -> Walk<State,Custom>:
  match result:
    case Working{state}:next(state)
    case Stopped{state,error}:Stopped{state,error}
def entity_checked(~State:Type,~Custom:Data,duplicate:Bool,+key:Key.Key,fields:List<&2,D.Field>,state:State,next:State -> Walk<State,Custom>,stage:State -> List<&2,D.Field> -> Walk<State,Custom>) -> Walk<State,Custom>:
  match duplicate:
    case True{}:Stopped{state,R.DuplicateEntity{key}}
    case False{}:continued(~State,~Custom,next,stage(state,fields))
def entities(~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,values:List<&2,Snapshot.Entity>,+previous:List<&2,Key.Key>,state:State) -> Walk<State,Custom>:
  match values:
    case []:Working{state}
    case Snapshot.Entity{+key,components} <> rest:entity_checked(~State,~Custom,seen(key,previous),key,components,state,next => entities(~State,~Custom,~stage,rest,key <> previous,next),(next => values => fields(~State,~Custom,~stage,R.Component{key},values,next)))
def finished(~State:Type,~Custom:Data,~release:State -> State,+input:Snapshot.Snapshot,result:Walk<State,Custom>) -> R.Prepared<State,Custom>:
  match result:
    case Working{state}:R.BendvyReady{state,input}
    case Stopped{state,error}:R.Refused{release(state),input,error}
def header(~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,version:Bool,progress:Bool,state:State,+input:Snapshot.Snapshot) -> R.Prepared<State,Custom>:
  match version progress input:
    case False{} _ Snapshot.Snapshot{value,next,entities,resources}:R.Refused{state,Snapshot.Snapshot{value,next,entities,resources},R.UnsupportedVersion{D.Number{value}}}
    case True{} False{} Snapshot.Snapshot{version,next,entities,resources}:R.Refused{state,Snapshot.Snapshot{version,next,entities,resources},R.InvalidSnapshot{"$.nextEntity"}}
    case True{} True{} Snapshot.Snapshot{version,next,+values,+resources}:finished(~State,~Custom,~release,Snapshot.Snapshot{version,next,values,resources},continued(~State,~Custom,state => fields(~State,~Custom,~stage,R.Resource{},resources,state),entities(~State,~Custom,~stage,values,[],state)))
def prepare(~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,state:State,+input:Snapshot.Snapshot) -> R.Prepared<State,Custom>:
  match input:
    case Snapshot.Snapshot{+version,+next,+entities,+resources}:header(~State,~Custom,~stage,~release,U32.is_eq(version,1),Bool.and(U32.is_lt(0,next),U32.is_le(next,131073)),state,Snapshot.Snapshot{version,next,entities,resources})
