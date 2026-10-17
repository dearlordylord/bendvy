import Base
import ../../../src/ecs/restore-graph-data.bend as Graph
import ../../../src/ecs/snapshot-data.bend as Basic
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/entity-key.bend as Key

def patched(snapshot:Graph.Snapshot,value:U32) -> Graph.Snapshot:
  match snapshot:
    case Graph.Snapshot{Basic.Snapshot{version,floor,entities,_},relations,_}:Graph.Snapshot{Basic.Snapshot{version,floor,entities,[]},relations,[D.Field{"Mode",D.Number{value}}]}
def relation_cycle(found:Bool,name:String,groups:List<&2,Graph.Group>,source:Key.Key,target:Key.Key,rest:List<&2,Graph.Relation>) -> List<&2,Graph.Relation>:
  match found:
    case False{}:Graph.Relation{name,groups} <> rest
    case True{}:Graph.Relation{name,List.append(&2,Graph.Group,groups,[Graph.Group{target,[source]}])} <> rest
def append_cycle(values:List<&2,Graph.Relation>,+source:Key.Key,+target:Key.Key) -> List<&2,Graph.Relation>:
  match values:
    case []:[]
    case Graph.Relation{+name,groups} <> rest:relation_cycle(String.eq(name,"Parent"),name,groups,source,target,append_cycle(rest,source,target))
def cycle_keys(snapshot:Graph.Snapshot,entities:List<&2,Basic.Entity>) -> Graph.Snapshot:
  match snapshot entities:
    case Graph.Snapshot{basic,relations,machines},(Basic.Entity{_,_} <> Basic.Entity{second,_} <> Basic.Entity{third,_} <> _):Graph.Snapshot{basic,append_cycle(relations,second,third),machines}
    case snapshot _:snapshot
def cycle(snapshot:Graph.Snapshot) -> Graph.Snapshot:
  match snapshot:
    case Graph.Snapshot{Basic.Snapshot{+version,+floor,+entities,+resources},+relations,+machines}:cycle_keys(Graph.Snapshot{Basic.Snapshot{version,floor,entities,resources},relations,machines},entities)
def floor(value:Graph.Snapshot,next:U32) -> Graph.Snapshot:
  match value:
    case Graph.Snapshot{Basic.Snapshot{version,_,entities,resources},relations,machines}:Graph.Snapshot{Basic.Snapshot{version,next,entities,resources},relations,machines}
def bad_resource(value:Graph.Snapshot) -> Graph.Snapshot:
  match value:
    case Graph.Snapshot{Basic.Snapshot{version,next,entities,_},relations,machines}:Graph.Snapshot{Basic.Snapshot{version,next,entities,[D.Field{"Settings",D.Text{"late resource failure"}}]},relations,machines}
def factory_refused(value:Graph.Snapshot) -> Graph.Snapshot:
  match value:
    case Graph.Snapshot{Basic.Snapshot{version,next,entities,_},relations,machines}:Graph.Snapshot{Basic.Snapshot{version,next,entities,[D.Field{"Settings",D.Array{[D.Number{1234},D.Number{1235}]}}]},relations,machines}
def changed_relations(kind:U32,+first:Key.Key,second:Key.Key,relations:List<&2,Graph.Relation>) -> List<&2,Graph.Relation>:
  match kind:
    case 8:List.append(&2,Graph.Relation,relations,[Graph.Relation{"Ghost",[]}])
    case 9:[Graph.Relation{"Link",[Graph.Group{second,[Key.EntityKey{777,0}]}]}]
    case 10:[Graph.Relation{"Link",[Graph.Group{second,[first,first]}]}]
    case _:[Graph.Relation{"Link",[Graph.Group{first,[first]}]}]
def relation_trial(kind:U32,+snapshot:Graph.Snapshot,entities:List<&2,Basic.Entity>) -> Graph.Snapshot:
  match snapshot entities:
    case Graph.Snapshot{basic,relations,machines},Basic.Entity{+first,_} <> Basic.Entity{+second,_} <> _:Graph.Snapshot{basic,changed_relations(kind,first,second,relations),machines}
    case snapshot _:snapshot
def trial(kind:U32,snapshot:Graph.Snapshot) -> Graph.Snapshot:
  match snapshot:
    case Graph.Snapshot{Basic.Snapshot{+version,+next,+entities,+resources},+relations,+machines}:relation_trial(kind,Graph.Snapshot{Basic.Snapshot{version,next,entities,resources},relations,machines},entities)
def machine_trial(value:Graph.Snapshot,unknown:Bool) -> Graph.Snapshot:
  match value unknown:
    case Graph.Snapshot{basic,relations,machines} True{}:Graph.Snapshot{basic,relations,List.append(&2,D.Field,machines,[D.Field{"Ghost",D.Number{0}}])}
    case Graph.Snapshot{basic,relations,_} False{}:Graph.Snapshot{basic,relations,[D.Field{"Mode",D.Text{"wrong state type"}}]}
