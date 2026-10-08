import Base
import ./canonical-schema.bend as Schema
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# Evidence-only owner observations. These are not normal-user debug adapters.
type Resources is Data:
  Resources{entries:List<&2,Schema.Entry<Game.GameSchema>>,settings:String,clock:String}
type Snapshot is Data:
  Snapshot{namespace:U32,nextId:U32,highWater:U32,live:String,capacity:U32,depth:Nat,resources:Resources,events:List<&2,U32>,pendingCount:U32,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def array_join(~T:Data,a:Array<T> & String,b:Array<T> & String) -> Array<T> & String:
  match a b:
    case (left,l),(right,r):(ANode{left,right},"node("++l++","++r++")")
def array(~T:Data,~show:T -> String,owner:Array<T>) -> Array<T> & String:
  match owner:
    case ALeaf{+value}:(ALeaf{value},"leaf("++show(value)++")")
    case ANode{left,right}:array_join(~T,array(~T,~show,left),array(~T,~show,right))
def resource_clock(+entries:List<&2,Schema.Entry<Game.GameSchema>>,settings:Array<U32>,settingsText:String,observed:Array<U32> & String) -> Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()> & Resources:
  match observed:
    case (clock,clockText):(Schema.Owner{entries,settings,Game.Clock{clock}},Resources{entries,settingsText,clockText})
def resource_settings(entries:List<&2,Schema.Entry<Game.GameSchema>>,clock:Array<U32>,observed:Array<U32> & String) -> Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()> & Resources:
  match observed:
    case (settings,settingsText):resource_clock(entries,settings,settingsText,array(~U32,~U32.show,clock))
def resources(owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>) -> Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()> & Resources:
  match owner:
    case Schema.Owner{entries,settings,Game.Clock{clock}}:resource_settings(entries,clock,array(~U32,~U32.show,settings))
def pending_join(head:Application.World() -> Application.World(),observed:List<(Application.World() -> Application.World())> & U32) -> List<(Application.World() -> Application.World())> & U32:
  match observed:
    case (rest,count):(head<>rest,U32.add(count,1))
def pending(values:List<(Application.World() -> Application.World())>) -> List<(Application.World() -> Application.World())> & U32:
  match values:
    case []:([],0)
    case head<>rest:pending_join(head,pending(rest))
def snapshot_resources(+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,liveText:String,+capacity:U32,+depth:Nat,+events:List<&2,U32>,commands:List<(Application.World() -> Application.World())>,+count:U32,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observed:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()> & Resources) -> Application.World() & Snapshot:
  match observed:
    case (owner,values):(W.World{namespace,nextId,highWater,live,capacity,depth,Unit{},owner,events,commands,registrations,nextSystemId,clock},Snapshot{namespace,nextId,highWater,liveText,capacity,depth,values,events,count,registrations,nextSystemId,clock})
def snapshot_pending(namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,liveText:String,capacity:U32,depth:Nat,owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,events:List<&2,U32>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,observed:List<(Application.World() -> Application.World())> & U32) -> Application.World() & Snapshot:
  match observed:
    case (commands,count):snapshot_resources(namespace,nextId,highWater,live,liveText,capacity,depth,events,commands,count,registrations,nextSystemId,clock,resources(owner))
def snapshot_live(namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,events:List<&2,U32>,commands:List<(Application.World() -> Application.World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,observed:Array<Bool> & String) -> Application.World() & Snapshot:
  match observed:
    case (live,liveText):snapshot_pending(namespace,nextId,highWater,live,liveText,capacity,depth,owner,events,registrations,nextSystemId,clock,pending(commands))
def world(world:Application.World()) -> Application.World() & Snapshot:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,Unit{},owner,events,commands,registrations,nextSystemId,clock}:snapshot_live(namespace,nextId,highWater,capacity,depth,owner,events,commands,registrations,nextSystemId,clock,array(~Bool,~boolean,live))
