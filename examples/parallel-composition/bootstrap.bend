import Base
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-composer-service.bend as Service
import ./schema.bend as Schema
import ./declarations.bend as D
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ./application.bend as Application
import ../../src/ecs/execution-composer-schema.bend as Init
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-composer-program.bend as Scoped

def defined5(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,a0:D.MotionOwner(),a1:D.MotionOwner(),b0:D.LabelsOwner(),b1:D.LabelsOwner(),g0:D.GuardOwner(),result:Sys.Defined<Schema.World(),D.GuardOwner(),D.GuardLocal>) -> String:
  match result:
    case Sys.Defined{world,g1}:finish(Application.build(world,Reg.Product{Reg.Product{a0,a1,[]},Reg.Product{b0,b1,[]},[]},Reg.Product{g0,g1,[]},nesting))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def defined4(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,a0:D.MotionOwner(),a1:D.MotionOwner(),b0:D.LabelsOwner(),b1:D.LabelsOwner(),result:Sys.Defined<Schema.World(),D.GuardOwner(),D.GuardLocal>) -> String:
  match result:
    case Sys.Defined{world,g0}:defined5(~finish,nesting,first,second,a0,a1,b0,b1,g0,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~String,~Bool,~D.guard_program,~D.guard_body,world,"host-second",D.GuardLocal{ALeaf{702},0}))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def defined3(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,a0:D.MotionOwner(),a1:D.MotionOwner(),b0:D.LabelsOwner(),result:Sys.Defined<Schema.World(),D.LabelsOwner(),Labels.Local<Schema.Nominal>>) -> String:
  match result:
    case Sys.Defined{world,b1}:defined4(~finish,nesting,first,second,a0,a1,b0,b1,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~String,~Bool,~D.guard_program,~D.guard_body,world,"host-first",D.GuardLocal{ALeaf{701},0}))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def defined2(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,a0:D.MotionOwner(),a1:D.MotionOwner(),result:Sys.Defined<Schema.World(),D.LabelsOwner(),Labels.Local<Schema.Nominal>>) -> String:
  match result:
    case Sys.Defined{world,b0}:defined3(~finish,nesting,first,second,a0,a1,b0,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~D.labels_program,~Labels.body(~Schema.Nominal),world,"labels-second",Labels.Local{ALeaf{"LOCAL-504"},0,second}))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def defined1(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,a0:D.MotionOwner(),result:Sys.Defined<Schema.World(),D.MotionOwner(),Motion.Local<Schema.Nominal>>) -> String:
  match result:
    case Sys.Defined{world,a1}:defined2(~finish,nesting,first,second,a0,a1,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~D.labels_program,~Labels.body(~Schema.Nominal),world,"labels-first",Labels.Local{ALeaf{"LOCAL-503"},0,second}))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def defined0(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,result:Sys.Defined<Schema.World(),D.MotionOwner(),Motion.Local<Schema.Nominal>>) -> String:
  match result:
    case Sys.Defined{world,a0}:defined1(~finish,nesting,first,second,a0,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~D.motion_program,~Motion.body(~Schema.Nominal),world,"motion-second",Motion.Local{ALeaf{502},0,first}))
    case Sys.DefinitionRefused{_,_}:"definition-refused"
def second_activated(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,+first:W.Handle<Schema.Nominal>,+second:W.Handle<Schema.Nominal>,result:Schema.World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):defined0(~finish,nesting,first,second,Sys.define(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~D.motion_program,~Motion.body(~Schema.Nominal),world,"motion-first",Motion.Local{ALeaf{501},0,first}))
    case _:"activation-refused"
def second_reserved(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,first:W.Handle<Schema.Nominal>,result:Schema.World() & W.Reservation<Schema.Nominal>) -> String:
  match result:
    case (world,W.Reserved{+handle}):second_activated(~finish,nesting,first,handle,W.activate(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,world,handle))
    case _:"reservation-refused"
def first_activated(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,first:W.Handle<Schema.Nominal>,result:Schema.World() & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):second_reserved(~finish,nesting,first,W.reserve_id(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,world))
    case _:"activation-refused"
def first_reserved(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,result:Schema.World() & W.Reservation<Schema.Nominal>) -> String:
  match result:
    case (world,W.Reserved{+handle}):first_activated(~finish,nesting,handle,W.activate(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,world,handle))
    case _:"reservation-refused"
def created(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>,result:Init.Initialized<Schema.Nominal,Schema.components(),Schema.resources(),Unit>) -> String:
  match result:
    case Init.SchemaCreated{_,world}:first_reserved(~finish,nesting,W.reserve_id(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,world))
    case _:"creation-refused"
def run(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>) -> String:
  created(~finish,nesting,Init.trusted_create_seeded(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Schema.seed,W.factory(),Schema.resource_seed()))
def run_optional_none(~finish:Application.Application() -> String,nesting:List<&2,Scoped.Nested>) -> String:
  created(~finish,nesting,Init.trusted_create_seeded(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Schema.seed,W.factory(),Schema.absent_optional_seed()))
