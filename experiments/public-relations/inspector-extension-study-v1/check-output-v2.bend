import Base
import fixture-state.bend as State
import fixture-consumer.bend as C
import fixture-driver.bend as Driver
import check-observations.bend as Check
import format-output.bend as Format
import root-source/world.bend as W
import root-source/inspector.bend as I

def json_bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def row(+schema:String,+inspector:String,+system:String,value:Check.Boundary) -> String:
  match value:
    case Check.Boundary{id,allowed,before,after}:"{\"schema\":" ++ Format.quote(schema) ++ ",\"condition\":" ++ U32.show(id) ++ ",\"allowed\":" ++ json_bool(allowed) ++ ",\"before\":" ++ Format.quote(before) ++ ",\"after\":" ++ Format.quote(after) ++ ",\"inspector\":" ++ Format.quote(inspector) ++ ",\"system\":" ++ Format.quote(system) ++ "}"
def second(~S:Data,schema:String,inspector:String,system:String,first:String,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Check.Boundary) -> String:
  (world,observed)=result
  first ++ "," ++ row(schema,inspector,system,observed)
def first(~S:Data,+schema:String,+inspector:String,+system:String,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Check.Boundary) -> String:
  (world,observed)=result
  second(~S,schema,inspector,system,row(schema,inspector,system,observed),Check.observe(~S,world,1))
def described(~S:Data,schema:String,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,inspector:String,result:C.Holder<S> & String) -> String:
  (holder,text)=result
  first(~S,schema,inspector,text,Check.observe(~S,world,0))
def instance_observed(~S:Data,schema:String,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,holder:C.Holder<S>,result:I.Instance<S> & String) -> String:
  (instance,text)=result
  described(~S,schema,world,text,Driver.registry_dump(~S,holder))
# Metadata owners are observed before the direct read and remain out of its
# input type. Dropping them below is process teardown, not a public disposal API.
def completed(~S:Data,schema:String,result:Driver.Output<S>) -> String:
  match result:
    case Driver.Completed{_,Driver.Session{world,instance,holder,_,_,[]}}:instance_observed(~S,schema,world,holder,Driver.instance_dump(~S,instance))
    case _:"{\"error\":\"driver-refused\"}"
def main() -> String:
  "{\"format\":1,\"application\":\"InspectorMachineDirectCheckBoundary\",\"observations\":[" ++ completed(~State.Workshop,"Workshop",Driver.workshop()) ++ "," ++ completed(~State.Garden,"Garden",Driver.garden()) ++ "],\"scope\":" ++ Format.quote("Direct cursor-free machine Check adapter reads after the independently scheduled eight-phase driver; before/after whole closed-fixture World text is observed. Actual schedule conditions separately enforce identical world snapshots, but these records do not instrument that callback invocation.") ++ "}"
