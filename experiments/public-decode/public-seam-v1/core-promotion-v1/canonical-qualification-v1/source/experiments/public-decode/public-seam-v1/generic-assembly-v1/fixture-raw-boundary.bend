import Base
import ../../typed.bend as Old
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-data.bend as New

# Detached Data conversion at the fixture boundary; no Type owner inverse.
type ConvertedNew is Data:ConvertedNew{raw:New.Raw,items:List<&2,New.Raw>,fields:List<&2,New.Field>}
def to_new_array(head:ConvertedNew,rest:ConvertedNew) -> ConvertedNew:
  match head rest:
    case ConvertedNew{+head,_,_} ConvertedNew{_,+items,_}:ConvertedNew{New.Array{head <> items},head <> items,[]}
def to_new_object(+name:String,head:ConvertedNew,rest:ConvertedNew) -> ConvertedNew:
  match head rest:
    case ConvertedNew{+head,_,_} ConvertedNew{_,_,+fields}:ConvertedNew{New.Object{New.Field{name,head} <> fields},[],New.Field{name,head} <> fields}
def to_new_converted(raw:Old.Raw) -> ConvertedNew:
  match raw:
    case Old.Missing{}:ConvertedNew{New.Missing{},[],[]}
    case Old.Null{}:ConvertedNew{New.Null{},[],[]}
    case Old.Number{value}:ConvertedNew{New.Number{value},[],[]}
    case Old.SignedInteger{negative,magnitude}:ConvertedNew{New.SignedInteger{negative,magnitude},[],[]}
    case Old.Float{value}:ConvertedNew{New.Float{value},[],[]}
    case Old.Binary64{high,low}:ConvertedNew{New.Binary64{high,low},[],[]}
    case Old.Text{value}:ConvertedNew{New.Text{value},[],[]}
    case Old.Utf16Text{units}:ConvertedNew{New.Utf16Text{units},[],[]}
    case Old.Boolean{value}:ConvertedNew{New.Boolean{value},[],[]}
    case Old.Handle{namespace,id}:ConvertedNew{New.Handle{namespace,id},[],[]}
    case Old.Array{[]}:ConvertedNew{New.Array{[]},[],[]}
    case Old.Array{head <> rest}:to_new_array(to_new_converted(head),to_new_converted(Old.Array{rest}))
    case Old.Object{[]}:ConvertedNew{New.Object{[]},[],[]}
    case Old.Object{Old.Field{name,value} <> rest}:to_new_object(name,to_new_converted(value),to_new_converted(Old.Object{rest}))
def to_new_raw(converted:ConvertedNew) -> New.Raw:
  match converted:
    case ConvertedNew{raw,_,_}:raw
def to_new(raw:Old.Raw) -> New.Raw:to_new_raw(to_new_converted(raw))

type ConvertedOld is Data:ConvertedOld{raw:Old.Raw,items:List<&2,Old.Raw>,fields:List<&2,Old.Field>}
def to_old_array(head:ConvertedOld,rest:ConvertedOld) -> ConvertedOld:
  match head rest:
    case ConvertedOld{+head,_,_} ConvertedOld{_,+items,_}:ConvertedOld{Old.Array{head <> items},head <> items,[]}
def to_old_object(+name:String,head:ConvertedOld,rest:ConvertedOld) -> ConvertedOld:
  match head rest:
    case ConvertedOld{+head,_,_} ConvertedOld{_,_,+fields}:ConvertedOld{Old.Object{Old.Field{name,head} <> fields},[],Old.Field{name,head} <> fields}
def to_old_converted(raw:New.Raw) -> ConvertedOld:
  match raw:
    case New.Missing{}:ConvertedOld{Old.Missing{},[],[]}
    case New.Null{}:ConvertedOld{Old.Null{},[],[]}
    case New.Number{value}:ConvertedOld{Old.Number{value},[],[]}
    case New.SignedInteger{negative,magnitude}:ConvertedOld{Old.SignedInteger{negative,magnitude},[],[]}
    case New.Float{value}:ConvertedOld{Old.Float{value},[],[]}
    case New.Binary64{high,low}:ConvertedOld{Old.Binary64{high,low},[],[]}
    case New.Text{value}:ConvertedOld{Old.Text{value},[],[]}
    case New.Utf16Text{units}:ConvertedOld{Old.Utf16Text{units},[],[]}
    case New.Boolean{value}:ConvertedOld{Old.Boolean{value},[],[]}
    case New.Handle{namespace,id}:ConvertedOld{Old.Handle{namespace,id},[],[]}
    case New.Array{[]}:ConvertedOld{Old.Array{[]},[],[]}
    case New.Array{head <> rest}:to_old_array(to_old_converted(head),to_old_converted(New.Array{rest}))
    case New.Object{[]}:ConvertedOld{Old.Object{[]},[],[]}
    case New.Object{New.Field{name,value} <> rest}:to_old_object(name,to_old_converted(value),to_old_converted(New.Object{rest}))
def to_old_raw(converted:ConvertedOld) -> Old.Raw:
  match converted:
    case ConvertedOld{raw,_,_}:raw
def to_old(raw:New.Raw) -> Old.Raw:to_old_raw(to_old_converted(raw))
