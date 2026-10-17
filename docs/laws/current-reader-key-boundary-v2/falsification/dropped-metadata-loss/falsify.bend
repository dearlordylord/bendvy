import Base
import ./key.bend as Key
import ../../../../../src/ecs/event-runtime.bend as Ev
import ./stream.bend as Stream
import ../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ./spec.bend as Spec

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def positions(values:List<&2,Ev.Position>) -> String:List.show(&2,Ev.Position,position,values)
def batch(value:Ev.Batch<U32>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,U32,U32.show,values)
def domain(~S:Data,value:Event.Domain<S,U32>) -> String:
  match value:
    case Event.Domain{name}:name
def stream(~S:Data,value:Stream.Stream<S,U32>) -> String:
  match value:
    case Stream.Stream{kind,batches,readers,next,frame,boundary,capacity,dropped}:domain(~S,kind) ++ ";b=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ ";p=" ++ positions(readers) ++ ";next=" ++ U32.show(next) ++ ";frame=" ++ Nat.show(frame) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped)
def pair(name:String,actual:String,expected:String) -> String:name ++ "|" ++ actual ++ "|" ++ expected ++ "\n"
def key_case(name:String,+left:Key.Key,+right:Key.Key) -> String:pair("full_key_equality/" ++ name,Bool.show(Key.equal(left,right)),Bool.show(Spec.key_equal(left,right)))
def position_case(name:String,+success:Bool,+values:List<&2,Ev.Position>,+id:U32,+tick:Nat) -> String:pair("selected_completion_positions/" ++ name,positions(Stream.completed_positions(success,values,id,tick)),positions(Spec.positions(success,values,id,tick)))
def completion_case(~S:Data,name:String,+value:Stream.Stream<S,U32>,+id:U32,+tick:Nat,+success:Bool) -> String:pair("stream_completion_fields/" ++ name,stream(~S,Stream.completed(~S,~U32,value,id,tick,success)),stream(~S,Spec.completed(~S,~U32,value,id,tick,success)))
def advance_case(~S:Data,name:String,+value:Stream.Stream<S,U32>,+id:U32,+tick:Nat) -> String:pair("stream_explicit_advance/" ++ name,stream(~S,Stream.advance(~S,~U32,value,id,tick)),stream(~S,Spec.advanced(~S,~U32,value,id,tick)))
def existing() -> List<&2,Ev.Position>:[Ev.Position{1,2n,1n},Ev.Position{2,4n,3n}]
def duplicate() -> List<&2,Ev.Position>:[Ev.Position{1,2n,1n},Ev.Position{2,4n,3n},Ev.Position{1,5n,4n}]
def sample(~S:Data,readers:List<&2,Ev.Position>) -> Stream.Stream<S,U32>:Stream.Stream{Event.Domain{"typed"},[Ev.Batch{9n,[1,2]},Ev.Batch{1n,[]}],readers,9,4n,3n,5n,6n}
def keys() -> String:key_case("same",Key.EntityKey{1,2},Key.EntityKey{1,2}) ++ key_case("generation",Key.EntityKey{1,2},Key.EntityKey{1,3}) ++ key_case("index",Key.EntityKey{1,2},Key.EntityKey{2,2}) ++ key_case("max",Key.EntityKey{4294967295,4294967295},Key.EntityKey{4294967295,4294967295})
def completions() -> String:position_case("existing-failure",False{},existing(),1,8n) ++ position_case("absent-failure",False{},existing(),3,8n) ++ position_case("duplicates-success",True{},duplicate(),1,8n) ++ position_case("zero-boundary",True{},[Ev.Position{0,5n,7n}],0,0n)
def boundaries() -> String:position_case("empty-success",True{},[],7,4n) ++ position_case("absent-zero-failure",False{},existing(),3,0n)
def fields() -> String:completion_case(~Workshop,"existing-failure",sample(~Workshop,existing()),1,8n,False{}) ++ completion_case(~Garden,"existing-success",sample(~Garden,existing()),1,8n,True{}) ++ completion_case(~Workshop,"absent-failure",sample(~Workshop,existing()),3,8n,False{}) ++ completion_case(~Garden,"absent-success",sample(~Garden,existing()),3,8n,True{})
def advances() -> String:advance_case(~Workshop,"existing",sample(~Workshop,existing()),1,8n) ++ advance_case(~Garden,"absent",sample(~Garden,existing()),3,8n) ++ advance_case(~Workshop,"duplicates",sample(~Workshop,duplicate()),1,8n) ++ advance_case(~Garden,"max-zero",sample(~Garden,[Ev.Position{4294967295,5n,7n}]),4294967295,0n)
def main() -> IO(Unit):IO.print(keys() ++ completions() ++ boundaries() ++ fields() ++ advances())
