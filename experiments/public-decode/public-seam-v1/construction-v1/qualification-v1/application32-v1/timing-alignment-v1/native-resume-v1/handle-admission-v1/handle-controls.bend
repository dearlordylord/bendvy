import Base
import handle-application.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-size.bend as Size
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life

def target_text(~S:Data,target:Maybe<&2,W.Handle<S>>) -> String:
  match target:
    case None{}: "null"
    case Some{W.Handle{namespace,id}}: U32.show(namespace) ++ ":" ++ U32.show(id)
def cell_values(owner:Array<U32>) -> String:
  match owner:
    case ALeaf{+value}: U32.show(value) ++ ","
    case ANode{left,right}: cell_values(left) ++ cell_values(right)
def payload(~S:Data,owner:H.Payload<S>) -> String:
  match owner:
    case H.Payload{cells,name,target}: name ++ ":" ++ cell_values(cells) ++ ":" ++ target_text(~S,target)
def maybe_payload(~S:Data,owner:Maybe<&1,H.Payload<S>>) -> String:
  match owner:
    case None{}: "none;"
    case Some{value}: payload(~S,value) ++ ";"
def bools(values:Array<Bool>) -> String:
  match values:
    case ALeaf{True{}}: "1"
    case ALeaf{False{}}: "0"
    case ANode{left,right}: bools(left) ++ bools(right)
def string_join(items:List<&2,String>) -> String:
  match items:
    case []: ""
    case item <> []: item
    case item <> rest: item ++ "," ++ string_join(rest)
type RawTask is Data:
  VisitRaw{value:D.Raw}
  Ready{text:String}
  ArrayEnd{count:Nat}
  ObjectEnd{count:Nat}
  FieldEnd{name:String}
def raw_visits(items:List<&2,D.Raw>) -> List<&2,RawTask>:
  match items:
    case []: []
    case value <> rest: VisitRaw{value} <> raw_visits(rest)
def raw_field_visits(fields:List<&2,D.Field>) -> List<&2,RawTask>:
  match fields:
    case []: []
    case D.Field{name,value} <> rest: VisitRaw{value} <> FieldEnd{name} <> raw_field_visits(rest)
def raw_expand(value:D.Raw) -> List<&2,RawTask>:
  match value:
    case D.Missing{}: [Ready{"missing"}]
    case D.Null{}: [Ready{"null"}]
    case D.Number{value}: [Ready{"u32:" ++ U32.show(value)}]
    case D.SignedInteger{negative,magnitude}: [Ready{"integer:" ++ Nat.show(magnitude)}]
    case D.Float{value}: [Ready{"f32:" ++ F32.show(value)}]
    case D.Binary64{high,low}: [Ready{"binary64:" ++ U32.show(high) ++ ":" ++ U32.show(low)}]
    case D.Text{value}: [Ready{"str:" ++ value}]
    case D.Utf16Text{units}: [Ready{"utf16:" ++ List.show(&2,U32,U32.show,units)}]
    case D.Boolean{True{}}: [Ready{"bool:true"}]
    case D.Boolean{False{}}: [Ready{"bool:false"}]
    case D.Handle{namespace,id}: [Ready{"handle:" ++ U32.show(namespace) ++ ":" ++ U32.show(id)}]
    case D.Array{+items}: List.append(&2,RawTask,raw_visits(items),[ArrayEnd{List.length(&2,D.Raw,items)}])
    case D.Object{+fields}: List.append(&2,RawTask,raw_field_visits(fields),[ObjectEnd{List.length(&2,D.Field,fields)}])
def collect_strings(count:Nat,stack:List<&2,String>,accumulated:List<&2,String>) -> List<&2,String> & List<&2,String>:
  match count:
    case Zero{}: (accumulated,stack)
    case Succ{remaining}:
      match stack:
        case value <> tail: collect_strings(remaining,tail,value <> accumulated)
        case []: (accumulated,[])
def array_end_pair(result:List<&2,String> & List<&2,String>) -> List<&2,String>:
  match result:
    case (values,rest): ("[" ++ string_join(values) ++ "]") <> rest
def array_end(count:Nat,stack:List<&2,String>) -> List<&2,String>:
  array_end_pair(collect_strings(count,stack,[]))
def object_end_pair(result:List<&2,String> & List<&2,String>) -> List<&2,String>:
  match result:
    case (values,rest): ("{" ++ string_join(values) ++ "}") <> rest
def object_end(count:Nat,stack:List<&2,String>) -> List<&2,String>:
  object_end_pair(collect_strings(count,stack,[]))
def field_end(name:String,stack:List<&2,String>) -> List<&2,String>:
  match stack:
    case value <> rest: (name ++ ":" ++ value) <> rest
    case []: []
def raw_finished(stack:List<&2,String>) -> String:
  match stack:
    case value <> []: value
    case _: "formatter-stack-error"
def raw_step(todo:List<&2,RawTask>,stack:List<&2,String>,next:List<&2,RawTask> -> List<&2,String> -> String) -> String:
  match todo:
    case []: raw_finished(stack)
    case VisitRaw{value} <> rest: next(List.append(&2,RawTask,raw_expand(value),rest),stack)
    case Ready{text} <> rest: next(rest,text <> stack)
    case ArrayEnd{count} <> rest: next(rest,array_end(count,stack))
    case ObjectEnd{count} <> rest: next(rest,object_end(count,stack))
    case FieldEnd{name} <> rest: next(rest,field_end(name,stack))
def raw_walk(fuel:Nat,todo:List<&2,RawTask>,stack:List<&2,String>) -> String:
  match fuel:
    case Zero{}: "formatter-budget-error"
    case Succ{rest}: raw_step(todo,stack,todo => stack => raw_walk(rest,todo,stack))
def raw(+value:D.Raw) -> String: raw_walk(Nat.add(1n,Nat.mul(4n,Size.raw_size(value))),[VisitRaw{value}],[])
def raw_view_text(value:Maybe<&2,D.Raw>) -> String:
  match value:
    case None{}: "none;"
    case Some{canonical}: raw(canonical) ++ ";"
type RowView is Data:RowView{index:U32,value:Maybe<&2,D.Raw>,stamp:Life.Stamp}
def row_text(index:U32,value:Maybe<&2,D.Raw>,stamp:Life.Stamp) -> String:
  match stamp:
    case Life.Stamp{added,changed}: "row" ++ U32.show(index) ++ "=" ++ raw_view_text(value) ++ "stamp:" ++ U32.show(added) ++ ":" ++ U32.show(changed) ++ ";"
def row_view_done(~S:Data,+id:U32,value:Maybe<&2,D.Raw>,observed:Col.Column<S,H.Payload<S>> & Life.Stamp) -> Col.Column<S,H.Payload<S>> & RowView:
  match observed:
    case (column,stamp): (column,RowView{id,value,stamp})
def row_view_stamped(~S:Data,id:U32,value:Maybe<&2,D.Raw>,result:Col.Column<S,H.Payload<S>> & Life.Stamp) -> Col.Column<S,H.Payload<S>> & RowView:
  +id=id
  row_view_done(~S,id,value,result)
def row_view_taken(~S:Data,id:U32,result:Col.Column<S,H.Payload<S>> & Maybe<&2,D.Raw>) -> Col.Column<S,H.Payload<S>> & RowView:
  match result:
    case (column,value):
      +id=id
      row_view_stamped(~S,id,value,Col.lifecycle(~S,~H.Payload<S>,column,id))
def row_view(~S:Data,id:U32,column:Col.Column<S,H.Payload<S>>) -> Col.Column<S,H.Payload<S>> & RowView:
  +id=id
  row_view_taken(~S,id,Col.view(~S,~H.Payload<S>,~D.Raw,~H.project(~S),column,id))
def column_rows_join(~S:Data,text:String,result:Col.Column<S,H.Payload<S>> & String) -> Col.Column<S,H.Payload<S>> & String:
  match result:
    case (column,rows):(column,text ++ rows)
def column_rows_after_view(~S:Data,observed:Col.Column<S,H.Payload<S>> & RowView,next:U32 -> Col.Column<S,H.Payload<S>> -> Col.Column<S,H.Payload<S>> & String) -> Col.Column<S,H.Payload<S>> & String:
  match observed:
    case (column,RowView{index,value,stamp}):
      +index=index
      +text=row_text(index,value,stamp)
      +nextId=U32.add(index,1)
      column_rows_join(~S,text,next(nextId,column))
def column_rows(~S:Data,fuel:Nat,id:U32,column:Col.Column<S,H.Payload<S>>) -> Col.Column<S,H.Payload<S>> & String:
  match fuel:
    case Zero{}:(column,"")
    case Succ{rest}:
      column_rows_after_view(~S,row_view(~S,id,column),nextId => nextColumn => column_rows(~S,rest,nextId,nextColumn))
def stored_column_rows(~S:Data,result:Col.Column<S,H.Payload<S>> & String) -> String:
  match result:
    case (_,rows):rows
def stored_column(~S:Data,+nextId:U32,column:Col.Column<S,H.Payload<S>>) -> String:
  stored_column_rows(~S,column_rows(~S,U32.to_nat(U32.sub(nextId,1)),1,column))
def error_text(error:D.Error) -> String:
  match error:
    case D.Invalid{path,expected,actual}: path ++ ":" ++ expected ++ ":" ++ raw(actual)
    case D.FuelExhausted{path}: path ++ ":fuel-exhausted"
def checked_text(value:D.Checked) -> String:
  match value:
    case D.Accepted{canonical}: "ok:" ++ raw(canonical)
    case D.Rejected{error}: error_text(error)
def world_error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}: "MissingEntity"
    case W.CapacityExceeded{}: "CapacityExceeded"
    case W.NamespaceExhausted{}: "NamespaceExhausted"
    case W.SystemIdExhausted{}: "SystemIdExhausted"
def host_text(value:Maybe<&2,W.Status>) -> String:
  match value:
    case None{}: "not-attempted"
    case Some{W.Accepted{}}: "accepted"
    case Some{W.Rejected{error}}: "rejected:" ++ world_error(error)
def registration_text(entries:List<&2,W.RegistrationMeta>) -> String:
  match entries:
    case []: ""
    case W.RegistrationMeta{id,name,access} <> tail:
      U32.show(id) ++ ":" ++ name ++ List.show(&2,String,(value => value),access) ++ ";" ++ registration_text(tail)
def event_text(values:List<&2,U32>) -> String:
  match values:
    case []: ""
    case value <> rest: U32.show(value) ++ "," ++ event_text(rest)
def snapshot(~S:Data,world:H.World(~S)) -> String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:
      +nextId=nextId
      U32.show(namespace) ++ "/" ++ U32.show(nextId) ++ "/" ++ U32.show(highWater) ++ "/" ++ bools(live) ++ "/" ++ U32.show(capacity) ++ "/" ++ Nat.show(depth) ++ "/" ++ stored_column(~S,nextId,store) ++ "/" ++ payload(~S,resource) ++ "/" ++ event_text(events) ++ "/" ++ Nat.show(List.length(&1,(H.World(~S) -> H.World(~S)),pending)) ++ "/" ++ registration_text(registrations) ++ "/" ++ U32.show(nextSystemId) ++ "/" ++ U32.show(clock)
def incoming_text(~S:Data,value:Maybe<&1,H.Payload<S>>) -> String:
  match value:
    case None{}: "none;"
    case Some{owner}: payload(~S,owner) ++ ";"
def render(~S:Data,foreign:H.World(~S),cursor:U32,result:H.Outcome<S>) -> String:
  match result:
    case H.Outcome{world,incoming,checked,host}:
      checked_text(checked) ++ "|" ++ incoming_text(~S,incoming) ++ "|host:" ++ host_text(host) ++ "|" ++ snapshot(~S,W.barrier(~S,~H.Store(~S),~H.Payload<S>,~U32,world)) ++ "|foreign:" ++ snapshot(~S,foreign) ++ "|factory:" ++ U32.show(cursor)
