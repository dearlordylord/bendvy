import Base
import ./normal-values.bend as Game
import ./normal-snapshot.bend as Snapshot
import ./normal-consumer.bend as Consumer
import ./canonical-schema.bend as Schema
import ./canonical-app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
# Evidence-only ASCII fixture serializer; never a user debug metadata adapter.
def quote(value:String) -> String:
  "\""++value++"\""
def list(values:List<&2,String>) -> String:
  "["++String.join(values,",")++"]"
def names(values:List<&2,String>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:quote(head)<>names(rest)
def nums(values:List<&2,U32>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:U32.show(head)<>nums(rest)
def field(key:String,value:String) -> String:
  quote(key)++":"++value
def object(values:List<&2,String>) -> String:
  "{"++String.join(values,",")++"}"
def path(value:Schema.Path) -> String:
  match value:
    case Schema.Left{}:quote("Left")
    case Schema.Right{}:quote("Right")
def debug(value:App.Debug) -> String:
  match value:
    case App.Enabled{}:quote("Enabled")
    case App.Disabled{}:quote("Disabled")
def entry(value:Schema.Entry<Game.GameSchema>) -> String:
  match value:
    case Schema.Entry{id,key,name}:object([field("id",U32.show(id)),field("key",quote(key)),field("name",quote(name))])
def entries(values:List<&2,Schema.Entry<Game.GameSchema>>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:entry(head)<>entries(rest)
def need(value:SP.Requirement<Game.GameSchema>) -> String:
  match value:
    case SP.Resource{id}:object([field("kind",quote("Resource")),field("id",U32.show(id))])
    case SP.Component{id}:object([field("kind",quote("Component")),field("id",U32.show(id))])
    case SP.Service{id}:object([field("kind",quote("Service")),field("id",U32.show(id))])
def needs(values:List<&2,SP.Requirement<Game.GameSchema>>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:need(head)<>needs(rest)
def step(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:object([field("kind",quote("System")),field("id",U32.show(id)),field("condition",U32.show(condition))])
    case Sch.Phase{name}:object([field("kind",quote("Phase")),field("name",quote(name))])
    case Sch.Barrier{}:object([field("kind",quote("Barrier"))])
def steps(values:List<&2,Sch.Step>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:step(head)<>steps(rest)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:object([field("id",U32.show(id)),field("name",quote(name)),field("access",list(names(access)))])
def registrations(values:List<&2,W.RegistrationMeta>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>rest:registration(head)<>registrations(rest)
def world(value:Snapshot.Snapshot) -> String:
  match value:
    case Snapshot.Snapshot{namespace,nextId,highWater,live,capacity,depth,Snapshot.Resources{schemaEntries,settings,clockCells},events,pendingCount,regs,nextSystemId,clock}:object([field("namespace",U32.show(namespace)),field("nextId",U32.show(nextId)),field("highWater",U32.show(highWater)),field("live",quote(live)),field("capacity",U32.show(capacity)),field("depth",Nat.show(depth)),field("store",quote("unit")),field("schemaEntries",list(entries(schemaEntries))),field("settingsCells",quote(settings)),field("clockCells",quote(clockCells)),field("events",list(nums(events))),field("pendingCount",U32.show(pendingCount)),field("registrations",list(registrations(regs))),field("nextSystemId",U32.show(nextSystemId)),field("clock",U32.show(clock))])
def app(value:Consumer.AppSnapshot) -> String:
  match value:
    case Consumer.AppSnapshot{vdebug,namespace,name,vsteps,systemNamespace,id,systemName,access,cursor,first,second,ventries,ownerNeeds,vneeds}:object([field("debug",debug(vdebug)),field("schedule",object([field("namespace",U32.show(namespace)),field("name",quote(name)),field("steps",list(steps(vsteps)))])),field("registry",object([field("namespace",U32.show(systemNamespace)),field("id",U32.show(id)),field("name",quote(systemName)),field("access",list(names(access))),field("cursor",U32.show(cursor))])),field("paths",list([path(first),path(second)])),field("entries",list(entries(ventries))),field("ownerNeeds",list(needs(ownerNeeds))),field("provisionedNeeds",list(needs(vneeds)))])
def description(value:App.Description<Game.GameSchema>) -> String:
  match value:
    case App.Description{namespace,scheduleName,vsteps,systemNamespace,systemID,systemName,access,firstPath,secondPath,ventries,vneeds}:object([field("namespace",U32.show(namespace)),field("scheduleName",quote(scheduleName)),field("steps",list(steps(vsteps))),field("systemNamespace",U32.show(systemNamespace)),field("systemID",U32.show(systemID)),field("systemName",quote(systemName)),field("access",list(names(access))),field("firstPath",path(firstPath)),field("secondPath",path(secondPath)),field("entries",list(entries(ventries))),field("needs",list(needs(vneeds)))])
def maybe_description(value:Maybe<&2,App.Description<Game.GameSchema>>) -> String:
  match value:
    case None{}:"null"
    case Some{present}:description(present)
def observation(value:Consumer.Observation) -> String:
  match value:
    case Consumer.Observation{beforeWorld,afterWorld,beforeApp,afterApp,available,vdescription}:object([field("beforeWorld",world(beforeWorld)),field("afterWorld",world(afterWorld)),field("beforeApp",app(beforeApp)),field("afterApp",app(afterApp)),field("available",list(needs(available))),field("description",maybe_description(vdescription))])
