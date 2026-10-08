import Base
import ../candidate/src/ecs/machine.bend as Machine
import ../candidate/src/ecs/debug-state-metadata.bend as State
import ./resource-observation.bend as Resource
# Closed schema resource projection; every affine payload and machine marker
# remains in the returned owner. Detached values contain no access capability.
type Schema is Data:
  Schema{}
type TextKey is Data:
  TextKey{}
type NumericKey is Data:
  NumericKey{}
type Owner is Type:
  Owner{plain:Maybe<&1,Array<U32>>,missing:Maybe<&1,Array<U32>>,constructed:Maybe<&1,Array<U32>>,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Schema,TextKey,State.Value>,+numeric:Machine.Slot<Schema,NumericKey,State.Value>,cursor:U32}
type Observation is Data:
  Observation{plain:Bool,missing:Bool,constructed:Bool,transient:Bool,text:Maybe<&2,State.Value>,numeric:Maybe<&2,State.Value>}
def join_transient(plain:Maybe<&1,Array<U32>>,missing:Maybe<&1,Array<U32>>,constructed:Maybe<&1,Array<U32>>,plainPresent:Bool,missingPresent:Bool,constructedPresent:Bool,pair:Maybe<&1,Array<U32>> & Bool,+text:Machine.Slot<Schema,TextKey,State.Value>,+numeric:Machine.Slot<Schema,NumericKey,State.Value>,cursor:U32) -> Owner & Observation:
  match pair:
    case (transient,transientPresent):(Owner{plain,missing,constructed,transient,text,numeric,cursor},Observation{plainPresent,missingPresent,constructedPresent,transientPresent,Resource.current(~Schema,~TextKey,text),Resource.current(~Schema,~NumericKey,numeric)})
def join_constructed(plain:Maybe<&1,Array<U32>>,missing:Maybe<&1,Array<U32>>,plainPresent:Bool,missingPresent:Bool,pair:Maybe<&1,Array<U32>> & Bool,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Schema,TextKey,State.Value>,+numeric:Machine.Slot<Schema,NumericKey,State.Value>,cursor:U32) -> Owner & Observation:
  match pair:
    case (constructed,constructedPresent):join_transient(plain,missing,constructed,plainPresent,missingPresent,constructedPresent,Resource.presence(~Array<U32>,transient),text,numeric,cursor)
def join_missing(plain:Maybe<&1,Array<U32>>,plainPresent:Bool,pair:Maybe<&1,Array<U32>> & Bool,constructed:Maybe<&1,Array<U32>>,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Schema,TextKey,State.Value>,+numeric:Machine.Slot<Schema,NumericKey,State.Value>,cursor:U32) -> Owner & Observation:
  match pair:
    case (missing,missingPresent):join_constructed(plain,missing,plainPresent,missingPresent,Resource.presence(~Array<U32>,constructed),transient,text,numeric,cursor)
def join_plain(pair:Maybe<&1,Array<U32>> & Bool,missing:Maybe<&1,Array<U32>>,constructed:Maybe<&1,Array<U32>>,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Schema,TextKey,State.Value>,+numeric:Machine.Slot<Schema,NumericKey,State.Value>,cursor:U32) -> Owner & Observation:
  match pair:
    case (plain,plainPresent):join_missing(plain,plainPresent,Resource.presence(~Array<U32>,missing),constructed,transient,text,numeric,cursor)
def project(owner:Owner) -> Owner & Observation:
  match owner:
    case Owner{plain,missing,constructed,transient,+text,+numeric,cursor}:join_plain(Resource.presence(~Array<U32>,plain),missing,constructed,transient,text,numeric,cursor)
