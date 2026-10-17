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
