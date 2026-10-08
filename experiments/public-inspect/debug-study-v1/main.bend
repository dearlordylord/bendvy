import Base
import consumer.bend as A
import dump.bend as D
import skeleton.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Case is Data:
  Case{name:String,active:Bool,filter:F.Filter<A.Schema,A.Token>}
def cases() -> List<&2,Case>:
  [Case{"disabled",False{},F.Filter{None{},[],F.Unbounded{}}},Case{"omitted",True{},F.Filter{None{},[],F.Unbounded{}}},Case{"emptyWhitelist",True{},F.Filter{Some{[]},[],F.Unbounded{}}},Case{"emptyWith",True{},F.Filter{None{},[],F.Unbounded{}}},Case{"conjunctionTag",True{},F.Filter{None{},[A.Right{}],F.Unbounded{}}},Case{"whitelistUnsortedDuplicatesMissing",True{},F.Filter{Some{[10,3,10,0,77]},[],F.Unbounded{}}},Case{"zero",True{},F.Filter{None{},[],F.BoundedDecimal{[]}}},Case{"negativeZero",True{},F.Filter{None{},[],F.BoundedDecimal{[]}}},Case{"negativeFinite",True{},F.Filter{None{},[],F.BoundedDecimal{[]}}},Case{"negativeInfinity",True{},F.Filter{None{},[],F.BoundedDecimal{[]}}},Case{"fraction0.25",True{},F.Filter{None{},[],F.BoundedDecimal{[1]}}},Case{"fraction1.5WithTag",True{},F.Filter{None{},[A.Right{}],F.BoundedDecimal{[2]}}},Case{"nan",True{},F.Filter{None{},[],F.Unbounded{}}},Case{"positiveInfinity",True{},F.Filter{None{},[],F.Unbounded{}}},Case{"finite2Power53",True{},F.Filter{None{},[],F.BoundedDecimal{[2,9,9,0,4,7,4,5,2,9,9,1,7,0,0,9]}}}]
def access(value:C.Access<List<&2,U32>>) -> String:
  match value:
    case C.Found{+cells}:List.show(&2,U32,U32.show,cells)
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"MissingEntity"
def value(value:A.Values) -> String:
  match value:
    case A.Values{left,right}:access(left) ++ ":" ++ access(right)
def entry(entry:D.Entry<A.Schema,A.Values>) -> String:
  match entry:
    case D.Entry{W.Handle{_,id},cells}:U32.show(id) ++ "=" ++ value(cells)
def rows(rows:List<&2,D.Entry<A.Schema,A.Values>>) -> String:
  List.show(&2,D.Entry<A.Schema,A.Values>,entry,rows)
def output(out:F.Output<D.Dump<A.Schema,A.Values,List<&2,U32>>>) -> String:
  match out:
    case F.Disabled{}:"Disabled"
    case F.Enabled{D.Dump{count,cells,resource}}:"count=" ++ Nat.show(count) ++ "|rows=" ++ rows(cells) ++ "|resource=" ++ List.show(&2,U32,U32.show,resource)
def owner_rows(cells:List<&2,D.Row<A.Schema,A.Token,A.Values>>) -> String:
  match cells:
    case []:"end"
    case D.Row{W.Handle{_,id},_,v} <> tail:U32.show(id) ++ "=" ++ value(v) ++ ";" ++ owner_rows(tail)
def owner_join(extra:String,result:A.Frame() & D.Observed<A.Schema,A.Token,A.Values,List<&2,U32>>) -> A.World() & String:
  match result:
    case (Check.Frame{world},D.Observed{_,cells,resource}):(world,extra ++ "|owners=" ++ owner_rows(cells) ++ "|resource=" ++ List.show(&2,U32,U32.show,resource))
def count_commands_join(head:A.World() -> A.World(),result:List<(A.World() -> A.World())> & Nat) -> List<(A.World() -> A.World())> & Nat:
  (tail,count)=result
  (head <> tail,Nat.add(1n,count))
def count_commands(commands:List<(A.World() -> A.World())>) -> List<(A.World() -> A.World())> & Nat:
  match commands:
    case []:([],0n)
    case head <> tail:count_commands_join(head,count_commands(tail))
def snapshot_counted(ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:A.Store,resource:Array<U32>,+calls:U32,+cursor:U32,refused:List<Array<U32>>,events:List<&2,U32>,regs:List<&2,W.RegistrationMeta>,system:U32,+clock:U32,result:List<(A.World() -> A.World())> & Nat) -> A.World() & String:
  (commands,count)=result
  owner_join("clock=" ++ U32.show(clock) ++ "|pending=" ++ Nat.show(count) ++ "|cursor=" ++ U32.show(cursor) ++ "|projectionMarker=" ++ U32.show(calls),A.observe(Check.Frame{W.World{ns,next,high,live,capacity,depth,store,A.Resource{resource,calls,cursor,refused},events,commands,regs,system,clock}}))
def snapshot_commands(+ns:U32,+next:U32,+high:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,store:A.Store,resource:Array<U32>,+calls:U32,+cursor:U32,refused:List<Array<U32>>,+events:List<&2,U32>,commands:List<(A.World() -> A.World())>,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32) -> A.World() & String:
  # Commands remain affine: count via an owner-returning recursive traversal below.
  snapshot_counted(ns,next,high,live,capacity,depth,store,resource,calls,cursor,refused,events,regs,system,clock,count_commands(commands))
def snapshot(world:A.World()) -> A.World() & String:
  match world:
    case W.World{+ns,+next,+high,live,+capacity,+depth,store,A.Resource{resource,+calls,+cursor,refused},+events,commands,+regs,+system,+clock}:snapshot_commands(ns,next,high,live,capacity,depth,store,resource,calls,cursor,refused,events,commands,regs,system,clock)
def case_snapshot(text:String,result:A.World() & String) -> A.World() & String:
  (world,state)=result
  (world,text ++ "|" ++ state ++ "\n")
def observed_case(name:String,result:A.Frame() & F.Output<D.Dump<A.Schema,A.Values,List<&2,U32>>>) -> A.World() & String:
  match result:
    case (Check.Frame{world},out):case_snapshot(name ++ "|" ++ output(out),snapshot(world))
def case_dispatch(active:Bool,filter:F.Filter<A.Schema,A.Token>,world:A.World()) -> A.Frame() & F.Output<D.Dump<A.Schema,A.Values,List<&2,U32>>>:
  match active:
    case False{}:A.disabled(filter,world)
    case True{}:A.run(True{},filter,world)
def execute_case(c:Case,world:A.World()) -> A.World() & String:
  match c:
    case Case{name,active,filter}:observed_case(name,case_dispatch(active,filter,world))
def lines_join(line:String,result:A.World() & String) -> A.World() & String:
  (world,tail)=result
  (world,line ++ tail)
def execute_join(rest:A.World() -> A.World() & String,result:A.World() & String) -> A.World() & String:
  (world,line)=result
  lines_join(line,rest(world))
def execute(cases:List<&2,Case>,world:A.World()) -> A.World() & String:
  match cases:
    case []:(world,"")
    case c <> rest:execute_join(w => execute(rest,w),execute_case(c,world))
def foreign_snapshot(text:String,result:A.World() & String) -> String:
  (world,state)=result
  text ++ "|" ++ state
def foreign_result(prefix:String,result:A.World() & C.Access<List<&2,U32>>) -> String:
  (world,value)=result
  foreign_snapshot(prefix ++ "foreignSameIdGet|" ++ access(value),snapshot(world))
def foreign_reserved(world:A.World(),prefix:String,result:A.World() & W.Reservation<A.Schema>) -> String:
  match result:
    case (_,W.Reserved{handle}):foreign_result(prefix,C.get(~A.Schema,~A.Store,~A.Resource,~U32,~Col.Column<A.Schema,Array<U32>>,~Array<U32>,~List<&2,U32>,~A.Token,~A.take_left,~A.put_left,~A.project_array,A.left_family(),world,handle))
    case (_, _):prefix ++ "foreign-reservation-refused\n"
def foreign_created(world:A.World(),prefix:String,created:WIO.Creation<A.Schema,A.Store,A.Resource,U32>) -> String:
  match created:
    case WIO.Created{other}:foreign_reserved(world,prefix,W.reserve_id(~A.Schema,~A.Store,~A.Resource,~U32,other))
    case _:prefix ++ "foreign-world-refused\n"
def after_cases(result:A.World() & String) -> IO(String):
  (world,prefix)=result
  IO.bind(WIO.Creation<A.Schema,A.Store,A.Resource,U32>,String,WIO.create(~A.Schema,~A.Store,~A.Resource,~U32,~A.empty,A.Resource{ALeaf{99},0,7,[]}),other => IO.pure(String,foreign_created(world,prefix,other)))
def created(result:WIO.Creation<A.Schema,A.Store,A.Resource,U32>) -> IO(String):
  match result:
    case WIO.Created{world}:after_cases(execute(cases(),A.configured(A.reserve_many(10n,world))))
    case _:IO.pure(String,"world-refused\n")
def printed(text:String) -> IO(Unit):IO.print(text)
def main() -> IO(Unit):
  IO.bind(String,Unit,IO.bind(WIO.Creation<A.Schema,A.Store,A.Resource,U32>,String,WIO.create(~A.Schema,~A.Store,~A.Resource,~U32,~A.empty,A.Resource{ANode{ALeaf{19},ALeaf{23}},0,7,[]}),created),printed)
