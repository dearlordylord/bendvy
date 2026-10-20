import Base
import ./decode-data.bend as D
import ./entity-key.bend as Key
import ./snapshot-data.bend as Snapshot
import ./restore-raw-number.bend as Number

# Detached structural parsing failure or unsupported raw version. Schema-specific
# name/value/construction errors are a later typed restore stage, not these errors.
type Error is Data:
  Invalid{error:D.Error}
  UnsupportedVersion{version:D.Raw}
# Accepted contains a structurally parsed typed Snapshot; it is not yet schema
# validated or applied. Rejected retains complete original Raw and parsing error.
type Parsed is Data:
  Accepted{snapshot:Snapshot.Snapshot}
  Rejected{original:D.Raw,error:Error}
# Internal parser step result, not a second public restore/admission outcome.
type Decoded<T:Data> is Data:
  Value{value:T}
  Failed{error:Error}
def invalid(~T:Data,path:String,expected:String,raw:D.Raw) -> Decoded<T>:
  Failed{Invalid{D.Invalid{path,expected,raw}}}
def numeric_positive(path:String,raw:D.Raw,positive:Bool,value:U32,nonzero:Bool) -> Decoded<U32>:
  match positive nonzero:
    case True{} False{}:invalid(~U32,path,"positive unsigned 32-bit integer",raw)
    case _ _:Value{value}
def numeric_checked(+path:String,+raw:D.Raw,positive:Bool,result:Number.Checked) -> Decoded<U32>:
  match result:
    case Number.Invalid{}:invalid(~U32,path,"unsigned 32-bit integer",raw)
    case Number.Value{+value}:numeric_positive(path,raw,positive,value,U32.is_gt(value,0))
def number(+path:String,+raw:D.Raw,positive:Bool) -> Decoded<U32>:
  numeric_checked(path,raw,positive,Number.checked(raw))
def key_generation(index:U32,result:Decoded<U32>) -> Decoded<Key.Key>:
  match result:
    case Value{generation}:Value{Key.EntityKey{index,generation}}
    case Failed{error}:Failed{error}
def key_index(+path:String,+fields:List<&2,D.Field>,result:Decoded<U32>) -> Decoded<Key.Key>:
  match result:
    case Value{index}:key_generation(index,number(path ++ ".generation",D.field("generation",fields),False{}))
    case Failed{error}:Failed{error}
def key(+path:String,raw:D.Raw) -> Decoded<Key.Key>:
  match raw:
    case D.Object{+fields}:key_index(path,fields,number(path ++ ".index",D.field("index",fields),False{}))
    case other:invalid(~Key.Key,path,"object",other)
def entity_fields(saved:Key.Key,path:String,raw:D.Raw) -> Decoded<Snapshot.Entity>:
  match raw:
    case D.Object{fields}:Value{Snapshot.Entity{saved,fields}}
    case other:invalid(~Snapshot.Entity,path,"object",other)
def entity_key(+path:String,+fields:List<&2,D.Field>,result:Decoded<Key.Key>) -> Decoded<Snapshot.Entity>:
  match result:
    case Value{saved}:entity_fields(saved,path ++ ".components",D.field("components",fields))
    case Failed{error}:Failed{error}
def entity(+path:String,raw:D.Raw) -> Decoded<Snapshot.Entity>:
  match raw:
    case D.Object{+fields}:entity_key(path,fields,key(path ++ ".id",D.field("id",fields)))
    case other:invalid(~Snapshot.Entity,path,"object",other)
def entities_tail(head:Snapshot.Entity,result:Decoded<List<&2,Snapshot.Entity>>) -> Decoded<List<&2,Snapshot.Entity>>:
  match result:
    case Value{tail}:Value{head <> tail}
    case Failed{error}:Failed{error}
def entities_head(next:Unit -> Decoded<List<&2,Snapshot.Entity>>,result:Decoded<Snapshot.Entity>) -> Decoded<List<&2,Snapshot.Entity>>:
  match result:
    case Value{head}:entities_tail(head,next(Unit{}))
    case Failed{error}:Failed{error}
def entities(values:List<&2,D.Raw>,+index:U32) -> Decoded<List<&2,Snapshot.Entity>>:
  match values:
    case []:Value{[]}
    case raw <> rest:entities_head((_ => entities(rest,U32.add(index,1))),entity("$.entities[" ++ U32.show(index) ++ "]",raw))
def resources(next:U32,values:List<&2,Snapshot.Entity>,raw:D.Raw) -> Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Object{fields}:Value{Snapshot.Snapshot{1,next,values,fields}}
    case other:invalid(~Snapshot.Snapshot,"$.resources","object",other)
def entities_checked(next:U32,fields:List<&2,D.Field>,result:Decoded<List<&2,Snapshot.Entity>>) -> Decoded<Snapshot.Snapshot>:
  match result:
    case Value{values}:resources(next,values,D.field("resources",fields))
    case Failed{error}:Failed{error}
def entity_array(next:U32,fields:List<&2,D.Field>,raw:D.Raw) -> Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Array{values}:entities_checked(next,fields,entities(values,0))
    case other:invalid(~Snapshot.Snapshot,"$.entities","array",other)
def progress(+fields:List<&2,D.Field>,result:Decoded<U32>) -> Decoded<Snapshot.Snapshot>:
  match result:
    case Value{next}:entity_array(next,fields,D.field("entities",fields))
    case Failed{error}:Failed{error}
def version_checked(+fields:List<&2,D.Field>,+raw:D.Raw,result:Number.Checked) -> Decoded<Snapshot.Snapshot>:
  match result:
    case Number.Value{1}:progress(fields,number("$.nextEntity",D.field("nextEntity",fields),True{}))
    case _:Failed{UnsupportedVersion{raw}}
def object(+raw:D.Raw) -> Decoded<Snapshot.Snapshot>:
  match raw:
    case D.Object{+fields}:version_checked(fields,D.field("version",fields),Number.checked(D.field("version",fields)))
    case other:invalid(~Snapshot.Snapshot,"$","object",other)
def finished(original:D.Raw,result:Decoded<Snapshot.Snapshot>) -> Parsed:
  match result:
    case Value{snapshot}:Accepted{snapshot}
    case Failed{error}:Rejected{original,error}
# Parse the four-field snapshot object into typed detached Data without touching
# World. Version must be 1; nextEntity is positive U32; saved index/generation
# accept full U32 including zero as opaque tokens, not target allocator slots.
# Exact numeric conversion rejects fractions/nonfinite/out-of-range input before
# narrowing. Entities/components/resources shapes are checked in authored order;
# D.field keeps existing first-match semantics, not a new duplicate-property rule.
# Complete-key duplicates, schema dispatch and capacity are checked by typed restore.
def parse(+raw:D.Raw) -> Parsed:finished(raw,object(raw))
def saved_key(value:Key.Key) -> D.Raw:
  match value:
    case Key.EntityKey{index,generation}:D.Object{[D.Field{"index",D.Number{index}},D.Field{"generation",D.Number{generation}}]}
def saved_entities(values:List<&2,Snapshot.Entity>) -> List<&2,D.Raw>:
  match values:
    case []:[]
    case Snapshot.Entity{key,components} <> rest:D.Object{[D.Field{"id",saved_key(key)},D.Field{"components",D.Object{components}}]} <> saved_entities(rest)
# Encode typed Snapshot to the four-field Raw representation preserving entity and
# field order. This is not schema validation, JSON serialization or a Runtime
# checkpoint; an arbitrary typed Snapshot may still be refused by restore.
def encode(value:Snapshot.Snapshot) -> D.Raw:
  match value:
    case Snapshot.Snapshot{version,next,entities,resources}:D.Object{[D.Field{"version",D.Number{version}},D.Field{"nextEntity",D.Number{next}},D.Field{"entities",D.Array{saved_entities(entities)}},D.Field{"resources",D.Object{resources}}]}
