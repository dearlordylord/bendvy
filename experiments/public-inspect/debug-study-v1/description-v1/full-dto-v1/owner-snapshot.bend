import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import ../state-metadata.bend as State
import ../render-fixture.bend as R
import ./render.bend as Render
import ./owner-observation.bend as Owner
# Independent owner observation for before/after controls, not Description data.
def array_join(a:Array<U32> & List<&2,U32>,b:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match a b:
    case (left,+xs), (right,+ys):(ANode{left,right},List.append(&2,U32,xs,ys))
def array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:array_join(array(left),array(right))
def numbers(values:List<&2,U32>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:U32.show(head)<>numbers(tail)
def maybe_join(result:Array<U32> & List<&2,U32>) -> Maybe<&1,Array<U32>> & String:
  match result:
    case (owner,values):(Some{owner},R.array(numbers(values)))
def maybe(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}:(None{},"null")
    case Some{owner}:maybe_join(array(owner))
def pending(value:Machine.Pending<State.Value>) -> String:
  match value:
    case Machine.NoPending{}:"none"
    case Machine.Queued{state,skip}:"queued:"++Render.state(state)++":"++Render.boolean(skip)
def slot(~S:Data,~Key:Data,value:Machine.Slot<S,Key,State.Value>) -> String:
  match value:
    case Machine.Missing{}:"missing"
    case Machine.Present{state,next,previous,changed}:String.join([Render.state(state),pending(next),Render.current(previous),Render.boolean(changed)],"|")
def join_transient(plain:Maybe<&1,Array<U32>>,missing:Maybe<&1,Array<U32>>,constructed:Maybe<&1,Array<U32>>,plainValue:String,missingValue:String,constructedValue:String,pair:Maybe<&1,Array<U32>> & String,+text:Machine.Slot<Owner.Schema,Owner.TextKey,State.Value>,+numeric:Machine.Slot<Owner.Schema,Owner.NumericKey,State.Value>,+cursor:U32) -> Owner.Owner & String:
  match pair:
    case (transient,transientValue):(Owner.Owner{plain,missing,constructed,transient,text,numeric,cursor},String.join([plainValue,missingValue,constructedValue,transientValue,slot(~Owner.Schema,~Owner.TextKey,text),slot(~Owner.Schema,~Owner.NumericKey,numeric),U32.show(cursor)],"|"))
def join_constructed(plain:Maybe<&1,Array<U32>>,missing:Maybe<&1,Array<U32>>,plainValue:String,missingValue:String,pair:Maybe<&1,Array<U32>> & String,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Owner.Schema,Owner.TextKey,State.Value>,+numeric:Machine.Slot<Owner.Schema,Owner.NumericKey,State.Value>,+cursor:U32) -> Owner.Owner & String:
  match pair:
    case (constructed,constructedValue):join_transient(plain,missing,constructed,plainValue,missingValue,constructedValue,maybe(transient),text,numeric,cursor)
def join_missing(plain:Maybe<&1,Array<U32>>,plainValue:String,pair:Maybe<&1,Array<U32>> & String,constructed:Maybe<&1,Array<U32>>,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Owner.Schema,Owner.TextKey,State.Value>,+numeric:Machine.Slot<Owner.Schema,Owner.NumericKey,State.Value>,+cursor:U32) -> Owner.Owner & String:
  match pair:
    case (missing,missingValue):join_constructed(plain,missing,plainValue,missingValue,maybe(constructed),transient,text,numeric,cursor)
def join_plain(pair:Maybe<&1,Array<U32>> & String,missing:Maybe<&1,Array<U32>>,constructed:Maybe<&1,Array<U32>>,transient:Maybe<&1,Array<U32>>,+text:Machine.Slot<Owner.Schema,Owner.TextKey,State.Value>,+numeric:Machine.Slot<Owner.Schema,Owner.NumericKey,State.Value>,+cursor:U32) -> Owner.Owner & String:
  match pair:
    case (plain,plainValue):join_missing(plain,plainValue,maybe(missing),constructed,transient,text,numeric,cursor)
def project(owner:Owner.Owner) -> Owner.Owner & String:
  match owner:
    case Owner.Owner{plain,missing,constructed,transient,text,numeric,cursor}:join_plain(maybe(plain),missing,constructed,transient,text,numeric,cursor)
