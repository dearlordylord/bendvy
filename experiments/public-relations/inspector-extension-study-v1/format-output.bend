import Base
import root-source/world.bend as W
import fixture-state.bend as State
import fixture-consumer.bend as C
import fixture-driver.bend as Driver
import fixture-missing.bend as Missing
import fixture-dump.bend as Dump
import machine-requirements.bend as Req
import root-source/machine.bend as M
import root-source/inspector.bend as I
import root-source/inspector-metadata.bend as Meta

# Closed-fixture names/text are fixed ASCII without quote/backslash/control
# characters. This is not a general public JSON serializer.
def quote(value:String) -> String:
  "\"" ++ value ++ "\""
def current(~S:Data,~K:Data,value:M.CurrentView<S,K,U32>) -> String:
  match value:
    case M.Unavailable{}:"null"
    case M.Current{value}:U32.show(value)
def values(~S:Data,value:C.Values<S>) -> String:
  match value:
    case C.Values{flow,level}:"[" ++ current(~S,~State.FlowToken,flow) ++ "," ++ current(~S,~State.LevelToken,level) ++ "]"
def record(~S:Data,+schema:String,value:Driver.Record<S>) -> String:
  match value:
    case Driver.Record{label,value,inspections,world,inspector,system}:"{\"schema\":" ++ quote(schema) ++ ",\"label\":" ++ quote(label) ++ ",\"current\":" ++ values(~S,value) ++ ",\"inspections\":" ++ U32.show(inspections) ++ ",\"world\":" ++ quote(world) ++ ",\"inspector\":" ++ quote(inspector) ++ ",\"system\":" ++ quote(system) ++ "}"
def records(~S:Data,+schema:String,items:List<&2,Driver.Record<S>>) -> List<&2,String>:
  match items:
    case []:[]
    case head <> rest:record(~S,schema,head) <> records(~S,schema,rest)
type Section is Data:
  Section{records:List<&2,String>,errors:List<&2,String>}
def application(~S:Data,schema:String,result:Driver.Output<S>) -> Section:
  match result:
    case Driver.Completed{_,Driver.Session{_,_,_,_,items,errors}}:Section{records(~S,schema,items),errors}
    case Driver.CreationRefused{_,_}:Section{[],["creation-refused"]}
    case Driver.RegistrationRefused{_,_}:Section{[],["registration-refused"]}
def requirement(~S:Data,item:Req.Requirement<S>) -> String:
  match item:
    case Req.Resource{Meta.Resource{id,name}}:"{\"kind\":\"Resource\",\"id\":" ++ U32.show(id) ++ ",\"name\":" ++ quote(name) ++ "}"
    case Req.MachineRequirement{id,name}:"{\"kind\":\"Machine\",\"id\":" ++ U32.show(id) ++ ",\"name\":" ++ quote(name) ++ "}"
def instance(~S:Data,value:I.Instance<S>) -> String:
  match value:
    case I.Fresh{}:"fresh"
    case I.Active{cursor,registered}:U32.show(cursor) ++ ":" ++ U32.show(registered)
def maybe_result(~S:Data,value:Maybe<&2,C.Values<S>>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:values(~S,value)
def missing_dumped(~S:Data,schema:String,inspectorOwner:I.Instance<S>,args:List<&2,U32>,missing:List<&2,Req.Requirement<S>>,bodies:U32,result:Maybe<&2,C.Values<S>>,observed:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> String:
  (world,text)=observed
  "{\"schema\":" ++ quote(schema) ++ ",\"world\":" ++ quote(text) ++ ",\"instance\":" ++ quote(instance(~S,inspectorOwner)) ++ ",\"args\":" ++ List.show(&2,U32,U32.show,args) ++ ",\"missing\":" ++ List.show(&2,Req.Requirement<S>,requirement(~S),missing) ++ ",\"bodies\":" ++ U32.show(bodies) ++ ",\"result\":" ++ maybe_result(~S,result) ++ "}"
def missing(~S:Data,schema:String,result:Missing.Output<S>) -> String:
  match result:
    case Missing.Completed{_,Missing.MissingRun{world,instance,args,requirements,bodies,result}}:missing_dumped(~S,schema,instance,args,requirements,bodies,result,Dump.world(~S,world))
    case Missing.CreationRefused{_,_}:"{\"schema\":" ++ quote(schema) ++ ",\"error\":\"creation-refused\"}"
def combine(a:Section,b:Section,missingA:String,missingB:String) -> String:
  match a b:
    case Section{rowsA,errorsA} Section{rowsB,errorsB}:"{\"format\":1,\"application\":\"InspectorCommittedMachinesBoundary\",\"records\":" ++ List.show(&2,String,x => x,List.append(&2,String,rowsA,rowsB)) ++ ",\"scope\":" ++ quote("Independent closed-fixture whole owner/metadata boundary strings before outputs; pending closures absent, count0; no reconstruction of arbitrary closures or arbitrary schema truth") ++ ",\"missing\":[" ++ missingA ++ "," ++ missingB ++ "],\"schemaErrors\":{\"Workshop\":" ++ List.show(&2,String,quote,errorsA) ++ ",\"Garden\":" ++ List.show(&2,String,quote,errorsB) ++ "}}"
def main() -> String:
  combine(application(~State.Workshop,"Workshop",Driver.workshop()),application(~State.Garden,"Garden",Driver.garden()),missing(~State.Workshop,"Workshop",Missing.workshop()),missing(~State.Garden,"Garden",Missing.garden()))
