import Base
# Trusted declaration observations only. Strings are labels, never access grants.
type Storage is Data:
  Constructed{}
  Transient{}
  Plain{}
type Component is Data:
  Component{name:String,storage:Storage}
type Resource is Data:
  Resource{name:String,storage:Storage,present:Bool}
type RelationKind is Data:
  Hierarchy{}
  GeneralRelation{}
type Relation is Data:
  Relation{name:String,relatedName:String,kind:RelationKind,linkedDespawn:Bool,ordered:Bool}
type Machine is Data:
  Machine{name:String,states:List<&2,String>,current:Maybe<&2,String>}
type Service is Data:
  Service{name:String,provided:Bool}
type Access is Data:
  Access{reads:List<&2,String>,writes:List<&2,String>}
type Query is Data:
  Query{slot:String,reads:List<&2,String>,writes:List<&2,String>,optional:List<&2,String>,with:List<&2,String>,without:List<&2,String>,added:List<&2,String>,changed:List<&2,String>,relations:List<&2,String>}
type MachineAccess is Data:
  MachineAccess{reads:List<&2,String>,next:List<&2,String>,transitions:List<&2,String>,transitionEvents:List<&2,String>}
type System is Data:
  System{name:String,placements:List<&2,String>,queries:List<&2,Query>,resources:Access,events:Access,machines:MachineAccess,removed:List<&2,String>,despawned:Bool,relationFailures:List<&2,String>,services:List<&2,String>,when:List<&2,String>}
type Step is Data:
  Run{system:String}
  ApplyDeferred{}
  ApplyStateTransitions{schedules:List<&2,String>}
type Schedule is Data:
  Schedule{name:String,steps:List<&2,Step>}
type Entry is Data:
  Entry{name:String,readers:List<&2,String>,writers:List<&2,String>}
type Indexes is Data:
  Indexes{components:List<&2,Entry>,resources:List<&2,Entry>,events:List<&2,Entry>}
type Severity is Data:
  Warning{}
  Info{}
type Code is Data:
  EventNeverRead{}
  EventNeverWritten{}
  NextStateNeverApplied{}
  ComponentNeverRead{}
  ReadBeforeWrite{}
type Lint is Data:
  Lint{severity:Severity,code:Code,message:String,subject:String}
# Machine states are String observations in this draft, not full upstream StateValue.
# No Description format publication until actual state-value owner mapping exists.
# Trusted closed setup resolves actual system instances into detached metadata.
# Embedding their metadata avoids guessing runtime identity from display names.
type ResolvedStep is Data:
  ResolvedSystem{metadata:System}
  ResolvedDeferred{}
  ResolvedTransitions{schedules:List<&2,String>}
type ResolvedSchedule is Data:
  ResolvedSchedule{name:String,steps:List<&2,ResolvedStep>}
