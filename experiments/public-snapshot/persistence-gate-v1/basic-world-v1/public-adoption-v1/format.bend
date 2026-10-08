import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Declaration
import ./game.bend as Save
import ./leaf.bend as Leaf
import ./declaration.bend as Decl
import ../public-gate-v1/gate.bend as Gate
import ../export.bend as Export
import ../owner.bend as Owner
import ./world-owner.bend as WorldOwner
import ./validation.bend as Validation
import ./driver.bend as Driver
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

# Closed-fixture observation renderer: names and paths are authored ASCII.
# Not a proposed generic wire codec or arbitrary String JSON serializer.
def quoted(value:String) -> String:
  "\"" ++ value ++ "\""
type Token is Data:
  Text{value:String}
  Value{value:D.Raw}
def value_tokens(values:List<&2,D.Raw>,tail:List<&2,Token>) -> List<&2,Token>:
  match values:
    case []:tail
    case value <> []:Value{value} <> tail
    case value <> rest:Value{value} <> Text{","} <> value_tokens(rest,tail)
def field_tokens(fields:List<&2,D.Field>,tail:List<&2,Token>) -> List<&2,Token>:
  match fields:
    case []:tail
    case D.Field{name,value} <> []:Text{quoted(name) ++ ":"} <> Value{value} <> tail
    case D.Field{name,value} <> rest:Text{quoted(name) ++ ":"} <> Value{value} <> Text{","} <> field_tokens(rest,tail)
def expand(value:D.Raw,tail:List<&2,Token>) -> List<&2,Token>:
  match value:
    case D.Number{number}:Text{U32.show(number)} <> tail
    case D.Array{values}:Text{"["} <> value_tokens(values,Text{"]"} <> tail)
    case D.Object{values}:Text{"{"} <> field_tokens(values,Text{"}"} <> tail)
    case D.Text{text}:Text{quoted(text)} <> tail
    case D.Boolean{True{}}:Text{"true"} <> tail
    case D.Boolean{False{}}:Text{"false"} <> tail
    case D.Null{}:Text{"null"} <> tail
    case _:Text{quoted("UnexpectedRawConstructor")} <> tail
type Queue is Data:
  Queue{tokens:List<&2,Token>}
def render(fuel:Nat,work:Queue) -> String:
  match fuel work:
    case _ Queue{[]}:""
    case 0n _:"RENDER-FUEL"
    case 1n+more Queue{Text{value} <> rest}:value ++ render(more,Queue{rest})
    case 1n+more Queue{Value{value} <> rest}:render(more,Queue{expand(value,rest)})
def raw(value:D.Raw) -> String:
  render(128n,Queue{[Value{value}]})
def fields(fields:List<&2,D.Field>) -> String:
  raw(D.Object{fields})
def entity(value:Export.Entity) -> String:
  match value:
    case Export.Entity{id,values}:"{\"id\":" ++ U32.show(id) ++ ",\"components\":" ++ fields(values) ++ "}"
def entities_tail(values:List<&2,Export.Entity>) -> String:
  match values:
    case []:""
    case first <> rest:"," ++ entity(first) ++ entities_tail(rest)
def entities(values:List<&2,Export.Entity>) -> String:
  match values:
    case []:"[]"
    case first <> rest:"[" ++ entity(first) ++ entities_tail(rest) ++ "]"
def snapshot(value:Export.Snapshot) -> String:
  match value:
    case Export.Snapshot{version,next,values,resources}:"{\"version\":" ++ U32.show(version) ++ ",\"nextEntity\":" ++ U32.show(next) ++ ",\"entities\":" ++ entities(values) ++ ",\"resources\":" ++ fields(resources) ++ "}"
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:"{\"added\":" ++ U32.show(added) ++ ",\"changed\":" ++ U32.show(changed) ++ "}"
def column(value:Owner.ColumnOwner) -> String:
  match value:
    case Owner.ColumnOwner{rows,first,second}:"{\"rows\":" ++ entities(rows) ++ ",\"firstStamp\":" ++ stamp(first) ++ ",\"secondStamp\":" ++ stamp(second) ++ "}"
def codec(value:D.Codec) -> String:
  match value:
    case D.ArrayValue{D.FiniteNumber{}}:"{\"ArrayValue\":{\"FiniteNumber\":{}}}"
    case D.Nullable{D.ArrayValue{D.FiniteNumber{}}}:"{\"Nullable\":{\"ArrayValue\":{\"FiniteNumber\":{}}}}"
    case D.Nullable{D.ArrayValue{D.Integer{}}}:"{\"Nullable\":{\"ArrayValue\":{\"Integer\":{}}}}"
    case D.ArrayValue{D.Integer{}}:"{\"ArrayValue\":{\"Integer\":{}}}"
    case D.ArrayValue{D.LiteralValues{values}}:"{\"ArrayValue\":{\"LiteralValues\":" ++ raw(D.Array{values}) ++ "}}"
    case D.Literal{value}:"{\"Literal\":" ++ raw(value) ++ "}"
    case _:quoted("UnexpectedCodecConstructor")
def store(value:Owner.StoreOwner) -> String:
  match value:
    case Owner.StoreOwner{saved,transient,description}:"{\"saved\":" ++ column(saved) ++ ",\"transient\":" ++ column(transient) ++ ",\"codec\":" ++ codec(description) ++ "}"
def resources(value:Owner.ResourceOwner) -> String:
  match value:
    case Owner.ResourceOwner{saved,transient,description}:"{\"saved\":" ++ raw(saved) ++ ",\"transient\":" ++ raw(transient) ++ ",\"codec\":" ++ codec(description) ++ "}"
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,id}:"{\"namespace\":" ++ U32.show(namespace) ++ ",\"id\":" ++ U32.show(id) ++ "}"
def handles_tail(~S:Data,values:List<&2,W.Handle<S>>) -> String:
  match values:
    case []:""
    case first <> rest:"," ++ handle(~S,first) ++ handles_tail(~S,rest)
def handles(~S:Data,values:List<&2,W.Handle<S>>) -> String:
  match values:
    case []:"[]"
    case first <> rest:"[" ++ handle(~S,first) ++ handles_tail(~S,rest) ++ "]"
def unit_events(events:List<&2,Unit>) -> String:
  match events:
    case []:"[]"
    case _:quoted("UnexpectedNonemptyEvents")
def registrations(values:List<&2,W.RegistrationMeta>) -> String:
  match values:
    case []:"[]"
    case _:quoted("UnexpectedRegistrations")
def owner(~S:Data,value:WorldOwner.Observed<S>) -> String:
  match value:
    case WorldOwner.Observed{namespace,nextId,highWater,capacity,depth,live,columns,resource,events,pendingCount,registered,nextSystemId,clock}:"{\"namespace\":" ++ U32.show(namespace) ++ ",\"nextId\":" ++ U32.show(nextId) ++ ",\"highWater\":" ++ U32.show(highWater) ++ ",\"capacity\":" ++ U32.show(capacity) ++ ",\"depth\":" ++ Nat.show(depth) ++ ",\"handles\":" ++ handles(~S,live) ++ ",\"store\":" ++ store(columns) ++ ",\"resources\":" ++ resources(resource) ++ ",\"events\":" ++ unit_events(events) ++ ",\"pendingCount\":" ++ U32.show(pendingCount) ++ ",\"registrations\":" ++ registrations(registered) ++ ",\"nextSystemId\":" ++ U32.show(nextSystemId) ++ ",\"clock\":" ++ U32.show(clock) ++ "}"
def validation_error(value:D.Error) -> String:
  match value:
    case D.Invalid{path,expected,actual}:"{\"Invalid\":{\"path\":" ++ quoted(path) ++ ",\"expected\":" ++ quoted(expected) ++ ",\"actual\":" ++ raw(actual) ++ "}}"
    case D.FuelExhausted{path}:"{\"FuelExhausted\":{\"path\":" ++ quoted(path) ++ "}}"
def checked(value:D.Checked) -> String:
  match value:
    case D.Accepted{value}:"{\"Accepted\":" ++ raw(value) ++ "}"
    case D.Rejected{error}:"{\"Rejected\":" ++ validation_error(error) ++ "}"
def checked_field(value:Validation.CheckedField) -> String:
  match value:
    case Validation.CheckedField{name,result}:"{\"name\":" ++ quoted(name) ++ ",\"result\":" ++ checked(result) ++ "}"
def checks_tail(values:List<&2,Validation.CheckedField>) -> String:
  match values:
    case []:""
    case first <> rest:"," ++ checked_field(first) ++ checks_tail(rest)
def checks(values:List<&2,Validation.CheckedField>) -> String:
  match values:
    case []:"[]"
    case first <> rest:"[" ++ checked_field(first) ++ checks_tail(rest) ++ "]"
def checked_entity(value:Validation.CheckedEntity) -> String:
  match value:
    case Validation.CheckedEntity{id,fields}:"{\"id\":" ++ U32.show(id) ++ ",\"fields\":" ++ checks(fields) ++ "}"
def checked_entities_tail(values:List<&2,Validation.CheckedEntity>) -> String:
  match values:
    case []:""
    case first <> rest:"," ++ checked_entity(first) ++ checked_entities_tail(rest)
def checked_entities(values:List<&2,Validation.CheckedEntity>) -> String:
  match values:
    case []:"[]"
    case first <> rest:"[" ++ checked_entity(first) ++ checked_entities_tail(rest) ++ "]"
def validation(value:Validation.Validation) -> String:
  match value:
    case Validation.Validation{entities,resources}:"{\"entities\":" ++ checked_entities(entities) ++ ",\"resources\":" ++ checks(resources) ++ "}"
def gate_codec(~S:Data,~declaration:Declaration.Declaration<S,F.Payload>,gate:Gate.Gate<S,F.Payload,declaration>) -> String:
  match gate:
    case Gate.Transient{}:quoted("Transient")
    case Gate.Persisted{description,_}:codec(description)
def component_metadata(~S:Data,value:Owner.StoreOwner) -> String:
  match value:
    case Owner.StoreOwner{_,_,description}:gate_codec(~S,~F.declaration(~S),Leaf.factory(~S,~F.Payload,~F.declaration(~S),~F.project,Decl.constructed(~S,~F.Payload,~F.declaration(~S),~F.project,description)))
def resource_metadata(~S:Data,value:Owner.ResourceOwner) -> String:
  match value:
    case Owner.ResourceOwner{_,_,description}:gate_codec(~S,~Save.settings(~S),Leaf.factory(~S,~F.Payload,~Save.settings(~S),~F.project,Decl.constructed(~S,~F.Payload,~Save.settings(~S),~F.project,description)))
def gate_metadata(~S:Data,value:WorldOwner.Observed<S>) -> String:
  match value:
    case WorldOwner.Observed{_,_,_,_,_,_,columns,resource,_,_,_,_,_}:"{\"component\":" ++ component_metadata(~S,columns) ++ ",\"resource\":" ++ resource_metadata(~S,resource) ++ "}"
def report(~S:Data,value:Driver.Report<S>) -> String:
  match value:
    case Driver.Report{+before,firstOwner,secondOwner,first,second,after,firstValidation,afterValidation,+returned}:"{\"before\":" ++ owner(~S,before) ++ ",\"firstOwner\":" ++ owner(~S,firstOwner) ++ ",\"secondOwner\":" ++ owner(~S,secondOwner) ++ ",\"first\":" ++ snapshot(first) ++ ",\"second\":" ++ snapshot(second) ++ ",\"after\":" ++ snapshot(after) ++ ",\"firstValidation\":" ++ validation(firstValidation) ++ ",\"afterValidation\":" ++ validation(afterValidation) ++ ",\"gateMetadataBefore\":" ++ gate_metadata(~S,before) ++ ",\"gateMetadataAfter\":" ++ gate_metadata(~S,returned) ++ ",\"owner\":" ++ owner(~S,returned) ++ "}"
