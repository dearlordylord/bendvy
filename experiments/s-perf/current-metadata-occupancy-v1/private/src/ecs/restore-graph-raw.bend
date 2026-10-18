import Base
import ./decode-data.bend as D
import ./entity-key.bend as Key
import ./snapshot-data.bend as Snapshot
import ./restore-raw.bend as Basic
import ./restore-raw-number.bend as Number
import ./restore-graph-data.bend as Graph

type Parsed is Data:
  Accepted{snapshot:Graph.Snapshot}
  Rejected{original:D.Raw,error:Basic.Error}
def keys_tail(head:Key.Key,result:Basic.Decoded<List<&2,Key.Key>>) -> Basic.Decoded<List<&2,Key.Key>>:
  match result:
    case Basic.Value{tail}:Basic.Value{head <> tail}
    case Basic.Failed{error}:Basic.Failed{error}
def keys_head(next:Unit -> Basic.Decoded<List<&2,Key.Key>>,result:Basic.Decoded<Key.Key>) -> Basic.Decoded<List<&2,Key.Key>>:
  match result:
    case Basic.Value{head}:keys_tail(head,next(Unit{}))
    case Basic.Failed{error}:Basic.Failed{error}
def keys(+path:String,values:List<&2,D.Raw>,+index:U32) -> Basic.Decoded<List<&2,Key.Key>>:
  match values:
    case []:Basic.Value{[]}
    case raw <> rest:keys_head((_ => keys(path,rest,U32.add(index,1))),Basic.key(path ++ "[" ++ U32.show(index) ++ "]",raw))
def group_sources(target:Key.Key,result:Basic.Decoded<List<&2,Key.Key>>) -> Basic.Decoded<Graph.Group>:
  match result:
    case Basic.Value{sources}:Basic.Value{Graph.Group{target,sources}}
    case Basic.Failed{error}:Basic.Failed{error}
def group_target(path:String,raw:D.Raw,result:Basic.Decoded<Key.Key>) -> Basic.Decoded<Graph.Group>:
  match raw result:
    case _ Basic.Failed{error}:Basic.Failed{error}
    case D.Array{sources} Basic.Value{target}:group_sources(target,keys(path,sources,0))
    case other Basic.Value{_}:Basic.invalid(~Graph.Group,path,"array",other)
def group(+path:String,raw:D.Raw) -> Basic.Decoded<Graph.Group>:
  match raw:
    case D.Array{[target,sources]}:group_target(path ++ "[1]",sources,Basic.key(path ++ "[0]",target))
    case other:Basic.invalid(~Graph.Group,path,"target/sources pair",other)
def groups_tail(head:Graph.Group,result:Basic.Decoded<List<&2,Graph.Group>>) -> Basic.Decoded<List<&2,Graph.Group>>:
  match result:
    case Basic.Value{tail}:Basic.Value{head <> tail}
    case Basic.Failed{error}:Basic.Failed{error}
def groups_head(next:Unit -> Basic.Decoded<List<&2,Graph.Group>>,result:Basic.Decoded<Graph.Group>) -> Basic.Decoded<List<&2,Graph.Group>>:
  match result:
    case Basic.Value{head}:groups_tail(head,next(Unit{}))
    case Basic.Failed{error}:Basic.Failed{error}
def groups(+path:String,values:List<&2,D.Raw>,+index:U32) -> Basic.Decoded<List<&2,Graph.Group>>:
  match values:
    case []:Basic.Value{[]}
    case raw <> rest:groups_head((_ => groups(path,rest,U32.add(index,1))),group(path ++ "[" ++ U32.show(index) ++ "]",raw))
def relation_groups(name:String,result:Basic.Decoded<List<&2,Graph.Group>>) -> Basic.Decoded<Graph.Relation>:
  match result:
    case Basic.Value{values}:Basic.Value{Graph.Relation{name,values}}
    case Basic.Failed{error}:Basic.Failed{error}
def relation(+name:String,raw:D.Raw) -> Basic.Decoded<Graph.Relation>:
  match raw:
    case D.Array{values}:relation_groups(name,groups("$.relations." ++ name,values,0))
    case other:Basic.invalid(~Graph.Relation,"$.relations." ++ name,"array",other)
def relations_tail(head:Graph.Relation,result:Basic.Decoded<List<&2,Graph.Relation>>) -> Basic.Decoded<List<&2,Graph.Relation>>:
  match result:
    case Basic.Value{tail}:Basic.Value{head <> tail}
    case Basic.Failed{error}:Basic.Failed{error}
def relations_head(next:Unit -> Basic.Decoded<List<&2,Graph.Relation>>,result:Basic.Decoded<Graph.Relation>) -> Basic.Decoded<List<&2,Graph.Relation>>:
  match result:
    case Basic.Value{head}:relations_tail(head,next(Unit{}))
    case Basic.Failed{error}:Basic.Failed{error}
def relations(fields:List<&2,D.Field>) -> Basic.Decoded<List<&2,Graph.Relation>>:
  match fields:
    case []:Basic.Value{[]}
    case D.Field{name,raw} <> rest:relations_head((_ => relations(rest)),relation(name,raw))
def machines(basic:Snapshot.Snapshot,relations:List<&2,Graph.Relation>,raw:D.Raw) -> Basic.Decoded<Graph.Snapshot>:
  match raw:
    case D.Object{fields}:Basic.Value{Graph.Snapshot{basic,relations,fields}}
    case other:Basic.invalid(~Graph.Snapshot,"$.machines","object",other)
def resources(next:U32,entities:List<&2,Snapshot.Entity>,relations:List<&2,Graph.Relation>,+fields:List<&2,D.Field>,raw:D.Raw) -> Basic.Decoded<Graph.Snapshot>:
  match raw:
    case D.Object{values}:machines(Snapshot.Snapshot{1,next,entities,values},relations,D.field("machines",fields))
    case other:Basic.invalid(~Graph.Snapshot,"$.resources","object",other)
def relations_checked(next:U32,entities:List<&2,Snapshot.Entity>,+fields:List<&2,D.Field>,result:Basic.Decoded<List<&2,Graph.Relation>>) -> Basic.Decoded<Graph.Snapshot>:
  match result:
    case Basic.Value{values}:resources(next,entities,values,fields,D.field("resources",fields))
    case Basic.Failed{error}:Basic.Failed{error}
def relation_object(next:U32,entities:List<&2,Snapshot.Entity>,fields:List<&2,D.Field>,raw:D.Raw) -> Basic.Decoded<Graph.Snapshot>:
  match raw:
    case D.Object{values}:relations_checked(next,entities,fields,relations(values))
    case other:Basic.invalid(~Graph.Snapshot,"$.relations","object",other)
def entities_checked(next:U32,+fields:List<&2,D.Field>,result:Basic.Decoded<List<&2,Snapshot.Entity>>) -> Basic.Decoded<Graph.Snapshot>:
  match result:
    case Basic.Value{values}:relation_object(next,values,fields,D.field("relations",fields))
    case Basic.Failed{error}:Basic.Failed{error}
def entity_array(next:U32,fields:List<&2,D.Field>,raw:D.Raw) -> Basic.Decoded<Graph.Snapshot>:
  match raw:
    case D.Array{values}:entities_checked(next,fields,Basic.entities(values,0))
    case other:Basic.invalid(~Graph.Snapshot,"$.entities","array",other)
def progress(+fields:List<&2,D.Field>,result:Basic.Decoded<U32>) -> Basic.Decoded<Graph.Snapshot>:
  match result:
    case Basic.Value{next}:entity_array(next,fields,D.field("entities",fields))
    case Basic.Failed{error}:Basic.Failed{error}
def version(+fields:List<&2,D.Field>,+raw:D.Raw,result:Number.Checked) -> Basic.Decoded<Graph.Snapshot>:
  match result:
    case Number.Value{1}:progress(fields,Basic.number("$.nextEntity",D.field("nextEntity",fields),True{}))
    case _:Basic.Failed{Basic.UnsupportedVersion{raw}}
def object(raw:D.Raw) -> Basic.Decoded<Graph.Snapshot>:
  match raw:
    case D.Object{+fields}:version(fields,D.field("version",fields),Number.checked(D.field("version",fields)))
    case other:Basic.invalid(~Graph.Snapshot,"$","object",other)
def finished(original:D.Raw,result:Basic.Decoded<Graph.Snapshot>) -> Parsed:
  match result:
    case Basic.Value{snapshot}:Accepted{snapshot}
    case Basic.Failed{error}:Rejected{original,error}
def parse(+raw:D.Raw) -> Parsed:finished(raw,object(raw))
def saved_keys(values:List<&2,Key.Key>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case key <> rest:Basic.saved_key(key) <> saved_keys(rest)
def saved_groups(values:List<&2,Graph.Group>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case Graph.Group{target,sources} <> rest:D.Array{[Basic.saved_key(target),D.Array{saved_keys(sources)}]} <> saved_groups(rest)
def saved_relations(values:List<&2,Graph.Relation>) -> List<&2,D.Field>:
  match values:
    case []:[]
    case Graph.Relation{name,groups} <> rest:D.Field{name,D.Array{saved_groups(groups)}} <> saved_relations(rest)
def encode(value:Graph.Snapshot) -> D.Raw:
  match value:
    case Graph.Snapshot{Snapshot.Snapshot{version,next,entities,resources},relations,machines}:D.Object{[D.Field{"version",D.Number{version}},D.Field{"nextEntity",D.Number{next}},D.Field{"entities",D.Array{Basic.saved_entities(entities)}},D.Field{"relations",D.Object{saved_relations(relations)}},D.Field{"resources",D.Object{resources}},D.Field{"machines",D.Object{machines}}]}
