import Base
import ../../../../../../src/ecs/decode-data.bend as D
import ./scenario-schema.bend as Schema
import ../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ./app.bend as App
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/compose.bend as Q
import ../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../src/ecs/lifecycle.bend as Lifecycle
import ../dependencies/experiments/public-simulation/bend-v1/owner-view.bend as View

# Whole observation shape agreed before any executable backend output.
type Cell is Data:
  Cell{id:U32,payload:Maybe<&2,View.FullCell>,stamp:Lifecycle.Stamp}
type Storage is Data:
  Plain{}
  Transient{}
  Constructed{codec:D.Codec}
type Column is Data:
  Column{storage:Storage,cells:List<&2,Cell>}
type Columns is Data:
  Columns{position:Column,velocity:Column,health:Column}
type WorldSnapshot is Data:
  WorldSnapshot{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,liveBits:List<&2,Bool>,resource:Unit,events:List<&2,Unit>,pendingCount:U32,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,columns:Columns}
type RegistrySnapshot is Data:
  RegistrySnapshot{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,slot:String,clauses:List<&2,Query.Clause<Schema.Schema>>}
type RowValues is Data:
  RowValues{position:View.FullCell,velocityBefore:View.FullCell,health:Cmp.Access<View.FullCell>}
type RejectedArgs is Data:
  RejectedArgs{fail:Bool,cursor:U32}
type Operation is Data:
  Observed{}
  Run{result:Result<&2,&2,Q.Error<Unit>,List<&2,RowValues>>}
  PositionReplaced{result:W.Status,previous:Maybe<&2,View.FullCell>,incoming:Maybe<&2,View.FullCell>}
  RefusedRegistration{args:RejectedArgs,foreignWorld:WorldSnapshot,registry:RegistrySnapshot}
type Snapshot is Data:
  Snapshot{label:String,factoryNextNamespace:U32,world:WorldSnapshot,registries:List<&2,RegistrySnapshot>,operation:Operation,descriptions:List<&2,Maybe<&2,App.Description<Schema.Schema>>>}
type ScenarioReport is Data:
  ScenarioReport{category:String,phases:List<&2,Snapshot>}
type Report is Data:
  Report{plain:ScenarioReport,transient:ScenarioReport,constructed:ScenarioReport}
