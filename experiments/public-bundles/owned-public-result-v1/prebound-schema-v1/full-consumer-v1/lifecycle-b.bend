import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-bundles/owned-public-result-v1/prebound-schema-v1/full-consumer-v1/surface-b.bend as Flow
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/owned-public-result-v1/schema-b.bend as Owner
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/combined-other.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/owned-public-result-v1/composition.bend as Co
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/source-v1/experiments/public-bundles/production-candidate/schema-b.bend as Previous
def World() -> Type:W.World<A.Schema,A.Store,A.Mail,U32>
def array_text(value:C.Access<List<&2,U32>>) -> String:
  match value:
    case C.Found{+cells}:List.show(&2,U32,U32.show,cells)
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"missing"
def tag_text(value:C.Access<Unit>) -> String:
  match value:
    case C.Found{Unit{}}:"tag"
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"missing"
def value_text(value:C.Access<U32>) -> String:
  match value:
    case C.Found{value}:U32.show(value)
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"missing"
def value_seen(prefix:String,result:World() & C.Access<U32>) -> World() & String:
  match result:
    case (world,value):(world,prefix ++ ":" ++ value_text(value))
def tag_seen(+target:W.Handle<A.Schema>,prefix:String,result:World() & C.Access<Unit>) -> World() & String:
  match result:
    case (world,tag):value_seen(prefix ++ ":" ++ tag_text(tag),C.get(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_value,~U32,~U32,~A.Token,~A.take_value,~A.put_value,~A.project_value,A.family_value(),world,target))
def b_seen(+target:W.Handle<A.Schema>,prefix:String,result:World() & C.Access<List<&2,U32>>) -> World() & String:
  match result:
    case (world,b):tag_seen(target,prefix ++ ":" ++ array_text(b),C.get(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_tag,~K.Tag,~Unit,~A.Token,~A.take_tag,~A.put_tag,~A.project_tag,A.family_tag(),world,target))
def a_seen(+target:W.Handle<A.Schema>,result:World() & C.Access<List<&2,U32>>) -> World() & String:
  match result:
    case (world,a):b_seen(target,array_text(a),C.get(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_b,~Array<U32>,~List<&2,U32>,~A.Token,~A.take_b,~A.put_b,~A.project_array,A.family_b(),world,target))
def row(world:World(),+target:W.Handle<A.Schema>) -> World() & String:
  a_seen(target,C.get(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_a,~Array<U32>,~List<&2,U32>,~A.Token,~A.take_a,~A.put_a,~A.project_array,A.family_a(),world,target))
def second_row(first:String,result:World() & String) -> World() & String:
  match result:
    case (world,second):(world,first ++ "/" ++ second)
def first_row(+namespace:U32,result:World() & String) -> World() & String:
  match result:
    case (world,first):second_row(first,row(world,W.Handle{namespace,2}))
def named(result:World() & U32) -> World() & String:
  match result:
    case (world,+namespace):first_row(namespace,row(world,W.Handle{namespace,1}))
def observed_rows(world:World()) -> World() & String:named(W.namespace(~A.Schema,~A.Store,~A.Mail,~U32,world))
def observer_value(result:World() & String) -> Sys.Outcome<World(),Unit,String>:
  match result:
    case (world,rows):Sys.Succeeded{world,rows}
def observer_runner(world:World(),args:Unit) -> Sys.Outcome<World(),Unit,String>:
  observer_value(observed_rows(world))
def observer_ran(result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,String,observer_runner>) -> World() & String:
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,rows}}:(world,rows ++ "|observer-registry=" ++ Flow.registry(ns,id,name,access,cursor))
    case Sys.Completed{registration,Sys.Failed{world,Unit{}}}:(world,"UNEXPECTED_OBSERVER_FAILURE")
    case Sys.RegistrationRejected{registration,world,args}:(world,"UNEXPECTED_OBSERVER_REJECTION")
def observer_registered(result:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Unit,Unit,String,observer_runner>) -> World() & String:
  match result:
    case Sys.Registered{world,registration}:observer_ran(Sys.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~String,~observer_runner,registration,world,Unit{}))
    case Sys.RegistrationFailed{world}:(world,"UNEXPECTED_OBSERVER_REGISTRATION")
def observe(name:String,world:World()) -> World() & String:
  observer_registered(Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Unit,~Unit,~String,~observer_runner,world,name,["read:a","read:b","read:tag","read:value"]))
def delivery_text(delivery:Maybe<&1,Flow.Delivery>) -> String:
  match delivery:
    case None{}:"failed"
    case Some{delivery}:Flow.delivery(delivery)
def after(status:String,registry:String,delivery:Maybe<&1,Flow.Delivery>,before:String,result:World() & String) -> String:
  match result:
    case (world,after):status ++ "|before=" ++ before ++ "|after=" ++ after ++ "|registry=" ++ registry ++ "|teardown=" ++ Owner.world_snapshot(A.unwind(world)) ++ "|delivery=" ++ delivery_text(delivery)
def before(status:String,registry:String,delivery:Maybe<&1,Flow.Delivery>,result:World() & String) -> String:
  match result:
    case (world,before):after(status,registry,delivery,before,observe("bundle-observe-after",W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world)))
def ran(result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,Flow.Args,Unit,Flow.Delivery,Flow.runner>) -> String:
  match result:
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Succeeded{world,out}}:before("Succeeded",Flow.registry(ns,id,name,access,cursor),Some{out},observe("bundle-observe-before",world))
    case Sys.Completed{Sys.Registry{ns,id,name,access,cursor},Sys.Failed{world,Unit{}}}:before("Failed",Flow.registry(ns,id,name,access,cursor),None{},observe("bundle-observe-before",world))
    case _:"UNEXPECTED_REGISTRATION_RESULT"
def registered(args:Flow.Args,result:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Flow.Args,Unit,Flow.Delivery,Flow.runner>) -> String:
  match result:
    case Sys.Registered{world,registration}:ran(Sys.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Flow.Args,~Unit,~Flow.Delivery,~Flow.runner,registration,world,args))
    case _:"UNEXPECTED_REGISTRATION_REFUSAL"
# Closed registration initializer; its registration identity is unchanged.
def initialize(world:World()) -> Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Flow.Args,Unit,Flow.Delivery,Flow.runner>:
  Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Flow.Args,~Unit,~Flow.Delivery,~Flow.runner,world,"owned-commands",["write:a","write:b","write:tag","write:value","bundle.spawn","bundle.insert"])
def kind(value:SF.RegistryKind) -> String:
  match value:
    case SF.Component{}:"component"
    case SF.Resource{}:"resource"
    case SF.Event{}:"event"
    case SF.Relation{}:"relation"
    case SF.Service{}:"service"
def error(value:SF.Error) -> String:
  match value:
    case SF.DuplicateKey{k,key}:"DuplicateKey:" ++ kind(k) ++ ":" ++ key
    case SF.DuplicateName{k,name}:"DuplicateName:" ++ kind(k) ++ ":" ++ name
    case SF.UndeclaredDescriptor{k,key,name}:"UndeclaredDescriptor:" ++ kind(k) ++ ":" ++ key ++ ":" ++ name
# Refusal observes the full returned World; raw arguments were not yet created.
def bound(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,result:SF.Bound<A.Schema,World(),Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Flow.Args,Unit,Flow.Delivery,Flow.runner>>) -> String:
  match result:
    case SF.Built{registration}:registered(Flow.Args{Co.Input{K.input(True{},Bool.not(invalid)),Previous.replacement()},retry,fail,cleanup},registration)
    case SF.BindRejected{why,SF.Fragment{_,world}}:"SCHEMA_BIND_REJECTED|error=" ++ error(why) ++ "|world=" ++ Owner.world_snapshot(A.unwind(world))
def run(invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,world:World()) -> String:
  bound(invalid,retry,fail,cleanup,SF.bind_declared(~A.Schema,~World(),~Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Flow.Args,Unit,Flow.Delivery,Flow.runner>,~initialize,SF.Fragment{Flow.available(),world},Flow.required()))
