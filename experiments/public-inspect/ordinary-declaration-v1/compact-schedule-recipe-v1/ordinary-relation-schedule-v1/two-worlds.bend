import Base
import ./consumer-public.bend as Consumer
import ./state.bend as State
import ./dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-schedule.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation-system.bend as Registered
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as PublicRelation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def owner_text(~S:Data,owner:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2})) -> Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}) & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"Owner{ns=" ++ U32.show(ns) ++ "|id=" ++ U32.show(id) ++ "|name=" ++ name ++ "|access=" ++ List.show(&2,String,x=>x,access) ++ "|cursor=" ++ U32.show(cursor) ++ "}")
def observed_owner(~S:Data,prefix:String,result:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}) & String) -> String:
  match result:
    case (_,text):prefix ++ text
def after_dump(~S:Data,prefix:String,owner:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}),result:State.World(~S) & String) -> String:
  match result:
    case (_,text):observed_owner(~S,prefix ++ "|after=" ++ text ++ "|",owner_text(~S,owner))
def attached(~S:Data,prefix:String,result:Scheduled.Attachment<App.Application<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}),PublicRelation.View<S>,PublicRelation.observe(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~PublicRelation.builtin_row(~S)),Registered.empty_fold(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2})>,Consumer.Application(~S)>) -> String:
  match result:
    case Scheduled.Attached{_}:prefix ++ "|UnexpectedAttached"
    case Scheduled.Invalid{App.Application{_,Build.Registered{world,owner,_,debug}}}:after_dump(~S,prefix ++ "|Invalid",owner,Dump.world(~S,world))
def before_owner(~S:Data,prefix:String,world:State.World(~S),result:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}) & String) -> String:
  match result:
    case (owner,text):attached(~S,prefix ++ "|" ++ text,Relation.attach(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2},Schema.resource_schema(~S,~State.Resources<S>,Schema.resource(~S,~State.Resources<S>,"Counter")),owner,world,"Update",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Entry{Sch.System{1,1},[]}}))
def before_dump(~S:Data,owner:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}),result:State.World(~S) & String) -> String:
  match result:
    case (world,text):before_owner(~S,"before=" ++ text,world,owner_text(~S,owner))
def second_registered(~S:Data,owner:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}),result:Sys.RegistrationResult<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Unit,Unit,Unit,Registered.reader(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2})>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"SecondRegistrationFailed"
    case Sys.Registered{world,_}:before_dump(~S,owner,Dump.world(~S,world))
def second_created(~S:Data,owner:Registered.Owner(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2}),result:W.Creation<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>) -> String:
  match result:
    case W.CreateRejected{_,_}:"SecondCreateRejected"
    case W.Created{_,world}:second_registered(~S,owner,Registered.register(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2},world,"ReadLinks"))
def first_registered(~S:Data,factory:W.Factory,result:Sys.RegistrationResult<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>,Unit,Unit,Unit,Registered.reader(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2})>) -> String:
  match result:
    case Sys.RegistrationFailed{_}:"FirstRegistrationFailed"
    case Sys.Registered{_,owner}:second_created(~S,owner,W.create(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~Consumer.empty_store(~S),factory,State.Resources{ANode{ALeaf{61},ALeaf{62}}}))
def first_created(~S:Data,result:W.Creation<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>) -> String:
  match result:
    case W.CreateRejected{_,_}:"FirstCreateRejected"
    case W.Created{factory,world}:first_registered(~S,factory,Registered.register(~S,~Unit,~State.Resources<S>,~U32,~Consumer.declaration(~S),~W.Handle{1,2},world,"ReadLinks"))
def scenario(~S:Data) -> String:
  first_created(~S,W.create(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~Consumer.empty_store(~S),W.factory(),State.Resources{ANode{ALeaf{61},ALeaf{62}}}))
