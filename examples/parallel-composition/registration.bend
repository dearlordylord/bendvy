import Base
import ./schema.bend as S
import ./declarations.bend as D
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ./application.bend as App
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/world.bend as W

type MotionSlot is Type:
  MotionPending{compilation:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Motion.Family(~S.Nominal)>,local:Motion.Local<S.Nominal>}
  MotionRegistered{binding:D.MotionBinding()}
type LabelsSlot is Type:
  LabelsPending{compilation:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Labels.Family(~S.Nominal)>,local:Labels.Local<S.Nominal>}
  LabelsRegistered{binding:D.LabelsBinding()}
type GuardSlot is Type:
  GuardPending{compilation:D.GuardCompilation(),local:D.GuardLocal}
  GuardRegistered{binding:D.GuardBinding()}
type Inventory is Type:
  Inventory{world:S.World(),a:MotionSlot,b:MotionSlot,c:LabelsSlot,d:LabelsSlot,e:GuardSlot,f:GuardSlot}
type Outcome is Type:
  Registered{application:App.Application()}
  Refused{inventory:Inventory}
def finished(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,MotionRegistered{a},MotionRegistered{b},LabelsRegistered{c},LabelsRegistered{d},GuardRegistered{e},GuardRegistered{f}}:Registered{App.build(world,a,b,c,d,Reg.Product{e,f,[]},nesting)}
    case inventory:Refused{inventory}
def returned5(nesting:List<&2,Scoped.Nested>,a:MotionSlot,b:MotionSlot,c:LabelsSlot,d:LabelsSlot,e:GuardSlot,result:D.GuardCompilation() & Sys.Defined<S.World(),D.GuardOwner(),D.GuardLocal>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):finished(nesting,Inventory{world,a,b,c,d,e,GuardRegistered{Scope.CompiledBinding{compilation,owner}}})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,a,b,c,d,e,GuardPending{compilation,local}}}
def step5(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,a,b,c,d,e,GuardPending{compilation,local}}:returned5(nesting,a,b,c,d,e,Register.define_with_compilation(~S.Nominal,~S.Store(),~S.Store(),~S.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~String,~Bool,~D.guard_kernel,~D.guard_body,~S.Resources(),compilation,world,"host-second",local))
    case inventory:Refused{inventory}
def returned4(nesting:List<&2,Scoped.Nested>,a:MotionSlot,b:MotionSlot,c:LabelsSlot,d:LabelsSlot,f:GuardSlot,result:D.GuardCompilation() & Sys.Defined<S.World(),D.GuardOwner(),D.GuardLocal>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):step5(nesting,Inventory{world,a,b,c,d,GuardRegistered{Scope.CompiledBinding{compilation,owner}},f})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,a,b,c,d,GuardPending{compilation,local},f}}
def step4(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,a,b,c,d,GuardPending{compilation,local},f}:returned4(nesting,a,b,c,d,f,Register.define_with_compilation(~S.Nominal,~S.Store(),~S.Store(),~S.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~String,~Bool,~D.guard_kernel,~D.guard_body,~S.Resources(),compilation,world,"host-first",local))
    case inventory:Refused{inventory}
def returned3(nesting:List<&2,Scoped.Nested>,a:MotionSlot,b:MotionSlot,c:LabelsSlot,e:GuardSlot,f:GuardSlot,result:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Labels.Family(~S.Nominal)> & Sys.Defined<S.World(),D.LabelsOwner(),Labels.Local<S.Nominal>>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):step4(nesting,Inventory{world,a,b,c,LabelsRegistered{Scope.CompiledBinding{compilation,owner}},e,f})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,a,b,c,LabelsPending{compilation,local},e,f}}
def step3(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,a,b,c,LabelsPending{compilation,local},e,f}:returned3(nesting,a,b,c,e,f,Register.define_with_compilation(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Unit,~Labels.Family(~S.Nominal),~Labels.Local<S.Nominal>,~String,~String,~D.labels_kernel,~Labels.body(~S.Nominal),~S.Resources(),compilation,world,"labels-second",local))
    case inventory:Refused{inventory}
def returned2(nesting:List<&2,Scoped.Nested>,a:MotionSlot,b:MotionSlot,d:LabelsSlot,e:GuardSlot,f:GuardSlot,result:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Labels.Family(~S.Nominal)> & Sys.Defined<S.World(),D.LabelsOwner(),Labels.Local<S.Nominal>>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):step3(nesting,Inventory{world,a,b,LabelsRegistered{Scope.CompiledBinding{compilation,owner}},d,e,f})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,a,b,LabelsPending{compilation,local},d,e,f}}
def step2(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,a,b,LabelsPending{compilation,local},d,e,f}:returned2(nesting,a,b,d,e,f,Register.define_with_compilation(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Unit,~Labels.Family(~S.Nominal),~Labels.Local<S.Nominal>,~String,~String,~D.labels_kernel,~Labels.body(~S.Nominal),~S.Resources(),compilation,world,"labels-first",local))
    case inventory:Refused{inventory}
def returned1(nesting:List<&2,Scoped.Nested>,a:MotionSlot,c:LabelsSlot,d:LabelsSlot,e:GuardSlot,f:GuardSlot,result:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Motion.Family(~S.Nominal)> & Sys.Defined<S.World(),D.MotionOwner(),Motion.Local<S.Nominal>>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):step2(nesting,Inventory{world,a,MotionRegistered{Scope.CompiledBinding{compilation,owner}},c,d,e,f})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,a,MotionPending{compilation,local},c,d,e,f}}
def step1(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,a,MotionPending{compilation,local},c,d,e,f}:returned1(nesting,a,c,d,e,f,Register.define_with_compilation(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Unit,~Motion.Family(~S.Nominal),~Motion.Local<S.Nominal>,~String,~String,~D.motion_kernel,~Motion.body(~S.Nominal),~S.Resources(),compilation,world,"motion-second",local))
    case inventory:Refused{inventory}
def returned0(nesting:List<&2,Scoped.Nested>,b:MotionSlot,c:LabelsSlot,d:LabelsSlot,e:GuardSlot,f:GuardSlot,result:Decl.Compilation<S.Nominal,S.Store(),D.C(),D.R(),Motion.Family(~S.Nominal)> & Sys.Defined<S.World(),D.MotionOwner(),Motion.Local<S.Nominal>>) -> Outcome:
  match result:
    case (compilation,Sys.Defined{world,owner}):step1(nesting,Inventory{world,MotionRegistered{Scope.CompiledBinding{compilation,owner}},b,c,d,e,f})
    case (compilation,Sys.DefinitionRefused{world,local}):Refused{Inventory{world,MotionPending{compilation,local},b,c,d,e,f}}
def step0(nesting:List<&2,Scoped.Nested>,inventory:Inventory) -> Outcome:
  match inventory:
    case Inventory{world,MotionPending{compilation,local},b,c,d,e,f}:returned0(nesting,b,c,d,e,f,Register.define_with_compilation(~S.Nominal,~S.Store(),~D.C(),~D.R(),~Unit,~Motion.Family(~S.Nominal),~Motion.Local<S.Nominal>,~String,~String,~D.motion_kernel,~Motion.body(~S.Nominal),~S.Resources(),compilation,world,"motion-first",local))
    case inventory:Refused{inventory}
def define(world:S.World(), +first:W.Handle<S.Nominal>, +second:W.Handle<S.Nominal>,nesting:List<&2,Scoped.Nested>) -> Outcome:
  step0(nesting,Inventory{world,MotionPending{D.motion_compiled(),Motion.Local{ALeaf{501},0,first}},MotionPending{D.motion_compiled(),Motion.Local{ALeaf{502},0,first}},LabelsPending{D.labels_compiled(),Labels.Local{ALeaf{"LOCAL-503"},0,second}},LabelsPending{D.labels_compiled(),Labels.Local{ALeaf{"LOCAL-504"},0,second}},GuardPending{D.guard_compiled(),D.GuardLocal{ALeaf{701},0}},GuardPending{D.guard_compiled(),D.GuardLocal{ALeaf{702},0}}})
