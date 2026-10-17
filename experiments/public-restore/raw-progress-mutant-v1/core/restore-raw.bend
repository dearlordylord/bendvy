import ../../../../src/ecs/restore-raw.bend as Canonical
import Base
import ../../../../src/ecs/decode-data.bend as D
import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../../src/ecs/restore-raw-number.bend as Number

def invalid(~T:Data,path:String,expected:String,raw:D.Raw) -> Canonical.Decoded<T>:
  Canonical.Failed{Canonical.Invalid{D.Invalid{path,expected,raw}}}
def numeric_positive(path:String,raw:D.Raw,positive:Bool,value:U32,nonzero:Bool) -> Canonical.Decoded<U32>:
  match positive nonzero:
    case True{} False{}:invalid(~U32,path,"positive unsigned 32-bit integer",raw)
    case _ _:Canonical.Value{value}
def numeric_checked(+path:String,+raw:D.Raw,positive:Bool,result:Number.Checked) -> Canonical.Decoded<U32>:
  match result:
    case Number.Invalid{}:invalid(~U32,path,"unsigned 32-bit integer",raw)
    case Number.Value{+value}:numeric_positive(path,raw,positive,value,U32.is_gt(value,0))
def number(+path:String,+raw:D.Raw,positive:Bool) -> Canonical.Decoded<U32>:
  numeric_checked(path,raw,positive,Number.checked(raw))
def key_generation(index:U32,result:Canonical.Decoded<U32>) -> Canonical.Decoded<Key.Key>:
  match result:
    case Canonical.Value{generation}:Canonical.Value{Key.EntityKey{index,generation}}
    case Canonical.Failed{error}:Canonical.Failed{error}
def key_index(+path:String,+fields:List<&2,D.Field>,result:Canonical.Decoded<U32>) -> Canonical.Decoded<Key.Key>:
  match result:
    case Canonical.Value{index}:key_generation(index,number(path ++ ".generation",D.field("generation",fields),False{}))
    case Canonical.Failed{error}:Canonical.Failed{error}
def key(+path:String,raw:D.Raw) -> Canonical.Decoded<Key.Key>:
  match raw:
    case D.Object{+fields}:key_index(path,fields,number(path ++ ".index",D.field("index",fields),False{}))
    case other:invalid(~Key.Key,path,"object",other)
def entity_fields(saved:Key.Key,path:String,raw:D.Raw) -> Canonical.Decoded<Snapshot.Entity>:
  match raw:
    case D.Object{fields}:Canonical.Value{Snapshot.Entity{saved,fields}}
    case other:invalid(~Snapshot.Entity,path,"object",other)
def entity_key(+path:String,+fields:List<&2,D.Field>,result:Canonical.Decoded<Key.Key>) -> Canonical.Decoded<Snapshot.Entity>:
  match result:
    case Canonical.Value{saved}:entity_fields(saved,path ++ ".components",D.field("components",fields))
    case Canonical.Failed{error}:Canonical.Failed{error}
def entity(+path:String,raw:D.Raw) -> Canonical.Decoded<Snapshot.Entity>:
  match raw:
    case D.Object{+fields}:entity_key(path,fields,key(path ++ ".id",D.field("id",fields)))
    case other:invalid(~Snapshot.Entity,path,"object",other)
def entities_tail(head:Snapshot.Entity,result:Canonical.Decoded<List<&2,Snapshot.Entity>>) -> Canonical.Decoded<List<&2,Snapshot.Entity>>:
  match result:
    case Canonical.Value{tail}:Canonical.Value{head <> tail}
    case Canonical.Failed{error}:Canonical.Failed{error}
def entities_head(next:Unit -> Canonical.Decoded<List<&2,Snapshot.Entity>>,result:Canonical.Decoded<Snapshot.Entity>) -> Canonical.Decoded<List<&2,Snapshot.Entity>>:
  match result:
    case Canonical.Value{head}:entities_tail(head,next(Unit{}))
    case Canonical.Failed{error}:Canonical.Failed{error}
def entities(values:List<&2,D.Raw>,+index:U32) -> Canonical.Decoded<List<&2,Snapshot.Entity>>:
  match values:
    case []:Canonical.Value{[]}
    case raw <> rest:entities_head((_ => entities(rest,U32.add(index,1))),entity("$.entities[" ++ U32.show(index) ++ "]",raw))
def resources(next:U32,values:List<&2,Snapshot.Entity>,raw:D.Raw) -> Canonical.Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Object{fields}:Canonical.Value{Snapshot.Snapshot{1,next,values,fields}}
    case other:invalid(~Snapshot.Snapshot,"$.resources","object",other)
def entities_checked(next:U32,fields:List<&2,D.Field>,result:Canonical.Decoded<List<&2,Snapshot.Entity>>) -> Canonical.Decoded<Snapshot.Snapshot>:
  match result:
    case Canonical.Value{values}:resources(next,values,D.field("resources",fields))
    case Canonical.Failed{error}:Canonical.Failed{error}
def entity_array(next:U32,fields:List<&2,D.Field>,raw:D.Raw) -> Canonical.Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Array{values}:entities_checked(next,fields,entities(values,0))
    case other:invalid(~Snapshot.Snapshot,"$.entities","array",other)
def progress(+fields:List<&2,D.Field>,result:Canonical.Decoded<U32>) -> Canonical.Decoded<Snapshot.Snapshot>:
  match result:
    case Canonical.Value{next}:entity_array(U32.sub(next,1),fields,D.field("entities",fields))
    case Canonical.Failed{error}:Canonical.Failed{error}
def version_checked(+fields:List<&2,D.Field>,+raw:D.Raw,result:Number.Checked) -> Canonical.Decoded<Snapshot.Snapshot>:
  match result:
    case Number.Value{1}:progress(fields,number("$.nextEntity",D.field("nextEntity",fields),True{}))
    case _:Canonical.Failed{Canonical.UnsupportedVersion{raw}}
def object(+raw:D.Raw) -> Canonical.Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Object{+fields}:version_checked(fields,D.field("version",fields),Number.checked(D.field("version",fields)))
    case other:invalid(~Snapshot.Snapshot,"$","object",other)
def finished(original:D.Raw,result:Canonical.Decoded<Snapshot.Snapshot>) -> Canonical.Parsed:
  match result:
    case Canonical.Value{snapshot}:Canonical.Accepted{snapshot}
    case Canonical.Failed{error}:Canonical.Rejected{original,error}
def parse(+raw:D.Raw) -> Canonical.Parsed:finished(raw,object(raw))
def saved_key(value:Key.Key) -> D.Raw:
  match value:
    case Key.EntityKey{index,generation}:D.Object{[D.Field{"index",D.Number{index}},D.Field{"generation",D.Number{generation}}]}
def saved_entities(values:List<&2,Snapshot.Entity>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case Snapshot.Entity{key,components} <> rest:D.Object{[D.Field{"id",saved_key(key)},D.Field{"components",D.Object{components}}]} <> saved_entities(rest)
def encode(value:Snapshot.Snapshot) -> D.Raw:
  match value:
    case Snapshot.Snapshot{version,next,entities,resources}:D.Object{[D.Field{"version",D.Number{version}},D.Field{"nextEntity",D.Number{next}},D.Field{"entities",D.Array{saved_entities(entities)}},D.Field{"resources",D.Object{resources}}]}
