import Base
import fixture-state.bend as State
import machine-requirements.bend as Req
import root-source/inspector-metadata.bend as Legacy
import root-source/inspector.bend as I
import format-output.bend as Format

# This closed schema author explicitly supplies injective Flow=1, Level=2.
# Names do not provide authority. Resource=1 is a cross-category collision.
type Owner is Type:
  Owner{cells:Array<U32>,resource:Array<U32>,bodies:U32}
def json_bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def flow(~S:Data,+schema:String) -> Req.Requirement<S>:
  Req.machine(~S,~State.FlowToken,Req.Machine{1,schema ++ "/Flow"})
def level(~S:Data,+schema:String) -> Req.Requirement<S>:
  Req.machine(~S,~State.LevelToken,Req.Machine{2,schema ++ "/Level"})
def resource(~S:Data,schema:String) -> Req.Requirement<S>:
  Req.Resource{Legacy.Resource{1,schema ++ "/Owned"}}
def only_flow(~S:Data,value:Req.Requirement<S>) -> Bool:
  match value:
    case Req.MachineRequirement{id,_}:U32.is_eq(id,1)
    case _ :False{}
def none(~S:Data,value:Req.Requirement<S>) -> Bool:
  False{}
def pair(owner:Array<U32>) -> String:
  match owner:
    case ANode{ALeaf{a},ALeaf{b}}:"[" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "]"
    case _ :"null"
def refused(~S:Data,result:Req.Gate<S,Owner,I.Instance<S>,List<&2,U32>>) -> String:
  match result:
    case Req.Missing{Owner{cells,resource,bodies},instance,args,_}:"\"missingBodies\":" ++ U32.show(bodies) ++ ",\"argsPreserved\":" ++ List.show(&2,U32,U32.show,args) ++ ",\"ownerCellsPreserved\":" ++ pair(cells) ++ ",\"ownerResourcePreserved\":" ++ pair(resource)
    case Req.Ready{_,_,_}:"\"unexpectedReady\":true"
def schema(~S:Data,+name:String) -> String:
  "{\"schema\":" ++ Format.quote(name) ++ ",\"canonicalMachines\":[{\"token\":\"FlowToken\",\"id\":1},{\"token\":\"LevelToken\",\"id\":2}],\"sameResourceMachineId\":" ++ json_bool(Req.same(~S,resource(~S,name),flow(~S,name))) ++ ",\"sameMachineId\":" ++ json_bool(Req.same(~S,flow(~S,name),flow(~S,name))) ++ ",\"differentMachineId\":" ++ json_bool(Req.same(~S,flow(~S,name),level(~S,name))) ++ ",\"missingWhenOnlyFlowProvided\":" ++ List.show(&2,Req.Requirement<S>,Format.requirement(~S),Req.missing(~S,~only_flow(~S),[flow(~S,name),level(~S,name)])) ++ ",\"missingAllDeclarationOrder\":" ++ List.show(&2,Req.Requirement<S>,Format.requirement(~S),Req.missing(~S,~none(~S),[level(~S,name),resource(~S,name),flow(~S,name)])) ++ "," ++ refused(~S,Req.gate(~S,~Owner,~I.Instance<S>,~List<&2,U32>,Req.missing(~S,~none(~S),[level(~S,name),resource(~S,name),flow(~S,name)]),Owner{ANode{ALeaf{7},ALeaf{17}},ANode{ALeaf{3},ALeaf{13}},0},I.Fresh{},[91,19])) ++ "}"
def main() -> String:
  "{\"format\":1,\"application\":\"InspectorMachineMetadata\",\"schemas\":[" ++ schema(~State.Workshop,"Workshop") ++ "," ++ schema(~State.Garden,"Garden") ++ "]}"
